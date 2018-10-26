pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title ChainSpecifiable Contract
 * @dev The ChainSpecifiable Contract is used to manage chainId, that is used in signing messages
 *  to prevent replay attacks of new incoming transactions from one chain onto the other chain
 * @dev Work around to operate on Eth forked chains until github.com/ethereum/EIPs/pull/1344 is
 *  merged
 */
contract ChainSpecifiable is Ownable {

  // Chain ID of the
  uint private chainId;

  // Emit when chainId is updated
  event LogChainIdUpdated(uint indexed _old, uint indexed _new);

  /**
   * @notice Constructor
   * @param _chainId ChainId to be set
   */
  constructor(uint _chainId) public {
    chainId = _chainId;
  }

  /**
   * @notice Updates chainId to `_chainId`
   * @dev ONLY called if there is a chain split to avoid replay attacks across forks
   * @param _chainId new chainId
   */
  function setChainId(uint _chainId) external onlyOwner {
    uint _old = chainId;
    chainId = _chainId;
    emit LogChainIdUpdated(_old, _chainId);
  }

  /**
   * @notice Gets chainId
   * @return returns chainId
   */
  function getChainId() public view returns (uint) {
    return chainId;
  }

}
