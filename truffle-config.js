require('@babel/register')
const { alchemy } = require('./secrets')
const HDWalletProvider = require('truffle-hdwallet-provider')

// this mnemonic is used to generate accounts (address, public & priv keys)
// used to "pay" for deployment of smart contract.
const mnemonic = 'busy receive bunker accident course cave walnut absurd chief gas series great'

// this is where the npm deploy:local/ deploy:rinkeby
// choose between local and testnet
module.exports = {
  networks: {
    development: {
      host: '127.0.0.1',
      port: 7545,
      network_id: '*' // Match any network id
    },
    rinkeby: {
      // using truffle-hdwallet-provider package to generate account from mnemonic
      // in metamask with eth on it (the account we created with eth on rinkeby)
      // to connect to infura and make request through their node to publish
      // on rinkeby's testnet
      provider: function () {
        return new HDWalletProvider(mnemonic,
          alchemy)
      },
      network_id: 4
    }
  },
  contracts_directory: './contracts/',
  contracts_build_directory: './abis/',
  compilers: {
    solc: {
      optimizer: {
        enabled: true,
        runs: 200
      },
      version: '0.7.5'
    }
  }
}
