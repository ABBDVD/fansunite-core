pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "./ILeague001.sol";
import "./BaseLeague.sol";
import "../interfaces/IResolverRegistry.sol";
import "../interfaces/IResolver.sol";

import { LeagueLib001 as L } from "./LeagueLib001.sol";


/**
 * @title League Contract
 */
contract League001 is ILeague001, BaseLeague {

  // League version
  string internal VERSION = "0.0.1";
  // Number of Participants in each fixture
  uint internal PARTICIPANTS_PER_FIXTURE;

  // Season corresponds to `true` if exists, `false` otherwise
  mapping(uint => bool) internal supportedSeasons;
  // Season corresponds to list of fixture ids
  mapping(uint => uint[]) internal seasons;
  // List of seasons
  uint[] internal seasonList;
  // List of all fixtures ever in league
  // Fixture id is (i + 1), where i is the index of fixture
  L.Fixture[] internal fixtures;
  // List of participants ever played in league
  // Participant id is (i + 1), where i is the index of participant
  L.Participant[] internal participants;

  // Mapping of fixture hashes to whether they exist, to avoid duplicates
  mapping(bytes32 => bool) duplicateManager;

  // Fixture ids correspond to `true` if resolved, `false` if not resolved
  // Being resolved means at least one resolution has been pushed by ConsensusManager
  mapping(uint => bool) internal resolved;
  // fixture => resolver => payload
  mapping(uint => mapping(address => bytes)) internal resolutions;
  // fixture => resolver => boolean (whether pushed or not)
  mapping(uint => mapping(address => bool)) internal pushed;

  // Emit when new season added
  event LogSeasonAdded(uint indexed _year);
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
   * @param _registry Address of the FansUnite Registry Contact
   * @param _participantsPerFixture Number of participants allowed per fixture
   */
  constructor(
    string _class,
    string _name,
    address _registry,
    uint _participantsPerFixture
  )
    public
    BaseLeague(_class, _name, _registry)
  {
    PARTICIPANTS_PER_FIXTURE = _participantsPerFixture;
  }

  /**
   * @dev Throw is called by any account other than consensus
   */
  modifier onlyConsensus() {
    require(
      msg.sender == registry.getAddress("ConsensusManager"),
      "Sender is not ConsensusManager"
    );
    _;
  }

  ///////////////////////////////////////////////////////////////////////////////
  ///////////////////////////// external functions //////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////

  /**
   * @notice Adds a resolution payload for fixture with id `_fixture` and resolver `_resolver`
   * @param _fixture Id of the fixture being resolved
   * @param _resolver Address of the resolver that can resolve _payload
   * @param _payload Encoded resolution payload
   * @dev _payload can be 0x, should result in bet cancellation
   * @dev _payload can be 0x00..00, would be passed as valid resolution payload to resolvers
   */
  function pushResolution(uint _fixture, address _resolver, bytes _payload)
    external
    onlyConsensus
  {
    // TODO Reduce duplication when multiple resolvers use the same payload
    // NOTE pushResolution can be called to write and overwrite payload, by design
    // NOTE not validating _resolver and _fixture, economical guarantee from oracles

    if (!resolved[_fixture]) resolved[_fixture] = true;
    pushed[_fixture][_resolver] = true;
    resolutions[_fixture][_resolver] = _payload;

    emit LogFixtureResolved(_fixture, _resolver, _payload);
  }

  /**
   * @notice Starts a new season with year `_year`
   * @param _year Year of the first fixture in new season
   */
  function addSeason(uint _year) external {
    require(!_isSeasonSupported(_year), "Season already supported");

    supportedSeasons[_year] = true;
    seasonList.push(_year);

    emit LogSeasonAdded(_year);
  }

  /**
   * @notice Creates a new fixture for season `_season`
   * @param _season Season of fixture
   * @param _participants ids of participants in event
   * @param _start Start time (unix timestamp, seconds)
   * @dev _start is rounded off to the nearest minute
   */
  function scheduleFixture(uint _season, uint[] _participants, uint _start) external {
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
   * @param _name Name of the participant - should match pattern /^[a-zA-Z0-9.() ]+$/
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
   * @notice Gets resolution payload for fixture `_fixture` and resolver `_resolver`
   * @dev throws if fixture `_fixture` is not resolved for resolver `_resolver`
   * @param _fixture Id of the payload's corresponding fixture
   * @param _resolver Address of the payload's corresponding resolver
   * @return Resolution payload for fixture `_fixture` and resolver `_resolver`
   */
  function getResolution(uint _fixture, address _resolver) external view returns (bytes) {
    require(
      _isFixtureResolved(_fixture, _resolver) == 1,
      "Given resolver, for given fixture, has not been resolved"
    );

    return resolutions[_fixture][_resolver];
  }

  /**
   * @notice Gets a list of all seasons in league
   * @return Years of all seasons in league
   */
  function getSeasons() external view returns (uint[]) {
    return seasonList;
  }

  /**
   * @notice Gets the season with year `_year`
   * @param _year Year of the season
   * @return Year of the season
   * @return Ids fixtures scheduled in season `_year`
   */
  function getSeason(uint _year) external view returns (uint, uint[]) {
    require(_isSeasonSupported(_year), "League does not support given season");

    return (_year, seasons[_year]);
  }

  /**
   * @notice Gets start time for fixture `_fixture`
   * @param _fixture Id of fixture
   * @return start time of fixture `_fixture`
   */
  function getFixtureStart(uint _fixture) external view returns (uint) {
    require(_isFixtureScheduled(_fixture), "Given fixture is not scheduled in league");

    return fixtures[_fixture - 1].start;
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
   * @notice Gets participants count
   * @return participant count
   */
  function getParticipantCount() external view returns (uint) {
    return participants.length;
  }

  /**
   * @notice Checks if fixture with id `_fixture` has been scheduled in league
   * @param _fixture Id of the fixture
   * @return `true` if fixture with id `_fixture` is scheduled, `false` otherwise
   */
  function isFixtureScheduled(uint _fixture) external view returns (bool) {
    return _isFixtureScheduled(_fixture);
  }

  /**
   * @notice Checks if fixture with id `_fixture` has been resolved for resolver `_resolver`
   * @dev A fixture is resolved if at least one resolver receives resolution payload
   * @dev It is possible that some resolvers do not get resolution payloads from oracles
   * @param _fixture Id of the fixture
   * @param _resolver Address of the resolver
   * @return `0` if fixture is not resolved, `1` if fixture is resolved for resolver `_resolver`,
   *  `2` if fixture is resolved but not for resolver `_resolver
   */
  function isFixtureResolved(uint _fixture, address _resolver) external view returns (uint8) {
    return _isFixtureResolved(_fixture, _resolver);
  }

  /**
   * @notice Checks if participant id `_participant` is valid
   * @param _participant Id of the participant
   * @return `true` if participant id `_participant` is valid, `false` otherwise
   */
  function isParticipant(uint _participant) external view returns (bool) {
    return _isParticipant(_participant);
  }

  /**
   * @notice Checks if participant `_participant` is playing in fixture `_fixture`
   * @param _participant Id of the participant
   * @param _fixture Id of the fixture
   * @return `true` if participant `_participant` is scheduled in for fixture `_fixture`
   */
  function isParticipantScheduled(uint _participant, uint _fixture)
    external
    view
    returns (bool)
  {
    require(_isParticipant(_participant), "Given participant is not in league");
    require(_isFixtureScheduled(_fixture), "Given fixture is not scheduled");

    L.Fixture storage __fixture = fixtures[_fixture - 1];
    for (uint i = 0; i < __fixture.participants.length; i++)
      if (__fixture.participants[i] == _participant) return true;
    return false;
  }

  /**
   * @notice Gets the league version (matches LeagueFactory version)
   * @return Version of the league protocol
   */
  function getVersion() external view returns (string) {
    return VERSION;
  }


  ///////////////////////////////////////////////////////////////////////////////
  ///////////////////////////// internal view functions /////////////////////////
  ///////////////////////////////////////////////////////////////////////////////

  // internal isFixtureScheduled
  function _isFixtureScheduled(uint _fixture) internal view returns (bool) {
    return _fixture > 0 && _fixture < fixtures.length + 1;
  }

  // internal isFixtureResolved
  function _isFixtureResolved(uint _fixture, address _resolver) internal view returns (uint8) {
    if (!resolved[_fixture])
      return 0;
    return pushed[_fixture][_resolver] ? 1 : 2;
  }

  // internal isParticipant
  function _isParticipant(uint _participant) internal view returns (bool) {
    return _participant > 0 && _participant < participants.length + 1;
  }

  // validate all participants
  function _areParticipants(uint[] _participants) internal view returns (bool) {
    for (uint i = 0; i < _participants.length; i++) {
      if (!_isParticipant(_participants[i])) return false;
    }
    return true;
  }

  // internal isSeasonSupported
  function _isSeasonSupported(uint _year) internal view returns (bool) {
    return supportedSeasons[_year];
  }

}
