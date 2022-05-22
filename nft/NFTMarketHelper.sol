pragma solidity ^0.8.4;

import "./NFTMarketTransferToken.sol";

contract NFTMarketHepler {
    address public marketPlaceaddr = 0x26A40096D230E7385591135C5EDcD51025527cb0;
    // enum Status{ DEAL, ORDER, CANCLE }

    // struct MarketItem {
    //     uint itemId;
    //     address nftContract;
    //     uint256 tokenId;
    //     address payable seller;
    //     address payable owner;
    //     address moneyMintAddress;
    //     uint256 price;
    //     Status sold;
    //  }
    function getOrderLimt(uint start, uint offset) public view returns (marketPlace.MarketItem[] memory) {
        uint256 number = marketPlace(marketPlaceaddr).getOrderMarketNumbers();
        marketPlace.MarketItem[] memory  orders = marketPlace(marketPlaceaddr).fetchMarketItemsLimit(0, number);
        if(offset + start > number) {
            offset = number - start;
        }

        marketPlace.MarketItem[] memory items = new marketPlace.MarketItem[](offset);
        for (uint i = start; i < start + offset; i++) {
            items[i - start] =  orders[i];
        }

        return items;

    }
}
