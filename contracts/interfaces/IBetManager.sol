pragma solidity ^0.4.24;


/**
 * @title Interface for Bet Manger Contract
 */
contract IBetManager {

  /**
   * @notice Claims a bet, transfers tokens and fees based on fixture resolution
   * @param _bet Hash of all the bet parameters
   * @return Result of bet
   */
  function claimBet(bytes32 _bet) external returns (uint8);

  /**
   * @notice Cancels a bet which has been partially filled
   * @param _bet Hash of all the bet parameters
   * @return Returns `true` if bet was successfully cancelled,
   */
  function cancelBet(bytes32 _bet) external returns (bool);

  /**
   * @notice Returns all the bet ids for the provided user address
   * @param _user Address of the user
   */
  function getUserBetIds(address _user) external view returns (bytes32[]);

  /**
   * @notice Returns all the parameters associated with bet `_bet`
   * @param _bet Hash of all the bet parameters
   * @return Addresses associated with `_bet`
   *  [backer, layer, backerToken, layerToken, feeRecipient, league, resolver]
   * @return Params associated with bet
   *  [backerStake, backerFee, layerFee, expiration, fixture, odds]
   * @return The bet payload
  */
  function getBetDetails(bytes32 _bet) external view returns (address[7], uint[6], bytes);
}
