/* global assert, contract, it, before, afterEach, after, artifacts, describe */

const BetLibMock = artifacts.require('./mocks/BetLibMock.sol');
const web3 = require('web3');
const { BetFactory } = require('./helpers/betFactory');

contract('BetLib', (accounts) => {

  describe('Common BetLib tests', async () => {

    let mock
      , betProps;

    const baseBet = {
      backer: accounts[0],
      layer: accounts[1],
      token: accounts[2],
      feeRecipient: accounts[3],
      league: accounts[4],
      resolver: accounts[5],
      backerStake: 1000,
      backerFee: 1,
      layerFee: 2,
      expiration: Math.round(new Date().getTime() / 1000),
      fixture: 1,
      odds: 2 * 10 ** 8,
      payload: web3.utils.randomHex(4)
    };

    const betFactory = new BetFactory(baseBet);

    before(async () => {
      mock = await BetLibMock.new();
      betProps = await betFactory.generate({});
    });

    it('should create a bet struct successfully', async () => {

      const result = await mock.generate.call(betProps.subjects, betProps.params, betProps.payload);
      assert.deepEqual(result[0], betProps.subjects);
      assert.equal(result[1][0], betProps.params[0]);
      assert.equal(result[1][1], betProps.params[1]);
      assert.equal(result[1][2], betProps.params[2]);
      assert.equal(result[1][3], betProps.params[3]);
      assert.equal(result[1][4], betProps.params[4]);
      assert.equal(result[2], betProps.payload);
    });

    it('should hash bet parameters successfully', async () => {
      const hash = await mock.hash.call(betProps.subjects, betProps.params, betProps.payload, betProps.nonce);
      assert.equal(hash, betProps.hash);
    });

    it('should return the correct backer token return', async () => {
      const result = await mock.backerTokenReturn.call(betProps.subjects, betProps.params, betProps.payload);
      assert.equal(result, (baseBet.backerStake * baseBet.odds) / (10 ** 8));
    });

  });

});
