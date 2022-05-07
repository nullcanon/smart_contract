/**
 *Submitted for verification at BscScan.com on 2022-01-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-24
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-17
*/

pragma solidity ^0.8.6;

// SPDX-License-Identifier: Unlicensed
interface IERC20 {
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IUesInviteV1 {

    struct UserInfo {
        address upper;//上级
        address[] lowers;//下级
        uint256 startBlock;//邀请块高
    }

    event InviteV1(address indexed owner, address indexed upper, uint256 indexed height);//被邀请人的地址，邀请人的地址，邀请块高

    function inviteCount() external view returns (uint256);//邀请人数

    function inviteUpper1(address) external view returns (address);//上级邀请

    function inviteUpper2(address) external view returns (address, address);//上级邀请

    function inviteLower1(address) external view returns (address[] memory);//下级邀请

    function inviteLower2(address) external view returns (address[] memory, address[] memory);//下级邀请

    function inviteLower2Count(address) external view returns (uint256, uint256);//下级邀请

    function inviteLower1Count(address) external view returns (uint256);//下级邀请

}

contract UesInviteV1 is IUesInviteV1 {

    address public constant ZERO = address(0);
    uint256 public startBlock;
    address[] public inviteUserInfoV1;
    mapping(address => UserInfo) public inviteUserInfoV2;

    constructor () {
        startBlock = block.number;
    }
    
    function inviteCount() override public view returns (uint256) {
        return inviteUserInfoV1.length;
    }

    function inviteUpper1(address _owner) override public view returns (address) {
        return inviteUserInfoV2[_owner].upper;
    }

    function inviteUpper2(address _owner) override public view returns (address, address) {
        address upper1 = inviteUserInfoV2[_owner].upper;
        address upper2 = address(0);
        if (address(0) != upper1) {
            upper2 = inviteUserInfoV2[upper1].upper;
        }

        return (upper1, upper2);
    }

    function inviteLower1(address _owner) override public view returns (address[] memory) {
        return inviteUserInfoV2[_owner].lowers;
    }

    function inviteLower1Count(address _owner) override public view returns (uint256) {
        inviteUserInfoV2[_owner].lowers.length;
    }


    function inviteLower2(address _owner) override public view returns (address[] memory, address[] memory) {
        address[] memory lowers1 = inviteUserInfoV2[_owner].lowers;
        uint256 count = 0;
        uint256 lowers1Len = lowers1.length;
        for (uint256 i = 0; i < lowers1Len; i++) {
            count += inviteUserInfoV2[lowers1[i]].lowers.length;
        }
        address[] memory lowers;
        address[] memory lowers2 = new address[](count);
        count = 0;
        for (uint256 i = 0; i < lowers1Len; i++) {
            lowers = inviteUserInfoV2[lowers1[i]].lowers;
            for (uint256 j = 0; j < lowers.length; j++) {
                lowers2[count] = lowers[j];
                count++;
            }
        }
        
        return (lowers1, lowers2);
    }

    function inviteLower2Count(address _owner) override public view returns (uint256, uint256) {
        address[] memory lowers1 = inviteUserInfoV2[_owner].lowers;
        uint256 lowers2Len = 0;
        uint256 len = lowers1.length;
        for (uint256 i = 0; i < len; i++) {
            lowers2Len += inviteUserInfoV2[lowers1[i]].lowers.length;
        }
        
        return (lowers1.length, lowers2Len);
    }

    function register() internal returns (bool) {
        UserInfo storage user = inviteUserInfoV2[tx.origin];
        require(0 == user.startBlock, "COS:registed");
        user.upper = ZERO;
        user.startBlock = block.number;
        inviteUserInfoV1.push(tx.origin);
        
        emit InviteV1(tx.origin, user.upper, user.startBlock);
        
        return true;
    }

    function acceptInvitation(address _inviter, address _user) internal returns (bool) {
        require(_user != _inviter, "COS:FORBIDDEN");
        UserInfo storage user = inviteUserInfoV2[_user];
        // require(0 == user.startBlock, "UES:registed");
        if (0 != user.startBlock) {
            return false;
        }
        UserInfo storage upper = inviteUserInfoV2[_inviter];
        if (0 == upper.startBlock) {
            upper.upper = ZERO;
            upper.startBlock = block.number;
            inviteUserInfoV1.push(_inviter);
            
            emit InviteV1(_inviter, upper.upper, upper.startBlock);
        }
        user.upper = _inviter;
        upper.lowers.push(_user);
        user.startBlock = block.number;
        inviteUserInfoV1.push(_user);
        
        emit InviteV1(_user, user.upper, user.startBlock);

        return true;
    }

}

abstract contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract COSToken is IERC20, Ownable, UesInviteV1{
    using SafeMath for uint256;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping (address => bool) isDividendExempt;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _updated;
    mapping (address=>bool) public inviteExcluded;

    address private marketAddress = 0x7A946F43d2C68E3A7De0cFA8d2DF03812c12a91E;
    address private lpFeeAddress2 = ZERO;
   

    uint256 private _tFeeTotal;

    string private _name = "Contract Space";
    string private _symbol = "COS";
    uint8 private _decimals = 18;

    uint256 public _burnFee = 10;

    uint256 public tradeAmount = 0;
    uint256 private _previousburnFee;

    uint256 public _LPAddFee = 100;
    uint256 private _previousLPAddFee;

    uint256 public _LPShareFee = 100;
    uint256 private _previousLPShareFee;
    

    uint256 public _marketFee = 100;
    uint256 private _previousMarketFee;

    uint256 public _inviterUpperV1Fee = 100;
    uint256 private _previousInviterUpperV1Fee;
    uint256 public _inviterUpperV2Fee = 50;
    uint256 private _previousInviterUpperV2Fee;
    uint256 public _inviterLowerV1Fee = 0;
    uint256 private _previousInviterLowerV1Fee;
    uint256 public _inviterLowerV2Fee = 0;
    uint256 private _previousInviterLowerV2Fee;

    uint256 currentIndex;  
    uint256 private _tTotal = 500000 * 10**18;
    uint256 distributorGas = 500000;
    uint256 public minPeriod = 10 minutes;
    uint256 public LPFeefenhong;
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address private fromAddress;
    address private toAddress;

    bool public swapAndLiquifyEnabled = false;
    bool public isRemoveFee = false;
    bool public openInvite = true;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;

    bool inSwapAndLiquify;
    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    

    constructor() {
        _tOwned[msg.sender] = _tTotal;
       
        // PancakeSwap: 0x10ED43C718714eb63d5aA57B78B54704E256024E
        // Uniswap V2 (include Ropsten net): 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D 
        // pancake Testnet 0xB6BA90af76D139AB3170c7df0139636dB6120F7e
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );

        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        //exclude owner and this contract from fee
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;
        lpFeeAddress2 = msg.sender;
        inviteExcluded[uniswapV2Pair] = true;
        inviteExcluded[address(uniswapV2Router)] = true;
        emit Transfer(address(0), msg.sender, _tTotal);
    }


    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

