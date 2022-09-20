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

contract BabyPresell is Ownable {


    //BSC: 0x55d398326f99059fF775485246999027B3197955
    //BSC testnet: 0xEdA5dA0050e21e9E34fadb1075986Af1370c7BDb
    address public usdtMintAddress = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    address public presellTokenMintAddress = 0xA3247B33baA9eA15b699C77237d5B16f5CFD822f;
    address public marketAddress = 0xd3c0b6Aa1538d639912789be705F18b5Fd89fcE6;

    // BSC testnet 1
    // BSC mainnet 500
    uint256 private usdtAmount = 1 * 10 ** 18;
    uint256 private preSellCoinPreAmount = 4500 * 10 ** 18;
    uint32 private counter;
    uint32 private withdrawCounter;

    // BSC testnet 10
    // BSC mainnet 1024
    uint32 private preMax = 10;
    uint64 private startAt;
    uint64 private endAt;
    
    bool public disableWhiteList;

    IERC20 public immutable usdtToken;
    IERC20 public immutable sellToken;
    mapping(address => uint256) public userPresellBalanceMap;
    mapping(address => bool) public hasBuy;
    mapping(address => bool) public whiteList;

    event BuyTokens(address indexed user, uint256 umount, uint256 coinamount);
    event WithdrawTokens(address indexed user,uint256 coinamount);

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

    function getUsdtAmount() public view returns (uint256) {
        return usdtAmount;
    }

    function getPresellMax() public view returns (uint32) {
        return preMax;
    }

    function setPresellMax(uint32 amount) public onlyOwner{
        preMax = amount;
    }


    function getPreSellCoinAmount() public view returns (uint256) {
        return preSellCoinPreAmount;
    }

    function getUserPreSellCoinAmount(address user) public view returns (uint256) {
        return userPresellBalanceMap[user];
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

    function buyTokens() public {
        require(!disableWhiteList && whiteList[msg.sender], "not in whiteList");

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
        emit BuyTokens(msg.sender, usdtAmount, preSellCoinPreAmount);
    }

    function withdrawPresellTokens() public {
        require(endAt < block.timestamp, "presell not end");

        uint256 amount = userPresellBalanceMap[msg.sender];

        require(amount > 0, 'user balance zero');

        bool sent = sellToken.transfer(msg.sender, amount);
        require(sent, "Token transfer failed");

        userPresellBalanceMap[msg.sender] = 0;
        withdrawCounter++;
        emit WithdrawTokens(msg.sender, amount);
    }

    function exigencyWithdrawToken(uint256 amount) public onlyOwner {
        bool sent = sellToken.transfer(msg.sender, amount);
        require(sent, "Token transfer failed");
    }

    function emergencyWithdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function setMarketAddress(address newAddress) public onlyOwner {
        marketAddress = newAddress;
    }
    

    function setAmount(uint256 newAmount) public onlyOwner {
        usdtAmount = newAmount;
    }

    function setTime(uint64 start, uint64 end) public onlyOwner {
        require(start > block.timestamp && end > start, "The start time has passed or end time must more than start");
        startAt = start;
        endAt = end;
    }

    function changeWhiteList(address account, bool state) public onlyOwner {
        whiteList[account] = state;
    }

    function changeWhiteListBatch(address[] memory accounts, bool[] memory states) public onlyOwner {
        require(accounts.length == states.length, "arrat length error");
        for(uint256 i = 0; i < accounts.length; ++i) {
            changeWhiteList(accounts[i], states[i]);
        }
    }

    function setDisableWhiteList(bool op) public onlyOwner {
        disableWhiteList = op;
    }
        
}
