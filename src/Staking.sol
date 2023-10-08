// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
// import "lib/openzeppelin-contracts/contracts/utils/math/Math.sol";

interface WETH {
    function deposit() external payable;
    function withdraw(uint256) external;
}

contract StakingContract is ERC20, Ownable {
    // using Math for uint256;
    //0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2

    WETH public weth;
    uint256 public apr = 1400;
    uint256 public compoundRatio = 10; 
    uint256 public compoundFeePercentage = 1; 

    mapping(address => uint256) public stakedETH;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public lastUpdateTime;

    constructor(address _wethTokenAddress) ERC20("Damkols Token", "DKT") {
        weth = WETH(_wethTokenAddress);
    }

    function stakeETH() external payable {
        require(msg.value > 0, "Amount must be greater than 0");
        weth.deposit{value: msg.value}();
        uint256 wethAmount = msg.value;
        stakedETH[msg.sender] = (stakedETH[msg.sender]) + (wethAmount);
        uint256 receiptAmount = (wethAmount) * (compoundRatio);
        _mint(msg.sender, receiptAmount);
        updateRewards(msg.sender);
    }

    function compoundRewards() external {
        uint256 stakerBalance = stakedETH[msg.sender];
        require(stakerBalance > 0, "No staked ETH to compound");
        uint256 compoundFee = (stakerBalance) * (compoundFeePercentage)/(100);
        weth.withdraw(compoundFee);
        payable(owner()).transfer(compoundFee);
        uint256 stakedWETH = rewards[msg.sender];
        rewards[msg.sender] = 0;
        stakedETH[msg.sender] = (stakedETH[msg.sender]) + (stakedWETH);
        updateRewards(msg.sender);
    }

    function withdraw() external {
        uint256 stakerBalance = stakedETH[msg.sender];
        require(stakerBalance > 0, "No staked ETH to withdraw");
        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        uint256 totalWithdrawal = (stakerBalance) + (reward);
        stakedETH[msg.sender] = 0;
        weth.withdraw(totalWithdrawal);
        payable(msg.sender).transfer(totalWithdrawal);
        _burn(msg.sender, totalWithdrawal);
    }

    function updateRewards(address staker) internal {
        uint256 stakerBalance = stakedETH[staker];
        uint256 timeElapsed = (block.timestamp) - (lastUpdateTime[staker]);
        uint256 annualReward = (stakerBalance) * (apr) * (timeElapsed) / (365 days) / (100); // Calculate annual reward
        rewards[staker] = (rewards[staker]) + ((annualReward) /(compoundRatio)); // Distribute rewards over time
    }
}
