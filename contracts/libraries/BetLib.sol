pragma solidity ^0.4.24;

library BetLib {


  bytes32 constant BET_SCHEMA_HASH = keccak256(abi.encodePacked(
    "address backerAddress",
    "address layerAddress",
    "address backerTokenAddress",
    "address layerTokenAddress",
    "address feeRecipientAddress",
    "uint256 backerTokenStake",
    "uint256 layerTokenStake",
    "uint256 backerFee",
    "uint256 layerFee",
    "address leagueAddress",
    "address resolverAddress",
    "uint256 fixtureId",
    "bytes betPayload",
    "uint256 expirationTimeSeconds",
    "uint256 salt"
  ));

  struct Bet {
    address backerAddress;
    address layerAddress;
    address backerTokenAddress;
    address layerTokenAddress;
    address feeRecipientAddress;
    uint backerTokenStake;
    uint layerTokenStake;
    uint backerFee;
    uint layerFee;
    address leagueAddress;
    address resolverAddress;
    uint fixtureId;
    bytes betPayload;
  }

  struct BetInfo {
    Bet bet;
    uint expirationTimeSeconds;
    uint salt;
  }

  function hash(BetInfo memory betInfo) internal pure returns (bytes32) {

    bytes memory variables1 = abi.encodePacked(
      betInfo.bet.backerAddress,
      betInfo.bet.layerAddress,
      betInfo.bet.backerTokenAddress,
      betInfo.bet.layerTokenAddress,
      betInfo.bet.feeRecipientAddress,
      betInfo.bet.backerTokenStake,
      betInfo.bet.layerTokenStake,
      betInfo.bet.backerFee,
      betInfo.bet.layerFee
    );

    bytes memory variables2 = abi.encodePacked(
      betInfo.bet.leagueAddress,
      betInfo.bet.resolverAddress,
      betInfo.bet.fixtureId,
      betInfo.bet.betPayload,
      betInfo.expirationTimeSeconds,
      betInfo.salt
    );

    return keccak256(abi.encodePacked(
      BET_SCHEMA_HASH,
      keccak256(abi.encodePacked(variables1, variables2))
    ));
  }

  function createBetInfo(address[7] addresses, uint[7] values, bytes betPayload) internal pure returns (BetInfo) {
    return BetInfo({
        bet: Bet({
          backerAddress: addresses[0],
          layerAddress: addresses[1],
          backerTokenAddress: addresses[2],
          layerTokenAddress: addresses[3],
          feeRecipientAddress: addresses[4],
          backerTokenStake: values[0],
          layerTokenStake: values[1],
          backerFee: values[2],
          layerFee: values[3],
          leagueAddress: addresses[5],
          resolverAddress: addresses[6],
          fixtureId: values[6],
          betPayload: betPayload
        }),
        expirationTimeSeconds: values[4],
        salt: values[5]
    });

  }
}
