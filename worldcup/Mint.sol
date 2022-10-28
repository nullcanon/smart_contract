
pragma solidity ^0.8.0;



import "./TeamERC1155.sol"
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract MintTeam {
    address public team;
    address public money;
    address public bank;
    uint256 public price;


    function random(uint number) public view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
            msg.sender))) % number + 1;
    }

    function mintWithBlindBox(uint256 quantity) public {
        uint256 amount = price * quantity;
        IERC20(money).transferFrom(msg.sender, bank, amount);
        for(uint256 i = 0; i < quantity; ++i){
            uint 
        }
        TeamERC1155(team).safeBatchTransferFrom(msg.sender, to, ids, amounts, "");
        
    }
}