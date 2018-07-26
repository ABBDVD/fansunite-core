pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../interfaces/IResolver.sol";


/**
 * @title MoneyLine Resolver
 * @dev TODO pre:Manan - inherit ERC165
 */
contract RMoneyLine is Ownable, IResolver {

  // League versions supported by RMoneyLine
  mapping(string => bool) internal versions;

  // Emit when resolver is validated to support new league version
  event LogSupportVersion(string _version);

  /**
   * @notice Constructor
   * @param _version Base version Resolver supports
   */
  constructor(string _version) public {
    versions[_version] = true;
  }

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
   * @notice Returns the Result of a Moneyline bet
   * @param _bWinner bet payload encoded winner participant id (backer's pick)
   * @param _rWinner resolution payload encoded winner participant id (resolution data)
   * @return 1 if backer loses and 2 if backer wins
   */
  function resolve(uint _bWinner, uint _rWinner) external pure returns (uint8) {
    return _bWinner == _rWinner ? 2 : 1;
  }

  /**
   * @notice Check if participant `_winner` is scheduled in fixture `_fixture` in league `_league`
   * @dev TODO pre:Manan => Finish implementation
   * @param _league League Address to perform validation for
   * @param _fixture Id of fixture
   * @param _winner Id of participant from bet payload
   * @return True if bet payload valid, false otherwise
   */
  function validate(address _league, uint _fixture, uint _winner) external view returns (bool);

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
  function getInitSelector() external view returns (bytes4) {
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
  function getValidatorSelector() external view returns (bytes4) {
    return this.validate.selector;
  }

  /**
   * @notice Checks whether resolver works with a specific league version
   * @param _version League version
   * @return True if resolver supports league version `_version`, false otherwise
   */
  function doesSupportVersion(string _version) external view returns (bool) {
    return versions[_version];
  }

}
