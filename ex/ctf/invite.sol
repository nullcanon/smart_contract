pragma solidity ^0.8.16;



abstract contract Inviter {
    event AddUpper(address indexed user, address indexed upper);

    mapping(address => address) public userUpper;
    mapping(address => address[]) public lowerUsers;
    mapping(address => uint256) public lowersUsersTradeVolume;

    uint256 public threshold = 5000 * 10 ** 18;

    function getUserTradeVolumeUset(address account) public returns (uint256) {
        return 0;
    }


    function addUpper(address user, address upper) public {
        require(user != upper, "Can't invite self");
        require(getUserTradeVolumeUset(account) >= threshold, "Can't invite self");

        address curUpper = userUpper[user];
        for(uint32 i = 0; i < 11; ++i) {
            if(curUpper == address(0)) {
                break;
            }
            require(curUpper != user, "Repetition upper");
        }
        userUpper[user] = upper;
        upperUsers[upper].push(user);
        emit AddUpper(user, upper);
    }

    function lowerLv1Amount(address account) public view  returns (uint256) {
        return upperUsers[account].length;
    }

    function getLowersL1(address account) external view  returns (address[] memory) {
        return upperUsers[account];
    }


    function getLowersL1Limit(address _owner , uint256 start , uint256 len) external view returns (address[] memory) {
        uint256 tmp = lowerUsers.length;
        address[] memory _lowerUsers = lowerUsers;
        require(start >= 0 && len > 0 && start + len <=  tmp, "out of range");

        address[] memory tmpData = new address[](len);
        for(uint256 i = 0 ; i < len ; i++ ){
            tmpData[i] = _lowerUsers[_owner].lowers[start + i];
        }
        return tmpData ;
    }

}