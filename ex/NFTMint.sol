pragma solidity ^0.8.0;

import "./NFTERC1155Mint.sol";


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


contract NFTMint is  Ownable{


    address public feeTo;
    address public feeToken;
    uint256 public feeAmount;

    mapping(address => mapping(address => uint)) public whiteList;

    mapping(address => bool) public openWhileList;

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

    event MintNft(address indexed user, address indexed nft, uint256 tokenid);

    function mintNft(address nftContract) public {
        if(!openWhileList[nftContract]) {
            require(inWhiteList(nftContract, msg.sender), "Not white list user");
            whiteList[nftContract][msg.sender] -= 1;
        } 

        IERC20(feeToken).transferFrom(msg.sender, feeTo, feeAmount);
        uint256 tokenid = NFTItems(nftContract).mintWithWiteList(msg.sender);
        emit MintNft(msg.sender, nftContract, tokenid);
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
}