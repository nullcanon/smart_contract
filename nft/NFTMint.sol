// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "../node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract MintNft is ERC1155Holder, Ownable {
    address private luckybeeMintAddress;
    address private hashbeeMintAddress;
    address private knightbeeMintAddress;
    address private queenbeeMintAddress;
    address private bumbleBeeMintAddress;

    address private beeTokenMintAddress = 0xB0bc99bdb71a4320a9aD357f68EBfBe6fFeBFc8A;

    address private feeAddress = 0xd3c0b6Aa1538d639912789be705F18b5Fd89fcE6;
    uint256 private feeAmount = 1 * 10 ** 18;

    // uint256 private mintTokenId = 1;
    mapping(address => uint256) totalHold;
    mapping(address => uint256) private mintTokenId;

    event mint(address indexed nftContractAddress, address indexed user);


    function mintNft(
        address nftContractAddress
    ) public {
        // check nftContractAddress

        require(IERC20(beeTokenMintAddress).allowance(msg.sender, feeAddress) >= feeAmount, "Token allowance too low");
        IERC20(beeTokenMintAddress).transferFrom(msg.sender, feeAddress, feeAmount);

        IERC1155(nftContractAddress).safeTransferFrom( address(this) , msg.sender, mintTokenId[nftContractAddress], 1 , "");
        mintTokenId[nftContractAddress] =  mintTokenId[nftContractAddress] + 1;
        totalHold[nftContractAddress] = totalHold[nftContractAddress] - 1;

        emit mint(nftContractAddress, msg.sender);
    }

    function addNftBatchWithNumber(
        address nftContractAddress,
        uint256 start,
        uint256 idsNumber
    ) public {
        uint256[] memory ids = new uint256[](idsNumber);
        uint256[] memory amounts = new uint256[](idsNumber);
        for (uint256 i = start; i < (idsNumber + start); i++) {
            ids[i] = i;
            amounts[i] = 1;
        }
        IERC1155(nftContractAddress).safeBatchTransferFrom(msg.sender, address(this), ids, amounts, "");
        totalHold[nftContractAddress] = totalHold[nftContractAddress] + idsNumber;
    }

    function addNftBatch(
        address nftContractAddress,
        uint256[] memory ids,
        uint256[] memory amounts
    ) public {
        IERC1155(nftContractAddress).safeBatchTransferFrom(msg.sender, address(this), ids, amounts, "");
        totalHold[nftContractAddress] = totalHold[nftContractAddress] + ids.length;
    }

    function withdraw(address nftContractAddress) public onlyOwner {
        uint256[] memory ids = new uint256[](totalHold[nftContractAddress]);
        uint256[] memory amounts = new uint256[](totalHold[nftContractAddress]);
        for (uint256 i = mintTokenId[nftContractAddress]; 
            i < (mintTokenId[nftContractAddress] + totalHold[nftContractAddress]); i++) {
            ids[i] = i;
            amounts[i] = 1;
        }
        IERC1155(nftContractAddress).safeBatchTransferFrom(msg.sender, address(this), ids, amounts, "");
    }
}