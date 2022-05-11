// contracts/Farming.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

import "../node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
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

contract Farming is Ownable ,ERC1155Holder{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    struct UserInfo {
        uint256 amount;           // current staked LP
        uint256 lastUpdateTime;   // unix timestamp for last details update (when pointsDebt calculated)
        uint256 pointsDebt;       // total points collected before latest deposit
    }
    
    struct NFTInfo {
        address contractAddress;
        uint256 id;             // NFT id
        uint256 remaining;      // NFTs remaining to farm
        uint256 price;          // points required to claim NFT
    }
    
    uint256 public emissionRate;       // points generated per LP token per second staked
    IERC20 public lpToken;             // token being staked
    
    NFTInfo[] public nfts;
    mapping(address => UserInfo) public users;

    event NFTAdded(address indexed contractAddress, uint256 id, uint256 total, uint256 price);
    event Staked(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 nftId, uint256 quantity);
    event Withdrawn(address indexed user, uint256 amount);
    
    constructor(uint256 _emissionRate, IERC20 _lpToken) public {
        emissionRate = _emissionRate;
        lpToken = _lpToken;
    }
    
    function addNFT(
        address contractAddress,    // Only ERC-1155 NFT Supported!
        uint256 id,
        uint256 total,              // amount of NFTs deposited to farm (need to approve before)
        uint256 price
    ) external onlyOwner {
        IERC1155(contractAddress).safeTransferFrom(
            msg.sender,
            address(this),
            id,
            total,
            ""
        );
        nfts.push(NFTInfo({
            contractAddress: contractAddress,
            id: id,
            remaining: total,
            price: price
        }));

        emit NFTAdded(contractAddress, id, total, price);
    }

    function addNFTBatch() external onlyOwner {

    }


    function stake(uint256 amount) external {
        lpToken.safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );
        
        UserInfo storage user = users[msg.sender];
        
        // already deposited before
        if(user.amount != 0) {
            user.pointsDebt = pointsBalance(msg.sender);
        }
        user.amount = user.amount.add(amount);
        user.lastUpdateTime = block.timestamp;

        emit Staked(msg.sender, amount);
    }
    
    // claim nft if points threshold reached
    function claim(uint256 nftId, uint256 quantity) public {
        NFTInfo storage nft = nfts[nftId];
        require(nft.remaining > 0, "All NFTs farmed");
        require(pointsBalance(msg.sender) >= nft.price.mul(quantity), "Insufficient Points");
        UserInfo storage user = users[msg.sender];
        
        // deduct points
        user.pointsDebt = pointsBalance(msg.sender).sub(nft.price.mul(quantity));
        user.lastUpdateTime = block.timestamp;
        
        // transfer nft
        IERC1155(nft.contractAddress).safeTransferFrom(
            address(this),
            msg.sender,
            nft.id,
            quantity,
            ""
        );
        
        nft.remaining = nft.remaining.sub(quantity);

        emit Claim(msg.sender, nftId, quantity);
    }
    
    function claimBatch(uint256[] calldata nftIds, uint256[] calldata quantity) external {
        require(nftIds.length == quantity.length, "Incorrect array length");
        for(uint64 i=0; i< nftIds.length; i++) {
            claim(nftIds[i], quantity[i]);
        }
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
        return blockTime.sub(user.lastUpdateTime).mul(emissionRate).mul(user.amount);
    }
    
    function nftCount() public view returns (uint256) {
        return nfts.length;
    }
    
    // Required function to allow receiving ERC-1155
    function onERC1155Received(
        address /*operator*/,
        address /*from*/,
        uint256 /*id*/,
        uint256 /*value*/,
        bytes calldata /*data*/
    )
        external
        pure
        returns(bytes4)
    {
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }
}