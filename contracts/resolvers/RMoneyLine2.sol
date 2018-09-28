pragma solidity ^0.4.24;

import "../interfaces/IResolver.sol";
import { ILeague001 as ILeague } from "../leagues/ILeague001.sol";

import "./BaseResolver.sol";


/**
 * @title MoneyLine Resolver
 * @dev RMoneyLine is a simple Money line contract
 */
contract RMoneyLine2 is IResolver, BaseResolver {

  /**
   * @notice Constructor
   * @param _version Base version Resolver supports
   */
  constructor(string _version) public BaseResolver(_version) { }

  /**
   * @notice Returns the Result of a Moneyline bet
   * @param _league Address of league
   * @param _fixture Id of fixture
   * @param _bWinner bet payload encoded winner participant id (backer's pick) or 0 (for draw)
   * @param _scores Array of scores, matching index as fixture.participants (resolution data)
   * @return `1` if backer loses and `2` if backer wins
   */
  function resolve(address _league, uint _fixture, uint _bWinner, uint[] _scores)
    external
    view
    returns (uint)
  {
    var (, _participants,) = ILeague(_league).getFixture(_fixture);

    if (_bWinner == 0)
      return _scores[0] == _scores[1] ? 2 : 1;

    uint _i = _participants[0] == _bWinner ? 0 : 1;
    return _scores[_i] > _scores[1 - _i] ? 2 : 1;
  }

  /**
   * @notice Check if participant `_winner` is scheduled in fixture `_fixture` in league `_league`
   * @param _league League Address to perform validation for
   * @param _fixture Id of fixture
   * @param _winner Id of participant from bet payload
   * @return `true` if bet payload valid, `false` otherwise
   */
  function validate(address _league, uint _fixture, uint _winner) external view returns (bool) {
    return _winner == 0 || ILeague(_league).isParticipantScheduled(_winner, _fixture);
  }

  /**
   * @notice Gets the signature of the init function
   * @return The init function signature compliant with ABI Specification
   */
  function getInitSignature() external pure returns (string) {
    return "resolve(address,uint256,uint256,uint256[])";
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
