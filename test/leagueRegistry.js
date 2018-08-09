/* global assert, contract, it, before, afterEach, artifacts, describe */

let LeagueRegistry = artifacts.require('./LeagueRegistry');
const { ensureException } = require('./helpers/utils');

/* eslint no-unused-vars: "off" */
contract('LeagueRegistry', async accounts => {

  let owner = accounts[0];
  let dummyAddressA = "0x1111111111111111111111111111111111111111";
  let dummyAddressB = "0x2222222222222222222222222222222222222222";

  describe('Test cases for setting registry', async () => {
    let registryContract;

    before(async () => {
      let instance = await LeagueRegistry.deployed();
      registryContract = await instance.getRegistryContract.call();
    });

    afterEach(async () => {
      let instance = await LeagueRegistry.deployed();
      await instance.setRegistryContract(registryContract);
    });

    it('should successfully set registry contract', async () => {
      let instance = await LeagueRegistry.deployed();

      await instance.setRegistryContract(dummyAddressA, { from: owner });
      let result = await instance.getRegistryContract.call();
      assert.equal(result, dummyAddressA, "registry contract cannot be updated");
    });

    it('should throw exception when non-owner tries to set registry contact', async () => {
      let instance = await LeagueRegistry.deployed();

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
      let instance = await LeagueRegistry.deployed();
      await instance.createClass("soccer", { from: owner });
      await instance.createClass("baseball", { from: owner });
    });

    describe('Test cases for validating class creation', async () => {

      it('should support existing classes', async () => {
        let instance = await LeagueRegistry.deployed();

        let result = await instance.isClassSupported.call("tennis");
        assert.isFalse(result, "supports class that is not added");

        result = await instance.isClassSupported.call("soccer");
        assert.isTrue(result, "cannot create new classes successfully");

        result = await instance.isClassSupported.call("baseball");
        assert.isTrue(result, "cannot create new classes successfully");
      });

      it('should be able to retrieve existing classes', async () => {
        let instance = await LeagueRegistry.deployed();

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
        let instance = await LeagueRegistry.deployed();

        try {
          await instance.createClass("foo", { from: accounts[1] }); // non-owner
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

      it('should throw exception on duplicate classes', async () => {
        let instance = await LeagueRegistry.deployed();

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

  it('should successfully add a factory', async () => {

  });

  it('should successfully update a factory', async () => {

  });

  it('should successfully set factory version', async () => {

  });

  it('should throw exception on setting invalid factory version', async () => {

  });

  it('should create a new league for valid class', async () => {

  });

  it('should throw exception when non-owner tries to create new league', async () => {

  });

  it('should throw exception when try to create new league for invalid class', async () => {

  });

});
