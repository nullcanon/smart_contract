
pragma solidity ^0.8.0;



import "./TeamERC1155.sol"
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/EnumerableMap.sol"

contract MintTeam {
    address public team;
    address public money;
    address public bank;
    uint256 public price;
    using EnumerableMap for EnumerableMap.UintToUintMap;
    uint numbers = 32;


    function random(uint number, uint nonce) public view returns(uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
            msg.sender, nonce))) % number + 1;
    }

    function mintWithBlindBox(uint256 quantity) public {
        uint256 amount = price * quantity;
        IERC20(money).transferFrom(msg.sender, bank, amount);

        EnumerableMap.UintToUintMap tokens;

        for(uint256 i = 0; i < quantity; ++i){
            uint256 tokenid = random(numbers, i);
            (bool success, uint256 value)  = tokens.tryGet(tokenids);
            if(success == true) {
                value = value + 1;
                tokens.set(tokenid, value);
            } else {
                tokens.set(tokenid, 1);
            }
        }

        for(uint256 i = 0; i < tokens.length(); ++i) {
            uint256[] ids = new ;

        }


        TeamERC1155(team).mintTokenIdWithWitelist(msg.sender, ids, amounts);
        
    }
}