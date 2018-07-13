pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import "./ILeague.sol";


/**
 * @title Interface for the fansunite league registry contract
 * @dev LeagueRegistry stores all the league contracts on the FansUnite Platform
 * @dev LeagueRegistry stores addresses to versioned LeagueFactory contracts to deploy new leagues
 */
contract ILeagueRegistry {

  bytes32 public leagueFactoryVersion = "0.0.1";
  mapping (bytes32 => address) public leagueFactories;


  /**
   * @notice Creates a new League Contract and saves it to the registry
   * @param _class Class of the league (eg. tennis)
   * @param _name Name of the League (eg. Shanghai Masters)
   * @param _leagueDetails off-chain details of the league (eg. IPFS hash)
   */
  function createLeague(string _class, string _name, string _leagueDetails) public;

  /**
   * @notice Updates leagueFactoryVersion and the corresponding factory address
   * @param _leagueFactory Address of the LeagueFactory for `_version`
   * @param _version Version string for leagueFactory
   */
  function setLeagueFactoryVersion(address _leagueFactory, bytes32 _version) public;

  /**
   * @notice Get league addresses by class
   * @param _class Class of the leagues
   * @return address[]
   */
  function getLeagueAddresses(string _class) public view returns (address[]);

  /**
   * @notice Get league address by name
   * @param _name Name of the league
   * @return address
   */
  function getLeagueAddress(string _name) public view returns (address);

  /**
   * @notice Get classes supported by FansUnite
   * @return string[]
   */
  function getClasses() public view returns (string[]);

  /**
   * @notice Check if league is registered
   * @param _name Name of the league
   * @return bool
   */
  function isRegisteredLeague(address _name) public view returns (bool);

  /**
   * @notice Check if class is registered
   * @param _class Any class
   * @return bool
   */
  function isRegisteredClass(address _class) public view returns (bool);
}
