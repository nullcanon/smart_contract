pragma solidity ^0.8.16;


import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.3.0/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.3.0/contracts/token/ERC20/SafeERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.3.0/contracts/utils/ReentrancyGuard.sol";

contract StakingRewards {

    IERC20 public rewardsToken;
    uint256 public rewardRate = 0;
    mapping(address => uint256) public rewards;

    uint256 public totalRewards;
    uint256 public startTime;
    uint256 public rateInterval = 1 days;
    uint256 public rateIntervalNumerator = 5;
    uint256 public rateIntervalDenominator = 1000;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    mapping(address => uint256) public userRewardPerTokenPaid;

    uint256 private _totalPowers;
    mapping(address => uint256) private _balances;



    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        // TODO 最后更新时的汇率
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }



    function totalPowers() external view returns (uint256) {
        return _totalPowers;
    }

    function powersOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function getCurRewardPool() public view returns (uint256) {
        uint256 nowTime = block.timestamp;
        uint256 times = (nowTime - startTime) / rateInterval;
        uint256 value = totalRewards;
        for(uint256 i = 0; i < times; ++i) {
            value = value - value * intervalNumerator / intervalDenominator;
        }
        return value * intervalNumerator / intervalDenominator;
    }

    function getCurRewardRate() public view returns (uint256) {
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
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(_totalSupply)
            );
    }

    function earned(address account) public view returns (uint256) {
        return _balances[account].mul(rewardPerToken().sub(userRewardPerTokenPaid[account])).div(1e18).add(rewards[account]);
    }





    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

}