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

    address public nftAMint;
    address public nftBMint;
    address public nftCMint;

    address public feeTo;
    address public feeToken;
    uint256 public feeAmount;

    event CompoundNft(address indexed to, uint256 tokenId)

    function compoundNft(uint256 nftAId, uint256 nftBId) public {

        IERC20(feeToken).transferFrom(msg.sender, feeTo, feeAmount);
        uint256 token_id = NFTItems(nftCMint).mintWithWiteList(msg.sender);

        BeeItems(nftAMint).brun(msg.sender, nftAId, 1);
        BeeItems(nftBMint).brun(msg.sender, nftBId, 1);
        emit CompoundNft(msg.sender, token_id);
    }

    function setNftMintAddress(address A, address B, address C) public onlyOwner {
        nftAMint = A;
        nftBMint = B;
        nftCMint = C;
    }

    function setFeeToken(address mint) public onlyOwner {
        feeToken = mint;
    }

    function setFeeTo(address to) public onlyOwner {
        feeTo = to;
    }
}