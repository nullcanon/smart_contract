
pragma solidity ^0.8.0;



import "./TeamERC1155.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/EnumerableMap.sol";



abstract contract Adminable is Context {
    mapping(address => bool) private _admins;
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ModificationAdmin(address indexed admin, bool oldState, bool newState);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Adminable: caller is not the owner");
        _;
    }

    modifier onlyAdmin() {
        require(isAdmin(_msgSender()), "Adminable: caller is not the admin");
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function isAdmin(address account) public view virtual returns (bool) {
        return _admins[account];
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function modificationAdmin(address admin, bool state) public virtual onlyOwner {
        emit ModificationAdmin(admin,  _admins[admin], state);
        _admins[admin] = state;
    }
}


contract MintTeam is Adminable{
    address public team;
    address public money;
    address public bank;
    uint256 public price;
    using EnumerableMap for EnumerableMap.UintToUintMap;
    uint numbers = 36;
    uint256 public mintLimit = 10;
    uint256[36] lefts = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35];
    uint256[36] rights = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36];


    event MintBlindBox(address indexed user, uint256 tokenid, uint256 amount);

    function setRange(uint256 _numbers, uint256[] memory _lefts, uint256[] memory _rights) public onlyAdmin {
        require(_lefts.length == _numbers, "lefts length error");
        require(_rights.length == _numbers, "rights length error");
        numbers = _numbers;
        for(uint256 i = 0; i < numbers; ++i) {
            lefts[i] = _lefts[i];
            rights[i] = _rights[i];
        }
    }
    

    function random(uint number, uint nonce) public view returns(uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty,  
            msg.sender, nonce))) % number + 1;
    }

    function getRandomTokenid(uint nonce) private view returns (uint256) {
        uint256 x = random(numbers, nonce);
        for(uint256 i = 0; i < numbers; ++i) {
            if(x > lefts[i] && x < rights[i]) {
                return i + 1;
            }
        }
        return 0;
    }

    function mintWithBlindBox(uint256 quantity) public  {
        require(quantity <= mintLimit, "Exceed the maximum limit");
        uint256 amount = price * quantity;
        IERC20(money).transferFrom(msg.sender, bank, amount);

        EnumerableMap.UintToUintMap storage tokens;

        for(uint256 i = 0; i < quantity; ++i){
            uint256 tokenid = getRandomTokenid(i);
            (bool success, uint256 value)  = tokens.tryGet(tokenid);
            if(success == true) {
                value = value + 1;
                tokens.set(tokenid, value);
            } else {
                tokens.set(tokenid, 1);
            }
        }

        uint256 length = tokens.length();
        uint256[] memory ids = new uint256[](length);
        uint256[] memory amounts = new uint256[](length);
        for(uint256 i = 0; i < length; ++i) {
            (uint256 id, uint256 amount1) = tokens.at(i);
            ids[i] = id;
            amounts[i] = amount1;
            emit MintBlindBox(msg.sender, id, amount);
        }

        TeamERC1155(team).mintTokenIdWithWitelist(msg.sender, ids, amounts);
    }

}