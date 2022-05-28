pragma solidity ^0.8.13;

import "../node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract ClaimERC20 is Ownable {
    mapping(address => uint) private userNonce;
    address private signer;
    address private erc20mint;

    event Claim(address indexed, uint256 indexed, uint indexed);

   function getMessageHash(
        address _to,
        uint256 _amount,
        uint _nonce
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_to, _amount, _nonce));
    }

    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
            );
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v + 27, r, s);
    }

    function verify(
        address _to,
        uint256 _amount,
        uint _nonce,
        bytes memory signature
    ) public view returns (bool) {
        bytes32 messageHash = getMessageHash(_to, _amount, _nonce);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == signer;
    }


    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }



    function claim(        
        address _to,
        uint256 _amount,
        uint _nonce,
        bytes memory signature
    ) public {
        require(verify(_to, _amount, _nonce, signature), "signature verify faild");
        require(userNonce[_to] < _nonce, "nonce verify faild");
        userNonce[_to] = userNonce[_to] + 1;

        IERC20(erc20mint).transfer(_to, _amount);
        emit Claim(_to, _amount, _nonce);
    }

    function setSigner(address _signer) public onlyOwner {
        signer = _signer;
    }

    function setToken(address _token) public onlyOwner {
        erc20mint = _token;
    }

    function urgentWithdraw(address _token) public onlyOwner {
        IERC20(_token).transfer( msg.sender, IERC20(erc20mint).balanceOf(address(this)));
    }

    function getSigner() public view returns (address) {
        return signer;
    }

    function getToken() public  view returns (address) {
        return erc20mint;
    }

}