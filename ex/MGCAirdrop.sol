pragma solidity ^0.8.10;

import "./MGCPresell.sol";


contract MGCAirdrop is Ownable {
    MGCPresell presellHandler = MGCPresell(0xAc16aa722e0fC4E14DA8d189ab28d3D1AC1F1a8B);

    uint256 perUintAmount;
    address mgctoken = 0x7773FeAF976599a9d6A3a7B5dc43d02AC166F255;

    mapping(address => bool) public hasWithdraw;

    function getUserPresellQuantity(address account) public view returns (uint32) {
        return presellHandler.getUserBuyQuantity(account);
    }

    function withdraw() public {
        require(!hasWithdraw[msg.sender], "Has been withdraw");
        uint32 userPresellQuantity = getUserPresellQuantity(msg.sender);
        require(userPresellQuantity > 0, "Not join presell");
        IERC20(mgctoken).transfer(msg.sender, perUintAmount * userPresellQuantity);
        hasWithdraw[msg.sender] = true;
        emit Withdrawn(msg.sender, userPresellQuantity, perUintAmount * userPresellQuantity);
    }

    // Withdraw ETH that gets stuck in contract by accident
    function emergencyWithdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function emergencyWithdrawToken(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }

    function setPerUintAmount(uint256 amount) external onlyOwner {
        perUintAmount = amount;
    }

    //event
    event Withdrawn(address indexed user , uint32 number, uint256 amount);

}