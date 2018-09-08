pragma solidity ^0.4.24;


/**
 * @title Interface for the fansunite league registry contract
 * @dev LeagueRegistry stores all the league contracts on the FansUnite Platform
 * @dev LeagueRegistry stores addresses to versioned factories responsible for deploying new
 *  league contracts
 */
contract ILeagueRegistry {

  /**
   * @notice Creates a new league class
   * @param _class Class of the league (eg. tennis)
   */
  function createClass(string _class) external;

  /**
   * @notice Creates a new League Contract and saves it to the registry
   * @param _class Class of the league (eg. tennis)
   * @param _name Name of the League (eg. Shanghai Masters)
   * @param _leagueDetails Off-chain details of the league (eg. IPFS hash)
   */
  function createLeague(string _class, string _name, bytes _leagueDetails) external;

  /**
   * @notice Upsert version `_version` to correspond factoryAddress `_leagueFactory`
   * @param _leagueFactory Address of the LeagueFactory for `_version`
   * @param _version Version string for leagueFactory
   */
  function addFactory(address _leagueFactory, string _version) external;

  /**
   * @notice Updates leagueFactoryVersion to `_version` if supported
   * @param _version Version string for leagueFactory
   */
  function setFactoryVersion(string _version) external;

  /**
   * @notice Gets Class with name `_class`
   * @param _class Class name
   * @return Class name
   * @return Address of all leagues in class
   */
  function getClass(string _class) external view returns (string, address[]);

  /**
   * @notice Gets league with id `_id`
   * @param _league Address of the league
   * @return League address
   * @return League name
   * @return League details (hash)
   */
  function getLeague(address _league) external view returns (address, string, bytes);

  /**
   * @notice Gets the current version used to deploy new leagues contracts
   * @return Current factory version
   */
  function getFactoryVersion() external view returns (string);

  /**
   * @notice Gets LeagueFactory contract address for version `_version`
   * @dev fails if `_version` does not match any
   * @param _version Version string for leagueFactory
   * @return Address of the LeagueFactory contract for version `_version`
   */
  function getFactory(string _version) external view returns (address);

  /**
   * @notice Checks if league with address `_league` is registered with FansUnite
   * @param _league address of the league
   * @return `true` if `_league` is registered with FansUnite, `false` otherwise
   */
  function isLeagueRegistered(address _league) external view returns (bool);

  /**
   * @notice Checks if class `_class` is supported by FansUnite
   * @param _class Any class
   * @return `true` if `_class` is supported by FansUnite, `false` otherwise
   */
  function isClassSupported(string _class) external view returns (bool);
}
