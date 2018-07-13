/* global assert, contract, it */

const Registry = artifacts.require('./Registry.sol');
const { ensureException } = require('./helpers/utils');

contract('Registry', async accounts => {

  it('should successfully add address for namekey that does not exist in registry', async () => {
    let instance = await Registry.deployed();

    let namekey = "BetManager";
    let address = accounts[1];

    await instance.changeAddress(namekey, address, { from: accounts[0] });
    let result = await instance.getAddress.call(namekey);
    assert.equal(result, address, 'registry does not add address for new namekey');
  });


  it('should successfully change address for existing namekey', async () => {
    let instance = await Registry.deployed();

    let namekey = "LeagueRegistry";
    let address = accounts[1];
    let new_address = accounts[2];

    await instance.changeAddress(namekey, address, { from: accounts[0] });
    let result = await instance.getAddress.call(namekey);
    assert.equal(result, address, 'registry does not add address for new namekey');

    await instance.changeAddress(namekey, new_address, { from: accounts[0] });
    result = await instance.getAddress.call(namekey);
    assert.equal(result, new_address, 'registry does not change address for existing namekey');
  });

  it('should throw exception when retrieving address for namekey that does not exist', async () => {
    let instance = await Registry.deployed();

    let namekey = "DoesNotExist";
    try {
      await instance.getAddress.call(namekey);
    } catch (err) {
      ensureException(err);
      return;
    }

    assert.fail('Expected throw not received');
  });

});
