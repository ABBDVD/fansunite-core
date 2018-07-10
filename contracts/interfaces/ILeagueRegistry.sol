pragma solidity ^0.4.24;

import "./ILeague.sol";

/**
 * @title Interface for the fansunite league registry contract
 * @dev LeagueRegistry stores all the league contracts on the FansUnite Platform
 * @dev LeagueRegistry stores addresses to versioned LeagueFactory contracts to deploy new leagues
 */
contract ILeagueRegistry {

  bytes32 public leagueFactoryVersion = "0.0.1";

  // version to LeagueFactory
  mapping (bytes32 => address) public leagueFactories;

  // Symbol/Name to league address: TODO - yet to formalize
  mapping(string => address) leagues;

  /**
   * @notice Creates a new League Contract and saves it to the registry
   * @param _name Name of the League
   * @param _symbol symbol of the league token
   * @param _leagueDetails off-chain details of the league
   */
  function createLeague(string _name, string _symbol, string _leagueDetails) public;

  function setLeagueFactoryVersion(address _leagueFactory, bytes32 _version) public;

  /**
   * @notice Get league address by symbol
   * @param _symbol Symbol of the league
   * @return address
   */
  function getLeagueAddress(string _symbol) public view returns (address);

  /**
  * @notice Check if league is registered
  * @param _leagueAddress Address of the league
  * @return bool
  */
  function isRegisteredLeague(address _leagueAddress) public view returns (bool);
}
