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

  /**
   * @dev Hashes the raw parameters of a fixture
   * @param _participants Ids of participants in fixture
   * @param _start Start time, unix timestamp (in seconds)
   * @return hash of tightly packed [_participants, _start]
   */
  function hashRawFixture(uint[] _participants, uint _start) internal view returns (bytes32) {
    // NOT EIP 712 Compliant, structs are not outward facing
    return keccak256(abi.encodePacked(_participants, _start));
  }

  /**
   * @dev Hashes the raw parameters of a participant
   * @param _name Name of the participant
   * @return hash of tightly packed `_name`
   */
  function hashRawParticipant(string _name) internal view returns (bytes32) {
    // NOT EIP 712 Compliant, structs are not outward facing
    return keccak256(abi.encodePacked(_name));
  }

}
