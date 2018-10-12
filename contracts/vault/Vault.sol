pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

import "../interfaces/IVault.sol";

import "../utils/RegistryAccessible.sol";


/*
 * @title Vault Contract
 * @dev Vault contract manages all deposits and withdrawals and keep calculated exposures in check
 */
contract Vault is Ownable, IVault, RegistryAccessible {

  using SafeMath for uint;

  address constant public ETH = 0x0;

  // TODO:v1:security Manan => Safer to set allowance limits, in case of exploits
  // Mapping of approved spenders by user
  mapping (address => mapping (address => bool)) private approved; // user => sender => bool
  // Mapping of tokens balances by token address, by user
  mapping (address => mapping (address => uint)) private balances; // token => user => amount
  // Addresses correspond to `true` if registered spenders, `false` otherwise
  mapping (address => bool) private spenders;

  // Emit when a new spender is added
  event LogSpenderAdded(address indexed _spender);

  /**
   * @notice Constructor
   * @param _registry Address of the Registry contract
   */
  constructor(address _registry) public RegistryAccessible(_registry) {

  }

  /**
   * @dev Throw is called by any account other than approved spenders for _user
   */
  modifier onlyApproved(address _user) {
    require(approved[_user][msg.sender], "User must approve sender as spender");
    _;
  }

  /**
   * @notice Deposits a specific token or ETH
   * @param _token Address of token that is being deposited
   * @param _amount Number of tokens to deposit
   */
  function deposit(address _token, uint _amount) external payable {
    require(
      _token == ETH ? msg.value > 0 && _amount == 0 : msg.value == 0 && _amount > 0,
      "If depositing ether, ether sent must be non-zero, otherwise _amount must be non-zero"
    );

    uint _value = _token == ETH ? msg.value : _amount;
    balances[_token][msg.sender] = balances[_token][msg.sender].add(_value);
    if (_token != ETH)
      require(
        ERC20(_token).transferFrom(msg.sender, address(this), _value),
        "Vault must be a approved spender for token to withdraw"
      );
  }

  /**
   * @notice Withdraws a specific token or ETH
   * @param _token Address of token that is being withdrawn
   * @param _amount Number of tokens to withdraw
   */
  function withdraw(address _token, uint _amount) external {
    require(_amount > 0, "Amount must be greater than zero");

    balances[_token][msg.sender] = balances[_token][msg.sender].sub(_amount);
    if (_token == ETH)
      msg.sender.transfer(_amount);
    else
      require(ERC20(_token).transfer(msg.sender, _amount), "Vault cannot transfer balance");
  }

  /**
   * @notice Transfers token from sender to `_to`
   * @param _token Address of token that is being transferred
   * @param _to Address to which tokens are being transferred to
   * @param _amount Number of tokens being transferred
   * @return `true` if transfer successful, `false` otherwise
   */
  function transfer(address _token, address _to, uint _amount) external returns (bool) {
    require(_amount > 0, "Amount must be greater than zero");

    address _from = msg.sender;
    balances[_token][_from] = balances[_token][_from].sub(_amount);
    balances[_token][_to] = balances[_token][_to].add(_amount);
    return true;
  }

  /**
   * @notice Transfers token from one address to another
   * @param _token Address of token that is being transferred
   * @param _from Address to which tokens are being transferred from
   * @param _to Address to which tokens are being transferred to
   * @param _amount Number of tokens being transferred
   */
  function transferFrom(address _token, address _from, address _to, uint _amount)
    external
    onlyApproved(_from)
    returns (bool)
  {
    require(_amount > 0, "Amount must be greater than zero");

    balances[_token][_from] = balances[_token][_from].sub(_amount);
    balances[_token][_to] = balances[_token][_to].add(_amount);
    return true;
  }

  /**
   * @notice Approves a spender to transfer balances of the sender
   * @param _spender Address of spender that is being approved
   */
  function approve(address _spender) external {
    require(spenders[_spender], "Spender must be registered with Vault");
    approved[msg.sender][_spender] = true;
  }

  /**
   * @notice Adds a spender
   * @param _spender Address of spender being added
   */
  function addSpender(address _spender) external onlyOwner {
    require(
      registry.getAddress("BetManager") == _spender,
      "Spender must be an active Bet Manager"
    );
    spenders[_spender] = true;
    emit LogSpenderAdded(_spender);
  }

  /**
   * @notice Returns the balance of a user for a specified token
   * @param _token Address of the token
   * @param _user Address of the user
   * @return token balance for the user
   */
  function balanceOf(address _token, address _user) external view returns (uint) {
    return balances[_token][_user];
  }

  /**
   * @notice Checks if a spender has been approved by a user
   * @param _user Address of the user
   * @param _spender Address of the spender
   * @return `true` if user's address is approved, otherwise `false`
   */
  function isApproved(address _user, address _spender) external view returns (bool) {
    return approved[_user][_spender];
  }


  /**
   * @notice Returns if an address has been approved as a spender
   * @param _spender Address of the spender
   * @return `true` if address as been registered as a spender, otherwise `false`
   */
  function isSpender(address _spender) external view returns (bool) {
    return spenders[_spender];
  }

}
