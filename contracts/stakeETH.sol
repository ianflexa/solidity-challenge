// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract StakingETH is ReentrancyGuard{
    /* INTERFACES */
    AggregatorV3Interface internal priceFeed;
    IERC20 public devUSDC;

    /* STATE VARIABLES */
    
    /// @notice last time this contract was called.
    uint256 private lastUpdateTime; 

    /// @notice the amount of reward rate divided by total supply in a time x, 
    /// @dev this is calculated in the rewardPerToken function.
    uint256 private rewardPerTokenStored; 

    /// @notice total amount of ETH in stake.
    uint256 private _totalSupply;

    /// @dev after a few tests this was the value that I found for have the 10%APR with 3 accounts stake 5ETH each.
    /// @dev they are in wei, so its like 0.0000000475 per second.
    /// @dev when rewards are issued they are converted to devUSDC via oracle.
    uint256 private constant REWARD_RATE = 47500000000;

    /* EVENTS */

    /// @dev Emitted when stake ETH
    event Staked(address indexed user, uint256 indexed amount);

    /// @dev Emitted when widthdraw ETH in stake
    event WithdrewStake(address indexed user, uint256 indexed amount);

    /// @dev Emitted when claim rewards
    event RewardsClaimed(address indexed user, uint256 indexed amount);


    /// @notice Update the reward when an account stake eth, withdraw eth or issue the rewards.
    /// @dev we recalculated the rewardPerTokenStored calling rewardPerToken().
    /// @dev set the new update with the last timestamp.
    /// @dev we update account rewards with the amount of earnings calling earned().
    /// @dev and then we update the userRewardPerTokenPaid with the recalculated rewardPerTokenStored.
    /// @param account who will receive the rewards update.
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        rewards[account] = earned(account);
        userRewardPerTokenPaid[account] = rewardPerTokenStored;
        _;
    }

    /// @notice store the rewards for rewardPerTokenStored when an account calls one of these functions: stake() ,  withdraw() or claimdevUSDC()
    mapping(address => uint256) private userRewardPerTokenPaid;

    /// @notice store the rewards when an account calls one of these functions: stake() ,  withdraw() or claimdevUSDC()
    /// @dev I made it public just for testing, but it's good practice to keep it private and create view functions to read the data
    mapping(address => uint256) public rewards;

    /// @notice store the amount of eth an account have in stake
    /// @dev I made it public just for testing, but it's good practice to keep it private and create view functions to read the data
    mapping(address => uint256) public _balances;


/*  0x8A753747A1Fa494EC906cE90E9f37563A8AF630e  rinkeby 
    0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419  mainnet 
    if you are going to test it locally, put the mainnet address inside the constructor
*/ 

/// @notice initializing the contract
/// @dev initializing the contract storing the oracle chainlink address 
/// @param _devUSDC  ERC20 dUSDC address
    constructor(address _devUSDC) {
        priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        devUSDC = IERC20(_devUSDC);
    }

    /* EXTERNAL FUNCTIONS */

    /// @notice send ETH to the contract for Stake 
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


    /// @notice withdraw an amount in stake
    /// @param _amount ETH amount you want to withdraw
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

    /// @notice issue your rewards in USDC from your stake period
    /// @dev we use `rewardUSDC()` to get the ETH price provided by the oracle
    /// @dev so we can convert it to the amount in dUSDC
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

    /* VIEW FUNCTIONS */

    /// @notice rewardPerTokenStored function converted to dUSDC
    function getRewardPerTokenStoredUSDC() public view returns (uint256) {
        return ((getEthPrice() * 10e9) * (rewardPerTokenStored)/1e18);
    }

    /// @notice rewardsPerToken function converted to dUSDC
    function rewardPerTokenUSDC() public view returns (uint256) {
        return ((getEthPrice() * 10e9) * (rewardPerToken())/1e18);
    }

    /// @notice rewards earned function converted to dUSDC
    function earnedUSDC(address account) public view returns (uint256) {
        return ((getEthPrice() * 10e9) * (earned(account))/1e18);
    }

    /// @notice rewards mapping converted to dUSDC
    function rewardUSDC(address account) public view returns (uint256) {
        return ((getEthPrice() * 10e9) * (rewards[account])/1e18);
    }

    /// @notice _balances mapping converted to dUSDC
    function _balancesUSDC(address account) public view returns (uint256) {
        return ((getEthPrice() * 10e9) * (_balances[account])/1e18);
    }

    /// @notice userRewardPerTokenPaid mapping converted to dUSDC
    function userRewardPerTokenPaidUSDC(address account) public view returns (uint256) {
        return ((getEthPrice() * 10e9) * (userRewardPerTokenPaid[account])/1e18);
    }

    /// @notice Ether price from chainlink
    function getEthPrice() public view returns(uint256) {
        (,int price,,,) = priceFeed.latestRoundData();
        return (uint256(price));
    }

    /// @notice last time this contract was called
    function getLastUpdateTime() public view returns (uint256) {
        return lastUpdateTime;
    }

    /// @notice get total ETH in stake
    function getTotalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /// @notice get reward rate
    function getRewardRate() public pure returns (uint256) {
        return REWARD_RATE;
    }

    /* PRIVATE FUNCTIONS */
    /// @notice calculate the rewardPerTokenStored
    /// @dev the calculation is: reward rate times staked time divided by totalsupply.
    /// @dev We multiply by 1e18 because _totalSupply is in wei
    /// @return 0 if there is no eth in stake. If greater than 0, calculate the rewardPerTokenStored.
    function rewardPerToken() private view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored +
            (((block.timestamp - lastUpdateTime) * REWARD_RATE * 1e18) / _totalSupply);
    }

    /// @notice calculate the amount of tokens a account earned yet.
    /// @dev the calculation is: stake balance of an account times the difference between rewardsPerToken() and rewardPerTokenStored of an account divided by 1e18 (since they are in wei). By the end we add this calculation to rewards of an account
    /// @return the calculation
    function earned(address account) private view returns (uint256) {
        return
            ((_balances[account] *
                (rewardPerToken() - userRewardPerTokenPaid[account])) / 1e18) +
            rewards[account];
    }
}
