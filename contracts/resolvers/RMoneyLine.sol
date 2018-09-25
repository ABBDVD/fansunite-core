pragma solidity ^0.4.24;

import "../interfaces/IResolver.sol";
import "./BaseResolver.sol";


/**
 * @title MoneyLine Resolver
 * @dev RMoneyLine is a simple Money line contract
 */
contract RMoneyLine is IResolver, BaseResolver {

  /**
   * @notice Constructor
   * @param _version Base version Resolver supports
   */
  constructor(string _version) public BaseResolver(_version) { }

  /**
   * @notice Returns the Result of a Moneyline bet
   * @param _bWinner bet payload encoded winner participant id (backer's pick)
   * @param _rWinner resolution payload encoded winner participant id (resolution data)
   * @return `1` if backer loses and `2` if backer wins
   */
  function resolve(address _league, uint _fixture, uint _bWinner, uint[] _scores)
    external
    pure
    returns (uint8)
  {
    return 0;
  }

  /**
   * @notice Check if participant `_winner` is scheduled in fixture `_fixture` in league `_league`
   * @param _league League Address to perform validation for
   * @param _fixture Id of fixture
   * @param _winner Id of participant from bet payload
   * @return `true` if bet payload valid, `false` otherwise
   */
  function validate(address _league, uint _fixture, uint _winner) external view returns (bool) {
    // TODO: pre:Manan => Finish implementation (blocked by League implementation)
    return true;
  }

  /**
   * @notice Gets the signature of the init function
   * @return The init function signature compliant with ABI Specification
   */
  function getInitSignature() external pure returns (string) {
    return "resolve(uint256,uint256)";
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
    return "validate(address,uint256,uint256)";
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
    return "Common MoneyLine Resolver: Betting on who wins the fixture";
  }

  /**
   * @notice Gets the bet type the resolver resolves
   * @return Type of the bet the resolver resolves
   */
  function getType() external view returns (string) {
    return "Moneyline";
  }

  /**
   * @notice Gets the resolver details
   * @return IPFS hash with resolver details
   */
  function getDetails() external view returns (bytes) {
    return new bytes(0);
  }

}
