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

abstract
contract UsdtPresell is Ownable {
    //BSC: 
    //BSC testnet: 0xEdA5dA0050e21e9E34fadb1075986Af1370c7BDb
    address public usdtMintAddress = 0xEdA5dA0050e21e9E34fadb1075986Af1370c7BDb;
    address public presellTokenMintAddress = 0xc2cC6268F2515FF54f180F3c9F92bF234CdaC351;
    address public marketAddress = 0xE520b615Df1E0d02e9aa0BC970145408dFB2cF86;
    uint256 public usdtAmount = 2 * 10 ** 18;
    uint256 public cosAmount = 2 * 10 ** 18;
    uint32 public counter;
    uint32 public preSellMax = 5;

    IERC20 public immutable usdtToken;
    IERC20 public immutable sellToken;
    mapping(address => uint256) public userBalanceMap;
    mapping(address => bool) public hasBuy;

    uint64 public startAt;
    uint64 public endAt;

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

    function getCoinAmount() public view returns (uint256) {
        return cosAmount;
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

    function getUserBalance(address user) public view returns (uint256) {
        return userBalanceMap[user];
    }

    function getPreSellCounter() public view returns (uint64) {
        return counter;
    }

    function getPreSellMax() public view returns (uint64) {
        return preSellMax;
    }


    function buyTokens() public {
        require(startAt < block.timestamp, "not start");

        require(endAt > block.timestamp, "has end");

        require(counter <= preSellMax, "user Max");

        require(
            !hasBuy[msg.sender],
            "already purchased"
        );

        require(
            usdtToken.allowance(msg.sender, address(this)) >= usdtAmount,
            "usdtToken allowance too low"
        );

        bool sent = usdtToken.transferFrom(msg.sender, marketAddress, usdtAmount);
        require(sent, "Token transfer failed");
        userBalanceMap[msg.sender] = cosAmount;
        hasBuy[msg.sender] = true;
        counter++;
    }

    function withdrawTokens() public {
        require(endAt < block.timestamp, "presell not end");

        require(userBalanceMap[msg.sender] > 0, 'user not presell');

        bool sent = sellToken.transfer(msg.sender, userBalanceMap[msg.sender]);
        require(sent, "Token transfer failed");

        userBalanceMap[msg.sender] = 0;
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

    function setCoinAmount(uint256 newAmount) public onlyOwner {
        cosAmount = newAmount;
    }


}


contract Test is UsdtPresell {
    constructor (string memory name_,
        uint64 _startAt,
        uint64 _endAt) public UsdtPresell(         _startAt,
         _endAt) {
        // solhint-disable-previous-line no-empty-blocks
    }

    function set() public {
        usdtMintAddress = address(0);
    }
}