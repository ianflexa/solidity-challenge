# Staking ETH Dapp with rewards in devUSDC token

- User can stake their ETH (Constant APR 10%)
- User gets rewarded in devUSDC (an ERC20 token you will create as well)
- Assume that devUSDC is always worth $1
- Minimum amount to stake is 5 ETH
- User can withdraw his staked ETH at anytime along with the rewards in devUSDC
- To get the price of ETH you will need to use a price oracle from chainlink

<h3> Verified Contracts on Rinkeby testnet: </h3>

- <a target= "_blank" href="https://rinkeby.etherscan.io/address/0x24974e1304729e02f92945a1c54109737ebc55c5#code">Staking Contract</a>
- <a target= "_blank" href="https://rinkeby.etherscan.io/address/0xEE33602Dc7B6B5468Bc2b01B9385AC4a6EB3C807#code">devUSDC Contract</a>


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
