import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";
import 'solidity-coverage';
import 'hardhat-gas-reporter';
import '@openzeppelin/hardhat-upgrades';
import "hardhat-interface-generator";
import 'solidity-docgen';
require('hardhat-contract-sizer');
require('dotenv').config();

const config = {
  solidity: {
    version: "0.8.18",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  paths: {
    sources: "./contracts/",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
    strict: true,
  },
  defaultNetwork: "hardhat",
  gasReporter: {
    currency: 'USD',
    gasPrice: 100,
    enabled: true,
  },
  networks: {
    optimism: {
      url: process.env.OPTIMISM_RPC_URL,
      // You can get the accounts from a node using `brownie accounts list`
      accounts: [process.env.PRIVATE_KEY],
    },
    opGoerli: {
      url: process.env.OPTIMISM_GOERLI_RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
    goerli: {
      url: process.env.GOERLI_RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: process.env.OPSCAN_API_KEY,
  },
  docgen: { pages: "files", templates: "./docs/templates" },
};

export default config;
