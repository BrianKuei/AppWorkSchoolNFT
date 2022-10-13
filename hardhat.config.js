require("@nomicfoundation/hardhat-toolbox");
require('@openzeppelin/hardhat-upgrades');
require("@nomiclabs/hardhat-etherscan");
require('dotenv').config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    hardhat: {
    },
    goerli: {
      url: `https://goerli.infura.io/v3/${process.env.INFURA_PRIVATE_KEY}`,
      accounts: [process.env.METAMASK_GOERLI_PRIVATE_KEY]
    },
  },
  etherscan: {
    apiKey: {
      goerli: process.env.ETHER_SCAN_KEY
    }
  }
};
