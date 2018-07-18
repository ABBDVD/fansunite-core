pragma solidity ^0.4.24;

/**
 * @title Interface for league deployment
 */
contract ILeagueFactory {

  /**
   * @notice deploys the league and adds default resolver modules.
   * Future versions of the factory can attach different modules or pass some other parameters.
   * @param _name Name of the league (approved by LeagueRegistry)
   * @param _leagueDetails off-line details of the league
   */
  function deployLeague(byte[64] _name, bytes32 _leagueDetails) external returns (address);
}
