
pragma solidity ^0.8.0;

import "../../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract Orchestrated is Ownable {
    event GrantedAccess(address access);
    
    mapping(address => mapping(bytes4 => bool)) public orchestration;
    
    constructor() Ownable() {}
    
    /// @dev Restrict usage to authorized users;
    modifier onlyOrchestrated(string memory err) {
        require(orchestration[msg.sender][msg.sig], err);
        _;
    }
    
    /// @dev add orchestration
    function orchestrate(address user, bytes4 sig) public OnlyOwner {
      orchestration[user][sig] = true;
      emit GrantedAccess(user);
    }
    

}