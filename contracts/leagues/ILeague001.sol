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
  function addSeason(uint _year) external;

  /**
   * @notice Creates a new fixture for season `_season`
   * @param _season Season of fixture
   * @param _participants ids of participants in event
   * @param _start Start time (unix timestamp, seconds)
   * @dev _start is rounded off to the nearest minute
   */
  function scheduleFixture(uint _season, uint[] _participants, uint _start) external;

  /**
   * @notice Adds a new participant to the league
   * @param _name Name of the participant - should match pattern /^[a-zA-Z0-9.() ]+$/
   * @param _details Off-chain hash of participant details
   */
  function addParticipant(string _name, bytes _details) external;

  /**
   * @notice Gets a list of all seasons in league
   * @return Years of all seasons in league
   */
  function getSeasons() external view returns (uint[]);

  /**
   * @notice Gets the season with year `_year`
   * @param _year Year of the season
   * @return Year of the season
   * @return Ids fixtures scheduled in season `_year`
   */
  function getSeason(uint _year) external view returns (uint, uint[]);

  /**
   * @notice Gets scheduled fixture with id `_id`
   * @param _id Id of the scheduled fixture
   * @return Fixture id
   * @return Participant Ids
   * @return Start time
   */
  function getFixture(uint _id) external view returns (uint, uint[], uint);

  /**
   * @notice Gets participant in league with id `_id`
   * @param _id Id of the participant
   * @return Participant Id
   * @return Participant name
   * @return Details of Participant (hash)
   */
  function getParticipant(uint _id) external view returns (uint, string, bytes);

  /**
   * @notice Gets participants count
   * @return participant count
   */
  function getParticipantCount() external view returns (uint);

}
