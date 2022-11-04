pragma solidity ^0.8.0;



import "./TeamERC1155.sol";
import "./RandomId.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Synthesizer is RandomId, Ownable{

    uint32 public compoundNumbers = 8;
    uint256 public worldcupTokenId = 0;
    address public teamNft;

    event CompoundNft(address indexed user, uint256[] tokenids);

    function compoundNft(uint256[] memory tokenids) public {
        require(tokenids.length == compoundNumbers, "tokenid numbers error");

        uint256[] memory amounts = new uint256[](tokenids.length);
        for(uint256 i = 0; i < tokenids.length; ++i) {
            amounts[i] = 1;
        }
        TeamERC1155(teamNft).brunBatch(msg.sender, tokenids, amounts);
        uint256[] memory nftTokenId = new uint256[](1);
        uint256[] memory nftAmount = new uint256[](1);
        nftTokenId[0] = worldcupTokenId;
        nftAmount[0] = 1;
        TeamERC1155(teamNft).mintTokenIdWithWitelist(msg.sender, nftTokenId, nftAmount);
        emit CompoundNft(msg.sender, tokenids);
    }

    function setTeamNft(address nft) public onlyOwner {
        teamNft = nft;
    }
}
