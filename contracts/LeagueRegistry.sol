pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./interfaces/ILeagueRegistry.sol";


/**
 * @title LeagueRegistry Contract
 * @notice Only FansUnite can add new leagues
 * @dev LeagueRegistry stores all the league contracts on the FansUnite Platform
 * @dev LeagueRegistry stores addresses to versioned factories responsible for deploying new
 *  league contracts
 */
contract LeagueRegistry is Ownable, ILeagueRegistry {

  /**
   * @notice Creates a new league class
   * @param _class Class of the league (eg. tennis)
   */
  function createClass(string _class) external onlyOwner;

  /**
   * @notice Creates a new League Contract and saves it to the registry
   * @param _class Class of the league (eg. tennis)
   * @param _name Name of the League (eg. Shanghai Masters)
   * @param _leagueDetails Off-chain details of the league (eg. IPFS hash)
   */
  function createLeague(string _class, string _name, bytes _leagueDetails) external onlyOwner;

  /**
   * @notice Updates leagueFactoryVersion to `_version` and factoryAddress to `_leagueFactory`
   * @param _leagueFactory Address of the LeagueFactory for `_version`
   * @param _version Version string for leagueFactory
   */
  function setLeagueFactoryVersion(address _leagueFactory, string _version) external onlyOwner;

  /**
   * @notice Gets Class with id `_id`
   * @param _id id of the class
   * @return Class id
   * @return Class name
   * @return Ids of league in class
   */
  function getClass(uint _id) external view returns (uint, string, uint[]);

  /**
   * @notice Gets league with id `_id`
   * @param _id id of the league
   * @return League id
   * @return League address
   * @return League name
   * @return League details (hash)
   */
  function getLeague(uint _id) external view returns (uint, address, string, bytes);

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
