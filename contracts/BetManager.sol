pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

import "./interfaces/IBetManager.sol";
import "./interfaces/ILeague.sol";
import "./interfaces/ILeagueRegistry.sol";
import "./interfaces/IRegistry.sol";
import "./interfaces/IResolver.sol";
import "./interfaces/IVault.sol";

import "./libraries/BetLib.sol";
import "./libraries/SignatureLib.sol";

import "./utils/RegistryAccessible.sol";
import "./utils/ChainSpecifiable.sol";

/**
  * @title Bet Manger Contract
  * @notice BetManager is the core contract responsible for bet validations and bet submissions
  */
contract BetManager is Ownable, IBetManager, RegistryAccessible, ChainSpecifiable {

  using SafeMath for uint;

  // Number of decimal places in BetLib.Odds
  uint public constant ODDS_DECIMALS = 4;

  // Mapping of Hash to corresponding BetLib.Bet struct
  mapping (bytes32 => BetLib.Bet) internal bets;
  // Resolves to `true` if hash is used, `false` otherwise
  mapping(bytes32 => bool) internal accepted;
  // Resolves to `true` if bet has been claimed, `false` otherwise
  mapping(bytes32 => bool) internal claimed;
  // Mapping of user address to Bet Hashes (ids)
  mapping(address => bytes32[]) internal betsByUser;

  // Emit when a Bet has been submitted
  event LogBetSubmitted(bytes32 indexed _hash, address indexed _league, uint indexed _fixture);

  /**
   * @notice Constructor
   * @dev Change chainId in case of a fork, making sure txs cannot be replayed on forked chains
   * @param _chainId ChainId to be set
   */
  constructor(uint _chainId) public ChainSpecifiable(_chainId) {

  }

  /**
   * @notice Submits a bet
   * @param _subjects Subjects associated with bet [backer, layer, token, league, resolver]
   * @param _params Parameters associated with bet [backerStake, fixture, odds, expiration]
   * @param _nonce Nonce, to ensure hash uniqueness
   * @param _payload Payload for resolver
   * @param _signature ECDSA signature along with the mode
   *  (0 = Typed, 1 = Geth, 2 = Trezor) {mode}{v}{r}{s}.
   */
  function submitBet(
    address[5] _subjects,
    uint[4] _params,
    uint _nonce,
    bytes _payload,
    bytes _signature
  )
    external
  {
    BetLib.Bet memory _bet = BetLib.generate(_subjects, _params, _payload);
    bytes32 _hash = BetLib.hash(_bet, chainId, _nonce);

    _authenticateBet(_bet, _hash, _signature);
    _authorizeBet(_bet);
    _validateBet(_bet);
    _processBet(_bet, _hash);
  }

  /**
   * @notice Claims a bet, transfers tokens and fees based on fixture resolution
   * @param _id Keccak-256 hash of the bet struct, along with chainId and nonce
   */
  function claimBet(bytes32 _id) external;

  /**
   * @notice Gets the bet result
   * @param _id Keccak-256 hash of the bet struct, along with chainId and nonce
   * @return Result of bet (refer to IResolver for specifics of the return type)
   */
  function getResult(bytes32 _id) external view returns (uint8);

  /**
   * @notice Gets all the bet identifiers for address `_subject`
   * @param _subject Address of a layer or backer
   * @return Returns list of bet ids for backer / layer `_subject`
   */
  function getBetsBySubject(address _subject) external view returns (bytes32[]);

  /**
   * @notice Gets subjects, params and payload associated with bet `_id`
   * @param _id Keccak-256 hash of the bet struct, along with chainId and nonce
   * @return Subjects associated with `_id` [backer, layer, token, league, resolver]
   * @return Params associated with `_id` [backerStake, expiration, fixture, odds]
   * @return Payload associated with `_id`
   */
  function getBet(bytes32 _id) external view returns (address[5], uint[4], bytes) {
    BetLib.Bet storage _bet = bets[_id];

    return ([
      _bet.backer,
      _bet.layer,
      _bet.token,
      _bet.league,
      _bet.resolver
    ], [
      _bet.backerStake,
      _bet.expiration,
      _bet.fixture,
      _bet.odds
    ],
      _bet.payload
    );
  }

  /**
   * @dev Throws if any of the following checks fail
   *  + `msg.sender` is `_bet.layer` || `_bet.layer == 0x00`
   *  + `msg.sender` is not `_bet.backer`
   *  + `_bet.backer` has signed `_hash`
   *  + `_hash` is unique (preventing replay attacks)
   * @param _bet Bet struct
   * @param _hash Keccak-256 hash of the bet struct, along with chainId and nonce
   * @param _signature ECDSA signature along with the mode
   */
  function _authenticateBet(BetLib.Bet memory _bet, bytes32 _hash, bytes _signature)
    internal
    view
  {
    require(
      msg.sender == _bet.layer || _bet.layer == address(0),
      "Bet is not permitted for the msg.sender to take"
    );
    require(
      _bet.backer != address(0) && _bet.backer != msg.sender,
      "Bet is not permitted for the msg.sender to take"
    );
    require(
      !accepted[_hash],
      "Bet with same hash been submitted before"
    );
    require(
      SignatureLib.isValidSignature(_hash, _bet.backer, _signature),
      "Tx is sent with an invalid signature"
    );
  }

  /**
   * @dev Throws if any of the following checks fail
   *  + `address(this)` is an approved spender by both backer and layer
   *  + `_bet.backer` has appropriate amount staked in vault
   *  + `_bet.layer` has appropriate amount staked in vault
   * @param _bet Bet struct
   */
  function _authorizeBet(BetLib.Bet memory _bet) internal view {
    IVault _vault = IVault(registry.getAddress("FanVault"));

    require(
      _vault.isApproved(_bet.backer, address(this)),
      "Backer has not approved BetManager to move funds in Vault"
    );
    require(
      _vault.isApproved(msg.sender, address(this)),
      "Layer has not approved BetManager to move funds in Vault"
    );
    require(
      _vault.balanceOf(_bet.token, _bet.backer) >= _bet.backerStake,
      "Backer does not have sufficient tokens"
    );
    require(
      _vault.balanceOf(_bet.token, _bet.layer) >= BetLib.backerReturn(_bet, ODDS_DECIMALS),
      "Layer does not have sufficient tokens"
    );
  }

  /**
   * @dev Throws if any of the following checks fail
   *  + `_bet.league` is a registered league with FansUnite
   *  + `_bet.resolver` is registered with league
   *  + `_bet.fixture` is scheduled with league
   *  + `_bet.resolver` is not resolved for `_bet.fixture`
   *  + `_bet.backerStake` must belong to set ℝ+
   *  + `_bet.odds` must belong to set ℝ+
   *  + `_bet.expiration` is greater than `now`
   *  + `_bet.payload` is valid according to resolver
   * @param _bet Bet struct
   */
  function _validateBet(BetLib.Bet memory _bet) internal view {
    ILeagueRegistry _leagueRegistry = ILeagueRegistry(registry.getAddress("LeagueRegistry"));
    ILeague _league = ILeague(_bet.league);

    require(
      _leagueRegistry.isLeagueRegistered(_bet.league),
      "League is not registered with FansUnite"
    );
    require(
      _league.isResolverRegistered(_bet.resolver),
      "Resolver is not registered with FansUnite"
    );
    require(
      _league.isFixtureScheduled(_bet.fixture),
      "Fixture is not scheduled with League"
    );
    require(
      _league.isFixtureResolved(_bet.fixture, _bet.resolver) != 1,
      "Fixture is already resolved"
    );
    require(
      _bet.backerStake > 0,
      "Stake does not belong to set ℝ+"
    );
    require(
      _bet.odds > 0,
      "Odds does not belong to set ℝ+"
    );
    require(
      _bet.expiration > block.timestamp,
      "Bet has expired"
    );

    __validatePayload(_bet);

  }

  /**
   * @dev Processes the funds and stores the bet
   * @param _bet Bet struct
   * @param _hash Keccak-256 hash of the bet struct, along with chainId and nonce
   */
  function _processBet(BetLib.Bet _bet, bytes32 _hash) internal {
    IVault _vault = IVault(registry.getAddress("FanVault"));
    uint _backerStake = _bet.backerStake;
    uint _layerStake = BetLib.backerReturn(_bet, ODDS_DECIMALS);

    require(
      _vault.transferFrom(_bet.token, _bet.backer, address(this), _backerStake),
      "Cannot transfer backer's stake to pool"
    );

    require(
      _vault.transferFrom(_bet.token, _bet.layer, address(this), _layerStake),
      "Cannot transfer layer's stake to pool"
    );

    bets[_hash] = _bet;
    accepted[_hash] = true;

    betsByUser[_bet.backer].push(_hash);
    betsByUser[msg.sender].push(_hash);

    emit LogBetSubmitted(_hash, _bet.league, _bet.fixture);
  }

  /**
   * @dev Throws if `_payload` is not valid
   * @param _bet Bet struct
   */
  function __validatePayload(BetLib.Bet memory _bet) private view {
    bool _isPayloadValid;
    address _resolver = _bet.resolver;
    address _league = _bet.league;
    uint256 _fixture = _bet.fixture;
    bytes4 _selector = IResolver(_resolver).getValidatorSelector();
    bytes memory _payload = _bet.payload;

    assembly {
      let _plen := mload(_payload)               // _plen = length of _payload
      let _tlen := add(_plen, 0x44)              // _tlen = total length of calldata
      let _p    := add(_payload, 0x20)           // _p    = encoded bytes of _payload

      let _ptr   := mload(0x40)                  // _ptr   = free memory pointer
      let _index := mload(0x40)                  // _index = same as _ptr
      mstore(0x40, add(_ptr, _tlen))             // update free memory pointer

      mstore(_index, _selector)                  // store selector at _index
      _index := add(_index, 0x04)                // _index = _index + 0x04
      _index := add(_index, 0x0C)                // _index = _index + 0x0C
      mstore(_index, _league)                    // store address at _index
      _index := add(_index, 0x14)                // _index = _index + 0x14
      mstore(_index, _fixture)                   // store _fixture at _index
      _index := add(_index, 0x20)                // _index = _index + 0x20

      for
      { let _end := add(_p, _plen) }             // init: _end = _p + _plen
      lt(_p, _end)                               // cond: _p < _end
      { _p := add(_p, 0x20) }                    // incr: _p = _p + 0x20
      {
        mstore(_index, mload(_p))                // store _p to _index
        _index := add(_index, 0x20)              // _index = _index + 0x20
      }

      let result := staticcall(30000, _resolver, _ptr, _tlen, _ptr, 0x20)

      switch result
      case 0 {
        // revert(_ptr, 0x20) dealt with outside of assembly
        _isPayloadValid := mload(_ptr)
      }
      default {
        _isPayloadValid := mload(_ptr)
      }
    }

    require(
      _isPayloadValid,
      "Bet payload is not valid"
    );
  }

}
