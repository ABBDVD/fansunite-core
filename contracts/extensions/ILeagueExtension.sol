pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;


/**
 * @title Interface for League Extension
 * @dev League Extension contract provides nice features to read data from FansUnite League
 *     contracts
 */
contract ILeagueExtension {

  /**
   * @notice Aggregates leagues from league `_league` for season `_season`
   * @dev Think of the output as 3 columns (Fixture Id, Participant Ids, Start) and each row as
   *     as a fixture
   * @dev TODO v1:Manan => Update to return an array of Fixture structs instead
   * @param _league address of the league contract
   * @param _season Season to get fixtures for
   * @return Fixture ids, participants and start times for event
   */
  function getFixtures(address _league, uint16 _season)
    external
    view
    returns (uint[], uint[][], uint[]);

}
