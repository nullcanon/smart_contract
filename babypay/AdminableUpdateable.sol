
pragma solidity ^0.8.17;

import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/proxy/utils/Initializable.sol"

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract AdminableUpdateable is Context, Initializable {
    mapping(address => bool) private _admins;
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ModificationAdmin(address indexed admin, bool oldState, bool newState);

    constructor() {
    }


    modifier onlyOwner() {
        require(owner() == _msgSender(), "Adminable: caller is not the owner");
        _;
    }

    modifier onlyAdmin() {
        require(isAdmin(_msgSender()), "Adminable: caller is not the admin");
        _;
    }

    function initOwner() internal onlyInitializing {
        _transferOwnership(_msgSender());
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
