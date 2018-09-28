/* global assert, contract, it, before, artifacts */

let ChainSpecifiable = artifacts.require('./utils/ChainSpecifiable');

contract('ChainSpecifiable', async accounts => {

  it('should successfully set the chain id', async () => {
    const chainId = 15;
    const newChainId = 1;

    let instance = await ChainSpecifiable.new(chainId);

    assert.equal(await instance.getChainId.call(), chainId, 'chain Id was not set in constructor');

    await instance.setChainId(newChainId, {from: accounts[0]});

    assert.equal(await instance.getChainId.call(), newChainId, 'chain Id was not changed');

  });

});