   function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}


    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        

        //indicates if fee should be deducted from transfer

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if ((to == uniswapV2Pair || from == uniswapV2Pair)
            && !inSwapAndLiquify
            && to != address(uniswapV2Router)
            && !_isExcludedFromFee[from]
            && !_isExcludedFromFee[to]) {
            //transfer amount, it will take tax, burn, liquidity fee
            tradeAmount = tradeAmount.add(amount);
            _transferStandard(from, to, amount);
        } else {

            bool shouldSetInviter = balanceOf(to) == 0 &&
                !inviteExcluded[from] &&
                !inviteExcluded[to] &&
                from != uniswapV2Pair &&
                to != uniswapV2Pair &&
                inviteUpper1(to) == ZERO;

            if (shouldSetInviter && openInvite) {
                acceptInvitation(from, to);
            }

            _tOwned[from] = _tOwned[from].sub(amount);
            _tOwned[to] = _tOwned[to].add(amount);
            emit Transfer(from, to, amount);
        }

        if(fromAddress == address(0) )fromAddress = from;
        if(toAddress == address(0) )toAddress = to;  
        if(!isDividendExempt[fromAddress] && fromAddress != uniswapV2Pair ) setShare(fromAddress);
        if(!isDividendExempt[toAddress] && toAddress != uniswapV2Pair ) setShare(toAddress);
        
        fromAddress = from;
        toAddress = to;  
         if(_tOwned[address(this)] >= 100 * 10**18 && from !=address(this) && LPFeefenhong.add(minPeriod) <= block.timestamp) {
             process(distributorGas) ;
             LPFeefenhong = block.timestamp;
        }
    }
    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0)return;
        uint256 nowbanance = _tOwned[address(this)];
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

          uint256 amount = nowbanance.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(IERC20(uniswapV2Pair).totalSupply());
         if( amount < 1 * 10**16) {
             currentIndex++;
             iterations++;
             return;
         }
         if(_tOwned[address(this)]  < amount )return;
            distributeDividend(shareholders[currentIndex],amount);
            
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
   

    function distributeDividend(address shareholder ,uint256 amount) internal {
            
            _tOwned[address(this)] = _tOwned[address(this)].sub(amount);
            _tOwned[shareholder] = _tOwned[shareholder].add(amount);
             emit Transfer(address(this), shareholder, amount);
    }
    function setShare(address shareholder) private {
           if(_updated[shareholder] ){      
                if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);              
                return;  
           }
           if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;  
            addShareholder(shareholder);
            _updated[shareholder] = true;
          
      }
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }
    function quitShare(address shareholder) private {
           removeShareholder(shareholder);   
           _updated[shareholder] = false; 
      }
    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }


    function _takeburnFee(
        address sender,
        uint256 tAmount
    ) private {
        if (_burnFee == 0 || tradeAmount < 10000 * 10**18) return;
        if(_tFeeTotal >= 4999 * 10**18)_burnFee = 0;
        _tOwned[address(0)] = _tOwned[address(0)].add(tAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
        emit Transfer(sender, address(0), tAmount);
    }

    function _takeLPShareFee(address sender,uint256 tAmount) private {
        if (_LPShareFee == 0 ) return;
        _tOwned[address(this)] = _tOwned[address(this)].add(tAmount);
        emit Transfer(sender, address(this), tAmount);
    }

    // function _takeInviterLowersFee(address cur, uint256 tAmount) private {
    //     address[] memory lower1_users;
    //     address[] memory lower2_users;
    //     (lower1_users, lower2_users )= inviteLower2(cur);

    //     uint256 lowerv1Count = lower1_users.length;
    //     uint256 lowerv2Count = lower2_users.length;
    //     address user;
    //     uint256 amount;
    //     if (lowerv1Count == 0) {
    //         _tOwned[lpFeeAddress2] = _tOwned[lpFeeAddress2].add(tAmount.div(10000).mul(_inviterLowerV1Fee));
    //     } else {
    //         amount = tAmount.div(10000).mul(_inviterLowerV1Fee).div(lowerv1Count);
    //         for (uint256 i = 0; i < lowerv1Count; i++) {
    //             user = lower1_users[i];
    //             if(user == ZERO) {
    //                 user = lpFeeAddress2;
    //             }
    //             _tOwned[user] = _tOwned[user].add(amount);
    //             emit Transfer(cur, user, amount);
    //         }
    //     }

    //     if (lowerv2Count == 0) {
    //         _tOwned[lpFeeAddress2] = _tOwned[lpFeeAddress2].add(tAmount.div(10000).mul(_inviterLowerV2Fee));
    //     } else {
    //         amount = tAmount.div(10000).mul(_inviterLowerV2Fee).div(lowerv2Count);
    //         for (uint256 i = 0; i < lowerv2Count; i++) {
    //             user = lower2_users[i];
    //             if(user == ZERO) {
    //                 user = lpFeeAddress2;
    //             }
    //             _tOwned[user] = _tOwned[user].add(amount);
    //             emit Transfer(cur, user, amount);
    //         }
    //     }
    // }


    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 inviterFee
    ) private {
        if (inviterFee == 0 || !openInvite) return;
        address cur;
        if (sender == uniswapV2Pair) {
            cur = recipient;
        } else if (recipient == uniswapV2Pair) {
            cur = sender;
        } else {
            _tOwned[lpFeeAddress2] = _tOwned[lpFeeAddress2].add(tAmount.div(10000).mul(inviterFee));
            // emit Transfer(sender, address(this), tAmount.div(10000).mul(_inviterFee));
            return;
        }

        address upperv1;
        address upperv2;
        (upperv1, upperv2) = inviteUpper2(cur);
        if (ZERO == upperv1) {
            upperv1 = lpFeeAddress2;
        }
        if (ZERO == upperv2) {
            upperv2 = lpFeeAddress2;
        }
        _tOwned[upperv1] = _tOwned[upperv1].add(tAmount.div(10000).mul(_inviterUpperV1Fee));
        emit Transfer(cur, upperv1, tAmount.div(10000).mul(_inviterUpperV1Fee));

        _tOwned[upperv2] = _tOwned[upperv2].add(tAmount.div(10000).mul(_inviterUpperV2Fee));
        emit Transfer(cur, upperv2, tAmount.div(10000).mul(_inviterUpperV2Fee));
        
        // _takeInviterLowersFee(cur, tAmount);
    }


    function _takeMarketFee(
        address sender,
        uint256 tAmount
    ) private {
        if (_marketFee == 0) return;

        _tOwned[marketAddress] = _tOwned[marketAddress].add(tAmount);
        emit Transfer(sender, marketAddress, tAmount);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, 
            0, 
            address(this),
            block.timestamp
        );
    }
    
    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
    }


    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(half); 
        uint256 newBalance = address(this).balance.sub(initialBalance);
        addLiquidity(otherHalf, newBalance);
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }


    function _takeLPAddFee(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _tOwned[address(this)] = _tOwned[address(this)].add(tAmount);
        emit Transfer(sender, address(this), tAmount);
        uint256 contractTokenBalance = balanceOf(address(this));
        if(contractTokenBalance >= _tTotal)
        {
            contractTokenBalance = _tTotal;
        }
        bool overMinTokenBalance = contractTokenBalance >= 1e18;

        if (!overMinTokenBalance || !swapAndLiquifyEnabled || inSwapAndLiquify || sender == uniswapV2Pair) return;
        swapAndLiquify(tAmount);
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _takeburnFee(sender, tAmount.div(10000).mul(_burnFee));
        _takeMarketFee(sender, tAmount.div(10000).mul(_marketFee));
        _takeLPShareFee(sender, tAmount.div(10000).mul(_LPShareFee));
        _takeLPAddFee(sender, recipient, tAmount.div(10000).mul(_LPAddFee));
        uint256 _inviteFee = _inviterUpperV1Fee + _inviterUpperV2Fee 
                            + _inviterLowerV1Fee + _inviterLowerV2Fee;
        _takeInviterFee(sender, recipient, tAmount, _inviteFee);

        uint256 recipientRate = 10000 -
            _burnFee -
            _LPShareFee - 
            _marketFee - 
            _LPAddFee -
            _inviteFee;
        _tOwned[recipient] = _tOwned[recipient].add(
            tAmount.div(10000).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(10000).mul(recipientRate));
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
    }

    function removeAllFee() public onlyOwner {
        _previousburnFee = _burnFee;
        _previousLPAddFee = _LPAddFee;
        _previousLPShareFee = _LPShareFee;
        _previousMarketFee = _marketFee;
        _previousInviterUpperV1Fee = _inviterUpperV1Fee;
        _previousInviterUpperV2Fee = _inviterUpperV2Fee;
        _previousInviterLowerV1Fee = _inviterLowerV1Fee;
        _previousInviterLowerV2Fee = _inviterLowerV2Fee;
        _burnFee = 0;
        _LPAddFee = 0;
        _LPShareFee = 0;
        _marketFee = 0;
        _inviterUpperV1Fee = 0;
        _inviterUpperV2Fee = 0;
        _inviterLowerV1Fee = 0;
        _inviterLowerV2Fee = 0;
        isRemoveFee = true;
    }

    function resetAllFee() public onlyOwner {
        require(isRemoveFee == true, "ERC20: Fees have not been removed");
        _burnFee = _previousburnFee;
        _LPAddFee = _previousLPAddFee;
        _LPShareFee = _previousLPShareFee;
        _marketFee = _previousMarketFee;
        _inviterUpperV1Fee = _previousInviterUpperV1Fee;
        _inviterUpperV2Fee = _previousInviterUpperV2Fee;
        _inviterLowerV1Fee = _previousInviterLowerV1Fee;
        _inviterLowerV2Fee = _previousInviterLowerV2Fee;
        isRemoveFee = false;
    }

    function setBrunFee(uint256 fee) public onlyOwner {
        _burnFee = fee;
    }

    function setLpshareFee(uint256 fee) public onlyOwner {
        _LPShareFee = fee;
    }

    function setInviterFee(uint256 fee1, uint256 fee2, uint256 fee3, uint256 fee4) public onlyOwner {
        _inviterUpperV1Fee = fee1;
        _inviterUpperV2Fee = fee2;
        _inviterLowerV1Fee = fee3;
        _inviterLowerV2Fee = fee4;
    }

    function setOpenInvite(bool open) public onlyOwner {
        openInvite = open;
    }

    function setInviteExclude(address addr) public onlyOwner {
        inviteExcluded[addr] = true;
    }


    // Withdraw ETH that gets stuck in contract by accident
    function emergencyWithdraw() external onlyOwner {
        payable(owner()).send(address(this).balance);
    }

    // Withdraw Token that gets stuck in contract by accident
    function emergencyWithdrawToken() external onlyOwner {
        uint256 amount = _tOwned[address(this)];
        _tOwned[address(this)] = 0;
        _tOwned[owner()] = _tOwned[owner()].add(amount);
        emit Transfer(address(this), owner(), amount);
    }
}


contract ERC20Transfer {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    function batch_transfer(address payable _token, address[] memory to, uint amount) public {
        require(msg.sender == owner);
        COSToken token = COSToken(_token);
        for (uint i = 0; i < to.length; i++) {
            require(token.transfer(to[i], amount), "transfer faild");
        }
    }

    function batch_transfer2(address payable _token, address[] memory to, uint[] memory amount) public {
        require(msg.sender == owner);
        require( (to.length == amount.length) && to.length >= 1, "length err");

        COSToken token = COSToken(_token);
        for (uint i = 0; i < to.length; i++) {
            require(token.transfer(to[i], amount[i]), "transfer faild");
        }
    }
}