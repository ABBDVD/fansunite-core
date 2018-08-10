/* global assert, contract, it, before, afterEach, after, artifacts, describe */

let League = artifacts.require('./leagues/League001')
  , LeagueRegistry = artifacts.require('./LeagueRegistry');

let { ensureException } = require("./helpers/utils");


/* eslint no-unused-vars: "off" */
contract('League', async accounts => {

  let owner = accounts[0];
  let dummyAddressA = "0x1111111111111111111111111111111111111111";
  let instance;

  before('setup contract instance', async () => {
    let leagueRegistry = await LeagueRegistry.deployed();

    await leagueRegistry.createClass("soccer", { from: owner });
    await leagueRegistry.createLeague("soccer", "FIFA", "0x00", { from: owner });

    let result = await leagueRegistry.getClass.call("soccer");

    instance = await League.at(result[1][0]);
    assert.equal(await instance.getName.call(), "FIFA", "cannot set up league");
  });

  describe('Test cases for adding seasons', async () => {

    it("should successfully create a new season", async () => {
      let result = await instance.getSeasons.call();
      assert.isArray(result, "unexpected return type on getSeasons");
      assert.lengthOf(result, 0, "new league has unexpected seasons");

      await instance.addSeason(2018, { from: accounts[1] }); // any address (non-owner)
      result = await instance.getSeasons.call();
      assert.isArray(result, "unexpected return type on getSeasons");
      assert.lengthOf(result, 1, "season not added / cannot be retrieved");

      await instance.getSeason.call(2018); // throws exception on failure
    });

    it("should throw exception on duplicate season years", async () => {
      try {
        await instance.addSeason(2018, { from: owner });
      } catch (err) {
        ensureException(err);
        return;
      }

      assert.fail('Expected throw not received');
    });

  });

  describe('Test cases for adding participants', async () => {

  });

  describe('Test cases for scheduling fixtures', async () => {

  });

  describe('Test cases for league information', async () => {

  });

  describe('Test cases for setting up resolvers', async () => {

  });

  describe('Test cases for ConsensusManager', async () => {

    describe('Test cases for updating consensus contract', async () => {

    });

    describe('Test cases for pushing consensus', async () => {

    });

  });

});
