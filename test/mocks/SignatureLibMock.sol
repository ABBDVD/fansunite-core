pragma solidity ^0.4.24;

import "../../contracts/libraries/SignatureLib.sol";

contract SignatureLibMock {

  function isValidSignature(bytes32 hash, address signer, bytes signature) external view returns (bool) {
    return SignatureLib.isValidSignature(hash, signer, signature);
  }

  function recover(bytes32 hash, bytes signature) external pure returns (address) {
    return SignatureLib.recover(hash, signature);
  }
}
