pragma solidity 0.8.4;

import "./node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./node_modules/@openzeppelin/contracts/access/Ownable.sol";


contract Crowdsale is Ownable{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    mapping(address => uint256) private _balances;
    IERC20 private _token;

    constructor(IERC20 token) public {
        require(address(token) != address(0), "Crowdsale: token wallet is the zero address");
        _token = token;
    }

    function withdrawTokens(address beneficiary) public {
        uint256 amount = _balances[beneficiary];
        require(amount > 0, "PostDeliveryCrowdsale: beneficiary is not due any tokens");

        _balances[beneficiary] = 0;
        _token.safeTransfer(beneficiary, amount);
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }


    function processPurchase(address beneficiary, uint256 tokenAmount) public onlyOwner {
        _balances[beneficiary] = _balances[beneficiary].add(tokenAmount);
    }


    function processPurchaseBatch(address[] memory beneficiarys, uint256[] memory tokenAmounts) public onlyOwner {
        for (uint256 i = 0; i < beneficiarys.length; ++i) {
            processPurchase(beneficiarys[i], tokenAmounts[i]);
        }
    }
    
    function processPurchaseBatch95(address[] memory beneficiarys) public onlyOwner {
        for (uint256 i = 0; i < beneficiarys.length; ++i) {
            processPurchase(beneficiarys[i], 95000000000000000000);
        }
    }

    function emergencyWithdraw() external onlyOwner {
        _token.safeTransfer(msg.sender, _token.balanceOf(address(this)));
    } 

    function token() public view returns (IERC20) {
        return _token;
    }
}
