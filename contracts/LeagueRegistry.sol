pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "./interfaces/ILeagueRegistry.sol";
import "./interfaces/ILeague.sol";
import "./interfaces/ILeagueFactory.sol";

import "./utils/RegistryAccessible.sol";



/**
 * @title LeagueRegistry Contract
 * @notice Only FansUnite can add new leagues
 * @dev LeagueRegistry stores all the league contracts on the FansUnite Platform
 * @dev LeagueRegistry stores addresses to versioned factories responsible for deploying new
 *  league contracts
 */
contract LeagueRegistry is Ownable, ILeagueRegistry, RegistryAccessible {

  // Factory version
  string internal factoryVersion; // TODO Manan => Edge case - version not set
  // Map of factory version to factory address
  mapping(string => address) internal factories;
  // Corresponds to `true` if class supported, false otherwise
  mapping(string => bool) internal supportedClasses;
  // List of all classes
  string[] internal classes;
  // Map of classes to corresponding league addresses
  mapping(string => address[]) internal leagues;
  // Evaluates to `true` if league supported, `false` otherwise
  mapping(address => bool) internal supportedLeagues;
  // Mapping of class to number of participants per fixture in leagues of class
  mapping(string => uint) internal participantsPerFixture;

  // Emit when new class added
  event LogClassCreated(string _class);
  // Emit when new league added
  event LogLeagueAdded(address indexed _league, string _class, string _name);
  // Emit when Factory updated
  event LogFactoryUpdated(string _version, address indexed _factory);
  // Emit when version updated
  event LogFactoryVersionUpdated(string _version);

  /**
   * @notice Constructor
   * @param _registry Address of the Registry contract
   */
  constructor(address _registry) public RegistryAccessible(_registry) {

  }

  /**
   * @notice Creates a new league class
   * @param _class Class of the league (eg. tennis)
   * @param _participantsPerFixture Number of participants per fixture in leagues of class `_class`
   */
  function createClass(string _class, uint _participantsPerFixture) external onlyOwner {
    require(supportedClasses[_class] == false, "Registry already supports class");
    supportedClasses[_class] = true;
    participantsPerFixture[_class] = _participantsPerFixture;
    classes.push(_class);

    emit LogClassCreated(_class);
  }

  /**
   * @notice Creates a new League Contract and saves it to the registry
   * @param _class Class of the league (eg. tennis)
   * @param _name Name of the League (eg. Shanghai Masters)
   */
  function createLeague(string _class, string _name) external onlyOwner {
    require(supportedClasses[_class] == true, "Class not supported by Registry");

    ILeagueFactory _factory = ILeagueFactory(factories[factoryVersion]);
    address _league = _factory.deployLeague(
      _class,
      _name,
      registry,
      participantsPerFixture[_class],
      msg.sender
    );

    leagues[_class].push(_league);
    supportedLeagues[_league] = true;

    emit LogLeagueAdded(_league, _class, _name);
  }

  /**
 * @notice Upsert version `_version` to correspond factoryAddress `_leagueFactory`
 * @param _leagueFactory Address of the LeagueFactory for `_version`
 * @param _version Version string for leagueFactory
 */
  function addFactory(address _leagueFactory, string _version) external onlyOwner {
    factories[_version] = _leagueFactory;
    emit LogFactoryUpdated(_version, _leagueFactory);
  }

  /**
   * @notice Updates factoryVersion to `_version` if supported
   * @param _version Version string for leagueFactory
   */
  function setFactoryVersion(string _version) external onlyOwner {
    require(factories[_version] != address(0), "Version is not supported by Registry");
    factoryVersion = _version;
    emit LogFactoryVersionUpdated(_version);
  }

  /**
   * @notice Gets Class with name `_class`
   * @param _class Class name
   * @return Class name
   * @return Address of all league in class
   */
  function getClass(string _class) external view returns (string, address[]) {
    require(supportedClasses[_class] == true, "Class not supported by Registry");
    return (_class, leagues[_class]);
  }

  /**
   * @notice Gets league with id `_id`
   * @param _league Address of the league
   * @return League address
   * @return League name
   * @return League details (hash)
   */
  function getLeague(address _league) external view returns (address, string, bytes) {
    ILeague _l = ILeague(_league);
    return (_league, _l.getName(), _l.getDetails());
  }

  /**
   * @notice Gets the current version used to deploy new leagues contracts
   * @return Current factory version
   */
  function getFactoryVersion() external view returns (string) {
    return factoryVersion;
  }

  /**
   * @notice Gets LeagueFactory contract address for version `_version`
   * @dev fails if `_version` does not match any
   * @param _version Version string for leagueFactory
   * @return Address of the LeagueFactory contract for version `_version`
   */
  function getFactory(string _version) external view returns (address) {
    require(factories[_version] != address(0), "Version is not supported by Registry");
    return factories[_version];
  }

  /**
   * @notice Checks if league with address `_league` is registered with FansUnite
   * @param _league address of the league
   * @return `true` if `_league` is registered with FansUnite, `false` otherwise
   */
  function isLeagueRegistered(address _league) external view returns (bool) {
    return supportedLeagues[_league];
  }

  /**
   * @notice Checks if class `_class` is supported by FansUnite
   * @param _class Any class
   * @return `true` if `_class` is supported by FansUnite, `false` otherwise
   */
  function isClassSupported(string _class) external view returns (bool) {
    return supportedClasses[_class];
  }

}
