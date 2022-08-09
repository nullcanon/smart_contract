pragma solidity ^0.8.10;

import "../liquidity-staker/interfaces/IStakingRewards.sol";
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.3.0/contracts/token/ERC20/IERC20.sol';

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract FarmHelper is Ownable{

    function stake(address pool, address token) external {
        uint256 this_balance = IERC20(token).balanceOf(address(this));
        IERC20(token).approve(pool, this_balance);
        IStakingRewards(pool).stake(this_balance);
    }

    function 

    function process(address pool) external {
        uint256 balance = IStakingRewards(pool).balanceOf(msg.sender);
        IStakingRewards(pool).getReward();
        
    }


    receive() external payable {}

    function emergencyWithdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function emergencyWithdrawToken(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }


}