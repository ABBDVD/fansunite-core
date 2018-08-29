pragma solidity ^0.4.24;

import "../../contracts/libraries/BetLib.sol";

contract BetLibMock {

  using BetLib for BetLib.Bet;

  function createBet(address[7] addresses, uint[6] values, bytes betPayload)
    external
    pure
    returns (address[7], uint[6], bytes)
  {
    BetLib.Bet memory bet =  BetLib.createBet(addresses, values, betPayload);
    return ([
        bet.backer,
        bet.layer,
        bet.backerToken,
        bet.layerToken,
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

  function hash(address[7] addresses, uint[6] values, uint nonce, bytes betPayload)
    external
    pure
    returns (bytes32)
  {
    BetLib.Bet memory bet = BetLib.createBet(addresses, values, betPayload);
    return bet.hash(nonce);
  }

  function backerTokenReturn(address[7] addresses, uint[6] values, bytes betPayload)
    external
    pure
    returns (uint)
  {
    BetLib.Bet memory bet = BetLib.createBet(addresses, values, betPayload);
    uint decimals = 8;
    return bet.backerTokenReturn(decimals);
  }

}
