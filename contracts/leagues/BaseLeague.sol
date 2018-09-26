pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../utils/RegistryAccessible.sol";


/**
 * @title League Contract
 */
contract BaseLeague is Ownable, RegistryAccessible {

  // Version of the league
  string internal version;
  // Name of the league
  string internal name;
  // Class to which the league belongs
  string internal class;
  // Hash of league details stored off-chain (eg. IPFS multihash)
  bytes internal details;

  /**
   * @notice Constructor
   * @param _class Class of league
   * @param _name Name of league
   * @param _version Version of league
   * @param _registry Address of the FansUnite Registry Contact
   */
  constructor(string _class, string _name, string _version, address _registry)
    public
    RegistryAccessible(_registry)
  {
    class = _class;
    name = _name;
    version = _version;
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
