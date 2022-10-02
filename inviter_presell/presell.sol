pragma solidity ^0.8.16;

import "./token.sol";
import "./inviter.sol";
import "./adminable.sol";


contract Presell is Invater{
    uint256 public hasBuyAmount;
    uint256 public launchAmount = 300;
    uint256 public price = 300 * 10 ** 18;
    uint256  public supperNodeAmount = 50 * 10 ** 18;
    address public beeAddress;
    address public beeMarket;
    IPancakeSwapV2Router02 public immutable uniswapV2Router;
    StakingRewards public stakingRewards;
    address public superNode;
    uint256 public launchTime;
    address public usdtAddress;
    address public rewardTokenAddress;
    uint256 public amountADesired;
    uint256 public amountBDesired;
    
    mapping(address => uint256) public invaterRewards;
     


    event BuyPowers(address indexed user, address indexed upper, uint256 amount);
    event WithdrawRewards(address indexed user, uint256 amount);

    function buyPowers(address upper) public {
        addUpper(msg.sender, upper);
        hasBuyAmount = hasBuyAmount + 1;
        IERC20(usdtAddress).transferFrom(msg.sender, address(this), price);
        IERC20(usdtAddress).transfer(superNode, supperNodeAmount);
        if(hasBuyAmount == launchAmount) {
            _launchAndBuyToken();
        }  
        if(hasBuyAmount > launchAmount){
            _buyToken(rewardTokenAddress, beeMarket, 5);
        }
        _buyBee();
        _invitationCommission(msg.sender);
        stakingRewards.stake(msg.sender, amount);

        emit BuyPowers(user, upper, amount);
    }

 
    function _launchAndBuyToken() private {
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
        stakingRewards.setStartTime(launctTime);
        _buyToken(rewardTokenAddress, beeMarket, 5);
    }

    function _buyToken(address tokenAddress, address to, uint256 tokenAmount) private {
        if(tokenAmount == 0) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = usdtAddress;
        path[1] = tokenAddress;
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            to,
            block.timestamp
        );

    }

    function _buyBee() private {
        _buyToken(beeAddress, beeMarket, 5 * 10 ** 18);
    }

    function _invitationCommission(address account) private {
        address upperLv1 = userUpper[account];
        if(upperLv1 == address(0)) {
            return;
        }
        invaterRewards[upperLv1] += 50 * 10 ** 18;
        address curUser = upperLv1;
        for(uint32 i = 0; i < 10; ++i) {
            curUser = userUpper[curUser];
            if(curUser == address(0)) {
                break;
            }
            invaterRewards[curUser] += 10 * 10 ** 18;
        }
    }

    function withdrawInvaterReward() public {
        require(block.timestamp > launcTime, "Not launched");
        uint256 amount = invaterRewards[msg.sender];
        require(amount > 0, "Not rewards");
        IERC20(rewardTokenAddress).transfer(msg.sender, amount);
        invaterRewards[msg.sender] = 0;
        emit WithdrawRewards(msg.sender, amount);
    }
}