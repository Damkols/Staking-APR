// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {StakingContract} from "../src/Staking.sol";
import "../src/MockWETH.sol";
// import "./Helpers.sol";

contract Staking is Test  {
    StakingContract public staking;
    MockWETH public mockWeth;

    address addr1;
    address addr2;
    address owner;

    uint256 privKA;
    uint256 privKB;

    uint256 ethAmount1;
    uint256 ethAmount2;

    uint256 public compoundRatio;
    uint256 public compoundFeePercentage;

    function setUp() public {
        mockWeth = new MockWETH();
        staking = new StakingContract(address(mockWeth));

        owner= msg.sender;

        addr1 = vm.addr(1);
        addr2 = vm.addr(2);

        compoundRatio = 10;
        compoundFeePercentage = 1; 

        ethAmount1 = 1 ether;
        ethAmount2 = 2 ether;
    }

    function stakeETH(address user, uint256 ethAmount) internal {
        staking.stakeETH{value: ethAmount}({from: user});
    }

    function compoundRewards(address user) internal {
        staking.compoundRewards({from: user});
    }

    function increaseTime(uint256 secondsToIncrease) internal {
        block.timestamp += secondsToIncrease;
    }

    function withdraw(address user) internal {
        staking.withdraw({from: user});
    }
    

    // Test staking ETH and minting receipt tokens
    function testStakeETH() public {
        uint256 initialETHBalance = address(this).balance;

        // User1 stakes 1 ETH
        // uint256 ethAmount1 = 1 ether;
        stakeETH(addr1, ethAmount1);

        // Check the contract's ETH balance increased and addr1's receipt token balance
        assertEq(address(this).balance == initialETHBalance.add(ethAmount1));
        assertEq(staking.balanceOf(addr1) == ethAmount1.mul(compoundRatio));

        // User2 stakes 2 ETH
        // uint256 ethAmount2 = 2 ether;
        stakeETH(addr2, ethAmount2);

        // Check addr2's receipt token balance
        assertEq(staking.balanceOf(addr2) == ethAmount2.mul(compoundRatio));

        // Check rewards for addr1 and addr2
        uint256 user1Reward = staking.rewards(addr1);
        uint256 user2Reward = staking.rewards(addr2);
        assertEq(user1Reward == 0); 
        assertEq(user2Reward == 0);
    }




    // Test compounding rewards

    function testCompoundRewards() public {
    // User1 stakes 1 ETH
    // uint256 ethAmount1 = 1 ether;
    stakeETH(addr1, ethAmount1);

    // Advance time by 1 year to accumulate rewards
    increaseTime(365 days);

    // User1 compounds rewards
    compoundRewards(addr1);

    // Check addr1's receipt token balance
    assertEq(staking.balanceOf(addr1) == ethAmount1.mul(compoundRatio));

    // Check rewards for addr1
    uint256 user1Reward = staking.rewards(addr1);
    assertEq(user1Reward > 0); // User1 should have rewards now

    // User2 stakes 2 ETH
    // uint256 ethAmount2 = 2 ether;
    stakeETH(addr2, ethAmount2);

    // Advance time by 6 months to accumulate rewards
    increaseTime(6 * 30 days);

    // User2 compounds rewards
    compoundRewards(addr2);

    // Check addr2's receipt token balance
    assertEq(staking.balanceOf(addr2) == ethAmount2.mul(compoundRatio));

    // Check rewards for addr2
    uint256 user2Reward = staking.rewards(addr2);
    assertEq(user2Reward > 0); // User2 should have rewards now

    // Check rewards for addr1 (should still have previous rewards plus more)
    uint256 newUser1Reward = staking.rewards(addr1);
    assertEq(newUser1Reward > user1Reward);

    // Check rewards for addr2 (should still have previous rewards plus more)
    uint256 newUser2Reward = staking.rewards(addr2);
    assertEq(newUser2Reward > user2Reward);
    }




    // Test withdrawing ETH and receipt tokens

    function testWithdraw() public {
    // User1 stakes 1 ETH
    // uint256 ethAmount1 = 1 ether;
    stakeETH(addr1, ethAmount1);

    // Advance time by 1 year to accumulate rewards
    increaseTime(365 days);

    // User1 compounds rewards
    compoundRewards(addr1);

    // Check addr1's receipt token balance
    assertEq(staking.balanceOf(addr1) == ethAmount1.mul(compoundRatio));

    // Check rewards for addr1
    uint256 user1Reward = staking.rewards(addr1);
    assertEq(user1Reward > 0); // User1 should have rewards now

    // User2 stakes 2 ETH
    // uint256 ethAmount2 = 2 ether;
    stakeETH(addr2, ethAmount2);

    // Advance time by 6 months to accumulate rewards
    increaseTime(6 * 30 days);

    // User2 compounds rewards
    compoundRewards(addr2);

    // Check addr2's receipt token balance
    assertEq(staking.balanceOf(addr2) == ethAmount2.mul(compoundRatio));

    // Check rewards for addr2
    uint256 user2Reward = staking.rewards(addr2);
    assertEq(user2Reward > 0); // User2 should have rewards now

    // Check rewards for addr1 (should still have previous rewards plus more)
    uint256 newUser1Reward = staking.rewards(addr1);
    assertEq(newUser1Reward > user1Reward);

    // Check rewards for addr2 (should still have previous rewards plus more)
    uint256 newUser2Reward = staking.rewards(addr2);
    assertEq(newUser2Reward > user2Reward);

    // User1 withdraws
    uint256 initialBalanceUser1 = address(addr1).balance;
    withdraw(addr1);

    // Check addr1's ETH balance increased and receipt token balance is 0
    assertEq(address(addr1).balance > initialBalanceUser1);
    assertEq(staking.balanceOf(addr1) == 0);

    // User2 withdraws
    uint256 initialBalanceUser2 = address(addr2).balance;
    withdraw(addr2);

    // Check addr2's ETH balance increased and receipt token balance is 0
    assertEq(address(addr2).balance > initialBalanceUser2);
    assertEq(staking.balanceOf(addr2) == 0);

    // Check rewards for addr1 and addr2 reset to 0 after withdrawal
    assertEq(staking.rewards(addr1) == 0);
    assertEq(staking.rewards(addr2) == 0);
    }

}
