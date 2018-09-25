pragma solidity ^0.4.24;

import "../interfaces/ILeagueFactory.sol";
import { League001 as League } from "./League001.sol";


/**
 * @title League Contract
 */
contract LeagueFactory001 is ILeagueFactory {

  /**
   * @notice deploys the league and adds default resolver modules.
   * @dev Future versions of the factory can attach different resolvers or pass some other parameters.
   * @param _class Class of the league
   * @param _name Name of the league (approved by LeagueRegistry)
   * @param _details Off-chain hash of league details
   * @param _registry Address of the registry contract
   * @param _owner Owner of the league (FansUnite)
   * @return Address of the created league contract
   */
  function deployLeague(
    string _class,
    string _name,
    bytes _details,
    address _registry,
    address _owner
  )
    external
    returns (address)
  {
    League _league = new League(_class, _name, "0.0.1", _details, _registry);
    _league.transferOwnership(_owner);
    return _league;
  }

}
