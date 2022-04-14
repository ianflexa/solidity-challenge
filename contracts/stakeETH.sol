// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract StakingETH is ReentrancyGuard{

    IERC20 public devUSDC;

    uint256 private lastUpdateTime; // last time the contract was call
    uint256 private rewardPerTokenStored; // reward rate / total stake supply at each given time
    uint256 private _totalSupply; // total staken in this contract
    uint256 private constant REWARD_RATE = 100; //  0.00100% or 10% APR

    event Staked(address indexed user, uint256 indexed amount);
    event WithdrewStake(address indexed user, uint256 indexed amount);
    event RewardsClaimed(address indexed user, uint256 indexed amount);


    //first we need to update the reward/token stored
    // second we update the last update tima
    //store on the rewards mapping the amount of token earned until now
    // then update user reward/token paid with the reward/token stored
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;

        rewards[account] = earned(account);
        userRewardPerTokenPaid[account] = rewardPerTokenStored;
        _;
    }

    mapping(address => uint256) public userRewardPerTokenPaid; // store the reward per token stored when users interact with the contract
    mapping(address => uint256) public rewards; // update the reward if user withdraw or staking more tokens
    mapping(address => uint256) private _balances; // n tokens staked per user

    constructor(address _devUSDC) {
        devUSDC = IERC20(_devUSDC);
    }

    /* External Functions */


    // first update the reward
    //second update the total supply of the contract
    // third update the balance of msg.sender
    // finally emit staked event
    function stakeETH()
        external
        payable
        nonReentrant
        updateReward (msg.sender)
    {
        require(msg.value >= 5 ether, "need at least 5ETH to stake");
        _totalSupply += msg.value;
        _balances[msg.sender] += msg.value;
        
        emit Staked(msg.sender, msg.value);
    }

    // first line requires a condition of the balance to be equal or more the _amount parameter
    //second update the total supply of the contract
    // third update the balance of msg.sender
    // finally emit staked event
    function withdrawETH(uint256 _amount)
        external
        nonReentrant
        updateReward (msg.sender)
    {
        require(_balances[msg.sender] >= _amount, "insuficient amount");
        _totalSupply -= _amount;
        _balances[msg.sender] -= _amount;
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "error");

        emit WithdrewStake(msg.sender, _amount);
    }

    // first line requires a condition of the msg.sender rewards balance to be greater than zero
    //second we put the value of rewards of the msg.sender in a stable variable 
    // third we reset msg.sender rewards
    // finally emit staked event
    function claimdevUSDC()
        external
        nonReentrant
        updateReward (msg.sender)
    {
        require(rewards[msg.sender] > 0, "no rewards to claim");
        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        devUSDC.transfer(msg.sender, reward);

        emit RewardsClaimed(msg.sender, reward);
    }

    /* Getter Functions */

    function rewardPerToken() public view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored +
            (((block.timestamp - lastUpdateTime) * REWARD_RATE * 1e18) / _totalSupply);
    }

    function earned(address account) public view returns (uint256) {
        return
            ((_balances[account] *
                (rewardPerToken() - userRewardPerTokenPaid[account])) / 1e18) +
            rewards[account];
    }

    function getLastUpdateTime() public view returns (uint256) {
        return lastUpdateTime;
    }

    function getRewardPerTokenStored() public view returns (uint256) {
        return rewardPerTokenStored;
    }

    function getTotalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function getRewardRate() public pure returns (uint256) {
        return REWARD_RATE;
    }
}
