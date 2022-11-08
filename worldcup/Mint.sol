
pragma solidity ^0.8.0;



import "./TeamERC1155.sol";
import "./RandomId.sol";
import "./Adminable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";



contract MintTeam is Adminable, RandomId{
    address public teamnft = 0x9D8f7aEA83ceCF102ab65e9A5b82106b07a68b28;
    address public money = 0x58a944f9c44D08461A471A1F6C6D15De351d97B3;
    address public bank = 0xd3c0b6Aa1538d639912789be705F18b5Fd89fcE6;
    address public daedAddress = 0x000000000000000000000000000000000000dEaD;
    uint256 public price = 300 * 10 ** 18;
    uint256 public mintLimit = 10;
    uint256 public feeRateDenominator = 1000;
    uint256 public feeRateNumerator = 50;
    

    event MintBlindBox(address indexed user, uint256 price, uint256 quantity, uint256[] tokenids);

    function setFeeRate(uint256 _feeRateNumerator, uint256 _feeRateDenominator) public onlyOwner{
        feeRateNumerator = _feeRateNumerator;
        feeRateDenominator = _feeRateDenominator;
    }

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

        uint256 feeAmount = amount * feeRateNumerator / feeRateDenominator;

        IERC20(money).transferFrom(msg.sender, bank, feeAmount);
        IERC20(money).transferFrom(msg.sender, daedAddress, amount - feeAmount);

        uint256[] memory ids = new uint256[](quantity);
        uint256[] memory amounts = new uint256[](quantity);

        for(uint256 i = 0; i < quantity; ++i){
            uint256 tokenid = getRandomTokenid(i);
            ids[i] = tokenid;
            amounts[i] = 1;
        }

        TeamERC1155(teamnft).mintTokenIdWithWitelist(msg.sender, ids, amounts);

        emit MintBlindBox(msg.sender, price, quantity, ids);
    }

}