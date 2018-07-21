pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import "../interfaces/ILeague.sol";


/**
 * @title Interface for a fansunite league contract
 * @dev League contract is a store of seasons, events, participants, resolvers and resolution payloads
 */
contract ILeague001 is ILeague {

  /**
   * @notice Starts a new season with year `_year`
   * @param _year Year of the first event in new season
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
  function addParticipant(bytes32 _name, bytes32 _details) external;

  /**
   * @notice Adds resolver with address `_resolver` to league, if registered with FansUnite
   * @param _resolver Address of the resolver contract
   */
  function addResolver(address _resolver) external;

  /**
   * @notice Adds a resolution payload for event with id `_eventId` and resolver `_resolver`
   * @param _eventId Id of the event being resolved
   * @param _resolver Address of the resolver that can resolve _payload
   * @param _payload Encoded resolution payload
   */
  function pushResolution(uint _eventId, address _resolver, bytes _payload) external;

  /**
   * @notice Gets a list of all seasons in league
   * @return uint16[] years of all seasons
   */
  function getSeasons() external view returns (uint16[]);

  /**
   * @notice Gets the on-going season
   * @return Year of the on-going season, if any, 0 otherwise
   */
  function getLiveSeason() external view returns (uint16);

  /**
   * @notice Gets all the scheduled fixtures for `_season`
   *
   *
   */
  function getFixtures(uint16 _season) external view returns (uint[][], uint[]);

  /**
   *
   *
   *
   */
  function getParticipants() external view returns (bytes32[], bytes32[]);

  /**
   *
   *
   *
   */
  function getResolution(/* TODO */) external view;

  /**
   *
   *
   *
   */
  function isFixtureScheduled(/* TODO */) external view;

  /**
   *
   *
   *
   */
  function isParticipant(/* TODO */) external view;

  /**
   *
   *
   *
   */
  function isResolverRegistered(/* TODO */) external view;

  /**
   *
   *
   *
   */
  function getName() external view returns (byte[64]);

  /**
   *
   *
   *
   */
  function getClass() external view returns (bytes32);

  /**
   *
   *
   *
   */
  function getDetails() external view returns (bytes32);

}
