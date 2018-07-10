pragma solidity ^0.4.24;

/**
 * @title Interface for league deployment
 */
contract ILeagueFactory {

  /**
   * @notice deploys the league and adds default resolver modules.
   * Future versions of the factory can attach different modules or pass some other parameters.
   */
  function deployLeague(string _name, string _symbol, string _leagueDetails) external returns (address);
}
