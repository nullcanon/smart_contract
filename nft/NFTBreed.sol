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

contract Breed is Ownable , ERC1155Holder{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct NftInfo {
        address contractAddress;
        uint256 tokenId;
    }
    
    struct UserInfo {
        NftInfo nftA;
        NftInfo nftB;
        uint256 startTimestamp;
    }

    uint256 private breedTime = 2 hours
    IERC20 public feeToken;
    uint256 private feeAddress;
    uint256 private feeAmount;
    
    mapping(address => UserInfo) public users;
    mapping(address => (mapping(address => uint256))) public nftHasBreedTokenId;

    event Mating(address indexed user, address indexed nftContractA, address indexed nftContractB, uint256 tokenIdA, uint256 tokenIdB);
    event Cancel(address indexed user, address indexed nftContractA, address indexed nftContractB, uint256 tokenIdA, uint256 tokenIdB);
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

    function mating( address nftContractA, uint256 tokenIdA, address nftContractB, uint256 tokenIdB) external {
        UserInfo storage user = users[msg.sender];
        require(user.startTimestamp == 0, "Only breed once at a time");

        feeToken.safeTransferFrom(
            msg.sender,
            address(this),
            feeAddress
        );
        IERC1155(nftContractA).safeTransferFrom(msg.sender, address(this), tokenIdA, 1, "");
        IERC1155(nftContractB).safeTransferFrom(msg.sender, address(this), tokenIdB, 1, "");
        
        user.startTimestamp = block.timestamp;
        user.nftA.contractAddress = nftContractA;
        user.nftA.tokenId = tokenIdA;
        user.nftB.contractAddress = nftContractB;
        user.nftB.tokenId = tokenIdB;
        emit Mating(msg.sender, user.nftA.contractAddress, user.nftB.contractAddress, user.nftA.tokenId, user.nftB.tokenId);
    }

    function cancel() public {
        UserInfo storage user = users[msg.sender];
        require(user.startTimestamp != 0, "not start mating");

        IERC1155(user.nftContractA).safeTransferFrom(address(this), msg.sender, user.tokenIdA, 1, "");
        IERC1155(user.nftContractB).safeTransferFrom(address(this), msg.sender, user.tokenIdB, 1, "");
        user.startTimestamp = 0;
        emit Cancel(msg.sender, user.nftA.contractAddress, user.nftB.contractAddress, user.nftA.tokenId, user.nftB.tokenId);
    }

    
    function claim(address nftContractAddress) public {
        uint256 nowTimestamp = block.timestamp;
        UserInfo storage user = users[msg.sender];
        require(user.startTimestamp != 0, "not start mating");
        require(user.startTimestamp + breedTime >= nowTimestamp, "not finish mating");

        // nft type
        


        emit Claim(msg.sender, user.nftA.contractAddress, user.nftB.contractAddress, user.nftA.tokenId, user.nftB.tokenId);
    }
    

    function nftCount() public view returns (uint256) {
        return nftIds.length;
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

    function setFeeMintAddress(address mint) public onlyOwner {
        feeToken = IERC20(mint);
    }

    function getFeeMintAddress() public view returns (address) {
        return address(feeToken) ;
    }

    function getWithdrawAmount() public view returns (uint256){
        return withdrawAmount;
    }

}