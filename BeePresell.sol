// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface IERC20 {

    function approve(address spender, uint256 usdtAmount) external returns (bool);
    
    function transfer(address, uint) external returns (bool);

    function transferFrom(
        address,
        address,
        uint
    ) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function balanceOf(address account) external view returns (uint256) ;

}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract BeePresell is Ownable {

    struct UserInfo {
        address upper;//
        address[] lowers;//
        uint256 startBlock;//
    }

    //BSC: 0x55d398326f99059fF775485246999027B3197955
    //BSC testnet: 0xEdA5dA0050e21e9E34fadb1075986Af1370c7BDb
    address public usdtMintAddress = 0x55d398326f99059fF775485246999027B3197955;
    address public presellTokenMintAddress = 0xE070ccA5cdFB3F2B434fB91eAF67FA2084f324D7;
    address public marketAddress = 0x3caa5ABC857473F8a31B619f0F7Fe7BfBde35816;

    // BSC testnet 1
    // BSC mainnet 500
    uint256 private usdtAmount = 500 * 10 ** 18;
    uint256 private preSellCoinPreAmount = 4500 * 10 ** 18;
    uint256 private inviteAirdropCoinAmount = 409600 * 10 ** 18;
    uint32 private counter;
    uint32 private withdrawCounter;
    uint32 private lowersCounter;

    // BSC testnet 10
    // BSC mainnet 1024
    uint32 private preMax = 1024;
        uint64 private startAt;
    uint64 private endAt;
    
    mapping(address => UserInfo) public inviteInfo;

    IERC20 public immutable usdtToken;
    IERC20 public immutable sellToken;
    mapping(address => uint256) public userPresellBalanceMap;
    mapping(address => bool) public userInviteBalancelMap;
    mapping(address => bool) public hasBuy;



    constructor(
        uint64 _startAt,
        uint64 _endAt
        ) {
        require(_startAt >= block.timestamp, "start at < now");
        require(_endAt >= _startAt, "end at < start at");

        startAt = _startAt;
        endAt = _endAt;
        usdtToken = IERC20(usdtMintAddress);
        sellToken = IERC20(presellTokenMintAddress);
    }
    function getLowersCount() public view returns (uint32) {
        return lowersCounter;
    }

    function getUsdtAmount() public view returns (uint256) {
        return usdtAmount;
    }

    function getPresellMax() public view returns (uint32) {
        return preMax;
    }

    function getPreSellCoinAmount() public view returns (uint256) {
        return preSellCoinPreAmount;
    }

    function getUserPreSellCoinAmount(address user) public view returns (uint256) {
        return userPresellBalanceMap[user];
    }

    function getUserInviteAirdropCoinAmount(address user) public view returns (uint256) {
        if (lowersCounter == 0 || inviteInfo[user].lowers.length == 0) {
            return 0;
        }
        return inviteAirdropCoinAmount / lowersCounter * inviteInfo[user].lowers.length;
    }

    function getStartTime() public view returns (uint64) {
        return startAt;
    }

    function getEndTime() public view returns (uint64) {
        return endAt;
    }

    function getUserHasBuy(address user) public view returns (bool) {
        return hasBuy[user];
    }

    function getPreSellCounter() public view returns (uint64) {
        return counter;
    }

    function getWithdrawCounter() public view returns (uint64) {
        return withdrawCounter;
    }

    function getUserLowersCount(address user) public view returns (uint256) {
        return inviteInfo[user].lowers.length;
    }

    function getUserLowers(address user) public view returns (address[] memory) {
        return inviteInfo[user].lowers;
    }

    function getUserLowersSlice(address user, uint256 start,  uint256 end) public view returns (address[] memory) {
        address[] storage lowers = inviteInfo[user].lowers;
        uint256 len = lowers.length;
        if (len > 0) {
            require(start < end && start < len && end <= len, "lower iterator out of range.");
            address[] memory addrSet = new address[](end - start);
            uint256 j = 0;
            for (uint256 i = start; i < end; i++) {
                addrSet[j] = lowers[i];
                j++;
            }
            return addrSet;
        }
        return new address[](0);
    }


    function getUserUpper(address user) public view returns (address) {
        return inviteInfo[user].upper;
    }

    function acceptInvitation(address _inviter) public returns (bool) {
        require(startAt < block.timestamp, "not start");
        require(endAt > block.timestamp, "has end");
        require(hasBuy[_inviter], "Bee:upper not buy");
        require(hasBuy[msg.sender], "Bee:user not buy");

        require(msg.sender != _inviter, "Bee:FORBIDDEN");

        UserInfo storage user = inviteInfo[msg.sender];
        UserInfo storage upper = inviteInfo[_inviter];

        require(upper.upper != msg.sender, "The inviter is a lower to the user");

        require(user.upper != _inviter, "Repeated invitation");

        require(user.upper == address(0), "Already have a upper");

        user.upper = _inviter;
        user.startBlock = block.number;

        upper.startBlock = block.number;
        upper.lowers.push(msg.sender);

        userInviteBalancelMap[_inviter] = true;
        ++lowersCounter;

        return true;
    }

    function buyTokens() public {
        require(startAt < block.timestamp, "not start");

        require(endAt > block.timestamp, "has end");

        require(counter <= preMax, "Pre-orders are sold out");

        require(!hasBuy[msg.sender],"already purchased");

        require(usdtToken.allowance(msg.sender, address(this)) >= usdtAmount, "usdtToken allowance too low");

        bool sent = usdtToken.transferFrom(msg.sender, marketAddress, usdtAmount);
        require(sent, "Token transfer failed");
        userPresellBalanceMap[msg.sender] = preSellCoinPreAmount;
        hasBuy[msg.sender] = true;
        counter++;
    }

    function withdrawPresellTokens() public {
        require(endAt < block.timestamp, "presell not end");

        require(userPresellBalanceMap[msg.sender] > 0, 'user balance zero');

        bool sent = sellToken.transfer(msg.sender, userPresellBalanceMap[msg.sender]);
        require(sent, "Token transfer failed");

        userPresellBalanceMap[msg.sender] = 0;
        withdrawCounter++;
    }

    function withdrawInviteAirdropTokens() public {
        require(endAt < block.timestamp, "presell not end");

        require(userInviteBalancelMap[msg.sender] == true, 'user not invite');

        bool sent = sellToken.transfer(msg.sender, getUserInviteAirdropCoinAmount(msg.sender));
        require(sent, "Token transfer failed");

        userInviteBalancelMap[msg.sender] = false;
    }

    function exigencyWithdraw(uint256 amount) public onlyOwner {
        bool sent = sellToken.transfer(msg.sender, amount);
        require(sent, "Token transfer failed");
    }

    function setMarketAddress(address newAddress) public onlyOwner {
        marketAddress = newAddress;
    }
    

    function setAmount(uint256 newAmount) public onlyOwner {
        usdtAmount = newAmount;
    }
}