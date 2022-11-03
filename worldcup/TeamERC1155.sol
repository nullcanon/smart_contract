
pragma solidity ^0.8.0;



import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/ERC1155.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";


contract TeamERC1155 is  Ownable, ERC1155Supply {

    uint256 public tokenSupply;
    uint256 public maxIndex = 1;
    mapping(address => bool) public whiteList;


    constructor() ERC1155("https://game.example/api/item/{id}.json") {
        whiteList[msg.sender] = true;
    }

    function addWhiteList(address account) public onlyOwner {
        whiteList[account] = true;
    }

    function mintTokenIdWithWitelist(address to, uint256[] memory tokenids, uint256[] memory amounts) public {
        require(whiteList[msg.sender], "Not in white");
        _mintBatch(to, tokenids, amounts, "");
    }

    function transferWithNumber(uint256 start, uint256 idsNumber, uint256 amount, address to) public {
        uint256[] memory ids = new uint256[](idsNumber);
        uint256[] memory amounts = new uint256[](idsNumber);
        for (uint256 i = start; i < (idsNumber + start); i++) {
            ids[i - start] = i;
            amounts[i - start] = amount;
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
    }

    function brunBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts) public {

        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _burnBatch(account, ids, amounts);
    }
}