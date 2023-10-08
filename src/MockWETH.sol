
// Mock WETH contract for testing
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
// import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract MockWETH is ERC20 {
constructor()
    ERC20("Weth", "Weth")
{}

// function mint(uint256 amount) public onlyOwner {
//     _mint(msg.sender, amount);
// }
}