/* global assert, contract, it, before, afterEach, after, artifacts, describe */

let League = artifacts.require('./leagues/League001')
  , LeagueRegistry = artifacts.require('./LeagueRegistry');

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

});
