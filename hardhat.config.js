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
  },
  etherscan: {
    apiKey: process.env.STAGING_ETHERSCAN_KEY,
  }
};
