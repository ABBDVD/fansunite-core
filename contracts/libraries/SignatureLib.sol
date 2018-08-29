pragma solidity ^0.4.24;

library SignatureLib {

  enum SignatureMode {
    TYPED_SIGN,
    GETH,
    TREZOR
  }

  /**
   * @notice Validates that a hash was signed by a specified signer.
   * @param hash Hash which was signed.
   * @param signer Address of the signer.
   * @param signature ECDSA signature along with the mode
   *  (0 = Typed (EIP712), 1 = Geth, 2 = Trezor) {mode}{v}{r}{s}.
   * @return Returns whether signature is from a specified user.
   */
  function isValidSignature(bytes32 hash, address signer, bytes signature)
    internal
    view
    returns (bool)
  {
    return recover(hash, signature) == signer;
  }

  /**
   * @notice Recovers signer from signature.
   * @param hash Hash which was signed.
   * @param signature ECDSA signature along with the mode
   *  (0 = Typed (EIP712), 1 = Geth, 2 = Trezor) {mode}{v}{r}{s}.
   * @return Returns Address of the signer.
   */
  function recover(bytes32 hash, bytes signature) internal pure returns (address) {
    require(signature.length == 66);
    SignatureMode mode = SignatureMode(uint8(signature[0]));

    uint8 v = uint8(signature[1]);
    bytes32 r;
    bytes32 s;
    assembly {
      r := mload(add(signature, 34))
      s := mload(add(signature, 66))
    }

    bytes32 _hash;
    if (mode == SignatureMode.GETH) {
      _hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    } else if (mode == SignatureMode.TREZOR) {
      _hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n\x20", hash));
    }

    return ecrecover(_hash, v, r, s);
  }

}