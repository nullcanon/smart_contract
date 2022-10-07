pragma solidity ^0.8.16;

import "./token.sol";
import "./inviter.sol";
import "./stake.sol";
import "./adminable.sol";



contract Presell is Inviter, Adminable{
    uint256 public hasBuyAmount;
    uint256 public launchAmount = 2;
    uint256 public price = 3 * 10 ** 18;
    uint256  public supperNodeAmount = 5 * 10 ** 16;
    address public beeAddress = 0xf7eBDBF6E7bDAD3157B18480feB8Eb095CcC1BFD;
    address public beeMarket = 0xd3c0b6Aa1538d639912789be705F18b5Fd89fcE6;
    IPancakeSwapV2Router02 public uniswapV2Router;
    StakingRewards public stakingRewards;
    address public superNode = 0xd3c0b6Aa1538d639912789be705F18b5Fd89fcE6;
    uint256 public launchTime;
    //BSC: 0x55d398326f99059fF775485246999027B3197955
    //BSC testnet: 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684
    address public usdtAddress = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    address public rewardTokenAddress = 0x84E96930F591394771d34AA154B578Af3f01D635;
    uint256 public amountADesired = 20000 * 10 ** 18;
    uint256 public amountBDesired = 1 * 10 ** 18;
    uint256 public amountBuyBee = 1 * 10 ** 15;
    uint256 public amountLunchBuy = 1 * 10 ** 18;
    uint256 public amountUpperVlRewards = 5 * 10 ** 16;
    uint256 public amountUpperVlToV11Rewards = 1 * 10 ** 16;

    mapping(address => uint256) public invaterRewards;

     
    address public supperUpper = 0xd3c0b6Aa1538d639912789be705F18b5Fd89fcE6;
    


    event BuyPowers(address indexed user, address indexed upper, uint256 amount);
    event WithdrawRewards(address indexed user, uint256 amount);

    constructor() {
        // pancake 0x10ED43C718714eb63d5aA57B78B54704E256024E
        // pancake Testnet 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        uniswapV2Router = IPancakeSwapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        stakingRewards = StakingRewards(0x8f3D40e21a1331C7222D7627dA74049c0c5670b4);
    }

    function changeSupperUpper(address account) public onlyOwner {
        supperUpper = account;
    }

    function buyPowers(address upper) public {
        require(stakingRewards.powersOf(upper) > 0 || upper == supperUpper, "Upper not buy");
        require(stakingRewards.powersOf(msg.sender) == 0 , "Has buy");
        addUpper(msg.sender, upper);
        hasBuyAmount = hasBuyAmount + 1;
        IERC20(usdtAddress).transferFrom(msg.sender, address(this), price);
        IERC20(usdtAddress).transfer(superNode, supperNodeAmount);
        if(hasBuyAmount == launchAmount) {
            _launchAndBuyToken();
        }  
        if(hasBuyAmount > launchAmount){
            _buyToken(rewardTokenAddress, beeMarket, amountLunchBuy);
        }
        _buyBee();
        _invitationCommission(msg.sender);
        stakingRewards.stake(msg.sender, price);

        emit BuyPowers(msg.sender, upper, price);
    }

 
    function _launchAndBuyToken() private {
        IERC20(rewardTokenAddress).approve(address(uniswapV2Router), amountADesired);
        IERC20(usdtAddress).approve(address(uniswapV2Router), amountBDesired);

        uniswapV2Router.addLiquidity(
            rewardTokenAddress,
            usdtAddress,
            amountADesired,
            amountBDesired,
            0,
            0,
            beeMarket,
            block.timestamp
        );
        launchTime = block.timestamp;
        stakingRewards.setStartTime(launchTime);
        _buyToken(rewardTokenAddress, beeMarket, amountLunchBuy);
    }

    function _buyToken(address tokenAddress, address to, uint256 tokenAmount) private {
        if(tokenAmount == 0) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = usdtAddress;
        path[1] = tokenAddress;
        IERC20(usdtAddress).approve(address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            to,
            block.timestamp
        );

    }

    function _buyBee() private {
        _buyToken(beeAddress, beeMarket, amountBuyBee);
    }

    function _invitationCommission(address account) private {
        address upperLv1 = userUpper[account];
        if(upperLv1 == address(0)) {
            return;
        }
        invaterRewards[upperLv1] += amountUpperVlRewards;
        address curUser = upperLv1;
        for(uint32 i = 0; i < 10; ++i) {
            curUser = userUpper[curUser];
            if(curUser == address(0)) {
                break;
            }
            invaterRewards[curUser] += amountUpperVlToV11Rewards;
        }
    }

    function withdrawInvaterReward() public {
        require(block.timestamp > launchTime, "Not launched");
        uint256 amount = invaterRewards[msg.sender];
        require(amount > 0, "Not rewards");
        IERC20(usdtAddress).transfer(msg.sender, amount * 95 / 100);
        IERC20(usdtAddress).transfer(beeMarket, amount * 5 /100);
        invaterRewards[msg.sender] = 0;
        emit WithdrawRewards(msg.sender, amount);
    }

    function emergencyWithdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function emergencyWithdrawToken(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }
}