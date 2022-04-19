const hre = require("hardhat");

async function main() {

    const DevUSDC = await hre.ethers.getContractFactory("Usdc");
    const dUSDC = await DevUSDC.deploy();
    
    await dUSDC.deployed();
    
    const AddrdUSDC = dUSDC.address
    console.log("DevUSDC Address Contract: ", dUSDC.address)

    const Stake = await hre.ethers.getContractFactory("StakingETH");
    const stake = await Stake.deploy(AddrdUSDC.toString());
    
    await stake.deployed();

    console.log("StakeETH Address Contract: ", stake.address)
} 

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
