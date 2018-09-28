/* global assert, contract, it, before, artifacts */

let RegistryAccessible = artifacts.require('./utils/RegistryAccessible');

contract('RegistryAccessible', async accounts => {

  it('should successfully set the chain id', async () => {
    let instance = await RegistryAccessible.new(accounts[1]);
    assert.equal(await instance.getRegistryContract.call(), accounts[1], 'registry contract was not set in contructor');
  });

});
