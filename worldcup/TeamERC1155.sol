
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


    function mintWithWiteList(address to) public returns (uint256){
        require(whiteList[msg.sender], "Not in white");
        _mint(to, maxIndex, 1, "");
        maxIndex = maxIndex + 1;
        tokenSupply = tokenSupply + 1;
        return maxIndex - 1;
    }

    function mintTokenIdWithWitelist(address to, uint256 tokenid, uint256 amount) public {
        require(whiteList[msg.sender], "Not in white");
        _mint(to, tokenid, amount, "");
    }

    function mintBatchWithNumber(uint256 idsNumber, uint256 amount) public onlyOwner{
        require(amount > 0, "amount must more than zero");
        uint256[] memory ids = new uint256[](idsNumber);
        uint256[] memory amounts = new uint256[](idsNumber);
        uint256 addSupply;
        for (uint256 i = tokenSupply; i < (idsNumber + tokenSupply); i++) {
            ids[i - tokenSupply] = i;
            amounts[i - tokenSupply] = amount;
            if(!exists(i)) {
                ++addSupply;
            }
        }
        tokenSupply = tokenSupply + addSupply;
        maxIndex = maxIndex + idsNumber;
        _mintBatch(msg.sender, ids, amounts, "");
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
        uint256 addSupply;
        for(uint256 i = 0; i < ids.length; ++i) {
            if(!exists(ids[i])) {
                ++addSupply;
            }
        }
        tokenSupply = tokenSupply + addSupply;
        _mintBatch(to, ids, amounts, data);
        maxIndex = maxIndex + ids.length;
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
        if (totalSupply(id) == 0) {
            --tokenSupply;
        }
    }
}