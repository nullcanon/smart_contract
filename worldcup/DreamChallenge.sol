pragma solidity ^0.8.0;

import "./Adminable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/IERC1155.sol";


// 1、添加梦幻挑战接口
// 2、梦幻挑战质押
// 小组赛、淘汰赛

contract DreamChallenge is Adminable, ERC1155Holder{

    address public teamNft;
    address public rewardToken;
    uint16 public challengeIdInex;
    uint256 public nftCost = 1 * 10 ** 18;

    enum Ctype {GROUP, KOUT} // 0 小组   1 淘汰
    struct Challenge {
        Ctype ctype; 
        uint16 id;
        uint256 startAt;
        uint256 endAt;
        uint256 openAt;
        uint256 tokenIdLeft;
        uint256 tokenIdRight;
        uint256 leftTotalAmount;
        uint256 rightTotalAmount;
        uint256 winnerTokenId;
    }

    struct UserInfo {
        uint16 challengeId;
        uint256 amountsLeft;
        uint256 amountsRight;
        bool isTakeReward;
    }

    mapping(uint16 => Challenge) challenges;

    // user -> (challengeId -> userinfo)
    mapping(address => mapping(uint16 => UserInfo)) userChallenges;
    mapping(address => uint16[]) userChallengeIds;

    event AddChallenge(address indexed admin, Ctype ctype, uint16 challengeId, uint256 startAt, uint256 endAt, uint256 tokenIdLeft, uint256 tokenIdRigth);
    event EnterChallenge(address indexed user, uint16 challengeId, uint256 tokenid, uint256 amount);
    event OpenChallenge(address indexed admin, uint16 challenageId);
    event WithdrawReward(address indexed user, uint16 challageId, uint256 amount);


    function addChallenge(Ctype _ctype, uint256 _startAt, uint256 _endAt,
        uint256 _tokenIdLeft, uint256 _tokenIdRight ) public onlyAdmin {

        require(_startAt > block.timestamp, "Start time must more than present time");
        require(_tokenIdLeft <= 36 && _tokenIdRight <= 36, "Token id must less than 37");
        challengeIdInex++;
        challenges[challengeIdInex] = Challenge(
            _ctype,
            challengeIdInex,
            _startAt,
            _endAt,
            0,
            _tokenIdLeft,
            _tokenIdRight,
            0,
            0,
            0
        );
    }

    function enterChallenge(uint16 _id, uint256 _tokenid, uint256 _amount) public {

        require(_amount > 0, "Amount is zero");
        Challenge memory chage = challenges[_id];

        require(chage.id != 0, "Id error");
        require(chage.startAt <= block.timestamp, "Challenge not start");
        require(chage.endAt > block.timestamp, "Challenge is end");
        require(chage.startAt < chage.endAt, "Start time must less than end time");
        require(chage.tokenIdLeft == _tokenid || chage.tokenIdRight == _tokenid, "Token id not in challenge");

        IERC1155(teamNft).safeTransferFrom(msg.sender, address(this), _tokenid, _amount, "");
        UserInfo memory userinfo = userChallenges[msg.sender][_id];
        userinfo.challengeId = _id;

        userChallengeIds[msg.sender].push(_id);
        if(chage.tokenIdLeft == _tokenid) {
            challenges[_id].leftTotalAmount += _amount;
            userinfo.amountsLeft += _amount;
        } else {
            challenges[_id].rightTotalAmount += _amount;
            userinfo.amountsRight += _amount;
        }

        userChallenges[msg.sender][_id] = userinfo;
    }

    function openChallenge(uint16 challengeId, uint256 winnerTokenId) public onlyAdmin {
        Challenge memory challenge = challenges[challengeId];
        require(challenge.id > 0, "Invalid challenge id");
        require(challenge.endAt < block.timestamp, "Challenge not end");

        challenge.openAt = block.timestamp;
        challenge.winnerTokenId = winnerTokenId;
        challenges[challengeId] = challenge;
        emit OpenChallenge(msg.sender, challengeId);
    }

    // reward token and stake nft.
    function withdrawReward(uint16 _challengeId) public {
        UserInfo memory userinfo = userChallenges[msg.sender][_challengeId];
        Challenge memory challenge = challenges[_challengeId];
        require(challenge.id > 0, "Invalid challenage");
        require(challenge.openAt < block.timestamp, "Challenage not opened");

        uint256 tokenid;
        uint256 amount;

        if(challenge.winnerTokenId == challenge.tokenIdLeft) {
            tokenid = challenge.tokenIdLeft;
            amount = userinfo.amountsLeft;
        } else {
            tokenid = challenge.tokenIdRight;
            amount = challenge.tokenIdRight;
        } 
        require(amount > 0, "Winner token amount is zero");

        uint256 winTokenAmount =  amount * nftCost * 80 / 100;

        IERC1155(teamNft).safeTransferFrom(address(this), msg.sender, tokenid, amount, "");
        IERC20(rewardToken).transfer(msg.sender, winTokenAmount);
        emit WithdrawReward(msg.sender, challenge.id, winTokenAmount);
    }

    function setTeamNft(address _nft) public onlyOwner {
        teamNft = _nft;
    }

    function setRewardToken(address _token) public onlyOwner {
        rewardToken = _token;
    }

    function setNftCost(uint256 _amount) public onlyOwner{
        nftCost = _amount;
    }

    function _getWinnerTokenId(uint16 challengeId) private view returns(uint256) {
        Challenge memory challenge = challenges[challengeId];
        if(challenge.winnerTokenId == challenge.tokenIdLeft) {
            return challenge.tokenIdLeft;
        } else {
            return challenge.tokenIdRight;
        }
    }

    function getUserRewards(address account, uint16 challengeId) public view returns(uint256){
        Challenge memory challenge = challenges[challengeId];
        if(challenge.id == 0) {
            return 0;
        }

        UserInfo memory userinfo = userChallenges[account][challengeId];

        if(userinfo.challengeId == 0) {
            return 0;
        }
        uint256 winAmount;
        if(challenge.winnerTokenId == challenge.tokenIdLeft) {
            winAmount = userinfo.amountsLeft;
        } else {
            winAmount = userinfo.amountsRight;
        }
        return winAmount * nftCost * 80 / 100;
    }

    function getUserChallenges(address account) public view returns(uint16[] memory) {
        return userChallengeIds[account];
    }

    function getUserChallengeInfo(address account, uint16 challengeId) public view returns(UserInfo memory) {
        return userChallenges[account][challengeId];
    }

    function getChallengeInfo(uint16 challengeId) public view returns(Challenge memory) {
        return challenges[challengeId];
    }
}