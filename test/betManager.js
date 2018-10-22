/* global assert, contract, it, before, after, afterEach, artifacts, describe */

let BetManager = artifacts.require('./BetManager')
  , LeagueRegistry = artifacts.require('./LeagueRegistry.sol')
  , League = artifacts.require('./League001.sol')
  , Token = artifacts.require('./mocks/Token.sol')
  , Resolver = artifacts.require('./mocks/MockResolver.sol')
  , ResolverRegistry = artifacts.require('./mocks/ResolverRegistry.sol')
  , Vault = artifacts.require('./Vault.sol')
  , Web3 = require('web3');

const { ensureException } = require('./helpers/utils');
const { BetFactory } = require('./helpers/betFactory');

const { NULL_ADDRESS, TOKEN_DECIMALS, ODDS_DECIMALS } = require('./helpers/constants');

const web3 = new Web3();

contract('BetManager', async accounts => {

  const owner = accounts[0];
  const backer = accounts[1];
  const layer = accounts[2];
  const unapprovedBacker = accounts[3];
  const unapprovedLayer = accounts[4];

  let instance;
  let vault;
  let leagueRegistry;
  let league;
  let resolver;
  let resolverRegistry;
  let betManager;
  let token;

  let defaultBetParams;
  let betFactory;

  const backerStake = 100 * 10 ** TOKEN_DECIMALS;
  const layerStake = 300 * 10 ** TOKEN_DECIMALS;
  const backerOdds = 3;

  const className = 'soccer';

  before('setup and populate contracts', async () => {

    // get contracts
    instance = await BetManager.deployed();
    vault = await Vault.deployed();
    leagueRegistry = await LeagueRegistry.deployed();
    resolverRegistry = await ResolverRegistry.deployed();
    betManager = await BetManager.deployed();

    // create dummy token and mint
    token = await Token.new();
    await token.mint(backer, 1000000 * 10 ** TOKEN_DECIMALS);
    await token.mint(layer, 1000000 * 10 ** TOKEN_DECIMALS);

    // // setup vault
    await vault.addSpender(instance.address, {from: owner});
    await vault.approve(instance.address, {from: backer});
    await vault.approve(instance.address, {from: layer});
    await vault.deposit(token.address, backerStake, {from: backer});
    await vault.deposit(token.address, layerStake, {from: layer});

    // populate league registry
    await leagueRegistry.createClass(className, 2, {from: owner});
    await leagueRegistry.createLeague(className, 'EPL', {from: owner});
    const classLeagues = await leagueRegistry.getClass.call(className);
    const leagueAddress = classLeagues[1][0];

    // populate resolver registry
    resolver = await Resolver.new('0.0.1');
    await resolverRegistry.addResolver(className, resolver.address, {from: owner});
    await resolverRegistry.registerResolver(className, resolver.address, {from: owner});

    // populate league
    league = League.at(leagueAddress);
    await resolverRegistry.useResolver(leagueAddress, resolver.address, {from: owner});
    await league.addSeason(2018, {from: owner});
    await league.addParticipant('Leicester City', '0x00', {from: owner});
    await league.addParticipant('Manchester United', '0x00', {from: owner});
    await league.scheduleFixture(2018, [1,2],  Math.floor(Date.now() / 1000) + 3600, {from: owner});

    // setup default bet params
    defaultBetParams = {
      backer,
      layer,
      token: token.address,
      league: league.address,
      resolver: resolver.address,
      backerStake,
      fixture: 1,
      odds: backerOdds * 10 ** ODDS_DECIMALS,
      expiration: Math.floor(Date.now() / 1000) + 60,
      payload: web3.eth.abi.encodeParameters(['uint8'], ['1'])
    };

    betFactory = new BetFactory(defaultBetParams);
  });


  describe('Test cases for bet submission', async () => {

    describe('Test cases for validating bet submission', async () => {
      let bet;

      before('submit bet', async () => {
        bet = await betFactory.generate();
        await instance.submitBet(bet.subjects, bet.params, bet.nonce, bet.payload, bet.signature, {from: layer});
      });

      it('should successfully submit a bet for each subject', async () => {
        const backerBets = await instance.getBetsBySubject.call(backer);

        assert.isArray(backerBets, 'unexpected return type for getBetsBySubject');
        assert.lengthOf(backerBets, 1, 'bet was not added for backer');
        assert.equal(backerBets[0], bet.hash, 'bet was not added for backer');

        const layerBets = await instance.getBetsBySubject.call(layer);
        assert.equal(layerBets[0], bet.hash, 'bet was not added for layer');
      });

      it('should successfully transfer the correct tokens for the layer', async() => {
        const backerBalance = await vault.balanceOf(token.address, backer);
        assert.equal(backerBalance, 0, 'on successful bet submission, tokens were not transferred for the layer');
      });

      it('should successfully transfer the correct tokens for the backer', async() => {
        const layerBalance = await vault.balanceOf(token.address, layer);
        assert.equal(layerBalance, 0, 'on successful bet submission, tokens were not transferred for the backer');
      });

      it('should successfully transfer the correct tokens in the bet manager', async() => {
        const betManagerBalance = await vault.balanceOf(token.address, betManager.address);
        assert.equal(betManagerBalance, backerStake + layerStake,'on successful bet submission, correct token amount was not transferred to bet manager');
      });

    });

    describe('Test cases for invalid bet submission', async () => {

      beforeEach('re-initialize vault token balances', async () => {
        const backerBalance = await vault.balanceOf.call(token.address, backer);
        const layerBalance = await vault.balanceOf.call(token.address, layer);

        if (backerBalance.toNumber() > 0) await vault.withdraw(token.address, backerBalance.toNumber(), {from: backer});
        if (layerBalance.toNumber() > 0) await vault.withdraw(token.address, layerBalance.toNumber(), {from: layer});

        await vault.deposit(token.address, backerStake, {from: backer});
        await vault.deposit(token.address, layerStake, {from: layer});
      });

      describe('Test cases for invalid bet authentication', async () => {

        it('should revert if layer is set and sender is not layer', async () => {
          const bet = await betFactory.generate();
          try {
            await instance.submitBet(bet.subjects, bet.params, bet.nonce, bet.payload, bet.signature, {from: accounts[5]}); // called from non-layer
          } catch (err) {
            ensureException(err);
            return;
          }

          assert.fail('Expected throw not received');
        });

        it('should revert if backer is not set', async () => {
          const bet = await betFactory.generate();
          bet.subjects[0] = NULL_ADDRESS;
          try {
            await instance.submitBet(bet.subjects, bet.params, bet.nonce, bet.payload, bet.signature, {from: layer});
          } catch (err) {
            ensureException(err);
            return;
          }

          assert.fail('Expected throw not received');
        });

        it('should revert if backer is the same as sender', async () => {
          const bet = await betFactory.generate({backer: layer});
          try {
            await instance.submitBet(bet.subjects, bet.params, bet.nonce, bet.payload, bet.signature, {from: layer});
          } catch (err) {
            ensureException(err);
            return;
          }

          assert.fail('Expected throw not received');
        });

        it('should revert if bet has already been submitted', async () => {
          const bet = await betFactory.generate();
          await instance.submitBet(bet.subjects, bet.params, bet.nonce, bet.payload, bet.signature, {from: layer});

          await vault.deposit(token.address, backerStake, {from: backer});
          await vault.deposit(token.address, layerStake, {from: layer});

          try {
            await instance.submitBet(bet.subjects, bet.params, bet.nonce, bet.payload, bet.signature, {from: layer});
          } catch (err) {
            ensureException(err);
            return;
          }

          assert.fail('Expected throw not received');
        });

        it('should revert if signature is invalid', async () => {
          const bet = await betFactory.generate();
          const invalidSignature = Web3.utils.randomHex(66);
          try {
            await instance.submitBet(bet.subjects, bet.params, bet.nonce, bet.payload, invalidSignature, {from: layer});
          } catch (err) {
            ensureException(err);
            return;
          }

          assert.fail('Expected throw not received');
        });

      });

      describe('Test cases for invalid bet authorization', async () => {

        describe('Test cases for validating bet manager approval', async () => {

          before('mint and deposit tokens for unapproved spenders', async () => {
            await token.mint(unapprovedBacker, backerStake);
            await token.mint(unapprovedLayer, layerStake);
            await vault.deposit(token.address, backerStake, {from: unapprovedBacker});
            await vault.deposit(token.address, layerStake, {from: unapprovedLayer});
          });

          it('should revert if backer has not approved bet manager in the vault', async () => {
            const bet = await betFactory.generate({backer: unapprovedBacker});
            try {
              await instance.submitBet(bet.subjects, bet.params, bet.nonce, bet.payload, bet.signature, {from: layer});
            } catch (err) {
              ensureException(err);
              return;
            }

            assert.fail('Expected throw not received');
          });

          it('should revert if layer has not approved bet manager in the vault', async () => {
            const bet = await betFactory.generate({layer: unapprovedLayer});
            try {
              await instance.submitBet(bet.subjects, bet.params, bet.nonce, bet.payload, bet.signature, {from: unapprovedLayer});
            } catch (err) {
              ensureException(err);
              return;
            }

            assert.fail('Expected throw not received');
          });

        });

        describe('Test cases for token balance validation', async () => {

          it('should revert if backer does not have sufficient tokens in the vault', async () => {
            const backerBalance = await vault.balanceOf.call(token.address, backer);
            const bet = await betFactory.generate({
              backerStake: backerBalance.toNumber() + (10 ** ODDS_DECIMALS),
              odds: 2 * 10 ** ODDS_DECIMALS
            });
            try {
              await instance.submitBet(bet.subjects, bet.params, bet.nonce, bet.payload, bet.signature, {from: layer});
            } catch (err) {
              ensureException(err);
              return;
            }

            assert.fail('Expected throw not received');
          });

          it('should revert if layer does not have sufficient tokens in the vault', async () => {
            const bet = await betFactory.generate({odds: 4 * 10 ** ODDS_DECIMALS});
            try {
              await instance.submitBet(bet.subjects, bet.params, bet.nonce, bet.payload, bet.signature, {from: layer});
            } catch (err) {
              ensureException(err);
              return;
            }

            assert.fail('Expected throw not received');
          });

        });

      });

      describe('Test cases for invalid bet validation', async () => {

        it('should revert if league is not registered', async () => {
          const bet = await betFactory.generate({league: NULL_ADDRESS});
          try {
            await instance.submitBet(bet.subjects, bet.params, bet.nonce, bet.payload, bet.signature, {from: layer});
          } catch (err) {
            ensureException(err);
            return;
          }

          assert.fail('Expected throw not received');
        });

        it('should revert if resolver is not registered', async () => {
          const bet = await betFactory.generate({resolver: NULL_ADDRESS});
          try {
            await instance.submitBet(bet.subjects, bet.params, bet.nonce, bet.payload, bet.signature, {from: layer});
          } catch (err) {
            ensureException(err);
            return;
          }

          assert.fail('Expected throw not received');
        });

        it('should revert if fixture is not scheduled', async () => {
          const bet = await betFactory.generate({fixture: 2});
          try {
            await instance.submitBet(bet.subjects, bet.params, bet.nonce, bet.payload, bet.signature, {from: layer});
          } catch (err) {
            ensureException(err);
            return;
          }

          assert.fail('Expected throw not received');
        });

        it('should revert if fixture is already resolved', async () => {
          const resolver = await Resolver.new('0.0.1');
          await resolverRegistry.addResolver(className, resolver.address, {from: owner});
          await resolverRegistry.registerResolver(className, resolver.address, {from: owner});
          await resolverRegistry.useResolver(league.address, resolver.address, {from: owner});
          await league.pushResolution(1, resolver.address, web3.eth.abi.encodeParameters(['uint8'], ['1']));

          const bet = await betFactory.generate({resolver: resolver.address});
          try {
            await instance.submitBet(bet.subjects, bet.params, bet.nonce, bet.payload, bet.signature, {from: layer});
          } catch (err) {
            ensureException(err);
            return;
          }

          assert.fail('Expected throw not received');
        });

        it('should revert if backer token stake is not greater than zero', async () => {
          const bet = await betFactory.generate({backerStake: 0});
          try {
            await instance.submitBet(bet.subjects, bet.params, bet.nonce, bet.payload, bet.signature, {from: layer});
          } catch (err) {
            ensureException(err);
            return;
          }

          assert.fail('Expected throw not received');
        });

        it('should revert if odds are not greater than zero', async () => {
          const bet = await betFactory.generate({odds: 0});
          try {
            await instance.submitBet(bet.subjects, bet.params, bet.nonce, bet.payload, bet.signature, {from: layer});
          } catch (err) {
            ensureException(err);
            return;
          }

          assert.fail('Expected throw not received');
        });

        it('should revert if bet has expired', async () => {
          const bet = await betFactory.generate({expiration: Math.floor(Date.now() / 1000) - 3600});
          try {
            await instance.submitBet(bet.subjects, bet.params, bet.nonce, bet.payload, bet.signature, {from: layer});
          } catch (err) {
            ensureException(err);
            return;
          }

          assert.fail('Expected throw not received');
        });

        it('should revert if bet payload is not valid', async () => {
          const bet = await betFactory.generate({payload: web3.eth.abi.encodeParameters(['uint8'], ['0'])});
          try {
            await instance.submitBet(bet.subjects, bet.params, bet.nonce, bet.payload, bet.signature, {from: layer});
          } catch (err) {
            ensureException(err);
            return;
          }

          assert.fail('Expected throw not received');
        });

      });

    });

  });

});
