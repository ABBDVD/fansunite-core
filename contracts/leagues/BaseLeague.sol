pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";


/**
 * @title League Contract
 */
contract BaseLeague is Ownable {

  // Version of the league
  string internal version = "0.0.1";
  // Name of the league
  string internal name;
  // Class to which the league belongs
  string internal class;
  // Hash of league details stored off-chain (eg. IPFS multihash)
  bytes internal details;

  // Address of the resolution contract (contact responsible for consensus / oracles)
  address internal consensus;

  // Emit when a Fixture is resolved, by resolver
  event LogConsensusContractUpdated(address indexed _old, address indexed _new);

  /**
   * @notice Constructor
   * @param _class Class of league
   * @param _name Name of league
   * @param _details Off-chain hash of league details
   */
  constructor(string _class, string _name, bytes _details, address _consensus) public {
    name = _name;
    class = _class;
    details = _details;
    consensus = _consensus;
  }

  /**
   * @dev Throw is called by any account other than consensus
   */
  modifier onlyConsensus() {
    require(msg.sender == consensus);
    _;
  }

  /**
   * @notice Sets consensus contract of the league to `_consensus`
   * @dev Only consensus contract will be able to call pushResolution
   * @param _consensus address of the consensus contract
   */
  function updateConsensusContract(address _consensus) external onlyOwner {
    require(_consensus != address(0), "Consensus contract cannot be set to 0x");
    address _old = consensus;
    consensus = _consensus;
    emit LogConsensusContractUpdated(_old, _consensus);
  }

  /**
   * @notice Sets league details
   * @param _details Off-chain hash of league details
   */
  function setDetails(bytes _details) external onlyOwner {
    details = _details;
  }

  /**
   * @notice Gets the name of the league
   * @return UTF-8 encoded name of league
   */
  function getName() external view returns (string) {
    return name;
  }

  /**
   * @notice Gets the class of the league
   * @return UTF-8 encoded class of league
   */
  function getClass() external view returns (string) {
    return class;
  }

  /**
   * @notice Gets the league details
   * @return IPFS hash with league details
   */
  function getDetails() external view returns (bytes) {
    return details;
  }

  /**
   * @notice Gets the league version (matches LeagueFactory version)
   * @return Version of the league protocol
   */
  function getVersion() external view returns (string) {
    return version;
  }

}
