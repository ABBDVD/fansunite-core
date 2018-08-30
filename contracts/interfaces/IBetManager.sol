pragma solidity ^0.4.24;

import "../utils/RegistryAccessible.sol";


/**
 * @title Interface for Bet Manger Contract
 */
contract IBetManager is RegistryAccessible {

  /**
   * @notice Claims a bet, transfers tokens and fees based on fixture resolution
   * @param _bet Keccak-256 EIP712 hash of the bet struct
   * @return Result of bet (refer to IResolver for specifics of the return type)
   */
  function claimBet(bytes32 _bet) external returns (uint8);

  /**
   * @notice Cancels a bet, if not filled
   * @param _bet Keccak-256 EIP712 hash of the bet
   * @return Returns `true` if bet successfully cancelled, `false` otherwise
   */
  function cancelBet(bytes32 _bet) external returns (bool);

  /**
   * @notice Returns all the bet identifiers for address `_subject`
   * @param _subject Address of a layer or backer
   */
  function getBetsBySubject(address _subject) external view returns (bytes32[]);

  /**
   * @notice Gets subjects, params and payload associated with bet `_bet`
   * @param _bet Keccak-256 EIP712 hash of the bet struct
   * @return Subjects associated with `_bet`
   *  [backer, layer, backerToken, layerToken, feeRecipient, league, resolver]
   * @return Params associated with `_bet`
   *  [backerStake, backerFee, layerFee, expiration, fixture, odds]
   * @return Payload associated with `_bet`
  */
  function getBet(bytes32 _bet) external view returns (address[6], uint[6], bytes);

}
