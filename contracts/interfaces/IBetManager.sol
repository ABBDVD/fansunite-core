pragma solidity 0.4.24;

/**
 * @title Interface for Bet Manger Contract
 */
contract IBetManager {

  /**
   * @notice Submits a bet
   * @param _subjects Subjects associated with bet [backer, layer, token, league, resolver]
   * @param _params Parameters associated with bet [backerStake, fixture, odds, expiration]
   * @param _nonce Nonce, to ensure hash uniqueness
   * @param _payload Payload for resolver
   * @param _signature ECDSA signature along with the mode
   *  (0 = Typed, 1 = Geth) {mode}{v}{r}{s}.
   */
  function submitBet(
    address[5] _subjects,
    uint[4] _params,
    uint _nonce,
    bytes _payload,
    bytes _signature
  )
    external;

  /**
   * @notice Claims a bet, transfers tokens and fees based on fixture resolution
   * @param _subjects Subjects associated with bet
   * @param _params Parameters associated with bet
   * @param _nonce Nonce, to ensure hash uniqueness
   * @param _payload Payload for resolver
   */
  function claimBet(address[5] _subjects, uint[4] _params, uint _nonce, bytes _payload) external;

  /**
   * @notice Gets the bet result
   * @param _league Address of league
   * @param _resolver Address of resolver
   * @param _fixture Id of fixture
   * @param _payload Payload for resolver
   * @return uint between 1 and 5 (check IResolver for details) or 0 (for unresolved fixtures)
   */
  function getResult(address _league, address _resolver, uint _fixture, bytes _payload)
    external
    view
    returns (uint);

  /**
   * @notice Gets all the bet identifiers for address `_subject`
   * @param _subject Address of a layer or backer
   * @return Returns list of bet ids for backer / layer `_subject`
   */
  function getBetsBySubject(address _subject) external view returns (bytes32[]);

}
