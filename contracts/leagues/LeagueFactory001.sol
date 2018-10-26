pragma solidity 0.4.24;

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
   * @param _registry Address of the registry contract
   * @param _participantsPerFixture Number of participants allowed per fixture
   * @param _owner Owner of the league (FansUnite)
   * @return Address of the created league contract
   */
  function deployLeague(
    string _class,
    string _name,
    address _registry,
    uint _participantsPerFixture,
    address _owner
  )
    external
    view
    returns (address)
  {
    League _league = new League(_class, _name, _registry, _participantsPerFixture);
    _league.transferOwnership(_owner);
    return _league;
  }

}
