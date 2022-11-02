pragma solidity ^0.8.0;



import "./TeamERC1155.sol";
import "./RandomId.sol";

contract Synthesizer is RandomId{

    uint32 compoundNumbers = 8;

    function compoundNft(uint256[] memory tokenids) public {
        require(tokenids.length == compoundNumbers, "tokenid numbers error");
        IERC1155(luckybeeMintAddress).safeTransferFrom( msg.sender, address(this), luckybeeId, 1 , "");
        BeeItems(luckybeeMintAddress).brun(address(this), luckybeeId, 1);

        IERC1155(hashbeeMintAddress).safeTransferFrom( msg.sender, address(this), hashbeeId, 1 , "");
        BeeItems(hashbeeMintAddress).brun(address(this), hashbeeId, 1);

        IERC1155(knightbeeMintAddress).safeTransferFrom( msg.sender, address(this), knightbeeId, 1 , "");
        BeeItems(knightbeeMintAddress).brun(address(this), knightbeeId, 1);

        IERC1155(queenbeeMintAddress).safeTransferFrom( msg.sender, address(this), queenbeeId, 1 , "");
        BeeItems(queenbeeMintAddress).brun(address(this), queenbeeId, 1);

        IERC20(beeTokenMintAddress).transferFrom(msg.sender, feeAddress, feeAmount);

        (uint256 minTokenId, uint256 index) = LibArrayForUint256Utils.min(nftIds);
        LibArrayForUint256Utils.removeByIndex(nftIds, index);
        IERC1155(bumbleBeeMintAddress).safeTransferFrom(address(this), msg.sender, minTokenId, 1 , "");

        emit BlendNft(msg.sender, minTokenId, bumbleBeeMintAddress);
    }
}
