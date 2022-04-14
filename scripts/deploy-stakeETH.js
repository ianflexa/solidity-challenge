const hre = require("hardhat");

async function main() {

    const Stake = await hre.ethers.getContractFactory("StakingETH");
    const stake = await Stake.deploy("0xEE33602Dc7B6B5468Bc2b01B9385AC4a6EB3C807"); //test
    
    await stake.deployed();

    console.log("StakeETH Address Contract: ", stake.address)
} 

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
