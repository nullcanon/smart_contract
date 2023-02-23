pragma solidity ^0.8.17;

import "./EIP-1822.sol";
import "./PayChannelUpdateable.sol";


contract PayChannel is PayChannelUpdateable, Proxiable {
        function updateCode(address newCode) onlyOwner public {
        updateCodeAddress(newCode);
    }
}