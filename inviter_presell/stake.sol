pragma solidity ^0.8.16;


import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.3.0/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.3.0/contracts/token/ERC20/SafeERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.3.0/contracts/utils/ReentrancyGuard.sol";
import "./adminable";

contract StakingRewards is Adminable{

    IERC20 public rewardsToken;
    mapping(address => uint256) public rewards;

    uint256 public totalRewards;
    uint256 public startTime;
    uint256 public rateInterval = 1 days;
    uint256 public rateIntervalNumerator = 5;
    uint256 public rateIntervalDenominator = 1000;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public userLastUpdateTime;

    uint256 private _totalPowers;
    mapping(address => uint256) private _balances;



    modifier updateReward(address account) {
        uint256 rate = getTimeWeightedAveRate(userLastUpdateTime[account], block.timestamp);
        rewardPerTokenStored = rewardPerToken(rate);
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
            userLastUpdateTime[account] = block.timestamp;
        }
        _;
    }

    function setStartTime(uint256 time) public onlyAdmin {
        startTime = time;
    }

    function totalPowers() external view returns (uint256) {
        return _totalPowers;
    }

    function powersOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function getCurRewardPool() public view returns (uint256) {
        return _getRewardPool(block.timestamp);
    }

    function _getRewardPool(uint256 time) private view returns (uint256) {
        if(startTime == 0) {
            return startTime;
        }
        uint256 times = (time - startTime) / rateInterval + 1;
        uint256 value = totalRewards;
        for(uint256 i = 0; i < times; ++i) {
            value = value - value * intervalNumerator / intervalDenominator;
        }
        return value * intervalNumerator / intervalDenominator;
    }

    function getCurRewardRate() public view returns (uint256) {
        return _getRewardRate(block.timestamp);
    }

    function _getRewardRate(uint256 time) private view returns (uint256) {
        uint256 curPoolAmount = getCurRewardPool();
        uint256 rewardRate = curPoolAmount.div(rateInterval);
        return rewardRate;
    }


    function getReward() public nonReentrant updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return block.timestamp;
    }

    function rewardPerToken(uint256 rewardRate) public view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(_totalSupply)
            );
    }

    function earned(address account) public view returns (uint256) {
        uint256 rate = getTimeWeightedAveRate(userLastUpdateTime[account], block.timestamp);
        return _balances[account].mul(rewardPerToken(rate).sub(userRewardPerTokenPaid[account])).div(1e18).add(rewards[account]);
    }

    // Time-weighted average rate
    function getTimeWeightedAveRate(uint256 leftTime, uint256 rightTime) public view returns (uint256){
        
        if(startTime == 0 || leftTime <= rightTime) {
            return 0;
        }
        
        if(rightTime - leftTime <= rateInterval) {

        }
        uint256 tmp = leftTime + rateInterval;
        uint256 leftInterval = tmp - (tmp - startTime) % rateInterval;
        uint256 leftReward = _getRewardPool(leftTime) * leftInterval / rateInterval;

        uint256 rightInterval = (rightTime - startTime) % rateInterval;
        uint256 rightReward = _getRewardPool(rightTime) * rightInterval / rateInterval;

        uint256 midInterval = rightTime - rightInterval - leftInterval - tmp;
        uint245 startReward = _getRewardPool(tmp + leftInterval); 
        uint256 midTotalReward = startReward;
        uint256 nextReward = startReward;
        uint256 frontReward = _getRewardPool(tmp + leftInterval);
        for(uint256 i = 0; i < midInterval / rateInterval; ++i) {
            frontReward = nextReward;
            nextReward = frontReward - (frontReward - nextReward) * intervalNumerator / intervalDenominator;
            midTotalReward = midTotalReward + nextReward;
        }
        return (midTotalReward + leftReward + rightReward) / (rightTime - leftTime);
    }

    function stake(address user, uint256 amount) external nonReentrant onlyAdmin updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        _totalSupply = _totalSupply.add(amount);
        _balances[user] = _balances[user].add(amount);
        emit Staked(user, amount);
    }



    function getReward() public nonReentrant updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }





    event Staked(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

}