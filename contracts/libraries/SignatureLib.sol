pragma solidity ^0.4.24;

library SignatureLib {

  enum SignatureMode {
    TYPED_SIGN,
    GETH
  }

  /**
   * @notice Validates that a hash was signed by a specified signer.
   * @param _hash Hash which was signed.
   * @param _signer Address of the signer.
   * @param _signature ECDSA signature along with the mode
   *  (0 = Typed, 1 = Geth) {mode}{v}{r}{s}.
   * @return Returns whether signature is from a specified user.
   */
  function isValidSignature(bytes32 _hash, address _signer, bytes _signature)
    internal
    view
    returns (bool)
  {
    return recover(_hash, _signature) == _signer;
  }

  /**
   * @notice Recovers signer from signature.
   * @param _hash Hash which was signed.
   * @param _signature ECDSA signature along with the mode
   *  (0 = Typed, 1 = Geth) {mode}{v}{r}{s}.
   * @return Returns Address of the signer.
   */
  function recover(bytes32 _hash, bytes _signature) internal pure returns (address) {
    require(_signature.length == 66);
    SignatureMode mode = SignatureMode(uint8(_signature[0]));

    uint8 v = uint8(_signature[1]);
    bytes32 r;
    bytes32 s;
    assembly {
      r := mload(add(_signature, 34))
      s := mload(add(_signature, 66))
    }

    bytes32 hash;
    if (mode == SignatureMode.GETH) {
      hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash));
    } else {
      hash = _hash;
    }

    return ecrecover(hash, v, r, s);
  }

}
