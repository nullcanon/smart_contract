
pragma solidity ^0.8.0;


import "./node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./node_modules/@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "./node_modules/@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract GameItems is ERC1155 , ERC1155Burnable{
    uint256 public constant GOLD = 0;
    uint256 public constant SILVER = 1;
    uint256 public constant THORS_HAMMER = 2;
    uint256 public constant SWORD = 3;
    uint256 public constant SHIELD = 4;

    constructor() ERC1155("https://game.example/api/item/{id}.json") {
        _mint(msg.sender, GOLD, 10**18, "");
        _mint(msg.sender, SILVER, 10**27, "");
        _mint(msg.sender, THORS_HAMMER, 1, "");
        _mint(msg.sender, SWORD, 10**9, "");
        _mint(msg.sender, SHIELD, 10**9, "");
    }

    function mintBatch() public {
        uint256[] memory ids = new uint256[](1000);
        uint256[] memory amounts = new uint256[](1000);
        for (uint256 i = 0; i < 1000; i++) {
            ids[i] = i;
            amounts[i] = 1;
        }
        _mintBatch(msg.sender, ids, amounts, "");
    }
}