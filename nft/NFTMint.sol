// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "../node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
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

contract MintNft is ERC1155Holder, Ownable {

    address private feeTokenMintAddress = 0xB0bc99bdb71a4320a9aD357f68EBfBe6fFeBFc8A;

    address private feeReceiveAddress = 0xd3c0b6Aa1538d639912789be705F18b5Fd89fcE6;

    mapping(address => uint256) private feeAmount;

    mapping(address => uint256[]) private mintTokenId;

    event mint(address indexed nftContractAddress, address indexed user);
    event addNft(address indexed nftContractAddress, uint256 idsNumber);
    event withdrawNft(address indexed nftContractAddress);

    mapping(address => bool) private whiteList;

    function changeWhiteList(address user,  bool opt) external onlyOwner {
        whiteList[user] = opt;
    }

    function changeWhiteListBatch(address[] memory userlist, bool opt) external onlyOwner {
        for (uint256 i = 0; i < userlist.length; i++) {
            whiteList[userlist[i]] = opt;
        }
    }

    function inWhiteList(address user) public view returns (bool) {
        return whiteList[user];
    }

    function mintNft(
        address nftContractAddress
    ) public {
        // check nftContractAddress
        require(inWhiteList(msg.sender), "Not white list user");

        require(IERC20(feeTokenMintAddress).allowance(msg.sender, address(this)) >= feeAmount[nftContractAddress], "Token allowance too low");
        IERC20(feeTokenMintAddress).transferFrom(msg.sender, feeReceiveAddress, feeAmount[nftContractAddress]);


        (uint256 minTokenId, uint256 index) = LibArrayForUint256Utils.min(mintTokenId[nftContractAddress]);
        LibArrayForUint256Utils.removeByIndex(mintTokenId[nftContractAddress], index);

        IERC1155(nftContractAddress).safeTransferFrom( address(this) , msg.sender, minTokenId , 1 , "");

        emit mint(nftContractAddress, msg.sender);
    }

    //Continuously add NFT in batches
    function addNftBatchWithNumber(
        address nftContractAddress,
        uint256 start,
        uint256 idsNumber
    ) public {
        uint256[] memory ids = new uint256[](idsNumber);
        uint256[] memory amounts = new uint256[](idsNumber);
        for (uint256 i = start; i < (idsNumber + start); i++) {
            ids[i-start] = i;
            amounts[i-start] = 1;
            mintTokenId[nftContractAddress].push(i);
        }
        IERC1155(nftContractAddress).safeBatchTransferFrom(msg.sender, address(this), ids, amounts, "");
        emit addNft(nftContractAddress, idsNumber);
    }

    function addNftBatch(
        address nftContractAddress,
        uint256[] memory ids,
        uint256[] memory amounts
    ) public {
        LibArrayForUint256Utils.extend(mintTokenId[nftContractAddress] ,ids);
        IERC1155(nftContractAddress).safeBatchTransferFrom(msg.sender, address(this), ids, amounts, "");
        emit addNft(nftContractAddress, ids.length);
    }

    function withdraw(address nftContractAddress) public onlyOwner {
        uint256 length = mintTokenId[nftContractAddress].length;
        uint256[] memory amounts = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            amounts[i] = 1;
        }
        IERC1155(nftContractAddress).safeBatchTransferFrom( address(this), msg.sender, mintTokenId[nftContractAddress], amounts, "");
        delete mintTokenId[nftContractAddress];
        emit withdrawNft(nftContractAddress);
    }

    function setFeeTokenMintAddress(address tokenAddress) public onlyOwner {
        feeTokenMintAddress = tokenAddress;
    }

    function setReceiveAddress(address tokenAddress) public onlyOwner {
        feeReceiveAddress = tokenAddress;
    }

    function setFeeAmount(address nftContractAddress, uint256 amount) public onlyOwner {
        feeAmount[nftContractAddress] = amount;
    }

    function getFeeAmount(address nftContractAddress) public view returns (uint256) {
        return feeAmount[nftContractAddress];
    }

    function getFeeMintAddress() public view returns (address) {
        return feeTokenMintAddress;
    }

    function getFeeReceiveAddress() public view returns (address) {
        return feeReceiveAddress;
    }

    function holdNumber(address nftContractAddress) public view returns (uint256) {
        return mintTokenId[nftContractAddress].length;
    }
}