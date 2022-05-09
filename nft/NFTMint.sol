
pragma solidity ^0.8.0;


import "./node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract MintNft is ERC1155Holder {
    address private luckybeeMintAddress;
    address private hashbeeMintAddress;
    address private knightbeeMintAddress;
    address private queenbeeMintAddress;
    address private bumbleBeeMintAddress;

    address private beeTokenMintAddress;

    address private feeAddress;
    uint256 private feeAmount = 200 * 10 ** 18;

    uint256 private mintTokenId = 1;
    uint256 private totalHold;

    function mintNft(
        address nftContractAddress,
    ) public {
        // check nftContractAddress

        require(IERC20(beeTokenMintAddress).allowance(msg.sender, feeAddress) >= feeAmount, "Token allowance too low");
        IERC20(beeTokenMintAddress).transferFrom(msg.sender, feeAddress, feeAmount);

        IERC1155(nftContractAddress).safeTransferFrom( address(this) , msg.sender, mintTokenId, 1 , "");
        ++mintTokenId;
        --totalHold;
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
        totalHold += idsNumber;
    }

    function addNftBatch(
        address nftContractAddress,
        uint256[] ids,
        uint256[] amounts
    ) public {
        IERC1155(nftContractAddress).safeBatchTransferFrom(msg.sender, address(this), ids, amounts, "");
        totalHold += ids.lenght;
    }

    function withdraw() public onlyOwner{
        uint256[] memory ids = new uint256[](totalHold);
        uint256[] memory amounts = new uint256[](totalHold);
        for (uint256 i = mintTokenId; i < (mintTokenId + totalHold); i++) {
            ids[i] = i;
            amounts[i] = 1;
        }
        IERC1155(nftContractAddress).safeBatchTransferFrom(msg.sender, address(this), ids, amounts, "");
    }
}