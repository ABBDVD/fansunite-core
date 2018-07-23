pragma solidity ^0.4.24;


/**
 * @title Interface for a fansunite league contract
 * @dev League contract is a store of seasons, fixtures, participants, resolvers and resolution
 *     payloads
 */
contract ILeague {

  /**
   * @notice Adds resolver with address `_resolver` to league
   * @dev fails if `_resolver` is not registered with FansUnite's Resolver Registry
   * @param _resolver Address of the resolver contract
   */
  function registerResolver(address _resolver) external;

  /**
   * @notice Adds a resolution payload for fixture with id `_fixtureId` and resolver `_resolver`
   * @param _fixtureId Id of the fixture being resolved
   * @param _resolver Address of the resolver that can resolve _payload
   * @param _payload Encoded resolution payload
   */
  function pushResolution(uint _fixtureId, address _resolver, bytes _payload) external;

  /**
   * @notice Sets league details
   * @param _details IPFS hash with league details
   */
  function setDetails(bytes _details) external;

  /**
   * @notice Gets resolution payload for fixture `_fixtureId` and resolver `_resolver`
   * @dev Requires the fixture `_fixtureId` to be resolved for resolver `_resolver`
   * @param _fixtureId Id of the payload's corresponding fixture
   * @param _resolver Address of the payload's corresponding resolver
   * @return Resolution payload for fixture `_fixtureId` and resolver `_resolver`
   */
  function getResolution(uint _fixtureId, address _resolver) external view returns (bytes);

  /**
   * @notice Checks if resolver with address `_resolver` is registered with league
   * @param _resolver Address of the resolver
   * @return True if resolver is registered with league, false otherwise
   */
  function isResolverRegistered(address _resolver) external view returns (bool);

  /**
   * @notice Checks if fixture with id `_id` has been scheduled in league
   * @param _id Id of the fixture
   * @return True if fixture with id `_id` is scheduled, false otherwise
   */
  function isFixtureScheduled(uint _id) external view returns (bool);

  /**
   * @notice Checks if fixture with id `_id` has been resolved for resolver `_resolver`
   * @dev A fixture is resolved if at least one resolver receives resolution payload
   * @dev It is possible that some resolvers do not get resolution payloads from oracles
   * @param _id Id of the fixture
   * @param _resolver Address of the resolver
   * @return 0 if fixture is not resolved, 1 if fixture is resolved and for resolver `_resolver`,
   *     2 if fixture is resolved but resolver `_resolver
   */
  function isFixtureResolved(uint _id, address _resolver) external view returns (uint8);

  /**
   * @notice Checks if participant id `_id` is valid
   * @param _id Id of the participant
   * @return True if participant id `_id` is valid, false otherwise
   */
  function isParticipant(uint _id) external view returns (bool);

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

}
