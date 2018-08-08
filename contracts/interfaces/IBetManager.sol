pragma solidity ^0.4.24;


/**
* @title Interface for Bet Manger Contract
*/
contract IBetManager {

  /**
    @notice Submits a bet
    @param _betAddresses Array of addresses that are associated with the bet [backerAddress, layerAddress, backerTokenAddress, layerTokenAddress, feeRecipientAddress]
    @param _betValues Array of uint256 that as associated with the bet [backerTokenAmount, layerTokenAmount, backerFee, layerFee, expirationTimeSeconds, salt]
    @param _betPayload The payload of the bet
    @param _signature ECDSA signature along with the mode (0 = Typed (EIP712), 1 = Geth, 2 = Trezor) {mode}{v}{r}{s}.
  */

  function submitBet(
    address[7] _betAddresses,
    uint[7] _betValues,
    bytes _betPayload,
    bytes _signature
  ) external returns (bytes32);

  /**
    @notice claims a bet, transfers tokens to winning parties, pays out fees and updates user restrictions
    @param _betHash Hash of all the bet parameters
  */
  function claimBet(bytes32 _betHash) external returns (uint8);

  /**
    @notice Returns all the bet ids (hashes) for the provided user address
    @param _user Address of the user
  */
  function getUserBetIds(address _user) external view returns (bytes32[]);

  /**
    @notice Returns all the parameters associated with a bet hash
    @param _betHash Hash of all the bet parameters
  */
  function getBetInfo(bytes32 _betHash)  external view returns (address[7], uint[5], bytes);

}
