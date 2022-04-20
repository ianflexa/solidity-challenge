const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("Staking Challenge Tests", function () {

    let Token;
    let rToken;
    let Stake;
    let stakev5;
    let owner;
    let addr1;
    let addr2;

    beforeEach(async function () {

        Token = await ethers.getContractFactory("Usdc");
        Stake = await ethers.getContractFactory("StakingETH");
        [owner, addr1, addr2] = await ethers.getSigners();
    
        rToken = await Token.deploy();
        await rToken.deployed();
        const tokenAddr = rToken.address;
        stakev5 = await Stake.deploy(tokenAddr.toString());
        await stakev5.deployed();
    });

    describe("Deployment", function () {

        it("Should assign the total supply of tokens to the owner", async function () {
            const ownerBalance = await rToken.balanceOf(owner.address);
            expect(await rToken.totalSupply()).to.equal(ownerBalance);
        });
    });

    describe("Transactions", function () {
        it("Should transfer tokens to the contract", async function () {
            const stakeAddr = stakev5.address;
            await rToken.transfer(stakeAddr.toString(), 1000000000000000000000000n);
            const stakeContractBalance = await rToken.balanceOf(stakeAddr.toString());
            expect(stakeContractBalance).to.equal(1000000000000000000000000n);
        
            const ownerBalance = await rToken.balanceOf(owner.getAddress());
            expect(ownerBalance).to.equal(0);
        });
    
        it("Should Stake 5ETH inside the contract", async function () {
            // OWNER
            const OwnerStake = await stakev5.stake({value: hre.ethers.utils.parseEther('5.0'),});
            const OwnerStakeBalance = await stakev5._balances(owner.getAddress());
            
            expect(OwnerStakeBalance).to.equal(hre.ethers.utils.parseEther('5.0'));
    
            // addr1
            const addr1Stake = await stakev5.connect(addr1).stake({value: hre.ethers.utils.parseEther('5.0'),});
            const addr1StakeBalance = await stakev5._balances(addr1.getAddress());
            
            expect(addr1StakeBalance).to.equal(hre.ethers.utils.parseEther('5.0'));
    
            //addr2
            const addr2Stake = await stakev5.connect(addr2).stake({value: hre.ethers.utils.parseEther('5.0'),});
            const addr2StakeBalance = await stakev5._balances(addr2.getAddress());
            
            expect(addr2StakeBalance).to.equal(hre.ethers.utils.parseEther('5.0'));
        });
    
        it("Should withdraw 5ETH from the contract", async function () {
            const stakeAddr = stakev5.address;
            await rToken.transfer(stakeAddr.toString(), 1000000000000000000000000n);
            // stake 
            const OwnerStake = await stakev5.stake({value: hre.ethers.utils.parseEther('5.0'),});
        
            const addr1Stake = await stakev5.connect(addr1).stake({value: hre.ethers.utils.parseEther('5.0'),});
            
            const addr2Stake = await stakev5.connect(addr2).stake({value: hre.ethers.utils.parseEther('5.0'),});
        
            // withdraw
            // owner
            const unStakeETH = await stakev5.withdraw(hre.ethers.utils.parseEther('5.0'));
            const newOwnerBalanceInStake = await stakev5._balances(owner.getAddress());
        
            expect(newOwnerBalanceInStake.toString()).to.equal("0");
        
            //addr1
            const addr1unStakeETH = await stakev5.connect(addr1).withdraw(hre.ethers.utils.parseEther('5.0'));
            const newaddr1BalanceInStake = await stakev5._balances(addr1.getAddress());
        
            expect(newaddr1BalanceInStake.toString()).to.equal("0");
        
            //addr2
            const addr2unStakeETH = await stakev5.connect(addr2).withdraw(hre.ethers.utils.parseEther('5.0'));
            const newaddr2BalanceInStake = await stakev5._balances(addr2.getAddress());
        
            expect(newaddr2BalanceInStake.toString()).to.equal("0");

        });

        it("Should withdraw rewards from the contract", async function () {
            const stakeAddr = stakev5.address;
            await rToken.transfer(stakeAddr.toString(), 1000000000000000000000000n);
            // stake 
            const OwnerStake = await stakev5.stake({value: hre.ethers.utils.parseEther('5.0'),});
        
            const addr1Stake = await stakev5.connect(addr1).stake({value: hre.ethers.utils.parseEther('5.0'),});
            
            const addr2Stake = await stakev5.connect(addr2).stake({value: hre.ethers.utils.parseEther('5.0'),});
        
            // withdraw
            // owner
            const unStakeETH = await stakev5.withdraw(hre.ethers.utils.parseEther('5.0'));
            const newOwnerBalanceInStake = await stakev5._balances(owner.getAddress());
        
            expect(newOwnerBalanceInStake.toString()).to.equal("0");
        
            //addr1
            const addr1unStakeETH = await stakev5.connect(addr1).withdraw(hre.ethers.utils.parseEther('5.0'));
            const newaddr1BalanceInStake = await stakev5._balances(addr1.getAddress());
        
            expect(newaddr1BalanceInStake.toString()).to.equal("0");
        
            //addr2
            const addr2unStakeETH = await stakev5.connect(addr2).withdraw(hre.ethers.utils.parseEther('5.0'));
            const newaddr2BalanceInStake = await stakev5._balances(addr2.getAddress());
        
            expect(newaddr2BalanceInStake.toString()).to.equal("0");
        
            //withdraw rewards
            // owner
            const ownerissueToken = await stakev5.claimdevUSDC();
            const ownerTokenBalance = await rToken.balanceOf(owner.getAddress());
            
            expect(parseInt(ownerTokenBalance, 10)).to.greaterThan(0);
        
            //addr1
            const addr1issueToken = await stakev5.connect(addr1).claimdevUSDC();
            const addr1TokenBalance = await rToken.balanceOf(addr1.getAddress());
            
            expect(parseInt(addr1TokenBalance, 10)).to.greaterThan(0);
            
            //addr2
            const addr2issueToken = await stakev5.connect(addr2).claimdevUSDC();
            const addr2TokenBalance = await rToken.balanceOf(addr2.getAddress());
            
            const stakeTokenBalance =  await rToken.balanceOf(stakev5.address);
            expect(parseInt(addr2TokenBalance, 10)).to.greaterThan(0);
        });
    });

    describe("Rewards", function () {
        it("APR of rewards should be 10%", async function () {
            const stakeAddr = stakev5.address;
            await rToken.transfer(stakeAddr.toString(), 1000000000000000000000000n);
            // stake 
            const OwnerStake = await stakev5.stake({value: hre.ethers.utils.parseEther('5.0'),});
            const addr1Stake = await stakev5.connect(addr1).stake({value: hre.ethers.utils.parseEther('5.0'),});
            const addr2Stake = await stakev5.connect(addr2).stake({value: hre.ethers.utils.parseEther('5.0'),});
            // before timestamp
            const blockNumBefore = await ethers.provider.getBlockNumber();
            const blockBefore = await ethers.provider.getBlock(blockNumBefore);
            const timestampBefore = blockBefore.timestamp;
        
            // skip time
            //if you are going to test, put the timestamp (1650327621) a year after the blocknumber you put into hardhat.config
            const fastFoward = await network.provider.send("evm_setNextBlockTimestamp", [1650327621]); //Tuesday, 19 April 2022 00:20:21
            const mine  = await network.provider.send("evm_mine");
        
            // after timestamp
            const blockNumAfter = await ethers.provider.getBlockNumber();
            const blockAfter = await ethers.provider.getBlock(blockNumAfter);
            const timestampAfter = blockAfter.timestamp;
            expect(1650327621).to.equal(timestampAfter);
        
            // withdraw
            // owner
            const oldownerBalanceInStake = await stakev5._balances(owner.getAddress());
            const unStakeETH = await stakev5.withdraw(hre.ethers.utils.parseEther('5.0'));
            const newOwnerBalanceInStake = await stakev5._balances(owner.getAddress());

            expect(newOwnerBalanceInStake.toString()).to.equal("0");

            //addr1
            const oldaddr1BalanceInStake = await stakev5._balances(addr1.getAddress());
            const addr1unStakeETH = await stakev5.connect(addr1).withdraw(hre.ethers.utils.parseEther('5.0'));
            const newaddr1BalanceInStake = await stakev5._balances(addr1.getAddress());

            expect(newaddr1BalanceInStake.toString()).to.equal("0");

            //addr2
            const oldaddr2BalanceInStake = await stakev5._balances(addr2.getAddress());
            const addr2unStakeETH = await stakev5.connect(addr2).withdraw(hre.ethers.utils.parseEther('5.0'));
            const newaddr2BalanceInStake = await stakev5._balances(addr2.getAddress());

            expect(newaddr2BalanceInStake.toString()).to.equal("0");

            //withdraw rewards
            // owner
            const ownerRewardsBalance = await stakev5.rewards(owner.getAddress());
            const ownerissueToken = await stakev5.claimdevUSDC();
            const ownerTokenBalance = await rToken.balanceOf(owner.getAddress());
            console.log("owner devUSDC balance: ", (ownerTokenBalance).toString())
            const ownerAPR = parseInt(oldownerBalanceInStake) / parseInt(ownerRewardsBalance);
            console.log("APR: ", ownerAPR);
            expect(Math.round(ownerAPR)).to.equal(10);


            //addr1
            const addr1RewardsBalance = await stakev5.rewards(addr1.getAddress());
            const addr1issueToken = await stakev5.connect(addr1).claimdevUSDC();
            const addr1TokenBalance = await rToken.balanceOf(addr1.getAddress());
            console.log("addr1 devUSDC balance: ", (addr1TokenBalance).toString())
            const addr1APR = parseInt(oldaddr1BalanceInStake) / parseInt(addr1RewardsBalance);
            console.log("APR: ", addr1APR);
            expect(Math.round(addr1APR)).to.equal(10);
            
            //addr2
            const addr2RewardsBalance = await stakev5.rewards(addr2.getAddress());
            const addr2issueToken = await stakev5.connect(addr2).claimdevUSDC();
            const addr2TokenBalance = await rToken.balanceOf(addr2.getAddress());
            console.log("addr2 devUSDC balance: ", (addr2TokenBalance).toString())
            const stakeTokenBalance =  await rToken.balanceOf(stakev5.address);

            const addr2APR = parseInt(oldaddr2BalanceInStake) / parseInt(addr2RewardsBalance);
            console.log("APR: ", addr2APR);
            expect(Math.round(addr2APR)).to.equal(10);
        });
    });
});