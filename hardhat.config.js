require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
const dotenv = require("dotenv");
dotenv.config();

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

module.exports = {
  networks: {
    mainnet: {
      url: `https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: [`${process.env.PRIVATE_KEY}`]
    },
    bsc: {
      url: `https://bsc-dataseed.binance.org/`,
      accounts: [`${process.env.PRIVATE_KEY}`]
    },
    polygon: {
      url: `https://polygon-rpc.com/`,
      accounts: [`${process.env.PRIVATE_KEY}`]
    }
  },
  etherscan: {
    apiKey: {
      polygon: process.env.POLYGONSCAN_API_KEY
    }
  },
  solidity: {
    version: "0.8.13",
    settings: {
      evmVersion: 'istanbul',
      optimizer: {
        enabled: true,
        runs: 400,
      }
    }
  },
};
