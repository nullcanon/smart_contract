pragma solidity ^0.8.0;



import "./TeamERC1155.sol";
import "./RandomId.sol";

contract Synthesizer is RandomId{

    uint32 public compoundNumbers = 8;
    uint256 public worldcupTokenId = 0;
    address public teamNft;

    event CompoundNft(address indexed user, uint256[] tokenids);

    function compoundNft(uint256[] memory tokenids) public {
        require(tokenids.length == compoundNumbers, "tokenid numbers error");

        uint256[] memory amounts = new uint256[](tokenids.length)
        for(uint256 i = 0; i < tokenids.length; ++i) {
            amounts[i] = 1;
        }
        TeamERC1155(teamNft).brunBatch(msg.sender, tokenids, amounts);
        TeamERC1155(teamNft).mintTokenIdWithWitelist(msg.sender, [worldcupTokenId], [1]);
        emit CompoundNft(msg.sender, tokenids);
    }
}
