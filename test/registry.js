/* global assert, contract, it, artifacts */

const Registry = artifacts.require('./Registry.sol');
const { ensureException } = require('./helpers/utils');

contract('Registry', async accounts => {

  let owner = accounts[0];
  let dummyAddressA = "0x1111111111111111111111111111111111111111";
  let dummyAddressB = "0x2222222222222222222222222222222222222222";

  it('should successfully add address for new namekey', async () => {
    let instance = await Registry.deployed();

    let namekey = "BetManager";
    let address = dummyAddressA;

    await instance.changeAddress(namekey, address, { from: owner });
    let result = await instance.getAddress.call(namekey);
    assert.equal(result, address, 'registry does not add address for new namekey');
  });


  it('should successfully change address for existing namekey', async () => {
    let instance = await Registry.deployed();

    let namekey = "LeagueRegistry";
    let address = dummyAddressA;
    let newAddress = dummyAddressB;

    await instance.changeAddress(namekey, address, { from: owner });
    let result = await instance.getAddress.call(namekey);
    assert.equal(result, address, 'registry does not add address for new namekey');

    await instance.changeAddress(namekey, newAddress, { from: owner });
    result = await instance.getAddress.call(namekey);
    assert.equal(result, newAddress, 'registry does not change address for existing namekey');
  });

  it('should throw exception when retrieving address for namekey that dne', async () => {
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

  it('should fail when non-owner tries to update address', async () => {
    let instance = await Registry.deployed();

    let namekey = "DoesNotExist";
    try {
      await instance.changeAddress(namekey, dummyAddressA, { from: accounts[1] }); // Non-owner
    } catch (err) {
      ensureException(err);
      return;
    }

    assert.fail('Expected throw not received');
  });

});
