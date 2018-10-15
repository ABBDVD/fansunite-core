pragma solidity ^0.4.24;


/**
 * @title Interface for a fansunite league contract
 * @dev League contract is a store of seasons, fixtures, participants, resolvers and resolution
 *  payloads
 */
contract ILeague {

  /**
   * @notice Adds a resolution payload for fixture with id `_fixture` and resolver `_resolver`
   * @param _fixture Id of the fixture being resolved
   * @param _resolver Address of the resolver that can resolve _payload
   * @param _payload Encoded resolution payload
   * @dev _payload can be 0x, should result in bet cancellation
   * @dev _payload can be 0x00..00, would be passed as valid resolution payload to resolvers
   */
  function pushResolution(uint _fixture, address _resolver, bytes _payload) external;

  /**
   * @notice Sets league details
   * @param _details Off-chain hash of league details
   */
  function setDetails(bytes _details) external;

  /**
   * @notice Gets resolution payload for fixture `_fixture` and resolver `_resolver`
   * @dev throws if fixture `_fixture` is not resolved for resolver `_resolver`
   * @param _fixture Id of the payload's corresponding fixture
   * @param _resolver Address of the payload's corresponding resolver
   * @return Resolution payload for fixture `_fixture` and resolver `_resolver`
   */
  function getResolution(uint _fixture, address _resolver) external view returns (bytes);

  /**
   * @notice Gets start time for fixture `_fixture`
   * @param _fixture Id of fixture
   * @return start time of fixture `_fixture`
   */
  function getFixtureStart(uint _fixture) external view returns (uint);

  /**
   * @notice Checks if fixture with id `_fixture` has been scheduled in league
   * @param _fixture Id of the fixture
   * @return `true` if fixture with id `_fixture` is scheduled, `false` otherwise
   */
  function isFixtureScheduled(uint _fixture) external view returns (bool);

  /**
   * @notice Checks if fixture with id `_fixture` has been resolved for resolver `_resolver`
   * @dev A fixture is resolved if at least one resolver receives resolution payload
   * @dev It is possible that some resolvers do not get resolution payloads from oracles
   * @param _fixture Id of the fixture
   * @param _resolver Address of the resolver
   * @return `0` if fixture is not resolved, `1` if fixture is resolved for resolver `_resolver`,
   *  `2` if fixture is resolved but not for resolver `_resolver
   */
  function isFixtureResolved(uint _fixture, address _resolver) external view returns (uint8);

  /**
   * @notice Checks if participant id `_participant` is valid
   * @param _participant Id of the participant
   * @return `true` if participant id `_participant` is valid, `false` otherwise
   */
  function isParticipant(uint _participant) external view returns (bool);

  /**
   * @notice Checks if participant `_participant` is playing in fixture `_fixture`
   * @param _participant Id of the participant
   * @param _fixture Id of the fixture
   * @return `true` if participant `_participant` is scheduled in for fixture `_fixture`
   */
  function isParticipantScheduled(uint _participant, uint _fixture)
    external
    view
    returns (bool);

  /**
   * @notice Gets the name of the league
   * @return UTF-8 encoded name of league
   */
  function getName() external view returns (string);

  /**
   * @notice Gets the class of the league
   * @return UTF-8 encoded class of league
   */
  function getClass() external view returns (string);

  /**
   * @notice Gets the league details
   * @return IPFS hash with league details
   */
  function getDetails() external view returns (bytes);

  /**
   * @notice Gets the league version (matches LeagueFactory version)
   * @return Version of the league protocol
   */
  function getVersion() external view returns (string);

}
