pragma solidity ^0.8.0;

import "./NFTERC1155Mint.sol";

contract NFTMint is  Ownable{
    function mintNft(address nftContract) public {
        NFTItems(nftContract).mintWithWiteList(msg.sender);
    }
}