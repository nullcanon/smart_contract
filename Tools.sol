// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract FunctionSelector {
    /*
    "transfer(address,uint256)"
    0xa9059cbb
    "transferFrom(address,address,uint256)"
    0x23b872dd
    */
    function getSelector(string calldata _func) external pure returns (bytes4) {
        return bytes4(keccak256(bytes(_func)));
    }

    function getTopic(string calldata _func) external pure returns (bytes32) {
        return keccak256(bytes(_func));
    }
}


contract RandomTest {
    uint randNonce = 0;
    uint[] ret;
    uint luckybee;
    uint hashbee;
    uint knightbee;
    uint queenbee;

    function randomTest(uint number) public {
        for(uint i = 0; i < number; ++i) {
            uint random = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % 100;
            randNonce++;

            if(random < 57) {
                luckybee++;
            } else if (random >= 57 && random < 82 ) {
                hashbee++;
            } else if (random >= 82 && random < 97) {
                knightbee++;
            } else {
                queenbee++;
            }

            ret.push(random);
        }
    }

    function getRet() public view returns (uint[] memory) {
        return ret;
    }
    function getLuckybee() public view returns (uint) {
        return luckybee;
    }

    function getHashbee() public view returns (uint) {
        return hashbee;
    }

    function getKnightbee() public view returns (uint) {
        return knightbee;
    }

    function getQueenbee() public view returns (uint) {
        return queenbee;
    }


    function cleanRet() public {
        luckybee = 0;
        hashbee = 0;
        knightbee = 0;
        queenbee = 0;
        delete ret;
    }
    
}