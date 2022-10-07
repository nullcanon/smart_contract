pragma solidity ^0.8.10;


import "./adminable.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StakingRewards is Adminable , ReentrancyGuard{
    using SafeMath for uint256;

    IERC20 public rewardsToken;
    mapping(address => uint256) public rewards;

    uint256 public totalRewards = 400 * 10 ** 18;
    uint256 public startTime;
    uint256 public rateInterval = 1 minutes;
    uint256 public rateIntervalNumerator = 5;
    uint256 public rateIntervalDenominator = 1000;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public userLastUpdateTime;

    uint256 private _totalPowers;
    mapping(address => uint256) private _balances;



    modifier updateReward(address account) {
        uint256 time = userLastUpdateTime[account];
        if(time <= startTime) {
            time = startTime;
        }
        uint256 rate = getTimeWeightedAveRate(time, block.timestamp);
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

    function curTime() external  view  returns (uint256) {
        return block.timestamp;
    }

    function powersOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function getCurRewardPool() public view returns (uint256) {
        return getRewardPool(block.timestamp);
    }

    function getRewardPool(uint256 time) public view returns (uint256) {
        if(startTime == 0) {
            return totalRewards;
        }
        uint256 times = (time - startTime) / rateInterval + 1;
        uint256 value = totalRewards;
        for(uint256 i = 0; i < times; ++i) {
            value = value - value * rateIntervalNumerator / rateIntervalDenominator;
        }
        // TODO 精度问题
        return value * rateIntervalNumerator / rateIntervalDenominator;
    }

    function _getRemainPool(uint256 time) private view returns (uint256) {
        if(startTime == 0) {
            return startTime;
        }
        uint256 times = (time - startTime) / rateInterval + 1;
        uint256 value = totalRewards;
        for(uint256 i = 0; i < times; ++i) {
            value = value - value * rateIntervalNumerator / rateIntervalDenominator;
        }
        return value;
    }

    function getRemainPool(uint256 time) public view returns (uint256) {
        if(startTime == 0) {
            return startTime;
        }
        uint256 times = (time - startTime) / rateInterval + 1;
        uint256 value = totalRewards;
        for(uint256 i = 0; i < times; ++i) {
            value = value - value * rateIntervalNumerator / rateIntervalDenominator;
        }
        return value;
    }

    function getCurRewardRate() public view returns (uint256) {
        return _getRewardRate(block.timestamp);
    }

    function _getRewardRate(uint256 time) private view returns (uint256) {
        uint256 curPoolAmount = getRewardPool(time);
        uint256 rewardRate = curPoolAmount.div(rateInterval);
        return rewardRate;
    }


    function lastTimeRewardApplicable() public view returns (uint256) {
        return block.timestamp;
    }

    function rewardPerToken(uint256 rewardRate) public view returns (uint256) {
        if (_totalPowers == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(_totalPowers)
            );
    }

    function earned(address account) public view returns (uint256) {
        uint256 rate = getTimeWeightedAveRate(userLastUpdateTime[account], block.timestamp);
        return _balances[account].mul(rewardPerToken(rate).sub(userRewardPerTokenPaid[account])).div(1e18).add(rewards[account]);
    }

    // Time-weighted average rate
    function getTimeWeightedAveRate(uint256 leftTime, uint256 rightTime) public view returns (uint256){
        
        if(startTime == 0 || leftTime >= rightTime || leftTime == 0) {
            return 0;
        }

        if(leftTime < startTime) {
            leftTime = startTime;
        }

        uint256 leftInterval = (rateInterval - (leftTime - startTime) % rateInterval) % rateInterval;
        uint256 leftReward = getRewardPool(leftTime) * leftInterval / rateInterval;

        uint256 rightInterval = (rightTime - startTime) % rateInterval;
        uint256 rightReward = getRewardPool(rightTime) * rightInterval / rateInterval;

        if(leftTime + leftInterval > rightTime) {
            return _getRewardRate(leftTime);
        }

        uint256 midInterval = rightTime - rightInterval - leftTime - leftInterval;
        uint256 startReward = getRemainPool(leftTime); 
        uint256 midTotalReward = 0;
        uint256 nextReward = 0;
        uint256 value = startReward;
        uint256 times = midInterval / rateInterval;
        for(uint256 i = 0; i < times; ++i) {
            nextReward = value * rateIntervalNumerator / rateIntervalDenominator;
            value = value - nextReward;
            midTotalReward += nextReward;
        }
        return (midTotalReward + leftReward + rightReward) / (rightTime - leftTime);
    }


    function stake(address user, uint256 amount) external nonReentrant onlyAdmin updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        _totalPowers = _totalPowers.add(amount);
        _balances[user] = _balances[user].add(amount);
        emit Staked(user, amount);
    }



    function getReward() public nonReentrant updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function setRewardToken(address token) public onlyOwner {
        rewardsToken = IERC20(token);
    }




    event Staked(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    function emergencyWithdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function emergencyWithdrawToken(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }
}