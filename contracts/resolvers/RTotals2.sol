pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "../interfaces/IResolver.sol";
import "../leagues/ILeague001.sol";
import "./BaseResolver.sol";

/**
 * @title Totals Resolver
 * @dev RTotals2 is a simple Totals bet type resolver contract
 */
contract RTotals2 is IResolver, BaseResolver {

  using SafeMath for uint;

  uint public TOTAL_DECIMALS = 2;

  /**
   * @notice Constructor
   * @param _version Base version Resolver supports
   */
  constructor(string _version) public BaseResolver(_version) { }

  /**
   * @notice Returns the Result of a Totals bet
   * @param _league Address of league
   * @param _fixture Id of fixture
   * @param _bParticipant bet payload encoded, participant id (backer's pick) or 0 (for draw)
   * @param _bTotal bet payload encoded, total score
   * @param _bOver bey payload encoded, `true` if score should be over `_bTotal`, `false` otherwise
   * @param _rScores Array of scores, matching index as fixture.participants (resolution data)
   * @return Bet outcome compliant with IResolver Specs [1,2]
   */
  function resolve(
    address _league,
    uint _fixture,
    uint _bParticipant,
    uint _bTotal,
    bool _bOver,
    uint[] _rScores
  )
    external
    view
    returns (uint)
  {
    // TODO HIGHLY experimental, do NOT use in production
    uint _score;

    var (, _participants,) = ILeague001(_league).getFixture(_fixture);

    if (_bParticipant == 0) _score = _rScores[0] + _rScores[1];
    else if (_participants[0] == _bParticipant) _score = _rScores[0];
    else _score = _rScores[1];

    _score = _score * 10 ** TOTAL_DECIMALS;

    int _x = int(_bTotal) - int(_score);

    if (_bOver) {
      if (_x == 25) return 4;
      if (_x == -25) return 3;
      if (_x > 25) return 2;
      if (_x < -25) return 1;
    } else {
      if (_x == 25) return 3;
      if (_x == -25) return 4;
      if (_x > 25) return 1;
      if (_x < -25) return 2;
    }

    return 5;
  }

  /**
   * @notice Checks if `_participant` is scheduled in fixture and if `_total` is multiple of 25
   * @param _league League Address to perform validation for
   * @param _fixture Id of fixture
   * @param _participant Id of participant from bet payload, 0 if team totals
   * @param _total Total score from bet payload
   * @return `true` if bet payload valid, `false` otherwise
   */
  function validate(address _league, uint _fixture, uint _participant, uint _total, bool /*_over*/)
    external
    view
    returns (bool)
  {
    bool _isPScheduled = ILeague001(_league).isParticipantScheduled(_participant, _fixture);
    return _participant == 0 || _isPScheduled || _total.mod(25) == 0;
  }

  /**
   * @notice Gets the signature of the init function
   * @return The init function signature compliant with ABI Specification
   */
  function getInitSignature() external pure returns (string) {
    return "resolve(address,uint256,uint256,uint256,bool,uint256[])";
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
    return "validate(address,uint256,uint256,uint256,bool)";
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
    return "Common Totals Resolver for two player leagues: Betting on the outcome of total scores";
  }

  /**
   * @notice Gets the bet type the resolver resolves
   * @return Type of the bet the resolver resolves
   */
  function getType() external view returns (string) {
    return "Totals2";
  }

  /**
   * @notice Gets the resolver details
   * @return IPFS hash with resolver details
   */
  function getDetails() external view returns (bytes) {
    return new bytes(0);
  }

}
