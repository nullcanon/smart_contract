pragma solidity ^0.8.0;


abstract contract RandomId {

    uint numbers = 36;
    uint256[36] lefts = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35];
    uint256[36] rights = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36];


    function random(uint number, uint nonce) internal virtual view returns(uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty,  
            msg.sender, nonce))) % number + 1;
    }

    function getRandomTokenid(uint nonce) internal virtual view returns (uint256) {
        uint256 x = random(numbers, nonce);
        for(uint256 i = 0; i < numbers; ++i) {
            if(x > lefts[i] && x <= rights[i]) {
                return i + 1;
            }
        }
        return 0;
    }



}