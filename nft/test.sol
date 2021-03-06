pragma solidity ^0.4.4;

contract Decode{
  //公匙：0x60320b8a71bc314404ef7d194ad8cac0bee1e331
  //sha3(msg): 0x4e03657aea45a94fc7d47ba826c8d667c0d1e6e33a64a036ec44f58fa12d6c45 (web3.sha3("abc");)
  //签名后的数据：0xf4128988cbe7df8315440adde412a8955f7f5ff9a5468a791433727f82717a6753bd71882079522207060b681fbd3f5623ee7ed66e33fc8e581f442acbcf6ab800

  //验签数据入口函数
  function decode() returns (address){
    bytes memory signedString =hex"c6f0926cc935839316144b325ebddcd0a60d16b29b0fbf1dedec47be8c34362f4491e15d2c72ae0598f302d34ee5244cfaf11f81f59b18fa3cbd24705d43e0a001";

    bytes32  r = bytesToBytes32(slice(signedString, 0, 32));
    bytes32  s = bytesToBytes32(slice(signedString, 32, 32));
    byte  v = slice(signedString, 64, 1)[0];
    return ecrecoverDecode(r, s, v);
  }

  //将原始数据按段切割出来指定长度
  function slice(bytes memory data, uint start, uint len) returns (bytes){
    bytes memory b = new bytes(len);

    for(uint i = 0; i < len; i++){
      b[i] = data[i + start];
    }

    return b;
  }

  //使用ecrecover恢复公匙
  function ecrecoverDecode(bytes32 r, bytes32 s, byte v1) returns (address addr){
     uint8 v = uint8(v1) + 27;
     addr = ecrecover(hex"f761dd7550224ec252e544c77097a6b94c9a0cab6ff4bfa068b5edf83e6da563", v, r, s);
  }

  //bytes转换为bytes32
  function bytesToBytes32(bytes memory source) returns (bytes32 result) {
    assembly {
        result := mload(add(source, 32))
    }
  }

   uint count;
  function testGas() public {
    
    for(uint i = 0; i < 10; ++i) {
        ++count;
    }
  
  }

    function testGas2() public {
      uint32 a = 1;
      uint c = 3;
      uint32 b = 2;
      uint d = 4;
  }

}
