pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./ILeague001.sol";
import { LeagueLib001 as L } from "./LeagueLib001.sol";


/**
 * @title League Contract
 */
contract League001 is Ownable, ILeague001 {

  // Version of the league
  string internal version = "0.0.1";
  // Name of the league
  string internal name;
  // Class to which the league belongs
  string internal class;
  // Hash of league details stored off-chain (eg. IPFS multihash)
  bytes internal details;

  // Address of the resolution contract (contact responsible for consensus / oracles)
  address internal consensus;

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
  // Fixture ids correspond to `true` if resolved, `false` if not resolved
  mapping(uint => bool) internal resolved;
  // Resolution payloads by resolver address, by fixture id
  mapping(uint => mapping(address => bytes)) internal resolutions;

  // Emit when a Fixture is resolved, by resolver
  event LogConsensusContractUpdated(address indexed _old, address indexed _new);
  // Emit when new Resolver added
  event LogResolverAdded(address _resolver);
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
   * @param _details Off-chain hash of league details
   */
  constructor(string _class, string _name, bytes _details, address _consensus) public {
    name = _name;
    class = _class;
    details = _details;
    consensus = _consensus;
  }

  /**
   * @dev Throw is called by any account other than consensus
   */
  modifier onlyConsensus() {
    require(msg.sender == consensus);
    _;
  }

  /**
   * @notice Sets consensus contract of the league to `_consensus`
   * @dev Only consensus contract will be able to call pushResolution
   * @param _consensus address of the consensus contract
   */
  function updateConsensusContract(address _consensus) external onlyOwner {
    require(_consensus != address(0), "Consensus contract cannot be set to 0x");
    address _old = consensus;
    consensus = _consensus;
    emit LogConsensusContractUpdated(_old, _consensus);
  }

  /**
   * @notice Adds resolver with address `_resolver` to league
   * @dev fails if `_resolver` is not registered with FansUnite's Resolver Registry
   * @param _resolver Address of the resolver contract
   */
  function registerResolver(address _resolver) external {
    // TODO:pre:blocked Manan => Finish implementation (blocked by Registry)
    resolvers.push(_resolver);

    emit LogResolverAdded(_resolver);
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
    // TODO:pre:think Manan => Think about case where _payload.length is 0 and payload is 0x00..00
    require(_fixtureId <= fixtures.length + 1, "Given Fixture is not scheduled in league");
    require(registeredResolvers[_resolver] == true, "League does not support given resolver");
    if (!resolved[_fixtureId]) resolved[_fixtureId] = true;
    resolutions[_fixtureId][_resolver] = _payload;
    emit LogFixtureResolved(_fixtureId, _resolver, _payload);
  }

  /**
   * @notice Starts a new season with year `_year`
   * @param _year Year of the first fixture in new season
   */
  function addSeason(uint16 _year) external {
    require(supportedSeasons[_year] == true, "Season already supported");
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
    // TODO:pre:gth Manan => Avoid ordered duplication (DoS attacks possible if hash collisions)
    require(supportedSeasons[_season] == true, "League does not support given season");
    L.Fixture memory _fixture;
    _fixture.id = fixtures.length + 1;
    _fixture.start = _start;
    seasons[_season].push(_fixture.id);
    fixtures.push(_fixture);
    _fixture.participants = _participants;

    emit LogFixtureAdded(_fixture.id);
  }

  /**
   * @notice Adds a new participant to the league
   * @param _name Name of the participant - should match pattern /[a-zA-Z ]+/
   * @param _details Off-chain hash of participant details
   */
  function addParticipant(string _name, bytes _details) external onlyOwner {
    // TODO:pre:gth Manan => Avoid name+details duplication?
    L.Participant memory _participant;
    _participant.name = _name;
    _participant.details = _details;
    _participant.id = participants.length + 1;
    participants.push(_participant);

    emit LogParticipantAdded(_participant.id);
  }

  /**
   * @notice Sets league details
   * @param _details Off-chain hash of league details
   */
  function setDetails(bytes _details) external onlyOwner {
    details = _details;
  }

  /**
   * @notice Gets resolution payload for fixture `_fixtureId` and resolver `_resolver`
   * @dev Requires the fixture `_fixtureId` to be resolved for resolver `_resolver`
   * @param _fixtureId Id of the payload's corresponding fixture
   * @param _resolver Address of the payload's corresponding resolver
   * @return Resolution payload for fixture `_fixtureId` and resolver `_resolver`
   */
  function getResolution(uint _fixtureId, address _resolver) external view returns (bytes) {
    require(resolved[_fixtureId], "Fixture not resolved.");
    require(
      resolutions[_fixtureId][_resolver].length > 0,
      "No payload provided for given resolver, for given fixture"
    );
    return resolutions[_fixtureId][_resolver];
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
    require(supportedSeasons[_year] == true, "League does not support given season");
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
    require(_id <= fixtures.length + 1, "Given fixture is not scheduled in league");
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
    require(_id <= participants.length + 1, "Given participant is not in league");
    L.Participant storage _participant = participants[_id - 1];
    return (_participant.id, _participant.name, _participant.details);
  }

  /**
   * @notice Checks if resolver with address `_resolver` is registered with league
   * @param _resolver Address of the resolver
   * @return `true` if resolver is registered with league, `false` otherwise
   */
  function isResolverRegistered(address _resolver) external view returns (bool) {
    return registeredResolvers[_resolver];
  }

  /**
   * @notice Checks if fixture with id `_id` has been scheduled in league
   * @param _id Id of the fixture
   * @return `true` if fixture with id `_id` is scheduled, `false` otherwise
   */
  function isFixtureScheduled(uint _id) external view returns (bool) {
    return _id <= fixtures.length + 1;
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
    if (!resolved[_id])
      return 0;
    if (resolutions[_id][_resolver].length == 0)
      return 1;
    return 2;
  }

  /**
   * @notice Checks if participant id `_id` is valid
   * @param _id Id of the participant
   * @return `true` if participant id `_id` is valid, `false` otherwise
   */
  function isParticipant(uint _id) external view returns (bool) {
    return _id <= participants.length + 1;
  }

  /**
   * @notice Gets the name of the league
   * @return UTF-8 encoded name of league
   */
  function getName() external view returns (string) {
    return name;
  }

  /**
   * @notice Gets the class of the league
   * @return UTF-8 encoded class of league
   */
  function getClass() external view returns (string) {
    return class;
  }

  /**
   * @notice Gets the league details
   * @return IPFS hash with league details
   */
  function getDetails() external view returns (bytes) {
    return details;
  }

  /**
   * @notice Gets the league version (matches LeagueFactory version)
   * @return Version of the league protocol
   */
  function getVersion() external view returns (string) {
    return version;
  }

}
