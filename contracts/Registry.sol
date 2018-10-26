pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./interfaces/IRegistry.sol";

/**
 * @title Registry Contract
 */
contract Registry is Ownable, IRegistry {

  /*
  Valid Address Keys
  leagueRegistry = getAddress("LeagueRegistry")
  resolverRegistry = getAddress("ResolverRegistry")
  betManager = getAddress("BetManager")
  consensusManager = getAddress("ConsensusManager")
  fanToken = getAddress("FanToken")
  fanVault = getAddress("FanVault")
  fanOrg = getAddress("FanOrg")
  */

  mapping (bytes32 => address) public storedAddresses;
  mapping (bytes32 => bool) public validAddressKeys;

  event LogChangeAddress(string _nameKey, address indexed _old, address indexed _new);

  /**
   * @notice Get the contract address
   * @param _nameKey is the key for the contract address mapping
   * @return Address of contract with namekey `_namekey`
   */
  function getAddress(string _nameKey) external view returns (address) {
    return _getAddress(_nameKey);
  }

  /**
   * @notice change the contract address
   * @param _nameKey is the key for the contract address mapping
   * @param _newAddress is the new contract address
   */
  function changeAddress(string _nameKey, address _newAddress) external onlyOwner {
    address oldAddress;

    if (validAddressKeys[keccak256(bytes(_nameKey))])
      oldAddress = _getAddress(_nameKey);
    else
      validAddressKeys[keccak256(bytes(_nameKey))] = true;

    storedAddresses[keccak256(bytes(_nameKey))] = _newAddress;
    emit LogChangeAddress(_nameKey, oldAddress, _newAddress);
  }

  // Internal getAddress
  function _getAddress(string _nameKey) private view returns (address) {
    require(validAddressKeys[keccak256(bytes(_nameKey))], "Namekey must be valid");
    return storedAddresses[keccak256(bytes(_nameKey))];
  }

}
