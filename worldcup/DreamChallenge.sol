pragma solidity ^0.8.0;

import "./Adminable.sol";

// 1、添加梦幻挑战接口
// 2、梦幻挑战质押
// 小组赛、淘汰赛

contract DreamChallenge is Adminable{

    address public teamNft;
    address public rewardToken;

    struct Challenge {
        uint8 ctype; // 0 小组   1 淘汰
        uint16 id;
        uint256 startAt;
        uint256 endAt;
        uint256 tokenIdLeft;
        uint256 tokenIdRight;
    }

    mapping(uint16 => Challenge) challenges;

    event AddChallenge();
    event EnterChallenge();
    event OpenChallenge();

    function setTeamNft(address _nft) public onlyOwner {
        teamNft = _nft;
    }

    function addChallenge(uint8 _ctype, uint256 _startAt, uint256 _endAt,
        uint256 _tokenIdLeft, uint256 _tokenIdRight ) public onlyAdmin{

    }

    function enterChallenge(uint16 _id, uint256 t_okenid, uint256 amount) public {

    }

    function openChallenge() public onlyAdmin {

    }

    function withdrawReward() public {

    }

    function getReward(address account, uint16 challengeId) public {

    }
}