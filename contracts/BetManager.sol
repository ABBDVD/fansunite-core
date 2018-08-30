pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

import "./interfaces/IBetManager.sol";
import "./interfaces/ILeague.sol";
import "./interfaces/ILeagueRegistry.sol";
import "./interfaces/IRegistry.sol";
import "./interfaces/IResolver.sol";
import "./interfaces/IVault.sol";

import "./libraries/BetLib.sol";
import "./libraries/SignatureLib.sol";
/**
* @title Bet Manger Contract
* @notice BetManager is the core contract responsible for bet validations and bet submissions
*/
contract BetManager is Ownable, IBetManager {

  using SafeMath for uint;
  using BetLib for BetLib.Bet;

}
