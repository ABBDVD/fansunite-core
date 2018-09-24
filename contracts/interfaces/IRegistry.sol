pragma solidity ^0.4.24;


/**
 * @title Interface for all FansUnite registry contracts
 */
contract IRegistry {

  /**
   * @notice get the contract address for `_namekey`
   * @param _nameKey is the key for the contract address mapping
   */
  function getAddress(string _nameKey) view public returns(address);

  /**
   * @notice change the contract address for `_namekey` to `_newAddress`
   * @param _nameKey is the key for the contract address mapping
   * @param _newAddress is the new contract address
   */
  function changeAddress(string _nameKey, address _newAddress) public;

}
