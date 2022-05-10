pragma solidity ^0.8.13;

import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/ERC1155.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract Synthesizer is ERC1155Holder {
    address private luckybeeMintAddress;
    address private hashbeeMintAddress;
    address private knightbeeMintAddress;
    address private queenbeeMintAddress;
    address private bumbleBeeMintAddress;

    address private beeTokenMintAddress;

    address private feeAddress;
    uint256 private feeAmount = 200 * 10 ** 18;

    function mixNft(
        uint256 luckybeeId,
        uint256 hashbeeId,
        uint256 knightbeeId,
        uint256 queenbeeId
    ) public {
        IERC1155(luckybeeMintAddress).safeTransferFrom( msg.sender, address(this), luckybeeId, 1 , "");
        IERC1155(luckybeeMintAddress).burn(address(this), luckybeeId, 1);

        IERC1155(hashbeeMintAddress).safeTransferFrom( msg.sender, address(this), hashbeeId, 1 , "");
        IERC1155(hashbeeMintAddress).burn(address(this), hashbeeId, 1);

        IERC1155(knightbeeMintAddress).safeTransferFrom( msg.sender, address(this), knightbeeId, 1 , "");
        IERC1155(knightbeeMintAddress).burn(address(this), knightbeeId, 1);

        IERC1155(queenbeeMintAddress).safeTransferFrom( msg.sender, address(this), queenbeeId, 1 , "");
        IERC1155(queenbeeMintAddress).burn(address(this), queenbeeId, 1);

        require(IERC20(beeTokenMintAddress).allowance(msg.sender, feeAddress) >= feeAmount, "Token allowance too low");
        IERC20(beeTokenMintAddress).transferFrom(msg.sender, feeAddress, feeAmount);

        // TODO queenbeeId
        IERC1155(bumbleBeeMintAddress).safeTransferFrom(address(this), msg.sender, queenbeeId, 1 , "");
    }

    function setAwardNftBatch() public {

    }
}
