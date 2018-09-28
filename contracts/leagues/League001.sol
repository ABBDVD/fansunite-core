pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "./ILeague001.sol";
import "./BaseLeague.sol";
import "../interfaces/IResolverRegistry.sol";
import "../interfaces/IResolver.sol";

import { LeagueLib001 as L } from "./LeagueLib001.sol";


/**
 * @title League Contract
 */
contract League001 is Ownable, ILeague001, BaseLeague {

  // Number of Participants in each fixture
  uint internal PARTICIPANTS_PER_FIXTURE;

  // Resolver addresses correspond to `true` if registered with league, `false` otherwise
  mapping(address => bool) internal registeredResolvers;
  // List of resolver addresses registered with league
  address[] internal resolvers;

  // Season corresponds to `true` if exists, `false` otherwise
  mapping(uint16 => bool) internal supportedSeasons;
  // Season corresponds to list of fixture ids
  mapping(uint16 => uint[]) internal seasons;
  // List of seasons
  uint16[] internal seasonList;
  // List of all fixtures ever in league
  L.Fixture[] internal fixtures;
  // List of participants ever played in league
  L.Participant[] internal participants;

  // Mapping of fixture hashes to whether they exist, to avoid duplicates
  // NOTE Think about converting uint fixture ids to bytes32 hashes?
  mapping(bytes32 => bool) duplicateManager;

  // Fixture ids correspond to `true` if resolved, `false` if not resolved
  // Being resolved means at least one resolution has been pushed
  mapping(uint => bool) internal resolved;
  // fixture => resolver => payload
  mapping(uint => mapping(address => bytes)) internal resolutions;
  // fixture => resolver => boolean (whether pushed or not)
  mapping(uint => mapping(address => bool)) internal pushed;

  // Emit when new Resolver added
  event LogResolverRegistered(address _resolver);
  // Emit when new season added
  event LogSeasonAdded(uint16 indexed _year);
  // Emit when new fixture added
  event LogFixtureAdded(uint _id);
  // Emit when new participant added
  event LogParticipantAdded(uint _id);
  // Emit when a Fixture is resolved, by resolver
  event LogFixtureResolved(uint indexed _fixtureId, address _resolver, bytes _payload);

  /**
   * @notice Constructor
   * @param _class Class of league
   * @param _name Name of league
   * @param _version Version of league
   * @param _registry Address of the FansUnite Registry Contact
   * @param _participantsPerFixture Number of participants allowed per fixture
   */
  constructor(
    string _class,
    string _name,
    string _version,
    address _registry,
    uint _participantsPerFixture
  )
    public
    BaseLeague(_class, _name, _version, _registry)
  {
    PARTICIPANTS_PER_FIXTURE = _participantsPerFixture;
  }

  /**
   * @dev Throw is called by any account other than consensus
   */
  modifier onlyConsensus() {
    require(msg.sender == registry.getAddress("ConsensusManager"));
    _;
  }

  ///////////////////////////////////////////////////////////////////////////////
  ///////////////////////////// external functions //////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////

  /**
   * @notice Adds resolver with address `_resolver` to league
   * @dev fails if `_resolver` is not registered with FansUnite's Resolver Registry
   * @param _resolver Address of the resolver contract
   */
  function registerResolver(address _resolver) external {
    require(
      !_isResolverRegistered(_resolver),
      "Resolver already registered"
    );
    require(
      IResolverRegistry(registry.getAddress("ResolverRegistry")).useResolver(class, _resolver),
      "Cannot use resolver"
    );
    require(
      IResolver(_resolver).doesSupportVersion(version),
      "Resolver does not support current league version"
    );

    registeredResolvers[_resolver] = true;
    resolvers.push(_resolver);

    emit LogResolverRegistered(_resolver);
  }

  /**
   * @notice Adds a resolution payload for fixture with id `_fixtureId` and resolver `_resolver`
   * @param _fixtureId Id of the fixture being resolved
   * @param _resolver Address of the resolver that can resolve _payload
   * @param _payload Encoded resolution payload
   */
  function pushResolution(uint _fixtureId, address _resolver, bytes _payload)
    external
    onlyConsensus
  {
    // TODO Reduce duplication when multiple resolvers use the same payload
    // _payload can be 0x, should result in bet cancellation
    // _payload can be 0x00..00, would be passed as valid resolution payload to resolvers
    require(_isFixtureScheduled(_fixtureId), "Given Fixture is not scheduled in league");
    require(_isResolverRegistered(_resolver), "League does not support given resolver");

    if (!resolved[_fixtureId]) resolved[_fixtureId] = true;
    pushed[_fixtureId][_resolver] = true;
    resolutions[_fixtureId][_resolver] = _payload;

    emit LogFixtureResolved(_fixtureId, _resolver, _payload);
  }

  /**
   * @notice Starts a new season with year `_year`
   * @param _year Year of the first fixture in new season
   */
  function addSeason(uint16 _year) external {
    require(!_isSeasonSupported(_year), "Season already supported");

    supportedSeasons[_year] = true;
    seasonList.push(_year);

    emit LogSeasonAdded(_year);
  }

  /**
   * @notice Creates a new fixture for the on-going season
   * @param _season Season of fixture
   * @param _participants ids of participants in event
   * @param _start Start time (unix timestamp)
   */
  function scheduleFixture(uint16 _season, uint[] _participants, uint _start) external {
    bytes32 _hash = L.hashRawFixture(_participants, _start);

    require(
      _isSeasonSupported(_season),
      "League does not support given season"
    );
    require(
      _participants.length == PARTICIPANTS_PER_FIXTURE,
      "Invalid number of participants in fixture"
    );
    require(
      _areParticipants(_participants),
      "Unknown participant scheduled for fixture"
    );
    require(
      _start > block.timestamp,
      "Fixture has already started"
    );
    require(
      !duplicateManager[_hash],
      "Fixture is duplicated in league"
    );

    L.Fixture memory _fixture;
    _fixture.id = fixtures.length + 1;
    _fixture.start = _start;
    fixtures.push(_fixture);
    fixtures[fixtures.length - 1].participants = _participants;
    seasons[_season].push(_fixture.id);
    duplicateManager[_hash] = true;

    emit LogFixtureAdded(_fixture.id);
  }

  /**
   * @notice Adds a new participant to the league
   * @param _name Name of the participant - should match pattern /[a-zA-Z ]+/
   * @param _details Off-chain hash of participant details
   */
  function addParticipant(string _name, bytes _details) external onlyOwner {
    bytes32 _hash = L.hashRawParticipant(_name);

    require(
      !duplicateManager[_hash],
      "Participant already in league"
    );

    L.Participant memory _participant;
    _participant.name = _name;
    _participant.details = _details;
    _participant.id = participants.length + 1;
    participants.push(_participant);
    duplicateManager[_hash] = true;

    emit LogParticipantAdded(_participant.id);
  }


  ///////////////////////////////////////////////////////////////////////////////
  ///////////////////////////// external view functions /////////////////////////
  ///////////////////////////////////////////////////////////////////////////////


  /**
   * @notice Gets resolution payload for fixture `_fixtureId` and resolver `_resolver`
   * @dev Requires the fixture `_fixtureId` to be resolved for resolver `_resolver`
   * @param _fixtureId Id of the payload's corresponding fixture
   * @param _resolver Address of the payload's corresponding resolver
   * @return Resolution payload for fixture `_fixtureId` and resolver `_resolver`
   */
  function getResolution(uint _fixtureId, address _resolver) external view returns (bytes) {
    require(
      _isFixtureResolved(_fixtureId, _resolver) == 1,
      "Given resolver, for given fixture, has not been resolved"
    );

    return resolutions[_fixtureId][_resolver];
  }

  /**
   * @notice Gets all resolvers in league
   * @return Addresses of all resolvers registered in league
   */
  function getResolvers() external view returns (address[]) {
    return resolvers;
  }

  /**
   * @notice Gets a list of all seasons in league
   * @return Years of all seasons in league
   */
  function getSeasons() external view returns (uint16[]) {
    return seasonList;
  }

  /**
   * @notice Gets the season with year `_year`
   * @param _year Year of the season
   * @return Year of the season
   * @return Ids fixtures scheduled in season `_year`
   */
  function getSeason(uint16 _year) external view returns (uint16, uint[]) {
    require(_isSeasonSupported(_year), "League does not support given season");

    return (_year, seasons[_year]);
  }

  /**
   * @notice Gets scheduled fixture with id `_id`
   * @param _id Id of the scheduled fixture
   * @return Fixture id
   * @return Participant Ids
   * @return Start time
   */
  function getFixture(uint _id) external view returns (uint, uint[], uint) {
    require(_isFixtureScheduled(_id), "Given fixture is not scheduled in league");

    L.Fixture storage _fixture = fixtures[_id - 1];
    return (_fixture.id, _fixture.participants, _fixture.start);
  }

  /**
   * @notice Gets participant in league with id `_id`
   * @param _id Id of the participant
   * @return Participant Id
   * @return Participant name
   * @return Details of Participant (hash)
   */
  function getParticipant(uint _id) external view returns (uint, string, bytes) {
    require(_isParticipant(_id), "Given participant is not in league");

    L.Participant storage _participant = participants[_id - 1];
    return (_participant.id, _participant.name, _participant.details);
  }

  /**
   * @notice Checks if resolver with address `_resolver` is registered with league
   * @param _resolver Address of the resolver
   * @return `true` if resolver is registered with league, `false` otherwise
   */
  function isResolverRegistered(address _resolver) external view returns (bool) {
    return _isResolverRegistered(_resolver);
  }

  /**
   * @notice Checks if fixture with id `_id` has been scheduled in league
   * @param _id Id of the fixture
   * @return `true` if fixture with id `_id` is scheduled, `false` otherwise
   */
  function isFixtureScheduled(uint _id) external view returns (bool) {
    return _isFixtureScheduled(_id);
  }

  /**
   * @notice Checks if fixture with id `_id` has been resolved for resolver `_resolver`
   * @dev A fixture is resolved if at least one resolver receives resolution payload
   * @dev It is possible that some resolvers do not get resolution payloads from oracles
   * @param _id Id of the fixture
   * @param _resolver Address of the resolver
   * @return `0` if fixture is not resolved, `1` if fixture is resolved and for resolver `_resolver`,
   *  `2` if fixture is resolved but resolver `_resolver
   */
  function isFixtureResolved(uint _id, address _resolver) external view returns (uint8) {
    return _isFixtureResolved(_id, _resolver);
  }

  /**
   * @notice Checks if participant id `_id` is valid
   * @param _id Id of the participant
   * @return `true` if participant id `_id` is valid, `false` otherwise
   */
  function isParticipant(uint _id) external view returns (bool) {
    return _isParticipant(_id);
  }

  /**
   * @notice Checks if participant `_participantId` is playing in fixture `_fixtureId`
   * @param _participantId Id of the participant
   * @param _fixtureId Id of the fixture
   * @return `true` if participant `_participantId` is scheduled in for fixture `_fixtureId`
   */
  function isParticipantScheduled(uint _participantId, uint _fixtureId)
    external
    view
    returns (bool)
  {
    require(_isParticipant(_participantId), "Given participant is not in league");
    require(_isFixtureScheduled(_fixtureId), "Given fixture is not scheduled");

    L.Fixture storage _fixture = fixtures[_fixtureId - 1];
    for (uint i = 0; i < _fixture.participants.length; i++)
      if (_fixture.participants[i] == _participantId) return true;
    return false;
  }


  ///////////////////////////////////////////////////////////////////////////////
  ///////////////////////////// internal view functions /////////////////////////
  ///////////////////////////////////////////////////////////////////////////////


  // internal isParticipant
  function _isResolverRegistered(address _resolver) internal view returns (bool) {
    return registeredResolvers[_resolver];
  }

  // internal isFixtureScheduled
  function _isFixtureScheduled(uint _id) internal view returns (bool) {
    return _id > 0 && _id < fixtures.length + 1;
  }

  // internal isFixtureResolved
  function _isFixtureResolved(uint _id, address _resolver) internal view returns (uint8) {
    if (!resolved[_id])
      return 0;
    return pushed[_id][_resolver] ? 1 : 2;
  }

  // internal isParticipant
  function _isParticipant(uint _id) internal view returns (bool) {
    return _id > 0 && _id < participants.length + 1;
  }

  // validate all participants
  function _areParticipants(uint[] _participants) internal view returns (bool) {
    bool _valid = true;
    for (uint i = 0; i < _participants.length; i++) {
      _valid = _valid && _isParticipant(_participants[i]);
    }
    return _valid;
  }

  // internal isSeasonSupported
  function _isSeasonSupported(uint16 _year) internal view returns (bool) {
    return supportedSeasons[_year];
  }

}
