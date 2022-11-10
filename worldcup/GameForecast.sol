pragma solidity ^0.8.0;

import "./Adminable.sol";
import "./TeamERC1155.sol"
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract GameForecast is Adminable{

    address public cupNft;
    address public rewardToken;
    uint256 public cupTokenId = 0;

    struct TeamInfo {
        uint8[8] teams8;
        uint8[4] teams4;
        uint8[2] teams2;
        uint8   first;
        uint8   third;
    }

    uint8[16] public team16;
    uint256 public openTime;
    uint256 public startTime;
    uint256 public endTime;
    
    mapping(address => uint16) public userForecastNumbers;
    mapping(address => mapping(uint16 => TeamInfo)) public userForecastInfo;
    TeamInfo public gameResult;

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

    function openForecast(uint8[8] calldata _teams8, uint8[4] calldata _teams4, uint8[2] calldata _teams2, uint8 _first, uint8 _third, uint256 _openTime) public onlyAdmin {
        require(block.timestamp > endTime, "not end");
        TeamInfo memory _gameResult = gameResult;
        _checkTeams8(_teams8);
        _checkTeams4(_teams8, _teams4);
        _checkTeams2(_teams4, _teams2);
        _checkFirst(_teams2, _first);
        _checkThrid(_teams4, _teams2, _third);
        _gameResult.teams8 = _teams8;
        _gameResult.teams4 = _teams4;
        _gameResult.teams2 = _teams2;
        _gameResult.first = _first;
        _gameResult.third = _third;
        gameResult = _gameResult;
        if(_openTime == 0) {
            openTime = block.timestamp;
        } else {
            openTime = _openTime;
        }
    }

    function enterForecast(uint8[8] calldata _teams8, uint8[4] calldata _teams4, uint8[2] calldata _teams2, uint8 _first, uint8 _third) public {
        require(block.timestamp > startTime, "not start");
        require(block.timestamp < endTime, "has end");
        _checkTeams8(_teams8);
        _checkTeams4(_teams8, _teams4);
        _checkTeams2(_teams4, _teams2);
        _checkFirst(_teams2, _first);
        _checkThrid(_teams4, _teams2, _third);
        address account = msg.sender;
        uint16 numbers = userForecastNumbers[account];
        numbers = numbers + 1;
        TeamInfo memory info = userForecastInfo[msg.sender][numbers];
        info.teams8 = _teams8;
        info.teams4 = _teams4;
        info.teams2 = _teams2;
        info.first = _first;
        info.third = _third;
        userForecastInfo[account][numbers] = info;
        userForecastNumbers[account] = numbers;
        TeamERC1155(cupNft).brun(account, cupTokenId, 1);
    }

    function getGameResultTeams8() public view returns (uint8[8] memory) {
        return gameResult.teams8;
    }

    function getGameResultTeams4() public view returns (uint8[4] memory) {
        return gameResult.teams4;
    }

    function getGameResultTeams2() public view returns (uint8[2] memory) {
        return gameResult.teams2;
    }

    function getGameResultFirst() public view returns (uint8) {
        return gameResult.first;
    }

    function getGameResultThird() public view returns (uint8) {
        return gameResult.third;
    }

    function getTeam16Tokenid() public view returns (uint8[16] memory) {
        return team16;
    }


    function getUserForecastRewards(address user, uint16 forecastId) public view returns (uint256) {

    }

    function claimForecastRewards(uint16 forecastId) public {
        require(block.timestamp > openTime && openTime > 0, "not open");

    }



    function _checkTeams8(uint8[8] calldata _teams8) private view {
        require(_teams8[0] == team16[0] || _teams8[0] == team16[1], "teams8 not in teams16");
        require(_teams8[1] == team16[2] || _teams8[1] == team16[3], "teams8 not in teams16");
        require(_teams8[2] == team16[4] || _teams8[2] == team16[5], "teams8 not in teams16");
        require(_teams8[3] == team16[6] || _teams8[3] == team16[7], "teams8 not in teams16");
        require(_teams8[4] == team16[8] || _teams8[4] == team16[9], "teams8 not in teams16");
        require(_teams8[5] == team16[10] || _teams8[5] == team16[11], "teams8 not in teams16");
        require(_teams8[6] == team16[12] || _teams8[6] == team16[13], "teams8 not in teams16");
        require(_teams8[7] == team16[14] || _teams8[7] == team16[15], "teams8 not in teams16");
    }

    function _checkTeams4(uint8[8] calldata _teams8, uint8[4] calldata _teams4) private pure {
        require(_teams4[0] == _teams8[0] || _teams4[0] == _teams8[1], "_teams4 not in _teams8");
        require(_teams4[1] == _teams8[2] || _teams4[1] == _teams8[3], "_teams4 not in _teams8");
        require(_teams4[2] == _teams8[4] || _teams4[2] == _teams8[5], "_teams4 not in _teams8");
        require(_teams4[3] == _teams8[6] || _teams4[3] == _teams8[7], "_teams4 not in _teams8");
    }

    function _checkTeams2(uint8[4] calldata _teams4, uint8[2] calldata _teams2) private pure {
        require(_teams2[0] == _teams4[0] || _teams2[0] == _teams4[1], "_teams2 not in _teams4");
        require(_teams2[1] == _teams4[2] || _teams2[1] == _teams4[3], "_teams2 not in _teams4");
    }

    function _checkFirst(uint8[2] calldata _teams2, uint8 firstTeam) private pure {
        require(firstTeam == _teams2[0] ||firstTeam == _teams2[1], "firstTeam not in _teams2");
    }

    function _checkThrid(uint8[4] calldata _teams4, uint8[2] calldata _teams2, uint8 thridTeam) private pure { 
        require(thridTeam != _teams2[0] && thridTeam != _teams2[1], "thridTeam must not in _teams2");
        require(thridTeam == _teams4[0] || thridTeam != _teams4[1]
        || thridTeam == _teams4[2] || thridTeam != _teams4[3], "thridTeam must in _teams4");
    }

    function getUserHits(address account, uint16 forecastId) public view returns (uint256){
        TeamInfo memory _teaminfo = userForecastInfo[account][forecastId];
        return _hit8(_teaminfo.teams8) + _hit4(_teaminfo.teams4) 
            + _hit2(_teaminfo.teams2) + _hitFirst(_teaminfo.first) + _hitThrid(_teaminfo.third);
    }

    function _hit8(uint8[8] memory _teams8) private view returns (uint16) {
        uint16 ret;
        uint8[8] memory winnerTeams8 = getGameResultTeams8();
        for(uint8 i = 0; i < 8; ++i) {
            for(uint8 j = 0; j < 8; ++j) {
                if(_teams8[i] == winnerTeams8[j]) {
                    ret++;
                }
            }
        }
        return ret;
    }

    function _hit4(uint8[4] memory _team4) private view returns (uint16) {
        uint16 ret;
        uint8[4] memory winnerTeams4 = getGameResultTeams4();
        for(uint8 i = 0; i < 4; ++i) {
            for(uint8 j = 0; j < 4; ++j) {
                if(_team4[i] == winnerTeams4[j]) {
                    ret++;
                }
            }
        }
        return ret;
    }

    function _hit2(uint8[2] memory _teams2) private view returns (uint16) {
        uint16 ret;
        uint8[2] memory winnerTeams2 = getGameResultTeams2();
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
        if(_first ==  getGameResultFirst()) {
            return 1;
        }
        return 0;
    }

    function _hitThrid(uint8 _third) private view returns (uint16) {
        if(_third ==  getGameResultThird()) {
            return 1;
        }
        return 0;
    }
 
}