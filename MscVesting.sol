
pragma solidity ^0.5.0;



import "./node_modules/@openzeppelin@2.5.0/contracts/drafts/TokenVesting.sol";



contract MscVesting is TokenVesting {
    constructor (address beneficiary, uint256 start, uint256 cliffDuration, uint256 duration, bool revocable) 
    TokenVesting(beneficiary, start, cliffDuration, duration, revocable) 
    public {
        
    }
}