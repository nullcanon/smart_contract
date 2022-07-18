
pragma solidity ^0.8.0;


import "../node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";



contract MGCItems is  ERC1155 , Ownable{

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

    function totalSupply() public view returns (uint256) {
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