pragma solidity ^0.4.24;


/**
 * @title Interface for all FansUnite Resolver contracts
 * @dev Resolvers MUST adhere to the following requirements:
 *     1. The resolver MUST implement init function (the init function is responsible for
 *        resolving the bet, given the bet payload and resolution payload)
 *     2. The getInitSignature function MUST return the init function's signature and it MUST
 *        comply with ABI Specification
 *     3. The getInitSelector function MUST return the init function's selector
 *     4. The init function MUST consume bet payload encoded function parameters BEFORE consuming
 *        resolution payload encoded function parameters
 *     5. The return value of init function MUST be of type uint8 and one of the following:
 *        + 1 if backer loses bet
 *        + 2 if backer wins bet
 *        + 3 if backer half wins bet
 *        + 4 if backer half loses bet
 *        + 5 if results in a push
 *
 *     6. The resolver MUST implement validator function (the function is responsible for
 *        validating bet payload on bet submission)
 *     7. The getValidatorSignature function MUST return the validator function's signature and it
 *        MUST comply with ABI Specification
 *     8. The getValidatorSelector MUST return the validator function's selector
 *     9. If the init function consumes n bet payload encoded arguments, the validator MUST
 *         consume n + 2 arguments. First, of type address and second of type uint256. The
 *         BetManager would send the league address and event id for bet payload validation.
 *         Following the two parameters, the validator function MUST consume the n bet payload
 *         encoded arguments in the exact same order as that in init.
 *     10. The resolver function MUST return a boolean, true if valid bet payload, false otherwise
 */
contract IResolver {

  /**
   * @notice Support league version `_version`
   * @param _version League version
   */
  function supportVersion(string _version) external;

  /**
   * @notice Gets the signature of the init function
   * @return The init function signature compliant with ABI Specification
   */
  function getInitSignature() external pure returns (string);

  /**
   * @notice Gets the selector of the init function
   * @dev Probably don't need this function as getInitSignature can be used to compute selector
   * @return Selector for the init function
   */
  function getInitSelector() external view returns (bytes4);

  /**
   * @notice Gets the signature of the validator function
   * @return The validator function signature compliant with ABI Specification
   */
  function getValidatorSignature() external pure returns (string);

  /**
   * @notice Gets the selector of the validator function
   * @dev Probably don't need this function as getValidatorSignature can be used to compute selector
   * @return Selector for the validator function
   */
  function getValidatorSelector() external view returns (bytes4);

  /**
   * @notice Checks whether resolver works with a specific league version
   * @param _version League version
   * @return `true` if resolver supports league version `_version`, `false` otherwise
   */
  function doesSupportVersion(string _version) external view returns (bool);

}
