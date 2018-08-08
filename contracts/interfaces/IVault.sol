pragma solidity ^0.4.24;

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
   * @notice Transfers token from one address to another
   * @param _token Address of token that is being transferred
   * @param _from Address to which tokens are being transferred from
   * @param _to Address to which tokens are being transferred toe
   * @param _amount Number of tokens being transferred
   */
  function transfer(address _token, address _from, address _to, uint _amount) external;

  /**
   * @notice Approves a spender to transfer balances of the sender
   * @param _spender Address of spender that is being approved
   */
  function approve(address _spender) external;

  /**
   * @notice Checks if a spender has been approved by a user
   * @param _user Address of the user
   * @param _spender Address of the spender
   * @return true if user's address is approved
   */
  function isApproved(address _user, address _spender) external view returns (bool);

  /**
   * @notice Adds a spender
   * @param _spender Address of spender being added
   */
  function addSpender(address _spender) external;

  /**
   * @notice Returns if an address has been approved as a spender
   * @param _spender Address of the spender
   * @return true if address as been registered as a spender
   */
  function isSpender(address _spender) external view returns (bool);

  /**
   * @notice Returns the balance of a user for a specified token
   * @param _token Address of the token
   * @param _user Address of the user
   * @return token balance for the user
   */
  function balanceOf(address _token, address _user) external view returns (uint);

  /**
   * @notice Returns the withdrawal restriction for a user for a specified token
   * @param _token Address of the token
   * @param _user Address of the user
   * @return Number of tokens restricted from being withdrawn for the user
   */
  function restrictionOf(address _token, address _user) external view returns (uint);

  /**
   * @notice Adds an amount to the withdrawal restriction for the user for that token
   * @param _token Address of the token
   * @param _user Address of the user
   * @param _amount Number of tokens restricted from being withdrawn for the user
   */
  function addRestriction(address _token, address _user, uint _amount) external;

  /**
   * @notice Subtracts an amount to the withdrawal restriction for the user for that token
   * @param _token Address of the token
   * @param _user Address of the user
   * @param _amount Number of tokens restricted from being withdrawn for the user
   */
  function subRestriction(address _token, address _user, uint _amount) external;

  /**
   * @notice Returns the balance that is available for a user for that token
   * @param _token Address of the token
   * @param _user Address of the user
   */
  function availableBalance(address _token, address _user) external view returns (uint);

}
