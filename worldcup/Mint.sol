
pragma solidity ^0.8.0;



import "./TeamERC1155.sol";
import "./RandomId.sol";
import "./Adminable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";



contract MintTeam is Adminable, RandomId{
    address public teamnft = 0x8398Cbb5d1fcb93A5704Db2b4e6bE70cA3b35F25;
    address public money = 0x5439D37489Eef432979734e8ca7a36A826Cc1b58;
    address public bank = 0x6C27A881Aaed718067B2A284B5Ac2291D6caF6EE;
    address public daedAddress = 0x6C27A881Aaed718067B2A284B5Ac2291D6caF6EE;
    uint256 public price = 200000 * 10 ** 18;
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

    function setDead(address _dead) public onlyOwner {
        daedAddress = _dead;
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