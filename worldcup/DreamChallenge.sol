pragma solidity ^0.8.0;

import "./Adminable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/IERC1155.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/EnumerableSet.sol";

// 1、添加梦幻挑战接口
// 2、梦幻挑战质押
// 小组赛、淘汰赛

contract DreamChallenge is Adminable, ERC1155Holder{

    address public teamNft = 0x9D8f7aEA83ceCF102ab65e9A5b82106b07a68b28;
    address public rewardToken = 0x58a944f9c44D08461A471A1F6C6D15De351d97B3;
    uint16 public challengeIdInex;
    uint256 public rate = 80;
    uint256 public nftCost = 1 * 10 ** 18;

    using EnumerableSet for EnumerableSet.UintSet;

    enum Ctype {GROUP, KOUT} // 0 小组   1 淘汰
    enum Target {NOMAL, LEFT, MIDDLE, RIGHT}
    struct Challenge {
        Ctype ctype; 
        Target winnerTarget;
        uint16 id;
        uint16 placeId;
        uint16 matchId;
        uint16 leftScore;
        uint16 rightScore;
        uint256 startAt;
        uint256 endAt;
        uint256 openAt;
        uint256 tokenIdLeft;
        uint256 tokenIdRight;
        uint256 leftTotalAmount;
        uint256 rightTotalAmount;
        uint256 leftMiddleTotalAmount;
        uint256 rightMiddleTotalAmount;
    }

    struct UserInfo {
        uint16 challengeId;
        uint256 amountsLeft;
        uint256 amountsRight;
        uint256 amountMiddleL;
        uint256 amountMiddleR;
        bool isTakeReward;
    }

    mapping(uint16 => Challenge) challenges;

    // user -> (challengeId -> userinfo)
    mapping(address => mapping(uint16 => UserInfo)) userChallenges;
    mapping(address => EnumerableSet.UintSet) userChallengeIds;


    event AddChallenge(address indexed admin, Ctype ctype, uint16 challengeId, uint16 placeId, uint16 matchId, uint256 startAt, 
    uint256 endAt, uint256 tokenIdLeft, uint256 tokenIdRight);

    event ModifyChallenge(address indexed admin, Ctype ctype, uint16 challengeId, uint16 placeId, uint16 matchId, uint256 startAt, 
    uint256 endAt, uint256 tokenIdLeft, uint256 tokenIdRight);
    event EnterChallenge(address indexed user, uint16 challengeId, Target target, uint256 tokenid, uint256 amount);
    event OpenChallenge(address indexed admin, uint16 challenageId, uint16 leftScore, uint16 rightScore, Target target, uint256 openTime);
    event WithdrawReward(address indexed user, uint16 challageId, uint256 amount);


    function addChallenge(Ctype _ctype, uint16 _placeId, uint16 _matchId, uint256 _startAt, uint256 _endAt,
        uint256 _tokenIdLeft, uint256 _tokenIdRight ) public onlyAdmin {

        require(_startAt > block.timestamp, "Start time must more than present time");
        require(_tokenIdLeft <= 32 && _tokenIdRight <= 32, "Token id must less than 37");
        challengeIdInex++;
        challenges[challengeIdInex] = Challenge(
            _ctype,
            Target.NOMAL,
            challengeIdInex,
            _placeId,
            _matchId,
            0,
            0,
            _startAt,
            _endAt,
            0,
            _tokenIdLeft,
            _tokenIdRight,
            0,
            0,
            0,
            0
        );
        emit AddChallenge(msg.sender, _ctype, challengeIdInex, _placeId, _matchId, _startAt, _endAt, _tokenIdLeft, _tokenIdRight);
    }

    function modifyChallenge(uint16 _cId, Ctype _ctype, uint16 _placeId, uint16 _matchId, uint256 _startAt, uint256 _endAt,
        uint256 _tokenIdLeft, uint256 _tokenIdRight) public onlyAdmin{
            Challenge memory challenge = challenges[_cId];
            require(challenge.id > 0, "Challenge not found");
            challenge.ctype = _ctype;
            challenge.placeId = _placeId;
            challenge.matchId = _matchId;
            challenge.startAt = _startAt;
            challenge.endAt = _endAt;
            challenge.tokenIdLeft = _tokenIdLeft;
            challenge.tokenIdRight = _tokenIdRight;
            challenges[_cId] = challenge;
            emit ModifyChallenge(msg.sender, _ctype, _cId, _placeId, _matchId, _startAt, _endAt, _tokenIdLeft, _tokenIdRight);
    }

    function enterChallenge(uint16 _id, Target _target, uint256 _tokenid, uint256 _amount) public {

        require(_amount > 0, "Amount is zero");
        require(_target != Target.NOMAL, "Target cant NOMAL");
        Challenge memory chage = challenges[_id];

        require(chage.id != 0, "Id error");
        require(chage.startAt <= block.timestamp, "Challenge not start");
        require(chage.endAt > block.timestamp, "Challenge is end");
        require(chage.startAt < chage.endAt, "Start time must less than end time");
        require(chage.tokenIdLeft == _tokenid || chage.tokenIdRight == _tokenid, "Token id not in challenge");
        if(chage.ctype == Ctype.KOUT) {
            require(_target == Target.LEFT || _target == Target.RIGHT, "Target error");
        }

        if(_target == Target.LEFT) {
            require(_tokenid == chage.tokenIdLeft, "tokenId and target not match");
        }
        
        if(_target == Target.RIGHT) {
            require(_tokenid == chage.tokenIdRight, "tokenId and target not match");
        }

        IERC1155(teamNft).safeTransferFrom(msg.sender, address(this), _tokenid, _amount, "");
        UserInfo memory userinfo = userChallenges[msg.sender][_id];
        userinfo.challengeId = _id;

        userChallengeIds[msg.sender].add(_id);
        if(_target == Target.LEFT) {
            require(_tokenid == chage.tokenIdLeft, "Token id not much");
            challenges[_id].leftTotalAmount += _amount;
            userinfo.amountsLeft += _amount;
        } else if (_target == Target.RIGHT){
            challenges[_id].rightTotalAmount += _amount;
            userinfo.amountsRight += _amount;
        } else {
            if(_tokenid == chage.tokenIdLeft) {
                challenges[_id].leftMiddleTotalAmount += _amount;
                userinfo.amountMiddleL += _amount;
            } else {
                challenges[_id].rightMiddleTotalAmount += _amount;
                userinfo.amountMiddleR += _amount;  
            }
        }

        userChallenges[msg.sender][_id] = userinfo;

        emit EnterChallenge(msg.sender, _id, _target, _tokenid, _amount);
    }


    function openChallenge(uint16 challengeId, Target winnerTarget, uint16 leftScore, uint16 rightScore, uint256 time) public onlyAdmin {
        Challenge memory challenge = challenges[challengeId];
        require(challenge.id > 0, "Invalid challenge id");
        require(challenge.endAt < block.timestamp, "Challenge not end");

        uint256 setTime = time;
        if(setTime == 0) {
            setTime = block.timestamp;
        }
        challenge.openAt = setTime;
        challenge.winnerTarget = winnerTarget;
        challenges[challengeId] = challenge;
        challenge.leftScore = leftScore;
        challenge.rightScore = rightScore;
        emit OpenChallenge(msg.sender, challengeId, leftScore, rightScore, winnerTarget, setTime);
    }

    // reward token and stake nft.
    function withdrawReward(uint16 _challengeId) public {
        UserInfo memory userinfo = userChallenges[msg.sender][_challengeId];
        Challenge memory challenge = challenges[_challengeId];
        require(challenge.id > 0, "Invalid challenage");
        require(challenge.openAt < block.timestamp, "Challenage not opened");
        require(userinfo.isTakeReward == false, "Has take reward");
        userinfo.isTakeReward = true;


        uint256 winAmount;
        uint256 userWinAmount;
        if(challenge.winnerTarget == Target.LEFT) {
            userWinAmount = userinfo.amountsLeft;
            winAmount = challenge.leftTotalAmount;
            IERC1155(teamNft).safeTransferFrom(address(this), msg.sender, challenge.tokenIdLeft, userWinAmount, "");
        } else if (challenge.winnerTarget == Target.RIGHT){
            userWinAmount = userinfo.amountsRight;
            winAmount = challenge.rightTotalAmount;
            IERC1155(teamNft).safeTransferFrom(address(this), msg.sender, challenge.tokenIdRight, userWinAmount, "");
        } else {
            userWinAmount = userinfo.amountMiddleL + userinfo.amountMiddleR;
            winAmount = challenge.leftMiddleTotalAmount + challenge.rightMiddleTotalAmount;
            if(userinfo.amountMiddleL > 0) {
                IERC1155(teamNft).safeTransferFrom(address(this), msg.sender, challenge.tokenIdLeft, userinfo.amountMiddleL, "");
            }

            if(userinfo.amountMiddleR > 0) {
                IERC1155(teamNft).safeTransferFrom(address(this), msg.sender, challenge.tokenIdRight, userinfo.amountMiddleR, "");
            }
        }
        uint256 loseAmount = userinfo.amountsLeft + userinfo.amountsRight + userinfo.amountMiddleL + userinfo.amountMiddleR - winAmount;

        uint256 amount = (loseAmount * nftCost * rate / 100) / winAmount * userWinAmount;
        require(amount > 0, "Winner token amount is zero");

        IERC20(rewardToken).transfer(msg.sender, amount);

        userChallenges[msg.sender][_challengeId] = userinfo;
        emit WithdrawReward(msg.sender, challenge.id, amount);
    }

    function setTeamNft(address _nft) public onlyOwner {
        teamNft = _nft;
    }

    function setRate(uint256 _rate) public onlyOwner {
        rate = _rate;
    }

    function setRewardToken(address _token) public onlyOwner {
        rewardToken = _token;
    }

    function setNftCost(uint256 _amount) public onlyOwner{
        nftCost = _amount;
    }           

    function getUserRewards(address account, uint16 challengeId) public view returns(uint256){
        Challenge memory challenge = challenges[challengeId];
        if(challenge.id == 0 || challenge.openAt == 0) {
            return 0;
        }

        UserInfo memory userinfo = userChallenges[account][challengeId];

        if(userinfo.challengeId == 0 || userinfo.isTakeReward == true) {
            return 0;
        }
        uint256 winAmount;
        uint256 userWinAmount;
        if(challenge.winnerTarget == Target.LEFT) {
            userWinAmount = userinfo.amountsLeft;
            winAmount = challenge.leftTotalAmount;
        } else if (challenge.winnerTarget == Target.RIGHT){
            userWinAmount = userinfo.amountsRight;
            winAmount = challenge.rightTotalAmount;
        } else {
            userWinAmount = userinfo.amountMiddleL + userinfo.amountMiddleR;
            winAmount = challenge.leftMiddleTotalAmount + challenge.rightMiddleTotalAmount;
        }
        uint256 loseAmount = userinfo.amountsLeft + userinfo.amountsRight + userinfo.amountMiddleL + userinfo.amountMiddleR - winAmount;
        return (loseAmount * nftCost * rate / 100) / winAmount * userWinAmount;
    }

    function getUserChallenges(address account) public view returns(uint[] memory) {
        return userChallengeIds[account].values();
    }

    function getUserChallengeInfo(address account, uint16 challengeId) public view returns(UserInfo memory) {
        return userChallenges[account][challengeId];
    }

    function getChallengeInfo(uint16 challengeId) public view returns(Challenge memory) {
        return challenges[challengeId];
    }

    function withdraw(address nftContractAddress, uint256[] memory tokenids, uint256[] memory amounts) public onlyOwner {
        IERC1155(nftContractAddress).safeBatchTransferFrom( address(this), msg.sender, tokenids, amounts, "");
    }

    function emergencyWithdrawToken(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }
}