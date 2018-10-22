pragma solidity ^0.4.24;

import "../../contracts/libraries/BetLib.sol";

contract BetLibMock {

  using BetLib for BetLib.Bet;

  uint public chainId = 15;

  function generate(address[5] _subjects, uint[4] _params, bytes _payload)
    external
    pure
    returns (address[5], uint[4], bytes)
  {
    BetLib.Bet memory bet =  BetLib.generate(_subjects, _params, _payload);
    return ([
        bet.backer,
        bet.layer,
        bet.token,
        bet.league,
        bet.resolver
      ],
      [
        bet.backerStake,
        bet.fixture,
        bet.odds,
        bet.expiration
      ],
        bet.payload
    );
  }

  function hash(address[5] _subjects, uint[4] _params, bytes _payload, uint _nonce)
    external
    view
    returns (bytes32)
  {
    BetLib.Bet memory bet = BetLib.generate(_subjects, _params, _payload);
    return bet.hash(chainId, _nonce);
  }

  function backerReturn(address[5] _subjects, uint[4] _params, bytes _payload)
    external
    pure
    returns (uint)
  {
    BetLib.Bet memory bet = BetLib.generate(_subjects, _params, _payload);
    uint _decimals = 8;
    return bet.backerReturn(_decimals);
  }

}
