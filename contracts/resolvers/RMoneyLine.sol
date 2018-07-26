pragma solidity ^0.4.24;


import "../interfaces/IResolver.sol";


/**
 * @title MoneyLine Resolver
 * @dev TODO
 */
contract RMoneyLine is IResolver {

  // League versions supported by RMoneyLine
  string[] public versions;

  /**
   * @notice Support league version `_version`
   * @dev TODO: Manan => FansUnite only? Owner only?
   * @dev TODO: Manan => Emit event
   * @param _version League version
   */
  function supportVersion(string _version) external {
    versions.push(_version);
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
   * @dev TODO: Manan => Finish implementation
   * @param _version League version
   * @return True if resolver supports league version `_version`, false otherwise
   */
  function doesSupportVersion(string _version) external view returns (bool);

  /**
   * @notice Returns the Result of a Moneyline bet
   * @param _bWinner bet payload encoded winner participant id (backer's pick)
   * @param _rWinner resolution payload encoded winner participant id (resolution data)
   * @return 1 if backer loses and 2 if backer wins
   */
  function resolve(uint _bWinner, uint _rWinner) external pure returns (uint8) {
    if (_bWinner == _rWinner)
      return 2;
    return 1;
  }

  /**
   * @notice Check if participant `_winner` is scheduled in fixture `_fixture` in league `_league`
   * @dev TODO: Manan => Finish implementation
   * @param _league League Address to perform validation for
   * @param _fixture Id of fixture
   * @param _winner Id of participant from bet payload
   * @return True if bet payload valid, false otherwise
   */
  function validate(address _league, uint _fixture, uint _winner) external view returns (bool);

}
