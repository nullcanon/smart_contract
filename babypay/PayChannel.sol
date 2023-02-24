pragma solidity ^0.8.17;

import "./EIP-1822.sol";
import "./PayChannelUpdateable.sol";


contract PayChannel is PayChannelUpdateable, Proxiable {
        function updateCode(address newCode) onlyOwner public {
        updateCodeAddress(newCode);
    }
}





// 部署步骤

// 1、部署 PayChannel （该合约为可以升级的逻辑合约）
// 2、部署 Proxy 合约，传参分别为 web3.utils.sha3('constructor1()').substring(0,10) 和 PayChannel 合约地址
// 3、调用 PayChannel 的合约逻辑函数，调用的to地址为 Proxy 合约地址。

// 升级步骤
// 1、部署新的 PayChannel-v2 合约
// 2、调用 Proxy 地址的 updateCode 函数，参数填写 PayChannel-v2 合约地址
// 3、调用 PayChannel-v2 的合约逻辑函数，调用的to地址为 Proxy 合约地址。