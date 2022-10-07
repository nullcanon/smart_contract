pragma solidity ^0.8.16;



abstract contract Inviter {
    event AddUpper(address indexed user, address indexed upper);

    mapping(address => address) public userUpper;
    mapping(address => address[]) public upperUsers;


    function addUpper(address user, address upper) internal virtual {
        require(user != upper, "Can't invite self");
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

    function lowerLv1Amount(address account) public view virtual returns (uint256) {
        return upperUsers[account].length;
    }

    function getLowersL1(address account) public  view virtual returns (address[] memory) {
        return upperUsers[account];
    }
}