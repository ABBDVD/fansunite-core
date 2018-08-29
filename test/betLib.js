/* global assert, contract, it, before, afterEach, after, artifacts, describe */

const BetLibMock = artifacts.require('./mocks/BetLibMock.sol');
const web3 = require('web3');
const { BetFactory } = require('./helpers/betFactory');

contract('BetLib', (accounts) => {

  describe('Common BetLib tests', async () => {

    let mock;

    const betParams = {
      backer: accounts[0],
      layer: accounts[1],
      backerToken: accounts[2],
      layerToken: accounts[3],
      feeRecipient: accounts[4],
      league: accounts[5],
      resolver: accounts[6],
      backerStake: 1000,
      backerFee: 1,
      layerFee: 2,
      expiration: Math.round(new Date().getTime() / 1000),
      fixture: 1,
      odds: 2 * 10 ** 8,
      payload: web3.utils.randomHex(4)
    };

    const betFactory = new BetFactory(betParams);
    let bet;

    before(async () => {
      mock = await BetLibMock.new();
      bet = await betFactory.newSignedBet({});
    });

    it('should create a bet struct successfully', async () => {

      const result = await mock.createBet.call(bet.addresses, bet.values, bet.payload);
      assert.deepEqual(result[0], bet.addresses);
      assert.equal(result[1][0], bet.values[0]);
      assert.equal(result[1][1], bet.values[1]);
      assert.equal(result[1][2], bet.values[2]);
      assert.equal(result[1][3], bet.values[3]);
      assert.equal(result[1][4], bet.values[4]);
      assert.equal(result[2], bet.payload);
    });

    it('should hash bet parameters successfully', async () => {
      const hash = await mock.hash.call(bet.addresses, bet.values, bet.nonce, bet.payload);
      assert.equal(hash, bet.betHash);
    });

    it('should return the correct backer token return', async () => {
      const result = await mock.backerTokenReturn.call(bet.addresses, bet.values, bet.payload);
      assert.equal(result, (betParams.backerStake * betParams.odds) / (10 ** 8));
    });

  });

});
