const hre = require("hardhat");

async function main() {

    const DevUSDC = await hre.ethers.getContractFactory("DevUSDC");
    const dUSDC = await DevUSDC.deploy({value: hre.ethers.utils.parseEther('1.0'),});
    
    await dUSDC.deployed();

    console.log("DevUSDC Address Contract: ", dUSDC.address)
} 

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
