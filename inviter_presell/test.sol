pragma solidity ^0.8.16;

import "./stake.sol";

contract test {
    function test1() private {
        StakingRewards(0x05c8dC15515300725Fb02899678E3AC95D264184).setStartTime(1);
    }

    function test2() public  {
        test1();
    }
}