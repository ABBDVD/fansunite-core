pragma solidity ^0.4.24;

import "../../contracts/interfaces/IResolver.sol";
import "../../contracts/resolvers/BaseResolver.sol";


/**
 * @title Mock Resolver
 * @dev MockResolver is a resolver contract for testing the bet manager
 */
contract MockResolver is IResolver, BaseResolver {

  /**
   * @notice Constructor
   * @param _version Base version Resolver supports
   */
  constructor(string _version) public BaseResolver(_version) { }

  /**
   * @notice Simply returns the value that is provided
   * @param _result bet payload encoded result
   * @return `1` if backer loses, `2` if backer wins, `3` if backer half wins, `4` if backer half loses, `5` if push
   */
  function resolve(uint8 _result) external pure returns (uint8) {
    return _result;
  }

  /**
   * @notice Check if participant `_winner` is scheduled in fixture `_fixture` in league `_league`
   * @param _league League Address to perform validation for
   * @param _fixture Id of fixture
   * @param _result winning result
   * @return `true` if bet payload valid, `false` otherwise
   */
  function validate(address _league, uint _fixture, uint8 _result) external view returns (bool) {
    return _result >= 1 && _result <= 5;
//    return true;
  }

  /**
   * @notice Gets the signature of the init function
   * @return The init function signature compliant with ABI Specification
   */
  function getInitSignature() external pure returns (string) {
    return "resolve(uint8)";
  }

  /**
   * @notice Gets the selector of the init function
   * @dev Probably don't need this function as getInitSignature can be used to compute selector
   * @return Selector for the init function
   */
  function getInitSelector() external pure returns (bytes4) {
    return this.resolve.selector;
  }

  /**
   * @notice Gets the signature of the validator function
   * @return The validator function signature compliant with ABI Specification
   */
  function getValidatorSignature() external pure returns (string) {
    return "validate(address,uint256,uint8)";
  }

  /**
   * @notice Gets the selector of the validator function
   * @dev Probably don't need this function as getValidatorSignature can be used to compute selector
   * @return Selector for the validator function
   */
  function getValidatorSelector() external pure returns (bytes4) {
    return this.validate.selector;
  }

  /**
   * @notice Gets Resolver's description
   * @return Description of the resolver
   */
  function getDescription() external view returns (string) {
    return "Mock resolver for testing";
  }

  /**
   * @notice Gets the bet type the resolver resolves
   * @return Type of the bet the resolver resolves
   */
  function getType() external view returns (string) {
    return "Result";
  }

  /**
   * @notice Gets the resolver details
   * @return IPFS hash with resolver details
   */
  function getDetails() external view returns (bytes) {
    return new bytes(0);
  }

}
