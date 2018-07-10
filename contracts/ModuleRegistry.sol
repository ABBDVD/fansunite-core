pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./interfaces/IModuleRegistry.sol";


/**
* @title Module Registry Contract
* @notice Anyone can register Resolver modules, but only those "approved" by FansUnite will be available for leagues to add
* @notice BetValidator modules can only be added by Fansunite
*/
contract ModuleRegistry is Ownable, IModuleRegistry {

}
