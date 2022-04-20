# Staking ETH Dapp with rewards in devUSDC token

- User can stake their ETH (Constant APR 10%)
- User gets rewarded in devUSDC (an ERC20 token you will create as well)
- Assume that devUSDC is always worth $1
- Minimum amount to stake is 5 ETH
- User can withdraw his staked ETH at anytime along with the rewards in devUSDC
- To get the price of ETH you will need to use a price oracle from chainlink

<h3> Verified Contracts on Rinkeby testnet: </h3>

- <a target= "_blank" href="https://rinkeby.etherscan.io/address/0x2d1a0103a16317A5a5E2C7F3D7233d24462F3611#code">Staking Contract</a>
- <a target= "_blank" href="https://rinkeby.etherscan.io/address/0xa7B8D9f7E716D1Ec35BFf65523bBC99205F23dc6#code">devUSDC Contract</a>


# Basic Sample Hardhat Project



This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, a sample script that deploys that contract, and an example of a task implementation, which simply lists the available accounts.

Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```
