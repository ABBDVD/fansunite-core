/* global assert, contract, it, before, afterEach, after, artifacts, describe, web3 */

let League = artifacts.require('./leagues/League001')
  , LeagueRegistry = artifacts.require('./LeagueRegistry');

contract('League', async accounts => {

  let owner = accounts[0];


  describe('Gas costs for deploying League related contracts', async () => {

    it("Should deploy leagueRegistry with less than 4.7 mil gas", async () => {
      let registry = await LeagueRegistry.new();
      let receipt = await web3.eth.getTransactionReceipt(registry.transactionHash);
      assert.isBelow(receipt.gasUsed, 4700000); // 1407527
    });

    it("Should deploy league with less than 4.7 mil gas", async () => {
      let registry = await LeagueRegistry.deployed();

      await registry.createClass("soccer", { from: owner });
      let tx = await registry.createLeague("soccer", "FIFA", "0x00", { from: owner });
      assert.isBelow(tx.receipt.gasUsed, 4700000); // 1599294
    });


  });

});
