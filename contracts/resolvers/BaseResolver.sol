pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "../interfaces/ILeague.sol";


/**
 * @title BaseResolver
 * @dev (Abstract) BaseResolver implements functionality that all resolvers will need
 */
contract BaseResolver is Ownable {

  // League versions supported by RMoneyLine
  mapping(string => bool) internal versions;

  // Emit when resolver is validated to support new league version
  event LogSupportVersion(string _version);


  /**
   * @notice Constructor
   * @param _version Base version Resolver supports
   */
  constructor(string _version) public { versions[_version] = true; }

  /**
   * @notice Support league version `_version`
   * @param _version League version
   */
  function supportVersion(string _version) external onlyOwner {
    require(versions[_version] == false, "Resolver supports version already");
    versions[_version] = true;

    emit LogSupportVersion(_version);
  }

  /**
   * @notice Checks whether resolver supports a specific league
   * @param _league Address of league contract
   * @return `true` if resolver supports league `_league`, `false` otherwise
   */
  function doesSupportLeague(address _league) external view returns (bool) {
    string memory _version = ILeague(_league).getVersion();
    // TODO other sanity checks

    return versions[_version];
  }

}
