pragma solidity ^0.4.24;

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

  // Emit when Registry contract updated
  event LogRegistryUpdated(address indexed _old, address indexed _new);

  /**
   * @notice Updates registry contract address to `_reg`
   * @param _reg Address of the FansUnite Registry contract
   */
  function setRegistryContract(address _reg) public onlyOwner {
    require(_reg != address(0), "Registry address cannot be 0x");
    address _old = registry;
    registry = IRegistry(_reg);
    emit LogRegistryUpdated(_old, _reg);
  }

  /**
   * @notice Gets registry contract address
   * @return Address of the FansUnite Registry contract
   */
  function getRegistryContract() public view returns (address) {
    return registry;
  }
}
