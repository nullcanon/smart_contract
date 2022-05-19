// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/ERC1155.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";


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

contract BeeItems is  ERC1155 , Ownable{

    uint256 public tokenSupply;


    constructor() ERC1155("https://game.example/api/item/{id}.json") {
    }

    function mintBatchWithNumber(uint256 idsNumber) public onlyOwner{
        uint256[] memory ids = new uint256[](idsNumber);
        uint256[] memory amounts = new uint256[](idsNumber);
        for (uint256 i = tokenSupply; i < (idsNumber + tokenSupply); i++) {
            ids[i - tokenSupply] = i;
            amounts[i - tokenSupply] = 1;
        }
        _mintBatch(msg.sender, ids, amounts, "");
        tokenSupply = tokenSupply + idsNumber;
    }

    function transferWithNumber(uint256 start, uint256 idsNumber, address to) public {
        uint256[] memory ids = new uint256[](idsNumber);
        uint256[] memory amounts = new uint256[](idsNumber);
        for (uint256 i = start; i < (idsNumber + start); i++) {
            ids[i - start] = i;
            amounts[i - start] = 1;
        }
        safeBatchTransferFrom(msg.sender, to, ids, amounts, "");
    }


    function setURI(string memory newuri) public onlyOwner{
        _setURI(newuri);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
        tokenSupply = tokenSupply + ids.length;
    }

    function getTokenSupply() public view returns (uint256) {
        return tokenSupply;
    }

    function brun(
        address account,
        uint256 id,
        uint256 value) public {

        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _burn(account, id, value);
        --tokenSupply;
    }
}

contract Synthesizer is ERC1155Holder, Ownable {
    address private luckybeeMintAddress;
    address private hashbeeMintAddress;
    address private knightbeeMintAddress;
    address private queenbeeMintAddress;
    address private bumbleBeeMintAddress;

    address private beeTokenMintAddress;

    address private feeAddress = 0x6aAC70bf621B374a09f6B1959629BE9116c17aB4;
    uint256 private feeAmount = 200 * 10 ** 18;

    uint256[] private nftIds;

    event BlendNft (
        address indexed user,
        uint256 indexed tokenid,
        address nftContract
     );

    function blendNft(
        uint256 luckybeeId,
        uint256 hashbeeId,
        uint256 knightbeeId,
        uint256 queenbeeId
    ) public {
        IERC1155(luckybeeMintAddress).safeTransferFrom( msg.sender, address(this), luckybeeId, 1 , "");
        BeeItems(luckybeeMintAddress).brun(address(this), luckybeeId, 1);

        IERC1155(hashbeeMintAddress).safeTransferFrom( msg.sender, address(this), hashbeeId, 1 , "");
        BeeItems(hashbeeMintAddress).brun(address(this), hashbeeId, 1);

        IERC1155(knightbeeMintAddress).safeTransferFrom( msg.sender, address(this), knightbeeId, 1 , "");
        BeeItems(knightbeeMintAddress).brun(address(this), knightbeeId, 1);

        IERC1155(queenbeeMintAddress).safeTransferFrom( msg.sender, address(this), queenbeeId, 1 , "");
        BeeItems(queenbeeMintAddress).brun(address(this), queenbeeId, 1);

        IERC20(beeTokenMintAddress).transferFrom(msg.sender, feeAddress, feeAmount);

        (uint256 minTokenId, uint256 index) = LibArrayForUint256Utils.min(nftIds);
        LibArrayForUint256Utils.removeByIndex(nftIds, index);
        IERC1155(bumbleBeeMintAddress).safeTransferFrom(address(this), msg.sender, minTokenId, 1 , "");

        emit BlendNft(msg.sender, minTokenId, bumbleBeeMintAddress);
    }

    function addNFTBatch(
        address nftContractAddress,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external  {
        LibArrayForUint256Utils.extend(nftIds ,ids);
        IERC1155(nftContractAddress).safeBatchTransferFrom(msg.sender, address(this), ids, amounts, "");
    }

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
        }

        LibArrayForUint256Utils.extend(nftIds ,ids);

        IERC1155(nftContractAddress).safeBatchTransferFrom(msg.sender, address(this), ids, amounts, "");
    }


    function withdraw(address nftContractAddress) public onlyOwner {
        uint256 length = nftIds.length;
        uint256[] memory amounts = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            amounts[i] = 1;
        }
        IERC1155(nftContractAddress).safeBatchTransferFrom( address(this), msg.sender, nftIds, amounts, "");
        delete nftIds;
        // emit withdrawNft(nftContractAddress);
    }

    function  setNftMintAddress(
        address _luckybeeMintAddress,
        address _hashbeeMintAddress,
        address _knightbeeMintAddress,
        address _queenbeeMintAddress,
        address _bumbleBeeMintAddress) public onlyOwner {
            luckybeeMintAddress = _luckybeeMintAddress;
            hashbeeMintAddress = _hashbeeMintAddress;
            knightbeeMintAddress = _knightbeeMintAddress;
            queenbeeMintAddress = _queenbeeMintAddress;
            bumbleBeeMintAddress = _bumbleBeeMintAddress;
    }

    function getLuckybeeMintAddress() public view returns (address) {
        return luckybeeMintAddress;
    }

    function getHashbeeAddress() public view returns (address) {
        return hashbeeMintAddress;
    }

    function getKnightbeeMintAddress() public view returns (address) {
        return knightbeeMintAddress;
    }

    function getQueenbeeMintAddress() public view returns (address) {
        return queenbeeMintAddress;
    }

    function getBumbleBeeMintAddress() public view returns (address) {
        return bumbleBeeMintAddress;
    }

    function setMoneyMintAddress(address mint) public onlyOwner {
        beeTokenMintAddress = mint;
    }

    function getMoneyMintAddress() public view returns (address)  {
        return beeTokenMintAddress;
    }

    function setFeeAddress(address feeTo) public onlyOwner {
        feeAddress = feeTo;
    }

    function getFeeTo() public view returns (address){
        return feeAddress;
    }

    function setFeeAmount(uint256 amount) public onlyOwner {
        feeAmount = amount;
    }

    function getFeeAmount() public view returns (uint256) {
        return feeAmount;
    }

    function getNftAmount() public view returns (uint256) {
        return nftIds.length;
    }

    function getNextNftTokenId() public view returns (uint256) {
        (uint256 minTokenId, uint256 index) = LibArrayForUint256Utils.min(nftIds);
        return minTokenId;
    }
}
