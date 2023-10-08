// pragma solidity ^0.8.13;

// import {Test, console2} from "forge-std/Test.sol";
// import {StakingContract} from "../src/Staking.sol";


// abstract contract Helpers is Test {
//         StakingContract public staking;



// function setUp() public {
//         mockWeth = new MockWETH();
//         staking = new StakingContract(address(mockWeth));
// }
// function mkaddr(
//     string memory name
// ) public returns (address addr, uint256 privateKey) {
//     privateKey = uint256(keccak256(abi.encodePacked(name)));
//     // address addr = address(uint160(uint256(keccak256(abi.encodePacked(name)))))
//     addr = vm.addr(privateKey);
//     vm.label(addr, name);
// }

// // Helper function to increase time in the EVM
// function increaseTime(uint256 secondsToIncrease) internal {
//     // Increase time in the EVM
//     block.timestamp += secondsToIncrease;
// }

// // Helper function to stake ETH and mint receipt tokens
// function stakeETH(address user, uint256 ethAmount) internal {
//     staking.stakeETH{value: ethAmount}({from: user});
// }

// // Helper function to compound rewards
// function compoundRewards(address user) internal {
//     staking.compoundRewards({from: user});
// }

// // Helper function to withdraw ETH and receipt tokens
// function withdraw(address user) internal {
//     staking.withdraw({from: user});
// }

// }