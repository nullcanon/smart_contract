pragma solidity ^0.8.16;

import "./adminable.sol"


contract invater is Adminable {
    event AddUpper(address indexed user, address indexed upper)

    mapping(address => address) public userUpper;
    mapping(address => address[]) public upperUsers;
    


    function addUpper(address user, address upper) public onlyAdmin {
        address curUpper = userUpper[user];
        for(uint32 i = 0; i < 12; ++i) {
            if(curUpper == address(0)) {
                break;
            }
            require(curUpper != user, "Repetition upper");
        }
        userUpper[user] = upper;
        upperUsers[uppser].push(user);
        emit AddUpper(user, upper);
    }
}