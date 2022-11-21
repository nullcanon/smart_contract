
pragma solidity ^0.8.0;



import "./Adminable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";



contract TicketsWindow is Adminable{
    address public money = 0x5439D37489Eef432979734e8ca7a36A826Cc1b58;
    address public bank = 0x6C27A881Aaed718067B2A284B5Ac2291D6caF6EE;
    uint256 public price = 200000 * 10 ** 18;
    mapping(address => bool) public hasPay; 

    event PayMoney(address indexed user, uint256 price);

    function setPayMoney(address _money) public onlyOwner {
        money = _money;
    }

    function setBank(address _bank) public onlyOwner {
        bank = _bank;
    }

    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    function payMoney() public  {
        require(!hasPay[msg.sender], "User has pay.");

        IERC20(money).transferFrom(msg.sender, bank, price);
        hasPay[msg.sender] = true;

        emit PayMoney(msg.sender, price);
    }

}