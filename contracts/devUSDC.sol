// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DevUSDC is ERC20, ERC20Burnable, Ownable {

    AggregatorV3Interface internal priceFeed;

    uint256 public lastPriceAdjustment;

    event mintdUSD(address indexed account, uint256 amount);
    event withdraw(address indexed account, uint256 amount);
    event burndUSD(address indexed account, uint256 amount);

    mapping(address => uint256) public balances;

    constructor() ERC20("devUSDC", "dUSD") payable {
        require(msg.value >= 1 ether, "need at least 1eth to deploy the contract");
        priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        uint currentPrice;
        (currentPrice, lastPriceAdjustment) = getLatestPrice();
        uint256 _totalSupply = (currentPrice * 10e10)  * address(this).balance / 10e18;
        _mint(msg.sender, _totalSupply);
        emit mintdUSD(msg.sender, _totalSupply);
        balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    function mintUSDC() public payable returns(uint256 stableAmount) {
        require(msg.value > 0, "insufficient funds to mint devUSDC");
        uint currentPrice;
        (currentPrice, lastPriceAdjustment) = getLatestPrice();
        stableAmount = (currentPrice * 10e10) * msg.value;
        balances[msg.sender] += stableAmount;
        _mint(msg.sender, stableAmount);
        emit mintdUSD(msg.sender, stableAmount);
    }

    function withdrawETH(uint256 stableAmount) public returns (uint256 ethAmount) {
        require(balances[msg.sender] >= stableAmount, "insuficient balance amount");
        uint currentPrice;
        (currentPrice, lastPriceAdjustment) = getLatestPrice();
        require(stableAmount >= (currentPrice * 10e10), "min withdraw is 1 eth");
        ethAmount = stableAmount / (currentPrice * 10e10);
        require(address(this).balance >= ethAmount, "not enough funds for this transaction");
        balances[msg.sender] -= stableAmount;
        burn(stableAmount);
        emit burndUSD(msg.sender, stableAmount);
        payable(msg.sender).transfer(ethAmount);

        emit withdraw(msg.sender, ethAmount);
    }

    function getPoolBalance() public view returns(uint256 ethBalance, uint256 dUSDCBalance) {
        return(address(this).balance, balanceOf(address(this)));
    }


        function getLatestPrice() public view returns (uint, uint) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            uint timeStamp,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return (uint256(price), timeStamp);
    }
}