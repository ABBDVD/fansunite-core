let Registry = artifacts.require('./Registry.sol');
let LeagueRegistry = artifacts.require('./LeagueRegistry.sol');
let LeagueLib = artifacts.require('./leagues/LeagueLib001.sol');
let LeagueFactory = artifacts.require('./leagues/LeagueFactory001.sol');
let Vault = artifacts.require('./vault/Vault.sol');

module.exports = function(deployer, networks, accounts) {
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

          return deployer.deploy(LeagueRegistry)
            .then(() => {
              return LeagueRegistry.deployed();
            })
            .then((_leagueRegistry) => {
              leagueRegistry = _leagueRegistry;
              return _leagueRegistry.setRegistryContract(Registry.address);
            })
            .then(() => {
              return leagueRegistry.addFactory(LeagueFactory.address, "0.0.1");
            })
            .then(() => {
              return leagueRegistry.setFactoryVersion("0.0.1");
            });
        })
        .then(() => {
          return deployer.deploy(Vault)
            .then(() => {
              return Vault.deployed();
            })
            .then(_vault => {
              return _vault.setRegistryContract(Registry.address);
            });
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
          /* eslint no-console: "off" */
          console.log('\n');
          console.log('----- FansUnite Core Contracts -----');
          console.log('*** FansUnite Organization: ', accounts[0], '***');
          console.log('*** FansUnite Registry Address: ', Registry.address, '***');
          console.log('*** LeagueRegistry Address: ', LeagueRegistry.address, '***');
          console.log('*** FansUnite Vault Address: ', Vault.address, '***');
          console.log('-----------------------------------');
          console.log('\n');
        });
    });
  });
};
