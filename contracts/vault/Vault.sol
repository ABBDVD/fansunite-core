pragma solidity ^0.4.24;

import "../interfaces/IVault.sol";
import "../interfaces/IRegistry.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract Vault is Ownable, IVault {

  using SafeMath for uint;
  IRegistry public registry;

  address constant public ETH = 0x0;

  mapping (address => mapping (address => bool)) private approved;
  mapping (address => mapping (address => uint)) private balances;
  mapping (address => mapping (address => uint)) private restrictions;
  mapping (address => bool) private spenders;

  event LogWithdraw(address indexed _user, address _token, uint _amount);
  event LogDeposit(address indexed _user, address _token, uint _amount);
  event LogApprove(address indexed _user, address indexed _spender);
  event LogAddSpender(address indexed _spender);

  modifier onlySpender {
    require(spenders[msg.sender], "Spender should already be added");
    _;
  }

  modifier onlyApproved(address _user) {
    require(approved[_user][msg.sender], "User must approve spender");
    _;
  }

  constructor (address _registry) public {
    registry = IRegistry(_registry);
  }

  function deposit(address _token, uint _amount) external payable {
    require(_token == ETH || msg.value == 0, "Amount sent must be zero if token is ETH");

    uint value = _amount;
    if (_token == ETH) {
      value = msg.value;
    } else {
      require(ERC20(_token).transferFrom(msg.sender, address(this), value));
    }

    balances[_token][msg.sender] = balances[_token][msg.sender].add(value);
    emit LogDeposit(msg.sender, _token, value);
  }

  function withdraw(address _token, uint _amount) external {
    require(balances[_token][msg.sender].sub(_amount) >= restrictions[_token][msg.sender], "User should have enough tokens to cover their restricted withdrawal amount");
    require(balances[_token][msg.sender] >= _amount, "User should have enough tokens to withdraw");

    balances[_token][msg.sender] = balances[_token][msg.sender].sub(_amount);

    if (_token == ETH) {
      msg.sender.transfer(_amount);
    } else {
      require(ERC20(_token).transfer(msg.sender, _amount), "ERC20 Token must be transferred to vault");
    }

    emit LogWithdraw(msg.sender, _token, _amount);
  }

  function transfer(address _token, address _from, address _to, uint _amount)  external onlySpender onlyApproved(_from) {
    require(_amount > 0, "Amount to transfer must be greater than 0");
    balances[_token][_from] = balances[_token][_from].sub(_amount);
    balances[_token][_to] = balances[_token][_to].add(_amount);
  }

  function approve(address _spender) external {
    require(spenders[_spender], "Spender must be registered");
    approved[msg.sender][_spender] = true;
    emit LogApprove(msg.sender, _spender);
  }

  function isApproved(address _user, address _spender) external view returns (bool) {
    return approved[_user][_spender];
  }

  function addSpender(address _spender) external onlyOwner {
    require(registry.getAddress("BetManager") == _spender, "Spender must be a active Bet Manager");
    spenders[_spender] = true;
    emit LogAddSpender(_spender);
  }

  function isSpender(address _spender) external view returns (bool) {
    return spenders[_spender];
  }

  function balanceOf(address _token, address _user) external view returns (uint) {
    return balances[_token][_user];
  }

  function restrictionOf(address _token, address _user) external view returns (uint) {
    return restrictions[_token][_user];
  }

  function addRestriction(address _token, address _user, uint _amount) external onlySpender onlyApproved(_user) {
    restrictions[_token][_user] = balances[_token][_user].add(_amount);
  }

  function subRestriction(address _token, address _user, uint _amount) external onlySpender onlyApproved(_user) {
    restrictions[_token][_user] = balances[_token][_user].sub(_amount);
  }

  function availableBalance(address _token, address _user) external view returns (uint) {
    return balances[_token][_user].sub(restrictions[_token][_user]);
  }

}

