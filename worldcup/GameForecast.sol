pragma solidity ^0.8.17;

import "./Adminable.sol";
import "./TeamERC1155.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract GameForecast is Adminable{

    address public cupNft = 0x8398Cbb5d1fcb93A5704Db2b4e6bE70cA3b35F25;
    address public rewardToken = 0x5439D37489Eef432979734e8ca7a36A826Cc1b58;
    uint256 public cupTokenId = 0;

    struct TeamInfo {
        uint8[] teams8;
        uint8[] teams4;
        uint8[] teams2;
        uint8   first;
        uint8   third;
    }

    uint8[16] public team16;
    uint256 public openTime;
    uint256 public startTime;
    uint256 public endTime;
    
    mapping(uint16 => uint256) public hitsRewards;
    mapping(address => uint16) public userForecastNumbers;
    mapping(address => mapping(uint16 => uint256)) public userForcastTimestamp;
    mapping(address => mapping(uint16 => TeamInfo)) public userForecastInfo;
    mapping(address => mapping(uint16 => bool)) public isRewards;
    TeamInfo public gameResult;
    bool public isSetReward;

    event OpenForecast(address indexed oper, uint8[] teams16, uint256 opentime);
    event EnterForecast(address indexed user, uint256 id, uint8[] teams16);
    event ClaimRewards(address indexed user, uint256 amount, uint256 id);

    function setRewards(uint16[] calldata hitTimes, uint256[] calldata rewards) public onlyAdmin {
        require(hitTimes.length == rewards.length, "length error");
        for(uint16 i = 0 ; i < hitTimes.length; ++i) {
            hitsRewards[hitTimes[i]] = rewards[i];
        }
        isSetReward = true;
    }
    
    function setRewardToken(address token) public onlyOwner {
        rewardToken = token;
    }

    function setCupNft(address nft) public onlyOwner {
        cupNft = nft;
    }

    function setTeam16Tokenid(uint8[16] calldata _teams16) public onlyAdmin {
        uint8[16] memory _tmpTeams16;
        for(uint8 i = 0; i < 16; ++i) {
            _tmpTeams16[i] = _teams16[i];
        }
        team16 = _tmpTeams16;
    }

    function setTime(uint256 _startTime, uint256 _endTime) public onlyAdmin{
        require(_startTime > block.timestamp, "start time must more than now");
        require(_startTime < _endTime, "start time must less than end time");
        startTime = _startTime;
        endTime = _endTime;
    }

    function openForecast(uint8[] calldata _teams16 ,uint256 _openTime) public onlyAdmin {
        require(block.timestamp > endTime, "not end");
        TeamInfo memory info;
        info.teams8 = _teams16[:8];
        info.teams4 = _teams16[8:12];
        info.teams2 = _teams16[12:14];
        info.first = _teams16[14];
        info.third = _teams16[15];
        _checkTeams8(info.teams8);
        _checkTeams4(info.teams8, info.teams4);
        _checkTeams2(info.teams4, info.teams2);
        _checkFirst(info.teams2,info.first);
        _checkThrid(info.teams4, info.teams2, info.third);
        gameResult = info;
        if(_openTime == 0) {
            openTime = block.timestamp;
        } else {
            openTime = _openTime;
        }
        emit OpenForecast(msg.sender, _teams16, _openTime);
    }


    function enterForecast(uint8[] calldata _teams16) public {
        require(_teams16.length == 16, "_teams16 length not 16");
        require(block.timestamp > startTime, "not start");
        require(block.timestamp < endTime, "has end");
        TeamInfo memory info;
        info.teams8 = _teams16[:8];
        info.teams4 = _teams16[8:12];
        info.teams2 = _teams16[12:14];
        info.first = _teams16[14];
        info.third = _teams16[15];

        _checkTeams8(info.teams8);
        _checkTeams4(info.teams8, info.teams4);
        _checkTeams2(info.teams4, info.teams2);
        _checkFirst(info.teams2,info.first);
        _checkThrid(info.teams4, info.teams2, info.third);
        address account = msg.sender;
        uint16 numbers = userForecastNumbers[account];
        numbers = numbers + 1;
 
        userForecastInfo[account][numbers] = info;
        userForecastNumbers[account] = numbers;
        userForcastTimestamp[account][numbers] = block.timestamp;
        TeamERC1155(cupNft).brun(account, cupTokenId, 1);
        emit EnterForecast(msg.sender, numbers, _teams16);
    }

    function getUserForecastInfo(address account, uint16 forecastId) public view returns (uint8[16] memory) {
        TeamInfo memory userinfo =  userForecastInfo[account][forecastId];
        uint8[16] memory results;
        for(uint16 i = 0; i < 8; ++i) {
            results[i] = userinfo.teams8[i];
        }

        for(uint16 i = 0; i < 4; ++i) {
            results[i + 8] = userinfo.teams4[i];
        }
        results[12] = userinfo.teams2[0];
        results[13] = userinfo.teams2[1];
        results[14] = userinfo.first;
        results[15] = userinfo.third;
        return results;
    }

    function getGameResults() public view returns (uint8[16] memory) {
        TeamInfo memory _resultInfo =  gameResult;
        uint8[16] memory results;
        if(openTime > block.timestamp) {
            return results;
        }

        for(uint16 i = 0; i < 8; ++i) {
            results[i] = _resultInfo.teams8[i];
        }

        for(uint16 i = 0; i < 4; ++i) {
            results[i + 8] = _resultInfo.teams4[i];
        }
        results[12] = _resultInfo.teams2[0];
        results[13] = _resultInfo.teams2[1];
        results[14] = _resultInfo.first;
        results[15] = _resultInfo.third;
        return results;
    }


    function getTeam16Tokenid() public view returns (uint8[16] memory) {
        return team16;
    }

    function getUserHits(address account, uint16 forecastId) public view returns (uint16){
        TeamInfo memory _teaminfo = userForecastInfo[account][forecastId];
        return _hit8(_teaminfo.teams8) + _hit4(_teaminfo.teams4) 
            + _hit2(_teaminfo.teams2) + _hitFirst(_teaminfo.first) + _hitThrid(_teaminfo.third);
    }

    function getUserForecastRewards(address user, uint16 forecastId) public view returns (uint256) {
        if(isRewards[user][forecastId] || isSetReward == false) {
            return 0;
        }
        return hitsRewards[getUserHits(user, forecastId)];
    }

    function claimForecastRewards(uint16 forecastId) public {
        require(block.timestamp > openTime && openTime > 0, "not open");
        require(isSetReward, "not set rewards");
        require(!isRewards[msg.sender][forecastId], "user has reward");
        uint256 amount = getUserForecastRewards(msg.sender, forecastId);
        IERC20(rewardToken).transfer( msg.sender, amount);
        isRewards[msg.sender][forecastId] = true;
        emit ClaimRewards(msg.sender, amount, forecastId);
    }


    function _checkTeams8(uint8[] memory _teams8) private view {
        require(_teams8[0] == team16[0] || _teams8[0] == team16[1], "teams8 not in teams16");
        require(_teams8[1] == team16[2] || _teams8[1] == team16[3], "teams8 not in teams16");
        require(_teams8[2] == team16[4] || _teams8[2] == team16[5], "teams8 not in teams16");
        require(_teams8[3] == team16[6] || _teams8[3] == team16[7], "teams8 not in teams16");
        require(_teams8[4] == team16[8] || _teams8[4] == team16[9], "teams8 not in teams16");
        require(_teams8[5] == team16[10] || _teams8[5] == team16[11], "teams8 not in teams16");
        require(_teams8[6] == team16[12] || _teams8[6] == team16[13], "teams8 not in teams16");
        require(_teams8[7] == team16[14] || _teams8[7] == team16[15], "teams8 not in teams16");
    }

    function _checkTeams4(uint8[] memory _teams8, uint8[] memory _teams4) private pure {
        require(_teams4[0] == _teams8[0] || _teams4[0] == _teams8[1], "_teams4 not in _teams8");
        require(_teams4[1] == _teams8[2] || _teams4[1] == _teams8[3], "_teams4 not in _teams8");
        require(_teams4[2] == _teams8[4] || _teams4[2] == _teams8[5], "_teams4 not in _teams8");
        require(_teams4[3] == _teams8[6] || _teams4[3] == _teams8[7], "_teams4 not in _teams8");
    }

    function _checkTeams2(uint8[] memory _teams4, uint8[] memory _teams2) private pure {
        require(_teams2[0] == _teams4[0] || _teams2[0] == _teams4[1], "_teams2 not in _teams4");
        require(_teams2[1] == _teams4[2] || _teams2[1] == _teams4[3], "_teams2 not in _teams4");
    }

    function _checkFirst(uint8[] memory _teams2, uint8 firstTeam) private pure {
        require(firstTeam == _teams2[0] ||firstTeam == _teams2[1], "firstTeam not in _teams2");
    }

    function _checkThrid(uint8[] memory _teams4, uint8[] memory _teams2, uint8 thridTeam) private pure { 
        require(thridTeam != _teams2[0] && thridTeam != _teams2[1], "thridTeam must not in _teams2");
        require(thridTeam == _teams4[0] || thridTeam != _teams4[1]
        || thridTeam == _teams4[2] || thridTeam != _teams4[3], "thridTeam must in _teams4");
    }



    function _hit8(uint8[] memory _teams8) private view returns (uint16) {
        uint16 ret;
        uint8[] memory winnerTeams8 = gameResult.teams8;
        for(uint8 i = 0; i < 8; ++i) {
            for(uint8 j = 0; j < 8; ++j) {
                if(_teams8[i] == winnerTeams8[j]) {
                    ret++;
                }
            }
        }
        return ret;
    }

    function _hit4(uint8[] memory _team4) private view returns (uint16) {
        uint16 ret;
        uint8[] memory winnerTeams4 = gameResult.teams4;
        for(uint8 i = 0; i < 4; ++i) {
            for(uint8 j = 0; j < 4; ++j) {
                if(_team4[i] == winnerTeams4[j]) {
                    ret++;
                }
            }
        }
        return ret;
    }

    function _hit2(uint8[] memory _teams2) private view returns (uint16) {
        uint16 ret;
        uint8[] memory winnerTeams2 = gameResult.teams2;
        for(uint8 i = 0; i < 2; ++i) {
            for(uint8 j = 0; j < 2; ++j) {
                if(_teams2[i] == winnerTeams2[j]) {
                    ret++;
                }
            }
        }
        return ret; 
    }

    function _hitFirst(uint8 _first) private view returns (uint16) {
        if(_first ==  gameResult.first) {
            return 1;
        }
        return 0;
    }

    function _hitThrid(uint8 _third) private view returns (uint16) {
        if(_third ==  gameResult.third) {
            return 1;
        }
        return 0;
    }

    function withdraw(address nftContractAddress, uint256[] memory tokenids, uint256[] memory amounts) public onlyOwner {
        IERC1155(nftContractAddress).safeBatchTransferFrom( address(this), msg.sender, tokenids, amounts, "");
    }

    function emergencyWithdrawToken(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }
 
}