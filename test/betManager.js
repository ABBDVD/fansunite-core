/* global assert, contract, it, before, after, afterEach, artifacts, describe */

let BetManager = artifacts.require('./BetManager');
const { ensureException } = require('./helpers/utils');
const { NULL_ADDRESS } = require('./helpers/constants');

contract('BetManager', async accounts => {

  const owner = accounts[0];
  let instance;

  before('setup contract instance', async () => {
    instance = await BetManager.deployed();
  });

  describe('Test cases for bet submission', async () => {

    describe('Test cases for validating bet submission', async () => {

    });

    describe('Test cases for invalid bet submission', async () => {

      describe('Test cases for invalid bet authentication', async () => {

        it('should revert is layer is set and sender is not layer', async () => {

        });

        it('should revert if backer is not set', async () => {

        });

        it('should revert if backer is the same as sender', async () => {

        });

        it('should revert if bet has already been submitted', async () => {

        });

      });

      describe('Test cases for invalid bet authorization', async () => {

        it('should revert if backer has not approved bet manager in the vault', async () => {

        });

        it('should revert if layer has not approved bet manager in the vault', async () => {

        });

        it('should revert if backer does not have sufficient tokens in the vault', async () => {

        });

        it('should revert if layer does not have sufficient tokens in the vault', async () => {

        });

      });

      describe('Test cases for invalid bet validation', async () => {

        it('should revert if league is not registered', async () => {

        });

        it('should revert if resolver is not registered', async () => {

        });

        it('should revert if fixture is not scheduled', async () => {

        });

        it('should revert if fixture is already resolved', async () => {

        });

        it('should revert if backer token start is not greater than zero', async () => {

        });

        it('should revert if odds are not greater than zero', async () => {

        });

        it('should revert if bet has expired', async () => {

        });

        it('should revert if bet payload is not valid', async () => {

        });

      });

    });

  });

});
