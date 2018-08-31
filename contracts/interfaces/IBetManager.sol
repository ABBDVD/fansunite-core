pragma solidity ^0.4.24;

import "../utils/RegistryAccessible.sol";


/**
 * @title Interface for Bet Manger Contract
 */
contract IBetManager is RegistryAccessible {

  /**
   * @notice Submits a bet
   * @param _subjects Subjects associated with bet
   *  [backer, layer, token, feeRecipient, league, resolver]
   * @param _params Parameters associated with bet
   *  [backerStake, backerFee, layerFee, expiration, fixture, odds]
   * @param _layerFill The number of tokens that they layer intends to bet
   * @param _nonce Nonce, to ensure hash uniqueness
   * @param _payload Payload for resolver
   * @param _signature ECDSA signature along with the mode
   *  (0 = Typed (EIP712), 1 = Geth, 2 = Trezor) {mode}{v}{r}{s}.
   */
  function submitBet(
    address[6] _subjects,
    uint[6] _params,
    uint _layerFill,
    uint _nonce,
    bytes _payload,
    bytes _signature
  )
    external;

  /**
   * @notice Claims a bet, transfers tokens and fees based on fixture resolution
   * @param _bet Keccak-256 EIP712 hash of the bet struct
   */
  function claimBet(bytes32 _bet) external;

  /**
   * @notice Cancels bet `_bet`, if not filled
   * @param _bet Keccak-256 EIP712 hash of the bet
   */
  function cancelBet(bytes32 _bet) external;

  /**
   * @notice Gets the bet result
   * @param _bet Keccak-256 EIP712 hash of the bet struct
   * @return Result of bet (refer to IResolver for specifics of the return type)
   */
  function getResult(bytes32 _bet) external view returns (uint8);

  /**
   * @notice Gets all the bet identifiers for address `_subject`
   * @param _subject Address of a layer or backer
   * @return Returns list of bet ids for backer / layer `_subject`
   */
  function getBetsBySubject(address _subject) external view returns (bytes32[]);

  /**
   * @notice Gets subjects, params and payload associated with bet `_bet`
   * @param _bet Keccak-256 EIP712 hash of the bet struct
   * @return Subjects associated with `_bet`
   *  [backer, layer, backerToken, layerToken, feeRecipient, league, resolver]
   * @return Params associated with `_bet`
   *  [backerStake, backerFee, layerFee, expiration, fixture, odds]
   * @return Payload associated with `_bet`
   */
  function getBet(bytes32 _bet) external view returns (address[6], uint[6], bytes);

}
