pragma solidity ^0.8.0;

import "./ERC1155.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract BacthTransferHelper is Ownable{

    address public nftMintAddress;

    function batchTransfer(address[] memory users, uint256 start) public onlyOwner{
        for(uint256 i = start; i < start + users.length; i++) {
            BeeItems(nftMintAddress).safeTransferFrom(msg.sender, users[i - start], i, 1, "");
        }
    }

    function setMint(address mint) public onlyOwner {
        nftMintAddress = mint;
    }


    
}