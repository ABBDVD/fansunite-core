
module.exports = {
  networks: {
    development: {
      host: 'localhost',
      port: 8545,
      network_id: '*',
    },
    mainnet: {
      host: 'localhost',
      port: 8545,
      network_id: '1',
      gas: 7900000,
      gasPrice: 10000000000
    },
    ropsten: {
      // provider: new HDWalletProvider(...),
      host: 'localhost',
      port: 8545,
      network_id: '3',
      gas: 4500000,
      gasPrice: 150000000000
    },
    kovan: {
      // provider: new HDWalletProvider(...),
      host: 'localhost',
      port: 8545,
      network_id: '42',
      gas: 7900000,
      gasPrice: 10000000000
    },
    coverage: {
      host: 'localhost',
      port: 8545,
      network_id: '15',
      gas: 0xffffffff
    }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  }
};
