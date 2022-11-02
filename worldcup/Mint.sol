
pragma solidity ^0.8.0;



import "./TeamERC1155.sol";
import "./RandomId.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";



contract MintTeam is Adminable, RandomId{
    address public teamnft;
    address public money;
    address public bank;
    uint256 public price;
    uint256 public mintLimit = 10;


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

    function setTeamNft(address nft) public onlyOwner {
        teamnft = nft;
    }

    function setPayMoney(address paymoney) public onlyOwner {
        money = paymoney;
    }

    function setBank(address _bank) public onlyOwner {
        bank = _bank;
    }

    function setBlindBoxPrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    function mintWithBlindBox(uint256 quantity) public  {
        require(quantity <= mintLimit, "Exceed the maximum limit");
        uint256 amount = price * quantity;
        IERC20(money).transferFrom(msg.sender, bank, amount);

        uint256[] memory ids = new uint256[](quantity);
        uint256[] memory amounts = new uint256[](quantity);

        for(uint256 i = 0; i < quantity; ++i){
            uint256 tokenid = getRandomTokenid(i);
            ids[i] = tokenid;
            amounts[i] = 1;
        }

        TeamERC1155(teamnft).mintTokenIdWithWitelist(msg.sender, ids, amounts);
    }

}