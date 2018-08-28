pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

library BetLib {

  using SafeMath for uint;

  // Hash for the EIP712 Bet Schema
  bytes32 constant BET_SCHEMA_HASH = keccak256(abi.encodePacked(
    "Bet(",
    "address backer,",
    "address layer,",
    "address backerToken,",
    "address layerToken,",
    "address feeRecipient,",
    "address league,",
    "address resolver,",
    "uint256 backerStake,",
    "uint256 backerFee,",
    "uint256 layerFee,",
    "uint256 expiration,",
    "uint256 fixture,",
    "uint256 odds,",
    "bytes payload",
    ")"
  ));

  struct Bet {
    address backer;
    address layer;
    address backerToken;
    address layerToken;
    address feeRecipient;
    address league;
    address resolver;
    uint256 backerStake;
    uint256 backerFee;
    uint256 layerFee;
    uint256 expiration;
    uint256 fixture;
    uint256 odds;
    bytes payload;
  }

  /**
   * @notice Calculates Keccak-256 hash of the bet struct
   * @param _bet The bet struct
   * @param _nonce Arbitrary number to ensure uniqueness of bet hash
   * @return Keccak-256 EIP712 hash of the bet.
   */
  function hash(Bet _bet, uint _nonce) internal pure returns (bytes32) {

    bytes memory _addresses = abi.encodePacked(
      _bet.backer,
      _bet.layer,
      _bet.backerToken,
      _bet.layerToken,
      _bet.feeRecipient,
      _bet.league,
      _bet.resolver
    );

    bytes memory _params = abi.encodePacked(
      _bet.backerStake,
      _bet.backerFee,
      _bet.layerFee,
      _bet.expiration,
      _bet.fixture,
      _bet.odds
    );

    return keccak256(abi.encodePacked(
      _nonce,
      abi.encodePacked(
        BET_SCHEMA_HASH,
        _addresses,
        _params,
        keccak256(_bet.payload)
      )
    ));
  }

  /**
   * @notice Creates the bet structure
   * @param _addresses Array of bet address parameters
   * @param _values Array of bet value parameters
   * @param _payload Bet payload for resolver
   * @return Returns the bet struct
   */
  function createBet(address[7] _addresses, uint[6] _values, bytes _payload) internal pure returns (Bet) {
    return Bet({
      backer: _addresses[0],
      layer: _addresses[1],
      backerToken: _addresses[2],
      layerToken: _addresses[3],
      feeRecipient: _addresses[4],
      league: _addresses[5],
      resolver: _addresses[6],
      backerStake: _values[0],
      backerFee: _values[1],
      layerFee: _values[2],
      expiration: _values[3],
      fixture: _values[4],
      odds: _values[5],
      payload: _payload
    });
  }

  /**
   * @notice Calculates the return of bet for the backer
   * @param _bet Structure of the bet
   * @param _decimals Decimals of the odds
   * @return Returns the amount that backer wins based on the odds
   */
  function backerTokenReturn(Bet _bet, uint _decimals) internal pure returns (uint) {
    return _bet.backerStake.mul(_bet.odds).div(10 ** _decimals);
  }

}
