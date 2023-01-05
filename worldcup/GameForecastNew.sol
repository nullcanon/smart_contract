pragma solidity ^0.8.17;

import "./GameForecast.sol";


contract GameForecastNew  is Adminable{
    address public oldGameForecast;

    mapping 

    function setTeam16TokenidNew(uint8[16] calldata _teams16) public onlyAdmin {
        uint8[16] memory _tmpTeams16;
        for(uint8 i = 0; i < 16; ++i) {
            _tmpTeams16[i] = _teams16[i];
        }
        team16 = _tmpTeams16;
    }

    function enterForecast(uint8[] calldata _teams4, uint16 forecastId) public {
        uint8[16] memory userinfo = GameForecast(oldGameForecast).getUserForecastInfo(msg.sender, forecastId);

        emit EnterForecast(msg.sender, numbers, _teams16);
    }

}