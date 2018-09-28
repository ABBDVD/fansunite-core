/* global assert, contract, it, before, artifacts, describe */

let RMoneyLine2 = artifacts.require('./resolvers/RMoneyLine2')
  , LeagueRegistry = artifacts.require('./LeagueRegistry.sol')
  , League = artifacts.require('./League001.sol')
  , Web3 = require('web3');

const { ensureException } = require('./helpers/utils');

const web3 = new Web3();

contract('RMoneyLine2', async accounts => {
  let instance;
  const version = '0.0.1';
  const owner = accounts[0];

  before(async () => {
    instance = await RMoneyLine2.new(version);
  });

  describe('Test cases for constructor', async () => {

    it('should successfully set version in constructor', async () => {
      assert.isTrue(await instance.doesSupportVersion.call(version), 'version was not set in constructor');
    });

    it('should successfully support a new version', async () => {
      await instance.supportVersion('0.0.2', {from: accounts[0]});
      assert.isTrue(await instance.doesSupportVersion.call('0.0.2'), 'new version was added');
    });

    it('should revert if version is already supported', async () => {
      try {
        await instance.supportVersion('0.0.1', {from: accounts[0]});
      } catch (err) {
        ensureException(err);
        return;
      }

      assert.fail('Expected throw not received');
    });

  });

  describe('Test cases for resolver information', async () => {

    it('should return the correct signature for the init function', async () => {
      assert.equal(await instance.getInitSignature.call(), 'resolve(address,uint256,uint256,uint256[])');
    });

    it('should return the correct init selector', async () => {
      assert.equal(await instance.getInitSelector.call(), web3.eth.abi.encodeFunctionSignature('resolve(address,uint256,uint256,uint256[])'));
    });

    it('should return the correct validator signature', async () => {
      assert.equal(await instance.getValidatorSignature.call(), 'validate(address,uint256,uint256)');
    });
    it('should return the correct validator selector', async () => {
      assert.equal(await instance.getValidatorSelector.call(), web3.eth.abi.encodeFunctionSignature('validate(address,uint256,uint256)'));
    });

    it('should return the correct description', async () => {
      assert.equal(await instance.getDescription.call(), 'Common MoneyLine Resolver: Betting on who wins the fixture');
    });

    it('should return the correct type', async () => {
      assert.equal(await instance.getType.call(), 'Moneyline');
    });

    it('should return the correct details', async () => {
      assert.equal(await instance.getDetails.call(), '0x');
    });

  });

  describe('Test cases for validation and resolution', async () => {

    let leagueAddress;

    before('populate', async () => {
      const leagueRegistry = await LeagueRegistry.deployed();
      const className = 'soccer';
      await leagueRegistry.createClass(className, 2, {from: owner});
      await leagueRegistry.createLeague(className, 'EPL', {from: owner});
      const classLeagues = await leagueRegistry.getClass.call(className);
      leagueAddress = classLeagues[1][0];

      const league = League.at(leagueAddress);
      await league.addSeason(2018, {from: owner});
      await league.addParticipant('Leicester City', '0x00', {from: owner});
      await league.addParticipant('Manchester United', '0x00', {from: owner});
      await league.scheduleFixture(2018, [1,2],  Math.floor(Date.now() / 1000) + 3600, {from: owner});
    });

    describe('Test cases for validation', async () => {

      it('should return `true` if valid league, fixture and winner are provided', async () => {
        assert.isTrue(await instance.validate.call(leagueAddress, 1, 1));
      });

      it('should revert if invalid league was provided', async () => {
        try {
          await instance.validate.call(accounts[1], 1, 1);
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

      it('should revert if invalid fixture was provided', async () => {
        try {
          await instance.validate.call(leagueAddress, 99, 1);
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

      it('should revert if invalid winner was provided', async () => {
        try {
          await instance.validate.call(leagueAddress, 1, 99);
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

    });

    describe('Test cases for resolution', async() => {

      describe('Test cases for valid resolution', async () => {

        describe('Test cases for bWinner is 0', async () => {

          const bWinner = 0;

          it('should return `2` if score is a draw', async () => {
            const result = await instance.resolve(leagueAddress, 1, bWinner, [0, 0]);
            assert.equal(result.toNumber(), 2);
          });

          it('should return `1` if score is 1-0', async () => {
            const result = await instance.resolve(leagueAddress, 1, bWinner, [1, 0]);
            assert.equal(result.toNumber(), 1);
          });

          it('should return `1` if score is 0-1', async () => {
            const result = await instance.resolve(leagueAddress, 1, bWinner, [0, 1]);
            assert.equal(result.toNumber(), 1);
          });

        });

        describe('Test cases for bWinner is 1', async () => {

          const bWinner = 1;

          it('should return `1` if score is a draw', async () => {
            const result = await instance.resolve(leagueAddress, 1, bWinner, [0, 0]);
            assert.equal(result.toNumber(), 1);
          });

          it('should return `2` if score is 1-0', async () => {
            const result = await instance.resolve(leagueAddress, 1, bWinner, [1, 0]);
            assert.equal(result.toNumber(), 2);
          });

          it('should return `1` if score is 0-1', async () => {
            const result = await instance.resolve(leagueAddress, 1, bWinner, [0, 1]);
            assert.equal(result.toNumber(), 1);
          });

        });

        describe('Test cases for bWinner is 2', async () => {

          const bWinner = 2;

          it('should return `1` if score is draw', async () => {
            const result = await instance.resolve(leagueAddress, 1, bWinner, [0, 0]);
            assert.equal(result.toNumber(), 1);
          });

          it('should return `1` if score is 1-0', async () => {
            const result = await instance.resolve(leagueAddress, 1, bWinner, [1, 0]);
            assert.equal(result.toNumber(), 1);
          });

          it('should return `2` if score is 0-1', async () => {
            const result = await instance.resolve(leagueAddress, 1, bWinner, [0, 1]);
            assert.equal(result.toNumber(), 2);
          });

        });

      });

      describe('Test cases for invalid resolution', async () => {

        it('should revert if invalid league was provided', async () => {
          try {
            await instance.resolve.call(accounts[1], 1, 1, [0, 0]);
          } catch (err) {
            ensureException(err);
            return;
          }

          assert.fail('Expected throw not received');
        });

        it('should revert if invalid fixture was provided', async () => {
          try {
            await instance.resolve.call(leagueAddress, 99, 1, [0,0]);
          } catch (err) {
            ensureException(err);
            return;
          }

          assert.fail('Expected throw not received');
        });

        it('should revert if invalid winner was provided', async () => {
          // TODO: should this be?
        });

      });

    });

  });

});
