pragma solidity ^0.8.10;

import "./MGCPresell.sol";


contract MGCAirdrop is Ownable {
    MGCPresell presellHandler = MGCPresell(0xAc16aa722e0fC4E14DA8d189ab28d3D1AC1F1a8B);

    uint256 public perUintAmount = 500 * 10 ** 18;
    uint256 public userPerUintAmount;
    // 0x7773FeAF976599a9d6A3a7B5dc43d02AC166F255
    address public mgctoken = 0x7773FeAF976599a9d6A3a7B5dc43d02AC166F255;

    // 0x71fcA6c6204F768bf9f046aaa6E9c6B938C87B00
    address public sharetoken = 0x71fcA6c6204F768bf9f046aaa6E9c6B938C87B00;

    mapping(address => bool) public hasWithdraw;
    mapping(address => bool) public exchangeBacklist;
    mapping(address => bool) public userList;

    ////////////////read
    function getUserPresellQuantity(address account) public view returns (uint32) {
        return presellHandler.getUserBuyQuantity(account);
    }

    function canBeExchange(address account) public view returns (bool) {
        return (IERC20(sharetoken).balanceOf(account) > 0) && !exchangeBacklist[account];
    }

    function isUserList(address account) public view returns (bool) {
        return userList[account];
    }

    //////////////////wirte

    function exchangeWithdraw() public {
        require(!exchangeBacklist[msg.sender], "User in back list");
        uint256 balance = IERC20(sharetoken).balanceOf(msg.sender);
        require(balance > 0, "User not balance");

        IERC20(sharetoken).transferFrom(msg.sender, address(this), balance);
        IERC20(mgctoken).transfer(msg.sender, balance);
        emit Exchange(msg.sender, balance);
    }

    function userWithdraw() public {
        require(userList[msg.sender], "Not in user list or has been withdraw");
        require(userPerUintAmount > 0, "Not open");
        IERC20(mgctoken).transfer(msg.sender, userPerUintAmount);
        userList[msg.sender] = false;
        emit UserWithdrawn(msg.sender, userPerUintAmount);
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

    function addExchangeBacklist(address account) public onlyOwner {
        if (!exchangeBacklist[account]) {
            exchangeBacklist[account] = true;
        } else {
            exchangeBacklist[account] = false;
        }
    }

    function appendUser(address[] memory accounts) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            userList[accounts[i]] = true;
        }
    }

    function setPerUintAmount(uint256 amount) external onlyOwner {
        perUintAmount = amount;
    }

    function setUserPerUintAmount(uint256 amount) public onlyOwner {
        userPerUintAmount = amount;
    }

    ///////////////////event
    event Withdrawn(address indexed user , uint32 number, uint256 amount);
    event Exchange(address indexed user , uint256 amount);
    event UserWithdrawn(address indexed user , uint256 amount);

}