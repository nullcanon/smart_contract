// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
// import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/proxy/utils/Initializable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/access/OwnableUpgradeable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/utils/AddressUpgradeable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/token/ERC20/IERC20Upgradeable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/utils/math/SafeMathUpgradeable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/security/ReentrancyGuardUpgradeable.sol";


contract CoinBank is OwnableUpgradeable,ReentrancyGuardUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;


    bool private _paused;
    mapping(address => bool) public operators;

    struct inviteInfo {
        address addr;
        uint256 joinAt;
    }

    struct levelInfo {
        address addr;
        uint256 ratio;
    }
    struct withdrawLog {
        uint256 amount;
        uint256 logAt;
    }

    struct userInfo {
        uint256 joinAt;
        uint256 identity;//1 一级账户,2 二级账户 , 0 散户 
        uint256 oneRatio;
        uint256 twoRatio;
    }

    struct rewardInfo {
        uint256 rewardAmount; // 
        uint256 takedAmount; // 
    }

    mapping(address => address) public referrerOfUser; // user => referrer
    mapping(address => address[]) public usersOfReferrer; // referrer => user list
    mapping(address =>mapping(address => uint256)) private usersOfReferrerMap;// referrer -> user -> indexId
    mapping(address => inviteInfo[]) public userInfosOfReferrer; // referrer => user list

    IERC20Upgradeable public USDT; //
    address public receiveAddress;
    uint256 public fAmount ;


    mapping(address => userInfo) public userInfoMap; //
    mapping(address => rewardInfo) public rewardInfoMap; //
    mapping(address => withdrawLog[]) public withdrawLogs; //


    mapping(address => address[]) public levelTwoArr; // 
    mapping(address =>mapping(address => uint256)) private levelTwoIndexMap;// 

    address[] public levelOneArr; //
    mapping(address => uint256) private levelOneIndexMap;//

    uint256 public nums;

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }
    modifier onlyOperator() {
        require(operators[msg.sender], "Operator: caller is not the operator");
        _;
    }

    event RecordReferral(address indexed user, address indexed referrer);
    event TakeReward(address indexed user, uint256  amount);
    event Join(address indexed user);
    
    constructor(){}

    function initialize() initializer public {
        __Ownable_init();
        __ReentrancyGuard_init();

        _paused = false;
        operators[msg.sender] = true;

        fAmount = 200 ether;


    }

    function initDataForTest()public onlyOwner {
        fAmount = 2 ether;
    }
    
    function initData(address _receiveAddress,address _usdt)public onlyOwner {
        receiveAddress = _receiveAddress;
        USDT = IERC20Upgradeable(_usdt);
    }

    function setToken( address _receiveAddress) public onlyOwner {
        receiveAddress = _receiveAddress;
    }

    function setJoinAmount( uint256 fAmount_) public onlyOwner {
        fAmount = fAmount_;
    }

    function setOperator(address _operator, bool _enabled) public onlyOwner {
        operators[_operator] = _enabled;
    }

    function setPaused(bool paused_) public onlyOwner {
        _paused = paused_;
    }

    fallback() external payable {

    }
    receive() external payable {

  	}

    function rescuescoin(
        address _token,
        address payable _to,
        uint256 _amount
    ) public onlyOwner {
        if (_token == address(0)) {
            (bool success, ) = _to.call{ gas: 23000, value: _amount }("");
            require(success, "transferETH failed");
        } else {
            IERC20Upgradeable(_token).safeTransfer(_to, _amount);
        }
    }

    function setReferrerByAdmin(address user,address _referrer) public onlyOperator {
        _recordReferral(user, _referrer);
    }

    function _recordReferral(address _user, address _referrer) internal returns (bool) {
        if (_paused) {
            return false;
        }

        // record referral already
        if (referrerOfUser[_user] != address(0) || referrerOfUser[_referrer] == _user) {
            return false;
        }

        // invalid address
        if (
            _user == _referrer ||
            _user == address(0) ||
            _referrer == address(0) ||
            _user.isContract() ||
            _referrer.isContract()
        ) {
            return false;
        }
        
        _addUsersOfReferrer(_referrer,_user);
        emit RecordReferral(_user, _referrer);

        return true;
    }

    function addLevelOne(address _user,uint256 ratio) public onlyOperator {
        userInfo storage _userInfo = userInfoMap[_user];
        require(_userInfo.identity != 2, "is level two");
        require(ratio > 5 && ratio < 100 , "ratio too much"); //因为散户可以获得5%的返利

        userInfoMap[_user].identity = 1;
        userInfoMap[_user].oneRatio = ratio;

        _addLevelOne(_user);
    }

    function removeLevelOne(address _user) public onlyOperator {
        userInfo storage _userInfo = userInfoMap[_user];
        require(_userInfo.identity == 1, "is level two");

        userInfoMap[_user].identity = 0;
        userInfoMap[_user].oneRatio = 0;

        //下级的二级账户，都设置为散户
        address[] memory users_ = usersOfReferrer[_user];
        for (uint256 i = 0; i < users_.length; i++) {
            if (userInfoMap[users_[i]].identity == 2){
                userInfoMap[users_[i]].identity = 0;
            }
        }

        _removeLevelOne(_user);
    }

    function addLevelTwo(address _user,uint256 ratio) public {
        address me = msg.sender;
        require(userInfoMap[me].identity == 1, "myself must level one");
        require(ratio > 5 && userInfoMap[me].oneRatio >  ratio, "ratio too much"); // 因为二级账户返利应该比散户5%高吧
        require(getReferrer(_user) == me, "not my referrer");

        userInfo storage _userInfo = userInfoMap[_user];
        require(_userInfo.joinAt > 0, "user must joined");
        require(_userInfo.identity != 1, "is level one");

        _userInfo.identity = 2;
        _userInfo.twoRatio = ratio;

        _addLevelTwo(me,_user);
    }

    function removeLevelTwo(address _user) public {
        address me = msg.sender;
        require(userInfoMap[me].identity == 1, "myself must level one");
        require(getReferrer(_user) == me, "not my referrer");

        userInfo storage _userInfo = userInfoMap[_user];
        require(_userInfo.identity == 2, "is not level two");

        _userInfo.identity = 0;
        _userInfo.twoRatio = 0;

        _removeLevelTwo(me,_user);
    }

    function join(address referral) public nonReentrant {
        require(referrerOfUser[referral] != address(0) || userInfoMap[referral].identity == 1 , "referral must join or is level one");

        address user = msg.sender;
        userInfo storage _userInfo = userInfoMap[user];

        require(_userInfo.joinAt == 0, "had joined");

        bool b = _recordReferral(user,referral);
        require(b, "set referrer fail");

        _userInfo.joinAt = block.timestamp;
        USDT.safeTransferFrom(user, address(this) , fAmount);

        uint256 outAmount;
        address up1Addr = referral;
        userInfo memory up1UserInfo = userInfoMap[up1Addr];
        if (up1UserInfo.identity == 2){//上级是二级账户

            uint256 up1Amount = fAmount.mul(up1UserInfo.twoRatio).div(100);
            rewardInfoMap[up1Addr].rewardAmount += up1Amount;
            outAmount += up1Amount;

            //一级账户
            address levelOneAddr = getReferrer(up1Addr);
            if (levelOneAddr != address(0)){
                userInfo memory levelOneUserInfo = userInfoMap[levelOneAddr];
                uint256 levelOneAmount = fAmount.mul(levelOneUserInfo.oneRatio).div(100);
                if (levelOneAmount > up1Amount){ //正常情况，二级账户上级都是一级账户，这里都是大于的
                    levelOneAmount -= up1Amount;
                    rewardInfoMap[levelOneAddr].rewardAmount += levelOneAmount;
                    outAmount += levelOneAmount;
                }
            }

        }else if (up1UserInfo.identity == 1) {  // 上级就是一级团长身份
            uint256 levelOneAmount = fAmount.mul(up1UserInfo.oneRatio).div(100);

            rewardInfoMap[up1Addr].rewardAmount += levelOneAmount;
            outAmount += levelOneAmount;
            
        }else{//上级是散户
            uint256 up1Amount = fAmount.mul(5).div(100);
            rewardInfoMap[up1Addr].rewardAmount += up1Amount;
            outAmount += up1Amount;

            //一级账户
            address levelOneAddr = getUpLevelOne(up1Addr);
            if (levelOneAddr != address(0)){
                userInfo memory levelOneUserInfo = userInfoMap[levelOneAddr];
                uint256 levelOneAmount = fAmount.mul(levelOneUserInfo.oneRatio).div(100);
                if (levelOneAmount > up1Amount){ //正常情况，都是大于的
                    levelOneAmount -= up1Amount;
                    rewardInfoMap[levelOneAddr].rewardAmount += levelOneAmount;
                    outAmount += levelOneAmount;
                }
            }
        }


        USDT.safeTransfer(receiveAddress , fAmount.sub(outAmount,"sub fail"));

        nums += 1 ;
        emit Join(user);
    }

    function takeReward(uint256 _amount) public whenNotPaused {
        address _user = msg.sender;
        rewardInfo storage _rewardInfo = rewardInfoMap[_user];
        require((_rewardInfo.rewardAmount - _rewardInfo.takedAmount) >= _amount, "amount too much");

        _rewardInfo.takedAmount += _amount;
        USDT.safeTransfer(_user , _amount);

        withdrawLogs[_user].push(withdrawLog(_amount,block.timestamp));
        emit TakeReward(_user,_amount);
    }

    function takeRewardAll() public whenNotPaused {
        address _user = msg.sender;
        uint256 _amount = getCanTakeReward(_user);
        rewardInfo storage _rewardInfo = rewardInfoMap[_user];
        require((_rewardInfo.rewardAmount - _rewardInfo.takedAmount) >= _amount, "amount too much");

        _rewardInfo.takedAmount += _amount;
        USDT.safeTransfer(_user , _amount);

        withdrawLogs[_user].push(withdrawLog(_amount,block.timestamp));
        emit TakeReward(_user,_amount);
    }

    function getCanTakeReward(address _user) public view returns (uint256) {
        rewardInfo memory _rewardInfo = rewardInfoMap[_user];
        return _rewardInfo.rewardAmount - _rewardInfo.takedAmount;
    }
    function getCanTakeRewardx(address _user) public view returns (uint256) {
        rewardInfo memory _rewardInfo = rewardInfoMap[_user];
        return _rewardInfo.rewardAmount - _rewardInfo.takedAmount;
    }

    function checkbought(address _user) public view returns (bool){
        userInfo memory _userInfo = userInfoMap[_user];
        if (_userInfo.joinAt > 0 ){
            return true;
        }

        return false;
    }


    //寻找一级账户
    function getUpLevelOne(address _user) public view returns (address) {
        uint256 _level = 300;

        address _referrer = address(0);
        address[] memory _found = new address[](_level + 1);
        _found[0] = _user;

        for (uint256 _l = 1; _l <= _level; _l++) {
            _referrer = referrerOfUser[_user];
            if (_referrer == address(0) || _contains(_found, _referrer)) {
                return address(0);
            }

            if(userInfoMap[_referrer].identity == 1){
                return _referrer;
            }

            _user = _referrer;
            _found[_l] = _referrer;
        }

        return address(0);
    }

    //------------------------------------------------
    //-----------------referrer users ----------------
    //------------------------------------------------

    function _addUsersOfReferrer(address referrer,address _downuser) private {
        if (usersOfReferrerMap[referrer][_downuser] > 0){
            return;
        }

        usersOfReferrerMap[referrer][_downuser] = usersOfReferrer[referrer].length + 1;
        usersOfReferrer[referrer].push(_downuser);
        userInfosOfReferrer[referrer].push(inviteInfo(_downuser,block.timestamp));

        referrerOfUser[_downuser] = referrer;
    }

    function _removeUsersOfReferrer(address referrer,address _downuser) private {

        uint256 orderIndex = usersOfReferrerMap[referrer][_downuser];
        if (orderIndex == 0){
            return;
        }
        orderIndex -=1;
        uint256 lastOrderIndex = usersOfReferrer[referrer].length - 1;
    
        // When the token to delete is the last token, the swap operation is unnecessary.
        if (orderIndex != lastOrderIndex) {
            address last_downuser = usersOfReferrer[referrer][lastOrderIndex];
            inviteInfo memory last_downuserInfo = userInfosOfReferrer[referrer][lastOrderIndex];

            usersOfReferrer[referrer][orderIndex] = last_downuser; // Move the last token to the slot of the to-delete token
            userInfosOfReferrer[referrer][orderIndex] = last_downuserInfo;

            usersOfReferrerMap[referrer][last_downuser] = orderIndex + 1; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete usersOfReferrerMap[referrer][_downuser];
        usersOfReferrer[referrer].pop();
        userInfosOfReferrer[referrer].pop();

        referrerOfUser[_downuser] = address(0);
    }



    function _addLevelOne(address _user) private {
        if (levelOneIndexMap[_user] > 0){
            return;
        }

        levelOneIndexMap[_user] = levelOneArr.length + 1;
        levelOneArr.push(_user);
    }
    function _removeLevelOne(address _user) private {
        uint256 orderIndex = levelOneIndexMap[_user];
        if (orderIndex == 0){
            return;
        }

        orderIndex -=1;
        uint256 lastOrderIndex = levelOneArr.length - 1;

         if (orderIndex != lastOrderIndex) {
            address last_user = levelOneArr[lastOrderIndex];

            levelOneArr[orderIndex] = last_user; //
            levelOneIndexMap[last_user] = orderIndex+1; //
        }
        delete levelOneIndexMap[_user];
        levelOneArr.pop();
    }

    function countLevelOne() public view returns (uint256) {
        return levelOneArr.length;
    }

    function getLevelOneList(uint256 _startIndex,uint256 _endIndex) public view returns (levelInfo[] memory) {
        address[] memory users_ = levelOneArr;
        if (users_.length == 0) {
            return new levelInfo[](0);
        }

        if (_endIndex == 0) {
            _endIndex = users_.length - 1;
        }

        levelInfo[] memory _rets = new levelInfo[](_endIndex - _startIndex + 1);
        for (uint256 i = _startIndex; i <= _endIndex; i++) {
            _rets[i - _startIndex].addr = users_[i];
            _rets[i - _startIndex].ratio = userInfoMap[users_[i]].oneRatio;
        }

        return _rets;
    }


    function _addLevelTwo(address referrer,address _downuser) private {
        if (levelTwoIndexMap[referrer][_downuser] > 0){
            return;
        }

        levelTwoIndexMap[referrer][_downuser] = levelTwoArr[referrer].length + 1;
        levelTwoArr[referrer].push(_downuser);
    }

    function _removeLevelTwo(address referrer,address _downuser) private {

        uint256 orderIndex = levelTwoIndexMap[referrer][_downuser];
        if (orderIndex == 0){
            return;
        }
        orderIndex -=1;
        uint256 lastOrderIndex = levelTwoArr[referrer].length - 1;
    
        // When the token to delete is the last token, the swap operation is unnecessary.
        if (orderIndex != lastOrderIndex) {
            address last_downuser = levelTwoArr[referrer][lastOrderIndex];
            levelTwoArr[referrer][orderIndex] = last_downuser; //
            levelTwoIndexMap[referrer][last_downuser] = orderIndex + 1; // 
        }
        delete levelTwoIndexMap[referrer][_downuser];
        levelTwoArr[referrer].pop();
    }

    function countLevelTwo(address _user) public view returns (uint256) {
        return levelTwoArr[_user].length;
    }

    function getLevelTwoList(address _referrer,uint256 _startIndex,uint256 _endIndex) public view returns (levelInfo[] memory) {
        address[] memory users_ = levelTwoArr[_referrer];
        if (users_.length == 0) {
            return new levelInfo[](0);
        }

        if (_endIndex == 0) {
            _endIndex = users_.length - 1;
        }

        levelInfo[] memory _rets = new levelInfo[](_endIndex - _startIndex + 1);
        for (uint256 i = _startIndex; i <= _endIndex; i++) {
            _rets[i - _startIndex].addr = users_[i];
            _rets[i - _startIndex].ratio = userInfoMap[users_[i]].twoRatio;
        }

        return _rets;
    }


    //------------------------------------------------
    //-----------------referrerOfUser-----------------
    //------------------------------------------------
    function getReferrer(address _user) public view  returns (address) {
        return referrerOfUser[_user];
    }

    function getReferrerByLevel(address _user, uint256 _level) public view returns (address) {
        address _referrer = address(0);
        address[] memory _found = new address[](_level + 1);
        _found[0] = _user;

        for (uint256 _l = 1; _l <= _level; _l++) {
            _referrer = referrerOfUser[_user];
            if (_referrer == address(0) || _contains(_found, _referrer)) {
                return address(0);
            }

            _user = _referrer;
            _found[_l] = _referrer;
        }

        return _referrer;
    }

    function countUsersOfReferrer(address _referrer) public view returns (uint256) {
        return usersOfReferrer[_referrer].length;
    }

    function countUsersOfReferrerx(address _referrer) public view returns (uint256) {
        return usersOfReferrer[_referrer].length;
    }
    function getUsersOfReferrer(address _referrer) public view returns (address[] memory) {
        address[] memory users_ = usersOfReferrer[_referrer];
        return users_;
    }


    function getUserInfosOfReferrer(
        address _referrer,
        uint256 _startIndex,
        uint256 _endIndex
    ) public view returns (inviteInfo[] memory) {
        inviteInfo[] memory users_ = userInfosOfReferrer[_referrer];
        if (users_.length == 0) {
            return new inviteInfo[](0);
        }

        if (_endIndex == 0) {
            _endIndex = users_.length - 1;
        }

        inviteInfo[] memory _rets = new inviteInfo[](_endIndex - _startIndex + 1);
        for (uint256 i = _startIndex; i <= _endIndex; i++) {
            _rets[i - _startIndex] = users_[i];
        }

        return _rets;
    }

    function countWithdrawLogs(address _user) public view returns (uint256) {
        return withdrawLogs[_user].length;
    }

    function getWithdrawLogs(
        address _user,
        uint256 _startIndex,
        uint256 _endIndex
    ) public view returns (withdrawLog[] memory) {
        withdrawLog[] memory users_ = withdrawLogs[_user];
        if (users_.length == 0) {
            return new withdrawLog[](0);
        }

        if (_endIndex == 0) {
            _endIndex = users_.length - 1;
        }

        withdrawLog[] memory _rets = new withdrawLog[](_endIndex - _startIndex + 1);
        for (uint256 i = _startIndex; i <= _endIndex; i++) {
            _rets[i - _startIndex] = users_[i];
        }

        return _rets;
    }

    //------------------------------------------------
    //-----------------lib----------------------------
    //------------------------------------------------

    function _contains(address[] memory _list, address _a) internal pure returns (bool) {
        for (uint256 i = 0; i < _list.length; i++) {
            if (_list[i] == _a) {
                return true;
            }
        }
        return false;
    }

    function emergencyWithdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function emergencyWithdrawToken(address token, uint256 amount) external onlyOwner {
        IERC20Upgradeable(token).transfer(msg.sender, amount);
    }

}

