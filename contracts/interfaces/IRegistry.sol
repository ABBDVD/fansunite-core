pragma solidity ^0.4.24;

import "../introspection/ERC165.sol";

/**
 * @title Interface for all FansUnite registry contracts
 */
contract IRegistry {

  /**
   * @notice get the contract address
   * @param _nameKey is the key for the contract address mapping
   */
  function getAddress(string _nameKey) view public returns(address);

  /**
   * @notice change the contract address
   * @param _nameKey is the key for the contract address mapping
   * @param _newAddress is the new contract address
   */
  function changeAddress(string _nameKey, address _newAddress) public;

}
