// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/ERC1155.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
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

// nft market 
// support : erc1155
// support : use token buy

contract marketPlace is ReentrancyGuard , ERC1155Holder, Ownable{
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    address private feeAddress = 0xd3c0b6Aa1538d639912789be705F18b5Fd89fcE6;
    uint private feeNumerator = 300;
    uint private feeDenominator = 10000;
    
    enum Status{ DEAL, ORDER, CANCLE }

     constructor() {
     }
     
     struct MarketItem {
        uint itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        address moneyMintAddress;
        uint256 price;
        Status sold;
     }
     
     mapping(uint256 => MarketItem) private idToMarketItem;
     uint256[] private orderMarketItemIds;
     
     event MarketItemCreated (
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        address moneyMintAddress,
        uint256 price,
        Status sold
     );

    event MarketItemCancel (
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address moneyMintAddress,
        uint256 price,
        Status sold
     );
     
     event MarketItemSold (
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        address moneyMintAddress,
        uint256 price,
        Status sold
    );
     
    
    
    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
        ) public payable nonReentrant {
            require(price > 0, "Price must be greater than 0");
            
            _itemIds.increment();
            uint256 itemId = _itemIds.current();
  
            idToMarketItem[itemId] =  MarketItem(
                itemId,
                nftContract,
                tokenId,
                payable(msg.sender),
                payable(address(0)),
                address(0),
                price,
                Status.ORDER
            );
            orderMarketItemIds.push(itemId);
            
            IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
                
            emit MarketItemCreated(
                itemId,
                nftContract,
                tokenId,
                msg.sender,
                address(0),
                address(0),
                price,
                Status.ORDER
            );
        }

      function createMarketItemErc1155(
        address nftContract,
        address moneyMintAddress,
        uint256 tokenId,
        uint256 price
        ) public nonReentrant {
            require(price > 0, "Price must be greater than 0");
            
            _itemIds.increment();
            uint256 itemId = _itemIds.current();
  
            idToMarketItem[itemId] =  MarketItem(
                itemId,
                nftContract,
                tokenId,
                payable(msg.sender),
                payable(address(0)),
                moneyMintAddress,
                price,
                Status.ORDER
            );
            orderMarketItemIds.push(itemId);
            
            IERC1155(nftContract).safeTransferFrom( msg.sender, address(this), tokenId, 1 , "");
                
            emit MarketItemCreated(
                itemId,
                nftContract,
                tokenId,
                msg.sender,
                address(0),
                moneyMintAddress,
                price,
                Status.ORDER
            );
        }
    
    function cancelMarketItemErc1155(uint256 itemId) public nonReentrant {
        Status sold = idToMarketItem[itemId].sold;
        require(sold == Status.ORDER, "This Sale has alredy finnished");
        require(msg.sender == idToMarketItem[itemId].seller, "Do not have permission");
        address nftContract = idToMarketItem[itemId].nftContract;
        uint256 tokenId = idToMarketItem[itemId].tokenId;
        IERC1155(nftContract).safeTransferFrom(address(this), msg.sender, tokenId, 1 , "");
        idToMarketItem[itemId].sold = Status.CANCLE;
        idToMarketItem[itemId].owner = payable(msg.sender);
        LibArrayForUint256Utils.removeByValue(orderMarketItemIds, itemId);

        emit MarketItemCancel(
            itemId,
            nftContract,
            tokenId,
            address(this),
            idToMarketItem[itemId].moneyMintAddress,
            idToMarketItem[itemId].price,
            Status.CANCLE
        );
    }
    
    function createMarketSale(
        address nftContract,
        uint256 itemId
        ) public payable nonReentrant {
            uint256 price = idToMarketItem[itemId].price;
            uint256 tokenId = idToMarketItem[itemId].tokenId;
            Status sold = idToMarketItem[itemId].sold;
            require(msg.value == price, "Please submit the asking price in order to complete the purchase");
            require(sold == Status.ORDER, "This Sale has alredy finnished");
            emit MarketItemSold(
                itemId,
                nftContract,
                tokenId,
                idToMarketItem[itemId].seller,
                msg.sender,
                idToMarketItem[itemId].moneyMintAddress,
                price,
                Status.DEAL
            );

            idToMarketItem[itemId].seller.transfer(msg.value);
            IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
            idToMarketItem[itemId].owner = payable(msg.sender);
            _itemsSold.increment();
            idToMarketItem[itemId].sold = Status.DEAL;
            LibArrayForUint256Utils.removeByValue(orderMarketItemIds, itemId);
    }

    function createMarketSaleWithToken(
        address nftContract,
        address moneyMintAddress,
        uint256 itemId,
        uint256 price
        ) public nonReentrant {
            uint priceMarket = idToMarketItem[itemId].price;
            uint tokenId = idToMarketItem[itemId].tokenId;
            Status sold = idToMarketItem[itemId].sold;
            require(priceMarket == price, "Please submit the asking price in order to complete the purchase");
            require(sold == Status.ORDER, "This Sale has alredy finnished");
            emit MarketItemSold(
                itemId,
                nftContract,
                tokenId,
                idToMarketItem[itemId].seller,
                msg.sender,
                idToMarketItem[itemId].moneyMintAddress,
                price,
                Status.DEAL
            );

            require(IERC20(moneyMintAddress).allowance(msg.sender, address(this)) >= price, "Token allowance too low");
            uint256 fee = price.mul(feeNumerator).div(feeDenominator);
            bool sent = IERC20(moneyMintAddress).transferFrom(msg.sender, feeAddress, fee);
            require(sent, "Token fee transfer failed");

            sent = IERC20(moneyMintAddress).transferFrom(msg.sender, idToMarketItem[itemId].seller, price.sub(fee));
            require(sent, "Token seller transfer failed");

            IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
            idToMarketItem[itemId].owner = payable(msg.sender);
            _itemsSold.increment();
            idToMarketItem[itemId].sold = Status.DEAL;
            LibArrayForUint256Utils.removeByValue(orderMarketItemIds, itemId);
    }

    function createMarketSaleWithTokenErc1155(
        address nftContract,
        address tokenMintAddress,
        uint256 itemId,
        uint256 price
        ) public nonReentrant {
            uint priceMarket = idToMarketItem[itemId].price;
            uint tokenId = idToMarketItem[itemId].tokenId;
            Status sold = idToMarketItem[itemId].sold;
            require(priceMarket == price, "Please submit the asking price in order to complete the purchase");
            require(sold == Status.ORDER, "This Sale has alredy finnished");
            emit MarketItemSold(
                itemId,
                nftContract,
                tokenId,
                idToMarketItem[itemId].seller,
                msg.sender,
                idToMarketItem[itemId].moneyMintAddress,
                price,
                Status.DEAL
            );

            require(IERC20(tokenMintAddress).allowance(msg.sender, address(this)) >= price, "Token allowance too low");

            uint256 fee = price.mul(feeNumerator).div(feeDenominator);
            bool sent = IERC20(tokenMintAddress).transferFrom(msg.sender, feeAddress, fee);
            require(sent, "Token fee transfer failed");

            sent = IERC20(tokenMintAddress).transferFrom(msg.sender, idToMarketItem[itemId].seller, price.sub(fee));
            require(sent, "Token seller transfer failed");

            IERC1155(nftContract).safeTransferFrom(address(this), msg.sender, tokenId, 1 , "");
            idToMarketItem[itemId].owner = payable(msg.sender);
            _itemsSold.increment();
            idToMarketItem[itemId].sold = Status.DEAL;
            LibArrayForUint256Utils.removeByValue(orderMarketItemIds, itemId);
    }
        
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint itemCount = _itemIds.current();
        uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].owner == address(0)) {
                uint currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function fetchMarketItemsWithUser(address user) public view returns (MarketItem[] memory) {
        uint itemCount = _itemIds.current();
        uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].owner == address(0) && idToMarketItem[i + 1].seller == user) {
                uint currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function getItemsStatus(uint256 item) public view returns (Status) {
        return idToMarketItem[item].sold;
    }

    function fetchMarketItemsLimit(uint start, uint offset) public view returns (MarketItem[] memory) {
        require(start <= offset, "start must less than offset");
        require(start + offset < orderMarketItemIds.length, "start over length");
        MarketItem[] memory items = new MarketItem[](offset);
        for (uint i = start; i < offset; i++) {
            uint256 itemId = orderMarketItemIds[start];
            MarketItem storage currentItem = idToMarketItem[itemId];
            items[itemId] = currentItem;
        }

        return items;
    }
    
    function setFeeAddress(address _feeAddress) public onlyOwner {
        feeAddress = _feeAddress;
    }

    function setFeeNumerator(uint _feeNumerator) public onlyOwner {
        feeNumerator = _feeNumerator;
    }
    
    function setFeeDenominator(uint _feeDenominator) public onlyOwner {
        feeDenominator = _feeDenominator;
    } 

    function getFeeAddress() public view returns (address) {
        return feeAddress;
    }

    function getFeeNumerator() public view returns (uint) {
        return feeNumerator;
    }

    function getFeeDenominator() public view returns (uint) {
        return feeDenominator;
    }

    function getOrderMarketNumbers() public view returns (uint256) {
        return orderMarketItemIds.length;
    }

    function getOrderItemIds() public view returns (uint256[] memory) {
        return orderMarketItemIds;
    }

    function urgentWithdraw(
        address nftContractAddress, 
        uint256[] memory ids, 
        uint256[] memory amounts, 
        uint256[] memory itemIds
        ) public onlyOwner{
        for(uint i = 0; i < itemIds.length; i++) {
            uint256 itemId = itemIds[i];
            delete idToMarketItem[itemId];
            LibArrayForUint256Utils.removeByValue(orderMarketItemIds, itemId);
        }
        IERC1155(nftContractAddress).safeBatchTransferFrom( address(this), msg.sender, ids, amounts, "");
    }

}

/// Thanks for inspiration: https://github.com/dabit3/polygon-ethereum-nextjs-marketplace/
