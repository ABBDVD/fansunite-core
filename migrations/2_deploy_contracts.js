let ConvertLib = artifacts.require('./tokens/ConvertLib.sol');
let MetaCoin = artifacts.require('./libraries/MetaCoin.sol');
let Registry = artifacts.require('./Registry.sol');

module.exports = function(deployer) {
  deployer.deploy(ConvertLib);
  deployer.link(ConvertLib, MetaCoin);
  deployer.deploy(MetaCoin);

  deployer.deploy(Registry)
};
