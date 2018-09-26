const BetManager = artifacts.require('./BetManager.sol');
const Registry = artifacts.require('./Registry.sol');
const LeagueRegistry = artifacts.require('./LeagueRegistry.sol');
const League = artifacts.require('./League001.sol');
const Vault = artifacts.require('./Vault.sol');
const MockResolver = artifacts.require('./mocks/MockResolver.sol');
const Token = artifacts.require('./mocks/Token.sol');
const { ensureException } = require('./helpers/utils');
const { BetFactory } = require('./helpers/betfactory');
const { BalanceUtils } = require('./helpers/balanceutils');
const Web3 = require('web3');
const web3 = new Web3();
const { NULL_ADDRESS, ODDS_DECIMALS, TOKEN_DECIMALS } = require('./helpers/constants');

contract('BetManager', (accounts) => {

  let registry;
  let leagueRegistry;
  let vault;
  let betManager;
  let fanToken;
  let betToken;
  let resolver;
  let league;

  const owner = accounts[0];
  const backerAddress = accounts[1];
  const layerAddress = accounts[2];
  const feeRecipientAddress = accounts[3];
  const invalidLeagueAddress = accounts[4];
  const invalidResolverAddress = accounts[5];
  const unApprovedBackerAddress = accounts[6];
  const unApprovedLayerAddress = accounts[7];

  let betFactory;
  let balanceUtils;
  let defaultBetParams;

  const backerTokenStake = 100 * 10 ** TOKEN_DECIMALS;
  const backerFee = 1 * 10 ** TOKEN_DECIMALS;
  const layerTokenStake = 300* 10 ** TOKEN_DECIMALS;
  const layerFee = 3 * 10 ** TOKEN_DECIMALS;
  let backerOddsDecimal = 3;

  before(async () => {

    registry = await Registry.deployed();
    leagueRegistry = await LeagueRegistry.deployed();
    betManager = await BetManager.deployed();
    vault = await Vault.deployed();

    // create dummy Fan Token
    fanToken = await Token.new();
    betToken = await Token.new();
    await registry.changeAddress('FanToken', fanToken.address);

    // Mint tokens and approve vault
    await betToken.mint.sendTransaction(backerAddress, backerTokenStake);
    await betToken.mint.sendTransaction(layerAddress, layerTokenStake);
    await vault.addSpender.sendTransaction(betManager.address, {from: owner});
    await vault.deposit.sendTransaction(betToken.address, backerTokenStake, {from: backerAddress});
    await vault.deposit.sendTransaction(betToken.address, layerTokenStake, {from: layerAddress});
    await vault.approve.sendTransaction(betManager.address, {from: backerAddress});
    await vault.approve.sendTransaction(betManager.address, {from: layerAddress});

    // populate league registry
    const className = 'soccer';
    await leagueRegistry.createClass.sendTransaction(className, {from: owner});
    await leagueRegistry.createLeague.sendTransaction(className, 'EPL', '0x', {from: owner});
    const classLeagues = await leagueRegistry.getClass.call(className);
    const leagueAddress = classLeagues[1][0];

    // populate league
    league = League.at(leagueAddress);
    resolver = await MockResolver.new('0.0.1');
    await league.registerResolver(resolver.address);
    await league.addSeason.sendTransaction(2018, {from: owner});
    await league.scheduleFixture.sendTransaction(2018, [1,2], Math.round(new Date().getDate() / 1000), {from:owner});

    // Setup default bet params
    let expirationTimeSeconds = new Date();
    expirationTimeSeconds.setDate(expirationTimeSeconds.getDate() + 1);

    defaultBetParams = {
      backerAddress,
      layerAddress: NULL_ADDRESS,
      backerTokenAddress: betToken.address,
      layerTokenAddress: betToken.address,
      feeRecipientAddress,
      leagueAddress,
      resolverAddress: resolver.address,
      backerTokenStake,
      backerFee,
      layerFee,
      expirationTimeSeconds: Math.round(expirationTimeSeconds.getTime() / 1000),
      fixtureId: 1,
      backerOdds: backerOddsDecimal * 10 ** ODDS_DECIMALS,
      betPayload: Web3.utils.randomHex(4)
    };

    betFactory = new BetFactory(defaultBetParams);
    balanceUtils = new BalanceUtils(vault);

  });

  describe('fillBet', async () => {

    describe('validate bet', async () => {
      it('should revert if bet has been filled entirely', async () => {
        const bet = await betFactory.newSignedBet({}, layerTokenStake);
        await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, bet.betPayload, bet.signature, {from: layerAddress});
        try {
          await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, bet.betPayload, bet.signature, {from: layerAddress});
        } catch (err) {
          return ensureException(err);
        }
        assert.fail('fill bet did not revert');
      });

      it('should revert if the layerAddress exists and sender is not equal to the layerAddress', async () => {
        const bet = await betFactory.newSignedBet({ layerAddress }, layerTokenStake);
        try {
          await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, bet.betPayload, bet.signature, {from: owner});
        } catch (err) {
          return ensureException(err);
        }
        assert.fail('fill bet did not revert');
      });

      it('should revert if expiration time is greater than the current time', async () => {
        let expirationTimeSeconds = new Date();
        expirationTimeSeconds.setDate(expirationTimeSeconds.getDate() - 1);
        const bet = await betFactory.newSignedBet({ expirationTimeSeconds: Math.round(expirationTimeSeconds.getTime() / 1000) }, 100);
        try {
          await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, bet.betPayload, bet.signature, {from: layerAddress});
        } catch (err) {
          return ensureException(err);
        }
        assert.fail('fill bet did not revert');
      });

      it('should revert if league is not registered in the league registry', async () => {
        const bet = await betFactory.newSignedBet({ leagueAddress: invalidLeagueAddress }, layerTokenStake);
        try {
          await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, bet.betPayload, bet.signature, {from: layerAddress});
        } catch (err) {
          return ensureException(err);
        }
        assert.fail('fill bet did not fail');
      });

      it('should revert if resolver is not registered for the league', async () => {
        const bet = await betFactory.newSignedBet({ resolverAddress: invalidResolverAddress }, layerTokenStake);
        try {
          await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, bet.betPayload, bet.signature, {from: layerAddress});
        } catch (err) {
          return ensureException(err);
        }
        assert.fail('fill bet did not fail');
      });

      it('should revert if fixture is not scheduled', async () => {
        const bet = await betFactory.newSignedBet({ fixtureId: 2 }, layerTokenStake);
        try {
          await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, bet.betPayload, bet.signature, {from: layerAddress});
        } catch (err) {
          return ensureException(err);
        }
        assert.fail('fill bet did not fail');
      });

      it('should revert if bet has been cancelled', async () => {
        // TODO clean up
        await betToken.mint.sendTransaction(backerAddress, backerTokenStake);
        await betToken.mint.sendTransaction(layerAddress, layerTokenStake);
        await vault.deposit.sendTransaction(betToken.address, backerTokenStake, {from: backerAddress});
        await vault.deposit.sendTransaction(betToken.address, layerTokenStake, {from: layerAddress});
        const bet = await betFactory.newSignedBet(null, layerTokenStake);
        await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, bet.betPayload, bet.signature, {from: layerAddress});
        await betManager.cancelBet.sendTransaction(bet.betHash, {from: backerAddress});
        try {
          await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, bet.betPayload, bet.signature, {from: layerAddress});
        } catch (err) {
          return ensureException(err);
        }
        assert.fail('fill bet did not fail');
      });

      it('should revert if layer fill amount is not greater than 0', async () => {
        const bet = await betFactory.newSignedBet(null, 0);
        try {
          await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, bet.betPayload, bet.signature, {from: owner});
        } catch (err) {
          return ensureException(err);
        }
        assert.fail('fill bet did not revert');
      });

      it('should revert if sender is equal to backerAddress', async () => {
        const bet = await betFactory.newSignedBet(null, layerTokenStake);
        try {
          await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, bet.betPayload, bet.signature, {from: backerAddress});
        } catch (err) {
          return ensureException(err);
        }
        assert.fail('fill bet did not revert');
      });

      it('should revert if backer token stake is not greater than 0', async () => {
        // note: this will revert before require statement, so it may not be necessary
        const bet = await betFactory.newSignedBet({ backerTokenStake: 0 }, layerTokenStake);
        try {
          await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, bet.betPayload, bet.signature, {from: owner});
        } catch (err) {
          return ensureException(err);
        }
        assert.fail('fill bet did not revert');
      });

      it('should revert if backer odds is equal to 0', async () => {
        // note: this will revert before require statement, so it may not be necessary
        const bet = await betFactory.newSignedBet({ backerOdds: 0 }, layerTokenStake);
        try {
          await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, bet.betPayload, bet.signature, {from: owner});
        } catch (err) {
          return ensureException(err);
        }
        assert.fail('fill bet did not revert');
      });

      it('should revert if backer address equals layer address', async () => {
        const bet = await  betFactory.newSignedBet({layerAddress: backerAddress}, layerTokenStake);
        try {
          await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, bet.betPayload, bet.signature, {from: backerAddress});
        } catch (err) {
          return ensureException(err);
        }
        assert.fail('fill bet did not revert');
      });

      it('should revert if bet payload is not able to be resolved by resolver', async () => {
        // TODO
      });

      it('should revert if signature is not valid', async () => {
        const bet = await betFactory.newSignedBet({}, layerTokenStake);
        const invalidSignature = '0x00000';
        try {
          await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, bet.betPayload, invalidSignature, {from: layerAddress});
        } catch (err) {
          return ensureException(err);
        }
        assert.fail('fill bet did not revert');

      });
    });

    describe('validate bettor', async() => {

      before(async () => {
        await betToken.mint.sendTransaction(unApprovedBackerAddress, backerTokenStake);
        await betToken.mint.sendTransaction(unApprovedLayerAddress, layerTokenStake);
        await vault.deposit.sendTransaction(betToken.address, backerTokenStake, {from: unApprovedBackerAddress});
        await vault.deposit.sendTransaction(betToken.address, layerTokenStake, {from: unApprovedLayerAddress});
      });

      it('should revert if backer has not approved bet manager to access their balance', async () => {
        const bet = await betFactory.newSignedBet({backerAddress: unApprovedBackerAddress}, 300);
        try {
          await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, bet.betPayload, bet.signature, {from: layerAddress});
        } catch (err) {
          return ensureException(err);
        }
        assert.fail('fill bet did not revert');
      });

      it('should revert if layer has not approved bet manager to access their balance', async () => {
        const bet = await betFactory.newSignedBet(null, 300);
        try {
          await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, bet.betPayload, bet.signature, {from: unApprovedLayerAddress});
        } catch (err) {
          return ensureException(err);
        }
        assert.fail('fill bet did not revert');
      });

      it('should revert if backer does not have enough tokens', async () => {
        const bet = await betFactory.newSignedBet({backerTokenStake: backerTokenStake * 2}, layerTokenStake * 2);
        try {
          await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, bet.betPayload, bet.signature, {from: layerAddress});
        } catch (err) {
          return ensureException(err);
        }
        assert.fail('fill bet did not revert');
      });

      it('should revert if layer does not have enough tokens', async () => {
        const bet = await betFactory.newSignedBet({backerTokenStake: backerTokenStake * 2}, layerTokenStake * 2);
        try {
          await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, bet.betPayload, bet.signature, {from: layerAddress});
        } catch (err) {
          return ensureException(err);
        }
        assert.fail('fill bet did not revert');
      });
    });


    describe('Successfully submit bet', async () => {

      let bet;
      let layerFillTokenAmount = layerTokenStake / 2;

      let beforeBackerBalance;
      let beforeLayerBalance;
      let beforeBetManagerBalance;

      before(async() => {
        bet = await betFactory.newSignedBet({}, layerFillTokenAmount);
        await betToken.mint.sendTransaction(backerAddress, backerTokenStake);
        await betToken.mint.sendTransaction(layerAddress, layerTokenStake);
        await vault.deposit.sendTransaction(betToken.address, backerTokenStake, {from: backerAddress});
        await vault.deposit.sendTransaction(betToken.address, layerTokenStake, {from: layerAddress});
        beforeBackerBalance =  await vault.balanceOf.call(betToken.address, backerAddress);
        beforeLayerBalance =  await vault.balanceOf.call(betToken.address, layerAddress);
        beforeBetManagerBalance =  await vault.balanceOf.call(betToken.address, betManager.address);
        await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, bet.betPayload, bet.signature, {from: layerAddress});
      });

      it('should increment the layer filled amount', async () => {
        const layerFilled = await betManager.layerFilled.call(bet.betHash, layerAddress);
        assert.equal(layerFilled, layerFillTokenAmount);
      });

      it('should submit the bet', async () => {
        const result = await betManager.getBetDetails.call(bet.betHash);
        assert.deepEqual(result[0], bet.addresses);
        assert.equal(result[1][0], bet.values[0]);
        assert.equal(result[1][1], bet.values[1]);
        assert.equal(result[1][2], bet.values[2]);
        assert.equal(result[1][3], bet.values[3]);
        assert.equal(result[1][4], bet.values[4]);
        assert.equal(result[2], bet.betPayload);
      });

      it('should transfer the backer tokens in the vault to the bet manager address', async () => {
        const balance =  await vault.balanceOf.call(betToken.address, backerAddress);
        assert.equal(balance, beforeBackerBalance / 2);
      });

      it('should transfer the layer tokens in the vault to the bet manager address', async () => {
        const balance =  await vault.balanceOf.call(betToken.address, layerAddress);
        assert.equal(balance, beforeLayerBalance - layerFillTokenAmount);
      });

      it('should have the correct balance in the bet manager', async () => {
        const balance = await vault.balanceOf.call(betToken.address, betManager.address);
        assert.equal(balance.toNumber(), beforeBetManagerBalance.add((beforeBackerBalance / 2) + layerFillTokenAmount).toNumber());
      });

      it('should add the bet hash to the layer', async () => {
        // note: remove function and just use internal variables?
        const backerBets = await betManager.getUserBetIds.call(backerAddress);
        assert.equal(true, backerBets.indexOf(bet.betHash) !== -1);
      });

      it('should add the bet hash to the backer', async () => {
        const layerBets = await betManager.getUserBetIds.call(layerAddress);
        assert.equal(true, layerBets.indexOf(bet.betHash) !== -1);
      });

    });
  });

  describe('cancelBet', async() => {

    let bet;
    let layerFillTokenAmount = layerTokenStake / 2;

    before(async() => {
      bet = await betFactory.newSignedBet({}, layerFillTokenAmount);
      await betToken.mint.sendTransaction(backerAddress, backerTokenStake);
      await betToken.mint.sendTransaction(layerAddress, layerTokenStake);
      await vault.deposit.sendTransaction(betToken.address, backerTokenStake, {from: backerAddress});
      await vault.deposit.sendTransaction(betToken.address, layerTokenStake, {from: layerAddress});
      await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, bet.betPayload, bet.signature, {from: layerAddress});
    });

    it('should revert if sender is not backerAddress', async () => {
      try {
        await betManager.cancelBet.sendTransaction(bet.betHash, {from: layerAddress});
      } catch (err) {
        return ensureException(err);
      }
      assert.fail('cancel bet did not revert');
    });

    it('should revert if bet does not exist', async () => {
      const invalidBetHash = Web3.utils.randomHex(32);
      try {
        await betManager.cancelBet.sendTransaction(invalidBetHash, {from: backerAddress});
      } catch (err) {
        return ensureException(err);
      }
      assert.fail('cancel bet did not revert');
    });

    it('should set cancelled to true if sender is backerAddress', async () => {
      await betManager.cancelBet.sendTransaction(bet.betHash, {from: backerAddress});
      const cancelled = await betManager.cancelled.call(bet.betHash);
      assert.equal(cancelled, true);
    });
  });

  describe('claimBet', async () => {

    let partialFillDenominator = 2;
    let bet;
    let layerFillTokenAmount = layerTokenStake / partialFillDenominator;

    before(async() => {
      bet = await betFactory.newSignedBet({}, layerFillTokenAmount);
      await betToken.mint.sendTransaction(backerAddress, backerTokenStake);
      await betToken.mint.sendTransaction(layerAddress, layerTokenStake);
      await vault.deposit.sendTransaction(betToken.address, backerTokenStake, {from: backerAddress});
      await vault.deposit.sendTransaction(betToken.address, layerTokenStake, {from: layerAddress});
      await fanToken.mint.sendTransaction(backerAddress, backerFee);
      await vault.deposit.sendTransaction(fanToken.address, backerFee, {from: backerAddress});
      await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, bet.betPayload, bet.signature, {from: layerAddress});

      await league.updateConsensusContract.sendTransaction(owner, {from: owner});

      const resultPayload = web3.eth.abi.encodeParameters(['uint8'], ['1']);
      await league.pushResolution.sendTransaction(defaultBetParams.fixtureId, defaultBetParams.resolverAddress, resultPayload, {from:owner});

    });

    it('should revert if bet has already been claimed', async () => {
      await betManager.claimBet.sendTransaction(bet.betHash, {from: backerAddress});
      try {
        await betManager.claimBet.sendTransaction(bet.betHash, {from: backerAddress});
      } catch (err) {
        return ensureException(err);
      }
      assert.fail('claim bet did not revert');
    });

    it('should revert if the claimer is not the backer or one of the layers', async () => {
      try {
        await betManager.claimBet.sendTransaction(bet.betHash, {from: owner});
      } catch (err) {
        return ensureException(err);
      }
      assert.fail('claim bet did not revert');
    });

    it('should revert if the result is not available for the resolver', async () => {
      // TODO
      // try {
      //   await betManager.claimBet.sendTransaction(unresolvedBet.betHash, {from: layerAddress});
      // } catch (err) {
      //   return ensureException(err);
      // }
      // assert.fail('claim bet did not revert');
    });

    it('should set claimed to true for claimer', async () => {
      await betManager.claimBet.sendTransaction(bet.betHash, {from: layerAddress});
      assert.equal(await betManager.claimed.call(bet.betHash, layerAddress), true);
    });

    let beforeBetTokenBalances;
    let beforeFanTokenBalances;
    let betTokenAccounts;
    let fanTokenAccounts;

    describe('Backer claim', async () => {

      beforeEach(async() => {
        await betToken.mint.sendTransaction(backerAddress, backerTokenStake);
        await betToken.mint.sendTransaction(layerAddress, layerTokenStake);
        await vault.deposit.sendTransaction(betToken.address, backerTokenStake, {from: backerAddress});
        await vault.deposit.sendTransaction(betToken.address, layerTokenStake, {from: layerAddress});
        await fanToken.mint.sendTransaction(backerAddress, backerFee);
        await fanToken.mint.sendTransaction(layerAddress, layerFee);
        await vault.deposit.sendTransaction(fanToken.address, backerFee, {from: backerAddress});
        await vault.deposit.sendTransaction(fanToken.address, layerFee, {from: layerAddress});

        betTokenAccounts = {
          backer: backerAddress,
          layer: layerAddress,
          betManager: betManager.address
        };
        fanTokenAccounts = {
          backer: backerAddress,
          layer: layerAddress,
          feeRecipient: feeRecipientAddress
        };

        beforeBetTokenBalances = await balanceUtils.getBalances(betToken.address, betTokenAccounts);
        beforeFanTokenBalances = await balanceUtils.getBalances(fanToken.address, fanTokenAccounts);
      });

      it('should transfer the correct bet token amounts and FAN Token fee if the backer wins', async () => {
        const betPayload = web3.eth.abi.encodeParameters(['uint8','uint8'], ['1', '2']);
        bet = await betFactory.newSignedBet({betPayload}, layerFillTokenAmount);
        await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, betPayload, bet.signature, {from: layerAddress});
        await league.pushResolution.sendTransaction(defaultBetParams.fixtureId, defaultBetParams.resolverAddress, betPayload, {from:owner});
        await betManager.claimBet.sendTransaction(bet.betHash, {from: backerAddress});

        const betTokenBalances = await balanceUtils.getBalances(betToken.address, betTokenAccounts);
        const fanTokenBalances = await balanceUtils.getBalances(fanToken.address, fanTokenAccounts);

        assert.equal(betTokenBalances.backer.toNumber(), beforeBetTokenBalances.backer.add(layerFillTokenAmount).toNumber());
        assert.equal(betTokenBalances.layer.toNumber(), beforeBetTokenBalances.layer.sub(layerFillTokenAmount).toNumber());
        assert.equal(betTokenBalances.betManager.toNumber(), beforeBetTokenBalances.betManager.toNumber());

        assert.equal(fanTokenBalances.backer.toNumber(), beforeFanTokenBalances.backer.sub(backerFee / partialFillDenominator).toNumber());
        assert.equal(fanTokenBalances.layer.toNumber(), beforeFanTokenBalances.layer.toNumber());
        assert.equal(fanTokenBalances.feeRecipient.toNumber(), beforeFanTokenBalances.feeRecipient.add(backerFee/ partialFillDenominator).toNumber());
      });

      it('should transfer the correct bet tokens amounts and FAN Token fees if the backer half wins', async () => {
        const betPayload = web3.eth.abi.encodeParameters(['uint8'], ['2']);
        bet = await betFactory.newSignedBet({betPayload}, layerFillTokenAmount);
        await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, betPayload, bet.signature, {from: layerAddress});
        await league.pushResolution.sendTransaction(defaultBetParams.fixtureId, defaultBetParams.resolverAddress, betPayload, {from:owner});
        await betManager.claimBet.sendTransaction(bet.betHash, {from: backerAddress});

        const betTokenBalances = await balanceUtils.getBalances(betToken.address, betTokenAccounts);
        const fanTokenBalances = await balanceUtils.getBalances(fanToken.address, fanTokenAccounts);

        assert.equal(betTokenBalances.backer.toNumber(), beforeBetTokenBalances.backer.add(layerFillTokenAmount / 2).toNumber());
        assert.equal(betTokenBalances.layer.toNumber(), beforeBetTokenBalances.layer.sub(layerFillTokenAmount).toNumber());
        assert.equal(betTokenBalances.betManager.toNumber(), beforeBetTokenBalances.betManager.add(layerFillTokenAmount / 2).toNumber());

        assert.equal(fanTokenBalances.backer.toNumber(), beforeFanTokenBalances.backer.sub(backerFee / partialFillDenominator).toNumber());
        assert.equal(fanTokenBalances.layer.toNumber(), beforeFanTokenBalances.layer.toNumber());
        assert.equal(fanTokenBalances.feeRecipient.toNumber(), beforeFanTokenBalances.feeRecipient.add(backerFee/ partialFillDenominator).toNumber());
      });

      it('should transfer the correct bet token amounts if backer half loses', async () => {
        const betPayload = web3.eth.abi.encodeParameters(['uint8'], ['4']);
        bet = await betFactory.newSignedBet({betPayload}, layerFillTokenAmount);
        await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, betPayload, bet.signature, {from: layerAddress});
        await league.pushResolution.sendTransaction(defaultBetParams.fixtureId, defaultBetParams.resolverAddress, betPayload, {from:owner});

        await betManager.claimBet.sendTransaction(bet.betHash, {from: backerAddress});

        const betTokenBalances = await balanceUtils.getBalances(betToken.address, betTokenAccounts);
        const fanTokenBalances = await balanceUtils.getBalances(fanToken.address, fanTokenAccounts);

        assert.equal(betTokenBalances.backer.toNumber(), beforeBetTokenBalances.backer.sub(backerTokenStake / partialFillDenominator / 2).toNumber());
        assert.equal(betTokenBalances.layer.toNumber(), beforeBetTokenBalances.layer.sub(layerFillTokenAmount).toNumber());
        assert.equal(betTokenBalances.betManager.toNumber(), beforeBetTokenBalances.betManager
          .add(layerFillTokenAmount)
          .add(backerTokenStake / partialFillDenominator / 2).toNumber()
        );

        assert.equal(fanTokenBalances.backer.toNumber(), beforeFanTokenBalances.backer.toNumber());
        assert.equal(fanTokenBalances.layer.toNumber(), beforeFanTokenBalances.layer.toNumber());
        assert.equal(fanTokenBalances.feeRecipient.toNumber(), beforeFanTokenBalances.feeRecipient.toNumber());

      });

      it('should transfer the correct bet token amounts if backer pushes', async () => {
        const betPayload = web3.eth.abi.encodeParameters(['uint8'], ['5']);
        bet = await betFactory.newSignedBet({betPayload}, layerFillTokenAmount);
        await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, betPayload, bet.signature, {from: layerAddress});
        await league.pushResolution.sendTransaction(defaultBetParams.fixtureId, defaultBetParams.resolverAddress, betPayload, {from:owner});
        await betManager.claimBet.sendTransaction(bet.betHash, {from: backerAddress});

        const betTokenBalances = await balanceUtils.getBalances(betToken.address, betTokenAccounts);
        const fanTokenBalances = await balanceUtils.getBalances(fanToken.address, fanTokenAccounts);

        assert.equal(betTokenBalances.backer.toNumber(), beforeBetTokenBalances.backer.toNumber());
        assert.equal(betTokenBalances.layer.toNumber(), beforeBetTokenBalances.layer.sub(layerFillTokenAmount).toNumber());
        assert.equal(betTokenBalances.betManager.toNumber(), beforeBetTokenBalances.betManager.add(layerFillTokenAmount).toNumber());

        assert.equal(fanTokenBalances.backer.toNumber(), beforeFanTokenBalances.backer.toNumber());
        assert.equal(fanTokenBalances.layer.toNumber(), beforeFanTokenBalances.layer.toNumber());
        assert.equal(fanTokenBalances.feeRecipient.toNumber(), beforeFanTokenBalances.feeRecipient.toNumber());
      });
    });

    describe('Layer claim', async () => {

      let layerReturnTokenAmount = backerTokenStake / partialFillDenominator;

      beforeEach(async() => {
        await betToken.mint.sendTransaction(backerAddress, backerTokenStake);
        await betToken.mint.sendTransaction(layerAddress, layerTokenStake);
        await vault.deposit.sendTransaction(betToken.address, backerTokenStake, {from: backerAddress});
        await vault.deposit.sendTransaction(betToken.address, layerTokenStake, {from: layerAddress});
        await fanToken.mint.sendTransaction(backerAddress, backerFee);
        await fanToken.mint.sendTransaction(layerAddress, layerFee);
        await vault.deposit.sendTransaction(fanToken.address, backerFee, {from: backerAddress});
        await vault.deposit.sendTransaction(fanToken.address, layerFee, {from: layerAddress});

        betTokenAccounts = {
          backer: backerAddress,
          layer: layerAddress,
          betManager: betManager.address
        };
        fanTokenAccounts = {
          backer: backerAddress,
          layer: layerAddress,
          feeRecipient: feeRecipientAddress
        };

        beforeBetTokenBalances = await balanceUtils.getBalances(betToken.address, betTokenAccounts);
        beforeFanTokenBalances = await balanceUtils.getBalances(fanToken.address, fanTokenAccounts);
      });

      it('should transfer the correct bet token amounts and FAN Token fee if the layer wins', async () => {
        const betPayload = web3.eth.abi.encodeParameters(['uint8'], ['3']);
        bet = await betFactory.newSignedBet({betPayload}, layerFillTokenAmount);
        await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, betPayload, bet.signature, {from: layerAddress});
        await league.pushResolution.sendTransaction(defaultBetParams.fixtureId, defaultBetParams.resolverAddress, betPayload, {from:owner});
        await betManager.claimBet.sendTransaction(bet.betHash, {from: layerAddress});

        const betTokenBalances = await balanceUtils.getBalances(betToken.address, betTokenAccounts);
        const fanTokenBalances = await balanceUtils.getBalances(fanToken.address, fanTokenAccounts);

        assert.equal(betTokenBalances.backer.toNumber(), beforeBetTokenBalances.backer.sub(backerTokenStake / partialFillDenominator).toNumber());
        assert.equal(betTokenBalances.layer.toNumber(), beforeBetTokenBalances.layer.add(layerReturnTokenAmount).toNumber());
        assert.equal(betTokenBalances.betManager.toNumber(), beforeBetTokenBalances.betManager.toNumber());

        assert.equal(fanTokenBalances.backer.toNumber(), beforeFanTokenBalances.backer.toNumber());
        assert.equal(fanTokenBalances.layer.toNumber(), beforeFanTokenBalances.layer.sub(layerFee / partialFillDenominator).toNumber());
        assert.equal(fanTokenBalances.feeRecipient.toNumber(), beforeFanTokenBalances.feeRecipient.add(layerFee/ partialFillDenominator).toNumber());
      });

      it('should transfer the correct bet tokens amounts and FAN Token fees if the layer half wins', async () => {
        const betPayload = web3.eth.abi.encodeParameters(['uint8'], ['4']);
        bet = await betFactory.newSignedBet({betPayload}, layerFillTokenAmount);
        await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, betPayload, bet.signature, {from: layerAddress});
        await league.pushResolution.sendTransaction(defaultBetParams.fixtureId, defaultBetParams.resolverAddress, betPayload, {from:owner});
        await betManager.claimBet.sendTransaction(bet.betHash, {from: layerAddress});

        const betTokenBalances = await balanceUtils.getBalances(betToken.address, betTokenAccounts);
        const fanTokenBalances = await balanceUtils.getBalances(fanToken.address, fanTokenAccounts);

        assert.equal(betTokenBalances.backer.toNumber(), beforeBetTokenBalances.backer.sub(backerTokenStake / partialFillDenominator).toNumber());
        assert.equal(betTokenBalances.layer.toNumber(), beforeBetTokenBalances.layer.add(layerReturnTokenAmount / 2).toNumber());
        assert.equal(betTokenBalances.betManager.toNumber(), beforeBetTokenBalances.betManager.add(layerReturnTokenAmount / 2).toNumber());

        assert.equal(fanTokenBalances.backer.toNumber(), beforeFanTokenBalances.backer.toNumber());
        assert.equal(fanTokenBalances.layer.toNumber(), beforeFanTokenBalances.layer.sub(layerFee / partialFillDenominator).toNumber());
        assert.equal(fanTokenBalances.feeRecipient.toNumber(), beforeFanTokenBalances.feeRecipient.add(layerFee/ partialFillDenominator).toNumber());
      });

      it('should transfer the correct bet token amounts if layer half loses', async () => {
        const betPayload = web3.eth.abi.encodeParameters(['uint8'], ['2']);
        bet = await betFactory.newSignedBet({betPayload}, layerFillTokenAmount);
        await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, betPayload, bet.signature, {from: layerAddress});
        await league.pushResolution.sendTransaction(defaultBetParams.fixtureId, defaultBetParams.resolverAddress, betPayload, {from:owner});
        await betManager.claimBet.sendTransaction(bet.betHash, {from: layerAddress});

        const betTokenBalances = await balanceUtils.getBalances(betToken.address, betTokenAccounts);
        const fanTokenBalances = await balanceUtils.getBalances(fanToken.address, fanTokenAccounts);

        assert.equal(betTokenBalances.backer.toNumber(), beforeBetTokenBalances.backer.sub(layerReturnTokenAmount).toNumber());
        assert.equal(betTokenBalances.layer.toNumber(), beforeBetTokenBalances.layer.sub(layerFillTokenAmount / 2).toNumber());
        assert.equal(betTokenBalances.betManager.toNumber(), beforeBetTokenBalances.betManager
          .add(layerFillTokenAmount / 2)
          .add(backerTokenStake / partialFillDenominator).toNumber()
        );

        assert.equal(fanTokenBalances.backer.toNumber(), beforeFanTokenBalances.backer.toNumber());
        assert.equal(fanTokenBalances.layer.toNumber(), beforeFanTokenBalances.layer.toNumber());
        assert.equal(fanTokenBalances.feeRecipient.toNumber(), beforeFanTokenBalances.feeRecipient.toNumber());
      });

      it('should transfer the correct bet token amounts if layer pushes', async () => {
        const betPayload = web3.eth.abi.encodeParameters(['uint8'], ['5']);
        bet = await betFactory.newSignedBet({betPayload}, layerFillTokenAmount);
        await betManager.fillBet.sendTransaction(bet.addresses, bet.values, bet.layerTokenFillAmount, bet.salt, betPayload, bet.signature, {from: layerAddress});
        await league.pushResolution.sendTransaction(defaultBetParams.fixtureId, defaultBetParams.resolverAddress, betPayload, {from:owner});
        await betManager.claimBet.sendTransaction(bet.betHash, {from: layerAddress});

        const betTokenBalances = await balanceUtils.getBalances(betToken.address, betTokenAccounts);
        const fanTokenBalances = await balanceUtils.getBalances(fanToken.address, fanTokenAccounts);

        assert.equal(betTokenBalances.backer.toNumber(), beforeBetTokenBalances.backer.sub(backerTokenStake / partialFillDenominator).toNumber());
        assert.equal(betTokenBalances.layer.toNumber(), beforeBetTokenBalances.layer.toNumber());
        assert.equal(betTokenBalances.betManager.toNumber(), beforeBetTokenBalances.betManager.add(backerTokenStake / partialFillDenominator).toNumber());

        assert.equal(fanTokenBalances.backer.toNumber(), beforeFanTokenBalances.backer.toNumber());
        assert.equal(fanTokenBalances.layer.toNumber(), beforeFanTokenBalances.layer.toNumber());
        assert.equal(fanTokenBalances.feeRecipient.toNumber(), beforeFanTokenBalances.feeRecipient.toNumber());
      });
    });
  });
});
