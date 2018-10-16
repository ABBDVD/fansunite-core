let Registry = artifacts.require('./Registry.sol');
let FanToken = artifacts.require('./tokens/FanToken.sol');
let LeagueRegistry = artifacts.require('./LeagueRegistry.sol');
let ResolverRegistry = artifacts.require('./ResolverRegistry.sol');
let LeagueLib = artifacts.require('./leagues/LeagueLib001.sol');
let LeagueFactory = artifacts.require('./leagues/LeagueFactory001.sol');
let Vault = artifacts.require('./vault/Vault.sol');
let BetManager = artifacts.require('./BetManager.sol');
let truffle = require('../truffle');

module.exports = function(deployer, network, accounts) {
  let registry;

  return deployer.deploy(Registry).then(() => {
    return Registry.deployed().then(_registry => {
      registry = _registry;

      return deployer.deploy(LeagueLib)
        .then(() => {
          return deployer.link(LeagueLib, LeagueFactory);
        })
        .then(() => {
          return deployer.deploy(LeagueFactory);
        })
        .then(() => {
          let leagueRegistry;

          return deployer.deploy(LeagueRegistry, Registry.address)
            .then(() => {
              return LeagueRegistry.deployed();
            })
            .then((_leagueRegistry) => {
              leagueRegistry = _leagueRegistry;
              return leagueRegistry.addFactory(LeagueFactory.address, "0.0.1");
            })
            .then(() => {
              return leagueRegistry.setFactoryVersion("0.0.1");
            });
        })
        .then(() => {
          return deployer.deploy(FanToken);
        })
        .then(() => {
          return deployer.deploy(ResolverRegistry, Registry.address);
        })
        .then(() => {
          return deployer.deploy(Vault, Registry.address);
        })
        .then(() => {
          return deployer.deploy(BetManager, truffle.networks[network].network_id, Registry.address);
        })
        .then(() => {
          // FanOrg is ConsensusManager until Oracles are in place
          return registry.changeAddress("ConsensusManager", accounts[0]);
        })
        .then(() => {
          return registry.changeAddress("FanOrg", accounts[0]);
        })
        .then(() => {
          return registry.changeAddress("LeagueRegistry", LeagueRegistry.address);
        })
        .then(() => {
          return registry.changeAddress("FanVault", Vault.address);
        })
        .then(() => {
          return registry.changeAddress("ResolverRegistry", ResolverRegistry.address);
        })
        .then(() => {
          return registry.changeAddress("BetManager", BetManager.address);
        })
        .then(() => {
          return registry.changeAddress("FanToken", FanToken.address);
        })
        .then(() => {
          /* eslint no-console: "off" */
          console.log('\n');
          console.log('----- FansUnite Core Contracts -----');
          console.log('*** FansUnite Organization: ', accounts[0], '***');
          console.log('*** FansUnite Token: ', FanToken.address, '***');
          console.log('*** FansUnite Registry Address: ', Registry.address, '***');
          console.log('*** LeagueRegistry Address: ', LeagueRegistry.address, '***');
          console.log('*** ResolverRegistry Address: ', ResolverRegistry.address, '***');
          console.log('*** FansUnite Vault Address: ', Vault.address, '***');
          console.log('*** BetManager Address: ', BetManager.address, '***');
          console.log('-----------------------------------');
          console.log('\n');
        });
    });
  });
};
