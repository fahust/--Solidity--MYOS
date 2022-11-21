/**
 * Use this file to configure truffle.
 */
const HDWalletProvider = require("@truffle/hdwallet-provider");
require("dotenv").config();

require("ts-node").register({
  files: true,
});

module.exports = {
  networks: {
    // Useful for testing. The `development` network is used by default
    // development: {
    //   host: process.env.GANACHE_HOST,
    //   port: Number(process.env.GANACHE_PORT),
    //   network_id: "*",
    // },
    development: {
      host: 'localhost',
      port: 8545,
      network_id: "*",
      //gas: 4700000,
      //gasPrice: 20 * 1000000000
    },

    rinkeby: {
      provider: function () {
        return new HDWalletProvider(
          process.env.INFURA_MNEMONIC,
          `wss://rinkeby.infura.io/ws/v3/` + process.env.INFURA_PROJECT_RINKEBY_ID,
        );
      },
      network_id: 4,
      //gas: 4500000,
      //gasPrice: 10000000000,
    },
    matic: {
      provider: () =>
        new HDWalletProvider(
          process.env.INFURA_MNEMONIC,
          `https://polygon-mainnet.infura.io/v3/` + process.env.INFURA_APIKEY_MATIC,
        ),
      network_id: 137,
      gasPrice: 100000000000,
    },
    mumbai: {
      provider: () =>
        new HDWalletProvider(
          process.env.INFURA_MNEMONIC,
          `https://polygon-mumbai.infura.io/v3/` + process.env.INFURA_APIKEY_MUMBAI,
        ),
      network_id: 80001,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true,
    },
  },

  //plugins: ["solidity-coverage"],

  // Mocha options here.
  mocha: {
    reporter: "eth-gas-reporter",
    reporterOptions: { forceConsoleOutput: true, coinmarketcap:process.env.GAS_REPORTER_KEI, },
  },
  gasReporter: {
    enabled: true,
  },
  // Compiler configuration
  compilers: {
    solc: {
      version: process.env.SOLIDITY_VERSION,
      settings: {
        optimizer: {
          enabled: Boolean(process.env.OPTIMIZER),
          runs: Number(process.env.OPTIMIZER_RUNS),
        },
      },
    },
  },
};
