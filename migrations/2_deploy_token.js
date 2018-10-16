let FanToken = artifacts.require('./tokens/FanToken.sol');

module.exports = function(deployer) {
  return deployer.deploy(FanToken)
    .then(() => {
      /* eslint no-console: "off" */
      console.log('\n');
      console.log('----- FansUnite Token -----');
      console.log('*** FanToken: ', FanToken.address, '***');
      console.log('-----------------------------------');
      console.log('\n');
    });
};
