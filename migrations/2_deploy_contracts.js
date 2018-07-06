var ConvertLib = artifacts.require("./tokens/ConvertLib.sol");
var MetaCoin = artifacts.require("./libraries/MetaCoin.sol");

module.exports = function(deployer) {
  deployer.deploy(ConvertLib);
  deployer.link(ConvertLib, MetaCoin);
  deployer.deploy(MetaCoin);
};
