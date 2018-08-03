pragma solidity ^0.4.24;

/**
 * @title LeagueLib
 * @dev LeagueLib001 contains structs used in League001
 */
library LeagueLib001 {

  // Fixture struct
  struct Fixture {
    uint id;
    uint[] participants;
    uint startTime;
  }

  // Participant Struct
  struct Participant {
    uint id;
    string name;
    bytes details;
  }

}
