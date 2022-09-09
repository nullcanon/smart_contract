pragma solidity ^0.8.0;

import "./NFTERC1155Mint.sol";
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

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract NFTMint is  Ownable, ERC1155Holder{


    address public feeTo;
    address public feeToken;
    uint256 public feeAmount;
    mapping(address => uint256) public mintCount;

    mapping(address => mapping(address => uint)) public whiteList;

    mapping(address => bool) public openWhileList;

    mapping(address => uint256[]) private mintTokenId;

    function opWhiteList(address nftContractAddress, bool op) public onlyOwner {
        openWhileList[nftContractAddress] = op;
    }

    function addWhiteList(address nftContractAddress, address user,  uint quota) public onlyOwner {
        whiteList[nftContractAddress][user] += quota;
    }

    function addWhiteListBatch(address nftContractAddress, address[] memory userlist, uint quota) external onlyOwner {
        for (uint256 i = 0; i < userlist.length; i++) {
            addWhiteList(nftContractAddress, userlist[i], quota);
        }
    }

    function subWhiteList(address nftContractAddress, address user,  uint quota) public onlyOwner {
        if(whiteList[nftContractAddress][user] >= quota){
            whiteList[nftContractAddress][user] -= quota;
        } else {
            whiteList[nftContractAddress][user] = 0;
        }
    }

    function subWhiteListBatch(address nftContractAddress, address[] memory userlist, uint quota) external onlyOwner {
        for (uint256 i = 0; i < userlist.length; i++) {
            subWhiteList(nftContractAddress, userlist[i], quota);
        }
    }

    function inWhiteList(address nftContractAddress, address user) public view returns (bool) {
        return whiteList[nftContractAddress][user] > 0;
    }

    function mintQuota(address nftContractAddress, address user) public view returns (uint) {
        return whiteList[nftContractAddress][user];
    }


    function mintNft(address nftContract, bool isMbee) public {
        if(!openWhileList[nftContract]) {
            require(inWhiteList(nftContract, msg.sender), "Not white list user");
            whiteList[nftContract][msg.sender] -= 1;
        } 

        IERC20(feeToken).transferFrom(msg.sender, feeTo, feeAmount);
        uint256 tokenid;
        if(isMbee) {
            (uint256 minTokenId, uint256 index) = LibArrayForUint256Utils.min(mintTokenId[nftContract]);
            tokenid = minTokenId;
            LibArrayForUint256Utils.removeByIndex(mintTokenId[nftContract], index);
            IERC1155(nftContract).safeTransferFrom( address(this) , msg.sender, minTokenId , 1 , "");
        } else {
            tokenid = NFTItems(nftContract).mintWithWiteList(msg.sender);
        }
        mintCount[nftContract] += 1;
        emit MintNft(msg.sender, nftContract, tokenid);
    }


    //Continuously add NFT in batches
    function addNftBatchWithNumber(
        address nftContractAddress,
        uint256 start,
        uint256 idsNumber
    ) public {
        uint256[] memory ids = new uint256[](idsNumber);
        uint256[] memory amounts = new uint256[](idsNumber);
        require(start > 0, "start must more than zero");
        for (uint256 i = (idsNumber + start - 1); i >= start; i--) {
            ids[i-start] = i;
            amounts[i-start] = 1;
            mintTokenId[nftContractAddress].push(i);
        }
        IERC1155(nftContractAddress).safeBatchTransferFrom(msg.sender, address(this), ids, amounts, "");
    }

    function withdraw(address nftContractAddress) public onlyOwner {
        uint256 length = mintTokenId[nftContractAddress].length;
        uint256[] memory amounts = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            amounts[i] = 1;
        }
        IERC1155(nftContractAddress).safeBatchTransferFrom( address(this), msg.sender, mintTokenId[nftContractAddress], amounts, "");
        delete mintTokenId[nftContractAddress];
    }

    function setFeeToken(address mint) public onlyOwner {
        feeToken = mint;
    }

    function setFeeAmount(uint256 amount) public onlyOwner {
        feeAmount = amount;
    }

    function setFeeTo(address to) public onlyOwner {
        feeTo = to;
    }

    function getMintCount(address nft) view public returns (uint256) {
        return mintCount[nft];
    }

    event MintNft(address indexed user, address indexed nft, uint256 tokenid);
}