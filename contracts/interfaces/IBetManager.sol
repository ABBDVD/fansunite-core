pragma solidity ^0.4.24;

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
   *  (0 = Typed, 1 = Geth, 2 = Trezor) {mode}{v}{r}{s}.
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
   * @param _id Keccak-256 hash of the bet struct, along with chainId and nonce
   */
  function claimBet(bytes32 _id) external;

  /**
   * @notice Gets the bet result
   * @param _id Keccak-256 hash of the bet struct, along with chainId and nonce
   * @return Result of bet (refer to IResolver for specifics of the return type)
   */
  function getResult(bytes32 _id) external view returns (uint8);

  /**
   * @notice Gets all the bet identifiers for address `_subject`
   * @param _subject Address of a layer or backer
   * @return Returns list of bet ids for backer / layer `_subject`
   */
  function getBetsBySubject(address _subject) external view returns (bytes32[]);

  /**
   * @notice Gets subjects, params and payload associated with bet `_id`
   * @param _id Keccak-256 hash of the bet struct, along with chainId and nonce
   * @return Subjects associated with `_id` [backer, layer, token, league, resolver]
   * @return Params associated with `_id` [backerStake, expiration, fixture, odds]
   * @return Payload associated with `_id`
   */
  function getBet(bytes32 _id) external view returns (address[5], uint[4], bytes);

}
