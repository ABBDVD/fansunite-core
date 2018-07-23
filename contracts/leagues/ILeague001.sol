pragma solidity ^0.4.24;

import "../interfaces/ILeague.sol";


/**
 * @title Interface for a fansunite league contract
 * @dev League contract is a store of seasons, events, participants, resolvers and resolution payloads
 */
contract ILeague001 is ILeague {

  /**
   * @notice Starts a new season with year `_year`
   * @param _year Year of the first fixture in new season
   */
  function startSeason(uint16 _year) external;

  /**
   * @notice Creates a new fixture for the on-going season
   * @param _lineup ids of participants in event
   * @param _start Start time (unix timestamp)
   */
  function scheduleFixture(uint[] _lineup, uint _start) external;

  /**
   * @notice Adds a new participant to the league
   * @param _name Name of the participant - should match pattern /[a-zA-Z ]+/
   * @param _details Off-line hash of participant details
   */
  function addParticipant(string _name, bytes _details) external;

  /**
   * @notice Gets a list of all seasons in league
   * @return uint16[] years of all seasons for league
   */
  function getSeasons() external view returns (uint16[]);

  /**
   * @notice Gets the on-going season
   * @return Year of the on-going season, if any, 0 otherwise and ids fixtures scheduled
   *     for on-going season
   */
  function getLiveSeason() external view returns (uint16, uint[]);

  /**
   * @notice Gets scheduled fixture with id `_id`
   * @param _id Id of the scheduled fixture
   * @return fixture id, participant ids and start time
   */
  function getFixture(uint _id) external view returns (uint, uint[], uint);

  /**
   * @notice Gets participant in league with id `_id`
   * @param _id Id of the participant
   * @return id, name and details of Participant
   */
  function getParticipant(uint _id) external view returns (uint, string, bytes);

}
