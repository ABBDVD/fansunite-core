pragma solidity ^0.4.24;

import "../../contracts/libraries/BetLib.sol";

contract BetLibMock {

  using BetLib for BetLib.Bet;

  function generate(address[6] _subjects, uint[6] _params, bytes _payload)
    external
    pure
    returns (address[6], uint[6], bytes)
  {
    BetLib.Bet memory bet =  BetLib.generate(_subjects, _params, _payload);
    return ([
        bet.backer,
        bet.layer,
        bet.token,
        bet.feeRecipient,
        bet.league,
        bet.resolver
      ],
      [
        bet.backerStake,
        bet.backerFee,
        bet.layerFee,
        bet.expiration,
        bet.fixture,
        bet.odds
      ],
        bet.payload
    );
  }

  function hash(address[6] _subjects, uint[6] _params, bytes _payload, uint _nonce)
    external
    pure
    returns (bytes32)
  {
    BetLib.Bet memory bet = BetLib.generate(_subjects, _params, _payload);
    return bet.hash(_nonce);
  }

  function backerTokenReturn(address[6] _subjects, uint[6] _params, bytes _payload)
    external
    pure
    returns (uint)
  {
    BetLib.Bet memory bet = BetLib.generate(_subjects, _params, _payload);
    uint _decimals = 8;
    return bet.backerTokenReturn(_decimals);
  }

}
