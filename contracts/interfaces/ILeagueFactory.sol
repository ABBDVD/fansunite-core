pragma solidity ^0.4.24;

/**
 * @title Interface for league deployment
 */
contract ILeagueFactory {

  /**
   * @notice deploys the league and adds default resolver modules.
   * Future versions of the factory can attach different modules or pass some other parameters.
   */
  function deployLeague(byte[64] _name, string _leagueDetails) external returns (address);
}
