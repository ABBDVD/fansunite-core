/* global assert, contract, it, before, after, afterEach, artifacts, describe */

let ResolverRegistry = artifacts.require('./ResolverRegistry')
  , LeagueRegistry = artifacts.require('./LeagueRegistry')
  , { ensureException } = require('./helpers/utils')
  , Web3 = require('web3');

contract('LeagueRegistry', async accounts => {

  let instance;
  const owner = accounts[0];
  const supportedClass = 'soccer';
  const unsupportedClass = 'unsupported';

  before('setup contract instance', async () => {
    instance = await ResolverRegistry.deployed();
  });

  describe('Test cases for adding a resolver', async () => {

    before('add class to league registry', async () => {
      const leagueRegInstance = await LeagueRegistry.deployed();
      await leagueRegInstance.createClass(supportedClass, 2);

    });

    describe('Test cases for valid resolver addition', async () => {

      it('should successfully add a resolver', async () => {
        const resolver = Web3.utils.randomHex(20);
        await instance.addResolver(supportedClass, resolver);
        const result = await instance.isResolverRegistered(supportedClass, resolver);

        assert.equal(result.toNumber(), 1, 'Resolver was not registered');
      });

    });

    describe('Test cases for invalid resolver addition', async () => {

      it('should revert if resolver has already been registered for class', async () => {
        const resolver = Web3.utils.randomHex(20);
        await instance.addResolver(supportedClass, resolver);
        await instance.registerResolver(supportedClass, resolver, {from: owner});
        try {
          await instance.addResolver(supportedClass, resolver);
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

      it('should revert if resolver is already pending registration for class', async () => {
        const resolver = Web3.utils.randomHex(20);
        await instance.addResolver(supportedClass, resolver);

        try {
          await instance.addResolver(supportedClass, resolver);
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

      it('should revert if resolver is been rejected', async () => {
        const resolver = Web3.utils.randomHex(20);
        await instance.addResolver(supportedClass, resolver);
        await instance.rejectResolver(supportedClass, resolver, {from: owner});

        try {
          await instance.addResolver(supportedClass, resolver);
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

      it('should revert if class is not supported', async () => {
        const resolver = Web3.utils.randomHex(20);

        try {
          await instance.addResolver(unsupportedClass, resolver);
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

    });

  });

  describe('Test cases for registering a resolver', async () => {

    describe('Test cases for valid resolver registration', async () => {

      it('should successfully register a resolver', async () => {
        const resolver = Web3.utils.randomHex(20);
        await instance.addResolver(supportedClass, resolver);
        await instance.registerResolver(supportedClass, resolver, {from: owner});
        const result = await instance.isResolverRegistered(supportedClass, resolver);

        assert.equal(result.toNumber(), 2, 'Resolver was not registered');
      });

    });

    describe('Test cases for invalid resolver registration', async () => {

      it('should revert if resolver has already been registered for class', async () => {
        const resolver = Web3.utils.randomHex(20);
        await instance.addResolver(supportedClass, resolver);
        await instance.registerResolver(supportedClass, resolver, {from: owner});

        try {
          await instance.registerResolver(supportedClass, resolver, {from: owner});
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

      it('should revert if class is not registers', async () => {
        // TODO?
      });

      it('should revert if called by non-owner', async () => {
        const resolver = Web3.utils.randomHex(20);
        await instance.addResolver(supportedClass, resolver);

        try {
          await instance.registerResolver(supportedClass, resolver, {from: accounts[1]});
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

    });

  });

  describe('Test cases for rejecting a resolver', async () => {

    describe('Test cases for valid resolver rejection', async () => {

      it('should successfully reject a resolver', async () => {
        const resolver = Web3.utils.randomHex(20);
        await instance.addResolver(supportedClass, resolver);
        await instance.rejectResolver(supportedClass, resolver, {from: owner});
        const result = await instance.isResolverRegistered(supportedClass, resolver);

        assert.equal(result.toNumber(), 0, 'Resolver was not registered');
      });

    });

    describe('Test cases for invalid resolver rejection', async () => {

      it('should revert if resolver has already been rejected for class', async () => {
        const resolver = Web3.utils.randomHex(20);
        await instance.addResolver(supportedClass, resolver);
        await instance.rejectResolver(supportedClass, resolver, {from: owner});

        try {
          await instance.rejectResolver(supportedClass, resolver, {from: owner});
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

      it('should revert if resolver has already been registered', async () => {
        const resolver = Web3.utils.randomHex(20);
        await instance.addResolver(supportedClass, resolver);
        await instance.registerResolver(supportedClass, resolver, {from: owner});

        try {
          await instance.rejectResolver(supportedClass, resolver, {from: owner});
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

      it('should revert if called by non-owner', async () => {
        const resolver = Web3.utils.randomHex(20);
        await instance.addResolver(supportedClass, resolver);

        try {
          await instance.rejectResolver(supportedClass, resolver, {from: accounts[1]});  // non-owner
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

    });

  });

  describe('Test cases for nuking resolver', async () => {

    let resolver;

    beforeEach('add and register resolver', async () => {
      resolver = Web3.utils.randomHex(20);
      await instance.addResolver(supportedClass, resolver);
      await instance.registerResolver(supportedClass, resolver, {from: owner});
    });

    describe('Test cases for valid resolver nuke', async () => {

      it('should successfully nuke a resolver', async () => {
        const resolverIndex = 1;

        const resolverListBefore = await instance.getResolvers.call(supportedClass);
        const unregisterResolver = resolverListBefore[resolverIndex];

        await instance.nukeResolver(supportedClass, resolverIndex, {from: owner});
        const resolverListAfter = await instance.getResolvers.call(supportedClass);

        assert.lengthOf(resolverListAfter, resolverListBefore.length - 1, "Resolver list length did not decrease");

        resolverListBefore.splice(resolverIndex, 1, resolverListBefore.pop());
        assert.deepEqual(resolverListBefore, resolverListAfter, "Resolver was not removed from array");

        const result = await instance.isResolverRegistered(supportedClass, unregisterResolver);
        assert.equal(result.toNumber(), 0, "Resolver has not been set to rejected");
      });

    });

    describe('Test cases for invalid resolver nuke', async () => {

      it('should revert if index provided is out of bounds', async () => {
        const resolverList = await instance.getResolvers.call(supportedClass);
        try {
          await instance.nukeResolver(supportedClass, resolverList.length, {from: owner});
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

      it('should revert if resolver is not registered', async () => {
        // TODO will this ever happen?
      });

      it('should revert if called by non-owner', async () => {
        try {
          await instance.nukeResolver(supportedClass, 1, {from: accounts[1]});  // non-owner
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

    });

  });

});
