pragma solidity ^0.8.17;

import "./AdminableUpdateable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";




contract PayChannelUpdateable is AdminableUpdateable{

    // TODO 升级合约可以用柔性数组吗
    struct GameInfo {
        bool isRegister;
        uint256 startTime;
        uint256 endTime;
        uint256 index;
        string flag;
        uint256[] minLimit; // index 0 为游戏押注上限，后面一次为结果押注上限
        uint256[] maxLimit;
    }


    address public signer;
    address public bankAddress = address(this);

    uint256 public totalMaxLimit = 1000 * 10^18;
    uint256 public totalMinLimit = 1 * 10^18;
    
    mapping(address => bool) public payMoneyList;
    mapping(uint256 => GameInfo) public gameList;

    //nonce 变更后向后端发通知，后端获取到新的nonce作为下一次的取款nonce
    mapping(address => uint) public userNonce; 


    event PlayGamed(address indexed user, address indexed payMoney, uint256 gameId, uint256 resultId, uint256 amount);
    event RegisterGamed(uint256 gameId, uint256 startTime, uint256 endTime,  string flag, uint256[] minLimit, uint256[] maxLimit);
    event ModifyGamed(uint256 gameId, uint256 startTime, uint256 endTime, string flag, uint256[] minLimit, uint256[] maxLimit);
    event MoneyChanged(address indexed money, bool status);
    event Claimed(address indexed account, address indexed payMoney, uint256 amount, uint256 nonce);
    event UrgentWithdraw(address indexed account, address indexed payMoney, uint256 amount);
    event BankChanged(address indexed oldBank, address indexed newBank);
    event LimitChanged(uint256 oldMin, uint256 newMin, uint256 oldMax, uint256 newMax);
    event ModifyGameLimit(uint256 gameid, uint256 index, uint256 min, uint256 max);

    function initContract() public {
        bankAddress = address(this);
        totalMaxLimit = 1000 * 10^18;
        totalMinLimit = 1 * 10^18;
        initOwner();
    }

    function getLimit() view public returns (uint256, uint256) {
        return (totalMinLimit, totalMaxLimit);
    }

    function setTotalLimit(uint256 _min, uint256 _max) public onlyAdmin {
        emit LimitChanged(totalMinLimit, _min, totalMaxLimit, _max);
        totalMinLimit = _min;
        totalMaxLimit = _max;
    }

    function setBank(address _bank) public onlyOwner {
        emit BankChanged(bankAddress, _bank);
        bankAddress = _bank;
    }

    function _isPayETH(address money) pure public returns (bool) {
        return money == address(0);
    }

    function playGame(address _payMoney, uint256 _gameId, uint256 _resultId, uint256 _amount) public payable {
        require(payMoneyList[_payMoney], "Unsupported currencies");

        GameInfo memory _info = gameList[_gameId];
        require(_info.isRegister, "Unregistered game");
        require(_resultId <= _info.index && _resultId != 0, "Result id error");


        if( _isPayETH(_payMoney) ) {
            payable(bankAddress).transfer(_amount);
        } else {
            IERC20(_payMoney).transferFrom(msg.sender, bankAddress, _amount);
        }
 
        emit PlayGamed(msg.sender, _payMoney, _gameId, _resultId, _amount);
    }

    function registerGame(uint256 _gameId, uint256 _startTime, uint256 _endTime, string memory _flag, 
        uint256[] memory _minLimit, uint256[] memory _maxLimit) public onlyAdmin {
        require(_minLimit.length == _maxLimit.length, "Limit array length error");

        GameInfo memory _info =  gameList[_gameId];
        require(!_info.isRegister, "Game id has used");
        _info.isRegister = true;
        _info.startTime = _startTime;
        _info.endTime = _endTime;
        _info.flag = _flag;
        _info.minLimit = _minLimit;
        _info.maxLimit = _maxLimit;
        gameList[_gameId] = _info;
        emit RegisterGamed(_gameId, _startTime, _endTime, _flag, _minLimit, _maxLimit);
    }

    function modifyGame(uint256 _gameId, uint256 _startTime, uint256 _endTime, string memory _flag, 
        uint256[] memory _minLimit,  uint256[] memory _maxLimit) public onlyAdmin {

        require(_minLimit.length == _maxLimit.length, "Limit array length error");

        GameInfo memory _info =  gameList[_gameId];
        require(_info.isRegister, "Game id not register");
        _info.startTime = _startTime;
        _info.endTime = _endTime;
        _info.flag = _flag;
        _info.minLimit = _minLimit;
        _info.maxLimit = _maxLimit;
        gameList[_gameId] = _info;
        emit ModifyGamed(_gameId, _startTime, _endTime, _flag, _minLimit, _maxLimit);
    }

    function changePayMoneyList(address _money, bool _status) public onlyAdmin {
        payMoneyList[_money] = _status;
        emit MoneyChanged(_money, _status);
    }

   function getMessageHash(
        address _to,
        address _payMoney,
        uint256 _amount,
        uint256 _deadline,
        uint _nonce
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_to,_payMoney,  _amount, _deadline, _nonce));
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
        address _payMoney,
        uint256 _amount,
        uint256 _deadline,
        uint _nonce,
        bytes memory signature
    ) public view returns (bool) {
        bytes32 messageHash = getMessageHash(_to, _payMoney, _amount, _deadline, _nonce);
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
        address _payMoney,
        uint256 _amount,
        uint256 _deadline,
        uint _nonce,
        bytes memory _signature
    ) public {
        require(_deadline > block.timestamp, "Already expired");
        require(verify(_to, _payMoney, _amount, _deadline, _nonce, _signature), "signature verify faild");
        require(userNonce[_to] == _nonce, "nonce verify faild");
        userNonce[_to] = userNonce[_to] + 1;

        if( _isPayETH(_payMoney) ) {
            payable(msg.sender).transfer(_amount);
        } else {
            IERC20(_payMoney).transfer(msg.sender, _amount);
        }

        emit Claimed(msg.sender, _payMoney, _amount, _nonce);
    }

    function setSigner(address _signer) public onlyOwner {
        signer = _signer;
    }

    function urgentWithdraw(address _token, address _to, uint256 _amount) public onlyOwner {
        if( _isPayETH(_token) ) {
            payable(_to).transfer(_amount);
        } else {
            IERC20(_token).transfer(_to, _amount);
        }
        emit UrgentWithdraw(msg.sender, _token, _amount);
    }

    receive() external payable {}
}