let Registry = artifacts.require('./Registry.sol');
let LeagueRegistry = artifacts.require('./LeagueRegistry.sol');

let LeagueLib = artifacts.require('./leagues/LeagueLib001.sol');
let LeagueFactory = artifacts.require('./leagues/LeagueFactory001.sol');

module.exports = function(deployer, networks, accounts) {
  let registry
    , leagueRegistry;

  return deployer.deploy(Registry).then(() => {
    return Registry.deployed().then(_registry => {
      registry = _registry;

      return deployer.deploy(LeagueRegistry)
        .then(() => {
          return LeagueRegistry.deployed().then((_leagueRegistry) => {
            leagueRegistry = _leagueRegistry;
            return _leagueRegistry.setRegistryContract(Registry.address);
          });
        })
        .then(() => {
          return deployer.deploy(LeagueLib);
        })
        .then(() => {
          return deployer.link(LeagueLib, LeagueFactory);
        })
        .then(() => {
          return deployer.deploy(LeagueFactory);
        })
        .then(() => {
          // TODO: Dummy ConsensusManager
          return registry.changeAddress("ConsensusManager", accounts[0]);
        })
        .then(() => {
          return registry.changeAddress("FanOrg", accounts[0]);
        })
        .then(() => {
          return registry.changeAddress("LeagueRegistry", LeagueRegistry.address);
        })
        .then(() => {
          return leagueRegistry.addLeagueFactory(LeagueFactory.address, "0.0.1")
            .then(() => {
              return leagueRegistry.setLeagueFactoryVersion("0.0.1");
            });
        })
        .then(() => {
          /* eslint no-console: "off" */
          console.log('\n');
          console.log('----- FansUnite Core Contracts -----');
          console.log('*** FansUnite Organization: ', accounts[0], '***');
          console.log('*** FansUnite Registry Address: ', Registry.address, '***');
          console.log('*** LeagueRegistry Address: ', LeagueRegistry.address, '***');
          console.log('-----------------------------------');
          console.log('\n');
        });
    });
  });
};
