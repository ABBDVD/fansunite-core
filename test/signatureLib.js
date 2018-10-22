/* global assert, contract, it, artifacts, beforeEach */

let SignatureLibMock = artifacts.require('./mocks/SignatureLibMock.sol')
  , Web3 = require('web3')
  , web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:8545"));


contract('SignatureValidator', function (accounts) {

  const data = "0xb9caf644225739cd2bda9073346357ae4a0c3d71809876978bd81cc702b7fdc7";

  let mock;

  beforeEach(async () => {
    mock = await SignatureLibMock.new();
  });

  it('should validate geth signature', async () => {

    let sig = (await web3.eth.sign(data, accounts[0])).slice(2);

    let r = Buffer.from(sig.substring(0, 64), 'hex');
    let s = Buffer.from(sig.substring(64, 128), 'hex');
    let v = Buffer.from((parseInt(sig.substring(128, 130), 16) + 27).toString(16), 'hex');
    let mode = Buffer.from('01', 'hex');

    let signature = '0x' + Buffer.concat([mode, v, r, s]).toString('hex');

    assert.equal(true, await mock.isValidSignature.call(data, accounts[0], signature));
  });

  it('should return correct signer', async () => {
    let sig = (await web3.eth.sign(data, accounts[0])).slice(2);

    let r = Buffer.from(sig.substring(0, 64), 'hex');
    let s = Buffer.from(sig.substring(64, 128), 'hex');
    let v = Buffer.from((parseInt(sig.substring(128, 130), 16) + 27).toString(16), 'hex');
    let mode = Buffer.from('01', 'hex');

    let signature = '0x' + Buffer.concat([mode, v, r, s]).toString('hex');

    assert.equal(accounts[0], await mock.recover.call(data, signature));
  });

});
