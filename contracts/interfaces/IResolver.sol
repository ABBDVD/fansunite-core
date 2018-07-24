pragma solidity ^0.4.24;


/**
 * @title Interface for all FansUnite Resolver contracts
 */
contract IResolver {

  /**
   * @notice Gets the signature of the init function
   * @return The function signature compliant with ABI Specification
   */
  function getInitSignature() external view returns (string);

  /**
   * @notice Gets the selector of the init function
   * @dev Probably don't need this function as getInitSignature can be used to compute selector
   * @return Selector for the init function
   */
  function getInitSelector() external pure returns (bytes4);

}
