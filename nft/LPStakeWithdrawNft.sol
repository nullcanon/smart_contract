// contracts/Farming.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";


library LibSafeMathForUint256Utils {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMathForUint256: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMathForUint256: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMathForUint256: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMathForUint256: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMathForUint256: modulo by zero");
        return a % b;
    }

    function power(uint256 a, uint256 b) internal pure returns (uint256){

        if(a == 0) return 0;
        if(b == 0) return 1;

        uint256 c = 1;
        for(uint256 i = 0; i < b; i++){
            c = mul(c, a);
        }
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

library LibArrayForUint256Utils {

	/**
	 * @dev Searches a sortd uint256 array and returns the first element index that 
	 * match the key value, Time complexity O(log n)
	 *
	 * @param array is expected to be sorted in ascending order
	 * @param key is element 
	 *
	 * @return if matches key in the array return true,else return false 
	 * @return the first element index that match the key value,if not exist,return 0
	 */
	function binarySearch(uint256[] storage array, uint256 key) internal view returns (bool, uint) {
        if(array.length == 0){
        	return (false, 0);
        }

        uint256 low = 0;
        uint256 high = array.length-1;

        while(low <= high){
        	uint256 mid = LibSafeMathForUint256Utils.average(low, high);
        	if(array[mid] == key){
        		return (true, mid);
        	}else if (array[mid] > key) {
                high = mid - 1;
            } else {
                low = mid + 1;
            }
        }

        return (false, 0);
    }

    function firstIndexOf(uint256[] storage array, uint256 key) internal view returns (bool, uint256) {

    	if(array.length == 0){
    		return (false, 0);
    	}

    	for(uint256 i = 0; i < array.length; i++){
    		if(array[i] == key){
    			return (true, i);
    		}
    	}
    	return (false, 0);
    }

    function reverse(uint256[] storage array) internal {
        uint256 temp;
        for (uint i = 0; i < array.length / 2; i++) {
            temp = array[i];
            array[i] = array[array.length - 1 - i];
            array[array.length - 1 - i] = temp;
        }
    }

    function equals(uint256[] storage a, uint256[] storage b) internal view returns (bool){
    	if(a.length != b.length){
    		return false;
    	}
    	for(uint256 i = 0; i < a.length; i++){
    		if(a[i] != b[i]){
    			return false;
    		}
    	}
    	return true;
    }

    function removeByIndex(uint256[] storage array, uint index) internal{
    	require(index < array.length, "ArrayForUint256: index out of bounds");

        while (index < array.length - 1) {
            array[index] = array[index + 1];
            index++;
        }
        array.pop();
    }
    
    function removeByValue(uint256[] storage array, uint256 value) internal{
        uint index;
        bool isIn;
        (isIn, index) = firstIndexOf(array, value);
        if(isIn){
          removeByIndex(array, index);
        }
    }

    function addValue(uint256[] storage array, uint256 value) internal{
    	uint index;
        bool isIn;
        (isIn, index) = firstIndexOf(array, value);
        if(!isIn){
        	array.push(value);
        }
    }

    function extend(uint256[] storage a, uint256[] memory b) internal {
    	if(b.length != 0){
    		for(uint i = 0; i < b.length; i++){
    			a.push(b[i]);
    		}
    	}
    }

    function distinct(uint256[] storage array) internal returns (uint256 length) {
        bool contains;
        uint index;
        for (uint i = 0; i < array.length; i++) {
            contains = false;
            index = 0;
            uint j = i+1;
            for(;j < array.length; j++){
                if(array[j] == array[i]){
                    contains =true;
                    index = i;
                    break;
                }
            }
            if (contains) {
                for (j = index; j < array.length - 1; j++){
                    array[j] = array[j + 1];
                }
                array.pop();
                i--;
            }
        }
        length = array.length;
    }

    function max(uint256[] storage array) internal view returns (uint256 maxValue, uint256 maxIndex) {
        maxValue = array[0];
        maxIndex = 0;
        for(uint256 i = 0;i < array.length;i++){
            if(array[i] > maxValue){
                maxValue = array[i];
                maxIndex = i;
            }
        }
    }

    function min(uint256[] storage array) internal view returns (uint256 minValue, uint256 minIndex) {
        minValue = array[0];
        minIndex = 0;
        for(uint256 i = 0;i < array.length;i++){
            if(array[i] < minValue){
                minValue = array[i];
                minIndex = i;
            }
        }
    }

}

contract Farming is Ownable , ERC1155Holder{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    struct UserInfo {
        uint256 amount;           // current staked LP
        uint256 lastUpdateTime;   // unix timestamp for last details update (when pointsDebt calculated)
        uint256 pointsDebt;       // total points collected before latest deposit 结算数量
    }
    
    struct NFTInfo {
        address contractAddress;
        uint256 id;             // NFT id
        uint256 remaining;      // NFTs remaining to farm
        uint256 price;          // points required to claim NFT
    }
    
    IERC20 public lpToken;             // token being staked
    
    uint256[] public nftIds;
    mapping(address => UserInfo) public users;
    address[] private userlist;

    uint256 private withdrawAmount = 0;
    uint256 private lpUnitValue = 1065;
    uint256 private timeUnitValue = 864000;
    uint256 private threshold = lpUnitValue * timeUnitValue * 10 ** 18;

    event NFTAdded(address indexed contractAddress, uint256 id, uint256 total, uint256 price);
    event Staked(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 nftId, uint256 quantity);
    event Withdrawn(address indexed user, uint256 amount);
    
    constructor() {
    }

    function addNFTBatch(
        address nftContractAddress,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external  onlyOwner{
        LibArrayForUint256Utils.extend(nftIds ,ids);
        IERC1155(nftContractAddress).safeBatchTransferFrom(msg.sender, address(this), ids, amounts, "");
    }

    function addNftBatchWithNumber(
        address nftContractAddress,
        uint256 start,
        uint256 idsNumber
    ) public onlyOwner {
        uint256[] memory ids = new uint256[](idsNumber);
        uint256[] memory amounts = new uint256[](idsNumber);
        for (uint256 i = start; i < (idsNumber + start); i++) {
            ids[i-start] = i;
            amounts[i-start] = 1;
        }

        LibArrayForUint256Utils.extend(nftIds ,ids);

        IERC1155(nftContractAddress).safeBatchTransferFrom(msg.sender, address(this), ids, amounts, "");
    }

    function stake(uint256 amount) external {
        lpToken.safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );
        
        UserInfo storage user = users[msg.sender];
        userlist.push(msg.sender);
        
        // already deposited before
        if(user.amount != 0) {
            user.pointsDebt = pointsBalance(msg.sender);
        }
        user.amount = user.amount.add(amount);
        user.lastUpdateTime = block.timestamp;

        emit Staked(msg.sender, amount);
    }
    
    // claim nft if points threshold reached
    function claim(address nftContractAddress) public {
        require(nftIds.length > 0, "All NFTs farmed");
        require(pointsBalance(msg.sender) >= threshold, "Insufficient Points");
        UserInfo storage user = users[msg.sender];
        
        // deduct points
        user.pointsDebt = pointsBalance(msg.sender).sub(threshold);
        user.lastUpdateTime = block.timestamp;
        
        (uint256 minTokenId, uint256 index) = LibArrayForUint256Utils.min(nftIds);
        LibArrayForUint256Utils.removeByIndex(nftIds, index);

        // transfer nft
        IERC1155(nftContractAddress).safeTransferFrom(
            address(this),
            msg.sender,
            minTokenId,
            1,
            ""
        );
        ++withdrawAmount;

        emit Claim(msg.sender, minTokenId, 1);
    }
    
    
    function withdraw(uint256 amount) public {
        UserInfo storage user = users[msg.sender];
        require(user.amount >= amount, "Insufficient staked");
        
        // update users
        user.pointsDebt = pointsBalance(msg.sender);
        user.amount = user.amount.sub(amount);
        user.lastUpdateTime = block.timestamp;
        
        lpToken.safeTransfer(
            msg.sender,
            amount
        );
        emit Withdrawn(msg.sender, amount);
    }
    
    function exit() external {
        withdraw(users[msg.sender].amount);
    }
    
    function pointsBalance(address account) public view returns (uint256) {
        UserInfo memory user = users[account];
        return user.pointsDebt.add(_unDebitedPoints(user));
    }
    
    function _unDebitedPoints(UserInfo memory user) internal view returns (uint256) {
        uint256 blockTime = block.timestamp;
        return blockTime.sub(user.lastUpdateTime).mul(user.amount);
    }
    
    function nftCount() public view returns (uint256) {
        return nftIds.length;
    }

    function getNextNftTokenId() public view returns (uint256) {
        (uint256 minTokenId, uint256 index) = LibArrayForUint256Utils.min(nftIds);
        return minTokenId;
    }

    function getThreshold() public view returns (uint256) {
        return threshold;
    }

    function urgentWithdraw(address nftContractAddress) public onlyOwner{
        uint256 length = nftIds.length;
        uint256[] memory amounts = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            amounts[i] = 1;
        }
        IERC1155(nftContractAddress).safeBatchTransferFrom( address(this), msg.sender, nftIds, amounts, "");
        delete nftIds;
    }

    function setLpMintAddress(address mint) public onlyOwner {
        lpToken = IERC20(mint);
    }

    function setLpUnitValue(uint256 value) public onlyOwner {
        lpUnitValue = value;
        threshold = lpUnitValue * timeUnitValue * 10 ** 18;
    }

    function setTimeUnitValue(uint256 value) public onlyOwner {
        timeUnitValue = value;
        threshold = lpUnitValue * timeUnitValue * 10 ** 18;
    }
    
    function getLpMintAddress() public view returns (address) {
        return address(lpToken) ;
    }

    function getLpUnitValue() public view returns (uint256) {
        return lpUnitValue;
    }

    function getTimeUnitValue() public view returns (uint256) {
        return timeUnitValue;
    }

    function getUserStakeAmount(address user) public view returns (uint256) {
        return users[user].amount;
    }

    function getUserNextNftTime(address user) public view returns (uint256){
        // （阈值 - 当前产出）/当前质押数量 = 时间 
        uint256 v = pointsBalance(user);
        while(v > threshold) {
            v = v.sub(threshold);
        }
        uint256 userStakedAmount = getUserStakeAmount(user);
        if(userStakedAmount == 0) {
            return 0;
        }
        return threshold.sub(v).div(userStakedAmount);
    }

    function getWithdrawAmount() public view returns (uint256){
        return withdrawAmount;
    }

}