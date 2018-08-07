pragma solidity ^0.4.24;

/**
 * @title Interface for league deployment
 */
contract ILeagueFactory {

  /**
   * @notice deploys the league and adds default resolver modules.
   * @dev Future versions of the factory can attach different resolvers or pass some other parameters.
   * @param _class Class of the league
   * @param _name Name of the league (approved by LeagueRegistry)
   * @param _details Off-chain hash of league details
   * @return Address of the created league contract
   */
  function deployLeague(string _class, string _name, bytes _details)
    external
    returns (address);
}
