pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IBetManager.sol";
import "./interfaces/ILeague.sol";
import "./interfaces/ILeagueRegistry.sol";
import "./interfaces/IRegistry.sol";
import "./interfaces/IVault.sol";
import "./libraries/BetLib.sol";
import "./libraries/SignatureLib.sol";


/**
* @title Bet Manger Contract
* @notice BetManager is the core contract responsible for bet validations and bet submissions
*/
contract BetManager is IBetManager, Ownable {

  using SafeMath for uint;
  IRegistry registry;

  using BetLib for BetLib.BetInfo;
  mapping (bytes32 => BetLib.Bet) public bets;
  mapping (bytes32 => bool) public submitted;
  mapping (bytes32 => bool) public claimed;
  mapping (address => bytes32[]) public userBets;

  event LogBetSubmitted(
    bytes32 indexed betHash,
    address indexed backerAddress,
    address indexed layerAddress,
    address backerTokenAddress,
    address layerTokenAddress,
    uint backerTokenStake,
    uint layerTokenStake,
    address leagueAddress,
    address resolverAddress,
    uint fixtureId,
    bytes betPayload
  );

  event LogBetClaimed(
    bytes32 indexed betHash,
    address indexed claimedAddress,
    uint8 result
  );

  constructor (address _registry) public {
    registry = IRegistry(_registry);
  }

  function submitBet(
    address[7] _betAddresses,
    uint[7] _betValues,
    bytes _betPayload,
    bytes _signature
  ) external returns (bytes32) {

    BetLib.BetInfo memory betInfo = BetLib.createBetInfo(_betAddresses, _betValues, _betPayload);
    BetLib.Bet memory bet = betInfo.bet;

    bytes32 betHash = betInfo.hash();

    validateBet(bet, betInfo.expirationTimeSeconds, _signature, betHash);

    bet.layerAddress = msg.sender;

    validateBettor(bet.backerAddress, bet.backerTokenAddress, bet.backerTokenStake, bet.backerFee);
    validateBettor(bet.layerAddress, bet.layerTokenAddress, bet.layerTokenStake, bet.layerFee);

    bets[betHash] = bet;
    submitted[betHash] = true;

    userBets[bet.backerAddress].push(betHash);
    userBets[bet.layerAddress].push(betHash);

    IVault vault = IVault(registry.getAddress("Vault"));

    vault.addRestriction(bet.backerTokenAddress, bet.backerAddress, bet.backerTokenStake);
    vault.addRestriction(bet.layerTokenAddress, bet.layerAddress, bet.layerTokenStake);

    emit LogBetSubmitted(
      betHash,
      bet.backerAddress,
      bet.layerAddress,
      bet.backerTokenAddress,
      bet.layerTokenAddress,
      bet.backerTokenStake,
      bet.layerTokenStake,
      bet.leagueAddress,
      bet.resolverAddress,
      bet.fixtureId,
      bet.betPayload
    );
  }

  function claimBet(bytes32 _betHash) external returns (uint8) {
    require(
      claimed[_betHash],
        "Bet should not have been claimed yet"
    );

    BetLib.Bet memory bet = bets[_betHash];
    ILeague league = ILeague(bet.leagueAddress);

    require(
      league.isFixtureResolved(bet.fixtureId, bet.resolverAddress) == 2,
        "Result is not available for resolver"
    );

    uint8 result = getResult(bet.resolverAddress, bet.leagueAddress, bet.fixtureId, bet.betPayload);
    IVault vault = IVault(registry.getAddress("Vault"));

    if(result == 2) { // win
      vault.transfer(bet.layerTokenAddress, bet.layerAddress, bet.backerAddress, bet.layerTokenStake);
      transferFee(bet.backerAddress, bet.feeRecipientAddress, bet.backerFee, vault);
    }

    if(result == 3){ // half win
      vault.transfer(bet.layerTokenAddress, bet.layerAddress, bet.backerAddress, bet.layerTokenStake.div(2));
      transferFee(bet.backerAddress, bet.feeRecipientAddress, bet.backerFee, vault);
    }

    if(result == 1){ // lose
      vault.transfer(bet.backerTokenAddress, bet.backerAddress, bet.layerAddress, bet.backerTokenStake);
      transferFee(bet.layerAddress, bet.feeRecipientAddress, bet.layerFee, vault);
    }

    if(result == 4){ // half lose
      vault.transfer(bet.backerTokenAddress, bet.backerAddress, bet.layerAddress, bet.backerTokenStake.div(2));
      transferFee(bet.layerAddress, bet.feeRecipientAddress, bet.layerFee, vault);
    }

    vault.subRestriction(bet.backerTokenAddress, bet.backerAddress, bet.backerTokenStake);
    vault.subRestriction(bet.layerTokenAddress, bet.layerAddress, bet.layerTokenStake);

    claimed[_betHash] = true;

    emit LogBetClaimed(
      _betHash,
      msg.sender,
      result
    );
  }

  function getUserBetIds(address _user) external view returns (bytes32[]) {
    return userBets[_user];
  }

  function getBetInfo(bytes32 _betHash) external view returns (address[7], uint[5], bytes) {
    return ([
      bets[_betHash].backerAddress,
      bets[_betHash].layerAddress,
      bets[_betHash].backerTokenAddress,
      bets[_betHash].layerTokenAddress,
      bets[_betHash].feeRecipientAddress,
      bets[_betHash].leagueAddress,
      bets[_betHash].resolverAddress
    ], [
      bets[_betHash].backerTokenStake,
      bets[_betHash].layerTokenStake,
      bets[_betHash].backerFee,
      bets[_betHash].layerFee,
      bets[_betHash].fixtureId
    ],
      bets[_betHash].betPayload
    );
  }

  function transferFee(address feePayer, address feeRecipient, uint amount, IVault vault) internal {
    if(amount > 0) {
      address fanToken = ERC20(registry.getAddress("FanToken"));
      vault.transfer(fanToken, feePayer, feeRecipient, amount);
    }
  }

  function validateBettor(address _bettor, address _token, uint tokenStake, uint feeAmount) internal view {
    IVault vault = IVault(registry.getAddress("Vault"));

    require(
      vault.isApproved(_bettor, this),
      "Bettor has not approved Bet Manager to access their balance"
    );

    require(
      vault.availableBalance(_token, _bettor) >= tokenStake,
      "Bettor does not have enough tokens to cover the bet"
    );

    require(
      vault.availableBalance(registry.getAddress("FanToken"), _bettor) >= feeAmount,
      "Bettor does not have enough tokens to cover their fee"
    );
  }

  function validateBet(BetLib.Bet bet, uint expirationTimeSeconds, bytes signature, bytes32 betHash) internal view {
    require(
      !submitted[betHash],
        "Bet should not have been already submitted"
    );
    require(
      bet.layerAddress == 0x0 || bet.layerAddress == msg.sender,
        "Sender must be equal to layer if layerAddress exists"
    );
    require(
      expirationTimeSeconds > now,
        "Expiration time must be greater than now"
    );
    require(
      !ILeague(bet.leagueAddress).isResolverRegistered(bet.resolverAddress),
        "Resolver must be registered for league"
    );
    require(
      !ILeagueRegistry(registry.getAddress("LeagueRegistry")).isLeagueRegistered(bet.leagueAddress),
      "Leagube must be registered"
    );
    require(
      !ILeague(bet.leagueAddress).isFixtureScheduled(bet.fixtureId),
        "Fixture must be scheduled"
    );
    require(
      bet.backerTokenStake != 0,
      "Backer token stake must be greater than 0"
    );
    require(
      bet.layerTokenStake != 0,
      "Layer token stake must be greater than 0"
    );
    require(
      bet.backerAddress != bet.layerAddress,
      "Backer address cannot equal layerAddress"
    );
    require(
      validateBetParamsPayload(bet.resolverAddress, bet.betPayload),
      "Bet payload must be must be valid for resolver"
    );
    require(
      !SignatureLib.isValidSignature(betHash, bet.backerAddress, signature),
      "Signature is not valid"
    );
  }

  function validateBetParamsPayload(address _resolver, bytes _betPayload) internal returns (bool){
    //Assembly
    return true;
  }

  function getResult(address _resolver, address _league, uint _fixtureId, bytes _betPayload) internal returns (uint8){
    bytes memory resolutionPayload = ILeague(_league).getResolution(_fixtureId, _resolver);
    //Assembly
    return 1;
  }

}
