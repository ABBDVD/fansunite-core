pragma solidity 0.4.24;


/**
 * @title Interface for the Vault contract
 */
contract IVault {

  /**
   * @notice Deposits a specific token or ETH
   * @param _token Address of token that is being deposited
   * @param _amount Number of tokens to deposit
   */
  function deposit(address _token, uint _amount) external payable;

  /**
   * @notice Withdraws a specific token or ETH
   * @param _token Address of token that is being withdrawn
   * @param _amount Number of tokens to withdraw
   */
  function withdraw(address _token, uint _amount) external;

  /**
   * @notice Transfers token from sender to `_to`
   * @param _token Address of token that is being transferred
   * @param _to Address to which tokens are being transferred to
   * @param _amount Number of tokens being transferred
   * @return `true` if transfer successful, `false` otherwise
   */
  function transfer(address _token, address _to, uint _amount) external returns (bool);

  /**
   * @notice Transfers token from one address to another
   * @param _token Address of token that is being transferred
   * @param _from Address to which tokens are being transferred from
   * @param _to Address to which tokens are being transferred to
   * @param _amount Number of tokens being transferred
   * @return `true` if transfer successful, `false` otherwise
   */
  function transferFrom(address _token, address _from, address _to, uint _amount)
    external
    returns (bool);

  /**
   * @notice Approves address `_spender` to transfer balances of the sender
   * @param _spender Address of the spender
   */
  function approve(address _spender) external;

  /**
   * @notice Adds address `_spender` to spenders
   * @param _spender Address of the spender
   */
  function addSpender(address _spender) external;

  /**
   * @notice Returns the balance of a user for a specified token
   * @param _token Address of the token
   * @param _user Address of the user
   * @return token balance for the user
   */
  function balanceOf(address _token, address _user) external view returns (uint);

  /**
   * @notice Checks if address `_spender` has been approved by user `_user`
   * @param _user Address of the user
   * @param _spender Address of the spender
   * @return `true` if spender `_spender` is approved by user `_user`, `false` otherwise
   */
  function isApproved(address _user, address _spender) external view returns (bool);

  /**
   * @notice Checks if address `_spender` is added as spender
   * @param _spender Address of the spender
   * @return `true` if spender `_spender` is added as spender, `false` otherwise
   */
  function isSpender(address _spender) external view returns (bool);

}
