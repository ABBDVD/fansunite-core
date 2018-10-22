pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../interfaces/IRegistry.sol";

/**
 * @title RegistryAccessible Contract
 * @dev The RegistryAccessible stores the FansUnite's registry address and provides basic
 *  functionality to upgrade the address
 */
contract RegistryAccessible is Ownable {

  // Address of the registry contract
  IRegistry internal registry;

  /*
   * @notice Constructor
   * @param _registry Address of the registry contract
   */
  constructor(address _registry) public {
    registry = IRegistry(_registry);
  }

  /**
   * @notice Gets registry contract address
   * @return Address of the FansUnite Registry contract
   */
  function getRegistryContract() public view returns (address) {
    return registry;
  }
}
