pragma solidity 0.5.5;

import "./node_modules/@openzeppelin@2.5.0/contracts/crowdsale/distribution/PostDeliveryCrowdsale.sol";
import "./node_modules/@openzeppelin@2.5.0/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "./node_modules/@openzeppelin@2.5.0/contracts/crowdsale/Crowdsale.sol";
import "./node_modules/@openzeppelin@2.5.0/contracts/crowdsale/emission/AllowanceCrowdsale.sol";
import "./node_modules/@openzeppelin@2.5.0/contracts/ownership/Ownable.sol";

contract Presell is Crowdsale, TimedCrowdsale, PostDeliveryCrowdsale , AllowanceCrowdsale {


    constructor(
        uint256 rate,            // rate, in TKNbits
        address payable wallet,  // wallet to send Ether
        IERC20 token,            // the token
        uint256 openingTime,     // opening time in unix epoch seconds
        uint256 closingTime,      // closing time in unix epoch seconds
        address tokenWallet       // pay token
    )
        AllowanceCrowdsale(tokenWallet)
        PostDeliveryCrowdsale()
        TimedCrowdsale(openingTime, closingTime)
        Crowdsale(rate, wallet, token)
        public
    {
        // nice! this Crowdsale will keep all of the tokens until the end of the crowdsale
        // and then users can `withdrawTokens()` to get the tokens they're owed
    }

}