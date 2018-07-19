pragma solidity ^0.4.24;

import "./ILeague.sol";


/**
 * @title Interface for the fansunite league registry contract
 * @dev LeagueRegistry stores all the league contracts on the FansUnite Platform
 * @dev LeagueRegistry stores addresses to versioned factories responsible for deploying new league contracts
 */
contract ILeagueRegistry {

  /**
   * @notice Creates a new league class
   * @param _class Class of the league (eg. tennis)
   */
  function createClass(bytes32 _class) external;

  /**
   * @notice Creates a new League Contract and saves it to the registry
   * @param _class Class of the league (eg. tennis)
   * @param _name Name of the League (eg. Shanghai Masters)
   * @param _leagueDetails off-chain details of the league (eg. IPFS hash)
   */
  function createLeague(bytes32 _class, byte[64] _name, bytes32 _leagueDetails) external;

  /**
   * @notice Updates leagueFactoryVersion to `_version` and factoryAddress to `_leagueFactory`
   * @param _leagueFactory Address of the LeagueFactory for `_version`
   * @param _version Version string for leagueFactory
   */
  function setLeagueFactoryVersion(address _leagueFactory, bytes32 _version) external;

  /**
   * @notice Get the current version used to deploy new leagues contracts
   * @return current LeagueFactory version
   */
  function getFactoryVersion() external view returns (bytes32);

  /**
   * @notice Get LeagueFactory contract address for version `_version`
   * @param _version Version string for leagueFactory
   * @return address of the LeagueFactory contract for version `_version`
   */
  function getFactory(bytes32 _version) external view returns (address);

  /**
   * @notice Get all leagues in `_class`
   * @param _class Class of the leagues
   * @return leagueIds, addresses, names and details for all leagues in `_class`
   */
  function getLeagues(bytes32 _class) external view returns (uint[], address[], byte[64][], bytes32[]);

  /**
   * @notice Get league by `_id`
   * @param _id id of the league
   * @return leagueId, address, name and details for league with id `_id`
   */
  function getLeague(uint _id) external view returns (uint, address, byte[64], bytes32);

  /**
   * @notice Get classes supported by FansUnite
   * @return bytes32[] all classes on the FansUnite platform
   */
  function getClasses() external view returns (bytes32[]);

  /**
   * @notice Check if league with address `_leagueAddress` is registered with FansUnite
   * @param _leagueAddress address of the league
   * @return true if `_leagueAddress` is registered with FansUnite, false otherwise
   */
  function isLeagueRegistered(address _leagueAddress) external view returns (bool);

  /**
   * @notice Check if class `_class` is supported by FansUnite
   * @param _class Any class
   * @return true if `_class` is supported by FansUnite, false otherwise
   */
  function isClassSupported(bytes32 _class) external view returns (bool);
}
