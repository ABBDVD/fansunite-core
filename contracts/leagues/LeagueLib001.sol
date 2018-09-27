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
    uint start;
  }

  // Participant Struct
  struct Participant {
    uint id;
    string name;
    bytes details;
  }

  function hashRawFixture(uint[] _participants, uint _start) internal view returns (bytes32) {
    // NOT EIP 712 Compliant, structs are not outward facing
    bytes32 _hash = keccak256(
      abi.encodePacked(
        _participants,
        _start
      )
    );

    return _hash;
  }

}
