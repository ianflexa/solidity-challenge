const hre = require("hardhat");

async function main() {

    const Stake = await hre.ethers.getContractFactory("StakingETH");
    const stake = await Stake.deploy("0xaA62A6470811beaE2c4090f41Ce4Eb40b6A2B477"); //test
    
    await stake.deployed();

    console.log("StakeETH Address Contract: ", stake.address)
} 

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
