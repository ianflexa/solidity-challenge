// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract StakingETH is ReentrancyGuard{
    AggregatorV3Interface internal priceFeed;
    IERC20 public devUSDC;

    uint256 private lastUpdateTime; 
    uint256 private rewardPerTokenStored; 
    uint256 private _totalSupply; 
    uint256 private constant REWARD_RATE = 47500000000;

    event Staked(address indexed user, uint256 indexed amount);
    event WithdrewStake(address indexed user, uint256 indexed amount);
    event RewardsClaimed(address indexed user, uint256 indexed amount);

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;

        rewards[account] = earned(account);
        userRewardPerTokenPaid[account] = rewardPerTokenStored;
        _;
    }

    mapping(address => uint256) private userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public _balances;
/* 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e  rinkeby */ 
    constructor(address _devUSDC) {
        priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        devUSDC = IERC20(_devUSDC);
    }

    /* External Functions */

    function stake()
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
    function withdraw(uint256 _amount)
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
        uint reward = rewardUSDC(msg.sender);
        rewards[msg.sender] = 0;
        devUSDC.transfer(msg.sender, reward);

        emit RewardsClaimed(msg.sender, reward);
    }

    /* Getter Functions */

    function rewardPerToken() private view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored +
            (((block.timestamp - lastUpdateTime) * REWARD_RATE * 1e18) / _totalSupply);
    }

    function earned(address account) private view returns (uint256) {
        return
            ((_balances[account] *
                (rewardPerToken() - userRewardPerTokenPaid[account])) / 1e18) +
            rewards[account];
    }

    function getRewardPerTokenStoredUSDC() public view returns (uint256) {
        return ((getEthPrice() * 10e9) * (rewardPerTokenStored)/1e18);
    }

    function rewardPerTokenUSDC() public view returns (uint256) {
        return ((getEthPrice() * 10e9) * (rewardPerToken())/1e18);
    }

    function earnedUSDC(address account) public view returns (uint256) {
        return ((getEthPrice() * 10e9) * (earned(account))/1e18);
    }

    function rewardUSDC(address account) public view returns (uint256) {
        return ((getEthPrice() * 10e9) * (rewards[account])/1e18);
    }

    function _balancesUSDC(address account) public view returns (uint256) {
        return ((getEthPrice() * 10e9) * (_balances[account])/1e18);
    }

    function userRewardPerTokenPaidUSDC(address account) public view returns (uint256) {
        return ((getEthPrice() * 10e9) * (userRewardPerTokenPaid[account])/1e18);
    }

    function getEthPrice() public view returns(uint256) {
        (,int price,,,) = priceFeed.latestRoundData();
        return (uint256(price));
    }

    function getLastUpdateTime() public view returns (uint256) {
        return lastUpdateTime;
    }

    function getTotalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function getRewardRate() public pure returns (uint256) {
        return REWARD_RATE;
    }
}
