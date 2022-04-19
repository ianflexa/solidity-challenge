require("@nomiclabs/hardhat-waffle");
require('dotenv').config();
require("@nomiclabs/hardhat-etherscan");


module.exports = {
  solidity: '0.8.7',
  networks: {
    rinkeby: {
      url: process.env.STAGING_ALCHEMY_KEY, 
      accounts: [process.env.PRIVATE_KEY],
    },
    hardhat: {
      forking: {
        url: process.env.STAGING_ALCHEMY_KEY_MAINNET,
        blockNumber: 12257477 // 2021-04-17T12:00:00Z
      }
    },
  },
  etherscan: {
    apiKey: process.env.STAGING_ETHERSCAN_KEY,
  }
};
