pragma solidity ^0.4.24;

interface ERC165 {

  /// @notice Query if a contract implements an interface
  /// @param _interfaceID The interface identifier, as specified in ERC-165
  /// @dev This function uses less than 30,000 gas.
  /// @return `true` if the contract implements `_interfaceID` and
  ///  `_interfaceID` is not 0xffffffff, `false` otherwise
  function supportsInterface(bytes4 _interfaceID) external view returns (bool);
}
