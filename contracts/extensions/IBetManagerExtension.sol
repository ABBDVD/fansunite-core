pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;


/**
 * @title Interface for BetManager Extension
 * @dev BetManager Extension contract provides nice features to read data from FansUnite
 *  BetManager Contract
 */
contract IBetManagerExtension {

  /**
   * @notice Gets all bets for backer / layer `_subject`
   * @dev Think of the output as 4 columns (BetIds, Subjects, Params, Payloads) and each row as as
   *  a bet object
   * @dev TODO:v1:think Manan => Update to return an array of Bet structs instead
   * @param _betManager Address of the current BetManager contract?
   * @param _subject Address of the backer or layer
   * @return Bet Ids (Keccak256 hashes of bet struct)
   * @return Subjects, by bet
   * @return Params, by Bet
   * @return Start times, by Bet
   */
  function getBets(address _betManager, address _subject)
    external
    view
    returns (bytes32[], address[5][], uint[4][], bytes[]);

}
