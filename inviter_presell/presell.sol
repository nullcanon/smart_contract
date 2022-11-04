pragma solidity ^0.8.16;

import "./token.sol";
import "./inviter.sol";
import "./stake.sol";
import "./adminable.sol";



contract Presell is Inviter, Adminable{
    uint256 public hasBuyAmount;
    uint256 public launchAmount = 501;
    uint256 public price = 300 * 10 ** 18;
    uint256  public supperNodeAmount = 3 * 10 ** 18;
    uint256  public supperNodeAmountTotal;
    address public beeAddress = 0xE070ccA5cdFB3F2B434fB91eAF67FA2084f324D7;
    address public beeMarket = 0x0968e6cCda9A3FAC4f4769eaD4CAe9230Be5a51A;
    address public withdrawMarket = 0x2030d215b5c1A7821EE9a99dE25f7fa65839EE16;
    IPancakeSwapV2Router02 public uniswapV2Router;
    StakingRewards public stakingRewards;
    address public superNode = 0xC08cAB7ea58802Fdd0111821C25E08a37Ec9a46B;
    uint256 public launchTime;
    //BSC: 0x55d398326f99059fF775485246999027B3197955
    //BSC testnet: 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684
    address public usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
    address public rewardTokenAddress = 0x6AD2C901B3e2ceD94FaA84B4d01d0A588a14B6C3;
    uint256 public amountLunchBuy = 115 * 10 ** 18;
    uint256 public amountADesired = 31500 * 10 ** 18;
    uint256 public amountBDesired = 57500 * 10 ** 18;
    uint256 public amountBuyBee = 5 * 10 ** 18;
    uint256 public amountUpperVlRewards = 50 * 10 ** 18;
    uint256 public amountUpperVlToV11Rewards = 10 * 10 ** 18;
    uint256 public inviteRewardTotal;
    uint256 public startTime;

    mapping(address => uint256) public invaterRewards;

     
    address public supperUpper = 0xC08cAB7ea58802Fdd0111821C25E08a37Ec9a46B;
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
    address public lpAddress = 0x08517DF88fE9BFAd6274099f4270119EEA81942e;
    


    event BuyPowers(address indexed user, address indexed upper, uint256 amount);
    event WithdrawRewards(address indexed user, uint256 amount);

    constructor() {
        // pancake 0x10ED43C718714eb63d5aA57B78B54704E256024E
        // pancake Testnet 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        uniswapV2Router = IPancakeSwapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        stakingRewards = StakingRewards(0x3641FFd20D9563C581772E5fE0CbE48024c6149a);
        startTime = block.timestamp;
    }

    function changeSupperUpper(address account) public onlyOwner {
        supperUpper = account;
    }

    function changeStakeRewards(address addr) public onlyOwner {
        stakingRewards = StakingRewards(addr);
    }

    function changeStartTime(uint256 start) public onlyOwner {
        startTime = start;
    }

    function changeHasBuy(uint256 amount) public onlyOwner {
        hasBuyAmount = amount;
    }

    function buyPowers(address upper) public {
        require(startTime < block.timestamp, "Not start");
        require(stakingRewards.powersOf(upper) > 0 || upper == supperUpper, "Upper not buy");
        require(stakingRewards.powersOf(msg.sender) == 0 , "Has buy");
        addUpper(msg.sender, upper);
        hasBuyAmount = hasBuyAmount + 1;
        IERC20(usdtAddress).transferFrom(msg.sender, address(this), price);
        // IERC20(usdtAddress).transfer(superNode, supperNodeAmount);
        supperNodeAmountTotal += supperNodeAmount;
        if(hasBuyAmount == launchAmount) {
            _launchAndBuyToken();
        }  
        if(hasBuyAmount > launchAmount){
            _buyToken(rewardTokenAddress, deadAddress, amountLunchBuy);
        }
        _buyBee();
        _invitationCommission(msg.sender);
        stakingRewards.stake(msg.sender, price);

        emit BuyPowers(msg.sender, upper, price);
    }

    function setConfigsAddress(address[] memory addresses) external onlyOwner {
        beeAddress = addresses[0];
        beeMarket = addresses[1];
        superNode = addresses[2];
        usdtAddress = addresses[3];
        rewardTokenAddress = addresses[4];
        supperUpper = addresses[5];
        withdrawMarket = addresses[6];
        lpAddress = addresses[7];
    }

    function setConfigAmount(uint256[] memory amounts) external onlyOwner {
        launchAmount = amounts[0];
        price = amounts[1];
        supperNodeAmount = amounts[2];
        amountLunchBuy = amounts[3];
        amountADesired = amounts[4];
        amountBDesired = amounts[5];
        amountBuyBee = amounts[6];
        amountUpperVlRewards = amounts[7];
        amountUpperVlToV11Rewards = amounts[8];
    }

 
    function _launchAndBuyToken() private  {
        IERC20(rewardTokenAddress).approve(address(uniswapV2Router), amountADesired);
        IERC20(usdtAddress).approve(address(uniswapV2Router), amountBDesired);

        uniswapV2Router.addLiquidity(
            rewardTokenAddress,
            usdtAddress,
            amountADesired,
            amountBDesired,
            0,
            0,
            lpAddress,
            block.timestamp
        );
        launchTime = block.timestamp;
        stakingRewards.setStartTime(launchTime);
        _buyToken(rewardTokenAddress, deadAddress, amountLunchBuy);
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
        inviteRewardTotal += amountUpperVlRewards;
        address curUser = upperLv1;
        for(uint32 i = 0; i < 10; ++i) {
            curUser = userUpper[curUser];
            if(curUser == address(0)) {
                break;
            }
            invaterRewards[curUser] += amountUpperVlToV11Rewards;
            inviteRewardTotal += amountUpperVlToV11Rewards;
        }
    }

    function addInvaterRewards(address account, uint256 amount) public onlyOwner{
        invaterRewards[account] += amount;
    }

    function withdrawInvaterReward() external {
        require(block.timestamp > launchTime, "Not launched");
        uint256 amount = invaterRewards[msg.sender];
        require(amount > 0, "Not rewards");
        IERC20(usdtAddress).transfer(msg.sender, amount * 95 / 100);
        IERC20(usdtAddress).transfer(withdrawMarket, amount * 5 /100);
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