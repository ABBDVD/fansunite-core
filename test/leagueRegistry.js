/* global assert, contract, it, before, after, afterEach, artifacts, describe */

let LeagueRegistry = artifacts.require('./LeagueRegistry');
const { ensureException } = require('./helpers/utils');
const { NULL_ADDRESS } = require('./helpers/constants');

contract('LeagueRegistry', async accounts => {

  let owner = accounts[0];
  let dummyAddressA = "0x1111111111111111111111111111111111111111";
  let instance;

  before('setup contract instance', async () => {
    instance = await LeagueRegistry.deployed();
  });

  describe('Test cases for setting registry', async () => {
    let registryContract;

    before(async () => {
      registryContract = await instance.getRegistryContract.call();
    });

    afterEach(async () => {
      await instance.setRegistryContract(registryContract);
    });

    it('should successfully set registry contract', async () => {
      await instance.setRegistryContract(dummyAddressA, { from: owner });
      let result = await instance.getRegistryContract.call();
      assert.equal(result, dummyAddressA, "registry contract cannot be updated");
    });

    it('should throw exception when non-owner tries to set registry contact', async () => {
      try {
        await instance.setRegistryContract(dummyAddressA, { from: accounts[1] });
      } catch (err) {
        ensureException(err);
        return;
      }

      assert.fail('Expected throw not received');
    });

  });

  describe('Test cases for class creation', async () => {

    before('create two new classes', async () => {
      await instance.createClass("soccer", { from: owner });
      await instance.createClass("baseball", { from: owner });
    });

    describe('Test cases for validating class creation', async () => {

      it('should support existing classes', async () => {
        let result = await instance.isClassSupported.call("tennis");
        assert.isFalse(result, "supports class that is not added");

        result = await instance.isClassSupported.call("soccer");
        assert.isTrue(result, "cannot create new classes successfully");

        result = await instance.isClassSupported.call("baseball");
        assert.isTrue(result, "cannot create new classes successfully");
      });

      it('should be able to retrieve existing classes', async () => {
        let result = await instance.getClass.call("soccer");
        assert.isArray(result, "cannot retrieve existing classes, invalid return type");
        assert.lengthOf(result, 2, "cannot retrieve existing classes, invalid return type");
        assert.equal(result[0], "soccer", "cannot retrieve existing class, invalid name returned");
        assert.isArray(result[1], "cannot retrieve existing classes, invalid");
        assert.lengthOf(result[1], 0, "new class supports non-zero leagues");
      });

    });

    describe('Test cases for invalid class creation', async () => {

      it('should throw exception when non-owner tries to creates new class', async () => {
        try {
          await instance.createClass("foo", { from: accounts[1] }); // non-owner
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

      it('should throw exception on duplicate classes', async () => {
        try {
          await instance.createClass("soccer", { from: owner });
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

    });

  });

  describe('Test cases for factories and versioning', async () => {

    let factory;

    before('adding a factory', async () => {
      factory = await instance.getFactory.call("0.0.1");
    });

    after('cleaning up to default factory', async () => {
      await instance.addFactory(factory, "0.0.1", { from: owner });
      await instance.setFactoryVersion("0.0.1", { from: owner });
    });

    it('migrations should set factory version 0.0.1 up', async () => {
      let result = await instance.getFactoryVersion.call();
      assert.equal(result, "0.0.1", "default league factory not set");
      result = await instance.getFactory.call("0.0.1");
      assert.notEqual(result, NULL_ADDRESS, "default factory has null address");
    });

    describe('Test cases for valid factory additions', async () => {

      it('should successfully update a factory', async () => {
        await instance.addFactory(dummyAddressA, "0.0.2", { from: owner });
        let result = await instance.getFactory.call("0.0.2");
        assert.equal(result, dummyAddressA, "cannot add a new factory");
        result = await instance.getFactoryVersion.call();
        assert.equal(result, "0.0.1", "factory version changed on addition");
      });

      it('should successfully set factory version', async () => {
        await instance.setFactoryVersion("0.0.2", { from: owner });
        let result = await instance.getFactoryVersion.call();
        assert.equal(result, "0.0.2", "factory version cannot be updated");
      });

    });

    describe('Test cases for invalid factory additions', async () => {

      it('should throw exception on setting invalid factory version', async () => {
        try {
          await instance.setFactoryVersion("0.0.3", { from: owner }); // no factory added for version
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

      it('should throw exception on non-owner setting factory version', async () => {
        try {
          await instance.setFactoryVersion("0.0.1", { from: accounts[1] }); // non-owner
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

      it('should throw exception on non-owner adding factory', async () => {
        try {
          await instance.addFactory(dummyAddressA, "0.0.1", { from: accounts[1] }); // non-owner
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

    });

  });

  describe('Test cases for creating leagues', async () => {

    it('should create a new league for valid class', async () => {
      let result = await instance.getClass.call("soccer");
      assert.lengthOf(result[1], 0, "new class has unexpected leagues");

      await instance.createLeague("soccer", "english-premier-league", "0x00", { from: owner });
      result = await instance.getClass.call("soccer");
      assert.lengthOf(result[1], 1, "league not added to existing class");

      let league = result[1][0];
      assert.isTrue(await instance.isLeagueRegistered.call(league), "not support added league");
      result = await instance.getLeague.call(league);
      assert.isArray(result, "cannot retrieve existing league, invalid return type");
      assert.lengthOf(result, 3, "cannot retrieve existing league, invalid return type");
      assert.equal(result[0], league, "address returned by getClass does not match getLeague");
      assert.equal(result[1], "english-premier-league", "league name not set properly");
      assert.equal(result[2], "0x00", "league details not set properly");
    });

    it('should throw exception when non-owner tries to create new league', async () => {
      try {
        await instance.createLeague("soccer", "FIFA", "0x00", { from: accounts[1] }); // non-owner
      } catch (err) {
        ensureException(err);
        return;
      }

      assert.fail('Expected throw not received');
    });

    it('should throw exception when try to create new league for invalid class', async () => {
      try {
        await instance.createLeague("DoesNotExist", "FIFA", "0x00", { from: owner });
      } catch (err) {
        ensureException(err);
        return;
      }

      assert.fail('Expected throw not received');
    });

  });

});
