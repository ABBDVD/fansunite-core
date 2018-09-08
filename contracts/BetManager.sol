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
  mapping (bytes32 => BetLib.Bet) public bets;

  // Resolves to `true` if hash is used, `false` otherwise
  mapping(bytes32 => bool) public accepted;

  /**
   * @notice Constructor
   * @param _chainId ChainId to be set
   */
  constructor(uint _chainId) public ChainSpecifiable(_chainId) {

  }

  /**
   * @notice Submits a bet
   * @param _subjects Subjects associated with bet [backer, layer, token, league, resolver]
   * @param _params Parameters associated with bet [backerStake, fixture, odds, expiration]
   * @param _layerFill The number of tokens that they layer intends to bet
   * @param _nonce Nonce, to ensure hash uniqueness
   * @param _payload Payload for resolver
   * @param _signature ECDSA signature along with the mode
   *  (0 = Typed, 1 = Geth, 2 = Trezor) {mode}{v}{r}{s}.
   */
  function submitBet(
    address[5] _subjects,
    uint[4] _params,
    uint _layerFill,
    uint _nonce,
    bytes _payload,
    bytes _signature
  )
    external
  {
    BetLib.Bet memory _bet = BetLib.generate(_subjects, _params, _payload);
    bytes32 _hash = BetLib.hash(_bet, chainId, _nonce);
    // TODO: Manan
  }

  /**
   * @notice Claims a bet, transfers tokens and fees based on fixture resolution
   * @param _bet Keccak-256 hash of the bet struct, along with chainId and nonce
   */
  function claimBet(bytes32 _bet) external;

  /**
   * @notice Cancels bet `_bet`, if not filled
   * @param _bet Keccak-256 hash of the bet struct, along with chainId and nonce
   */
  function cancelBet(bytes32 _bet) external;

  /**
   * @notice Gets the bet result
   * @param _bet Keccak-256 hash of the bet struct, along with chainId and nonce
   * @return Result of bet (refer to IResolver for specifics of the return type)
   */
  function getResult(bytes32 _bet) external view returns (uint8);

  /**
   * @notice Gets all the bet identifiers for address `_subject`
   * @param _subject Address of a layer or backer
   * @return Returns list of bet ids for backer / layer `_subject`
   */
  function getBetsBySubject(address _subject) external view returns (bytes32[]);

  /**
   * @notice Gets subjects, params and payload associated with bet `_bet`
   * @param _bet Keccak-256 hash of the bet struct, along with chainId and nonce
   * @return Subjects associated with `_bet`
   *  [backer, layer, backerToken, layerToken, feeRecipient, league, resolver]
   * @return Params associated with `_bet`
   *  [backerStake, backerFee, layerFee, expiration, fixture, odds]
   * @return Payload associated with `_bet`
   */
  function getBet(bytes32 _bet) external view returns (address[5], uint[4], bytes);

  /**
   * @dev Throws if any of the following checks fail
   *  + `msg.sender` is `_bet.layer` || `_bet.layer == 0x00`
   *  + `_bet.backer` has signed `_hash`
   *  + `_hash` is unique (preventing replay attacks)
   * @param _bet Bet struct
   * @param _hash Keccak-256 hash of the bet struct, along with chainId and nonce
   * @param _signature ECDSA signature along with the mode
   */
  function _authenticateBet(BetLib.Bet _bet, bytes32 _hash, bytes _signature) internal {
    require(
      msg.sender == _bet.layer || _bet.layer == address(0),
      "Bet is not permitted for the msg.sender to take"
    );
    require(
      SignatureLib.isValidSignature(_hash, _bet.backer, _signature),
      "Tx is sent with an invalid signature"
    );
    require(
      !accepted[_hash],
      "Bet with same hash been submitted before"
    );
  }

  /**
   * @dev Throws if any of the following checks fail
   *  + `_bet.backer` has appropriate amount staked in vault
   *  + `_bet.layer` has appropriate amount staked in vault
   *  + `address(this)` is an approved spender by both backer and layer
   * @param _bet Bet struct
   */
  function _authorizeBet(BetLib.Bet _bet) internal;

  /**
   * @dev Throws if any of the following checks fail
   *  + `_bet.league` is a registered league with FansUnite
   *  + `_bet.resolver` is registered with league
   *  + `_bet.fixture` is scheduled with league
   *  + `_bet.payload` is valid according to resolver
   *  + `_bet.expiration` is greater than `now`
   * @param _bet Bet struct
   */
  function _validateBet(BetLib.Bet _bet) internal;

  /**
   * @dev Processes the funds and stores the bet
   * @param _bet Bet struct
   */
  function _processBet(BetLib.Bet _bet) internal;

}
