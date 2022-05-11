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
         bool sold;
     }
     
     mapping(uint256 => MarketItem) private idToMarketItem;
     
     event MarketItemCreated (
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        address moneyMintAddress,
        uint256 price,
        bool sold
     );
     
     event MarketItemSold (
         uint indexed itemId,
         address owner
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
                false
            );
            
            IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
                
            emit MarketItemCreated(
                itemId,
                nftContract,
                tokenId,
                msg.sender,
                address(0),
                address(0),
                price,
                false
            );
        }

      function createMarketItemErc1155(
        address nftContract,
        address moneyMintAddress,
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
                moneyMintAddress,
                price,
                false
            );
            
            IERC1155(nftContract).safeTransferFrom( msg.sender, address(this), tokenId, 1 , "");
                
            emit MarketItemCreated(
                itemId,
                nftContract,
                tokenId,
                msg.sender,
                address(0),
                moneyMintAddress,
                price,
                false
            );
        }
    

    
    function createMarketSale(
        address nftContract,
        uint256 itemId
        ) public payable nonReentrant {
            uint price = idToMarketItem[itemId].price;
            uint tokenId = idToMarketItem[itemId].tokenId;
            bool sold = idToMarketItem[itemId].sold;
            require(msg.value == price, "Please submit the asking price in order to complete the purchase");
            require(sold != true, "This Sale has alredy finnished");
            emit MarketItemSold(
                itemId,
                msg.sender
                );

            idToMarketItem[itemId].seller.transfer(msg.value);
            IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
            idToMarketItem[itemId].owner = payable(msg.sender);
            _itemsSold.increment();
            idToMarketItem[itemId].sold = true;
    }

    function createMarketSaleWithToken(
        address nftContract,
        address moneyMintAddress,
        uint256 itemId,
        uint256 price
        ) public payable nonReentrant {
            uint priceMarket = idToMarketItem[itemId].price;
            uint tokenId = idToMarketItem[itemId].tokenId;
            bool sold = idToMarketItem[itemId].sold;
            require(priceMarket == price, "Please submit the asking price in order to complete the purchase");
            require(sold != true, "This Sale has alredy finnished");
            emit MarketItemSold(
                itemId,
                msg.sender
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
            idToMarketItem[itemId].sold = true;
    }

    function createMarketSaleWithTokenErc1155(
        address nftContract,
        address tokenMintAddress,
        uint256 itemId,
        uint256 price
        ) public payable nonReentrant {
            uint priceMarket = idToMarketItem[itemId].price;
            uint tokenId = idToMarketItem[itemId].tokenId;
            bool sold = idToMarketItem[itemId].sold;
            require(priceMarket == price, "Please submit the asking price in order to complete the purchase");
            require(sold != true, "This Sale has alredy finnished");
            emit MarketItemSold(
                itemId,
                msg.sender
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
            idToMarketItem[itemId].sold = true;
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

    function fetchMarketItemsLimit(uint start, uint offset) public view returns (MarketItem[] memory) {
        uint itemCount = _itemIds.current();
        if(offset >= itemCount) {
            offset = itemCount;
        }

        // uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](offset);
        for (uint i = start; i < offset; i++) {
            if (idToMarketItem[i + 1].owner == address(0)) {
                uint currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
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

}

/// Thanks for inspiration: https://github.com/dabit3/polygon-ethereum-nextjs-marketplace/
