pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Capped.sol";

contract FanToken is ERC20Detailed, ERC20Capped {

  constructor()
    public
    ERC20Detailed("FansUnite Token", "FAN", 18)
    ERC20Capped(1000000000 * 10 ** 18)
  {

  }

}
