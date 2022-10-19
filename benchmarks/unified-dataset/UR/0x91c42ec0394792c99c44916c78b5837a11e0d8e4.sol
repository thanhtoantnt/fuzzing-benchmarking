 

pragma solidity ^0.5.7;


 
 
 
 
 
 
 
 

 
library SafeMath256 {
     
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + a % b);
        return a / b;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


 
contract Ownable {
    address private _owner;
    address payable internal _receiver;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ReceiverChanged(address indexed previousReceiver, address indexed newReceiver);

     
    constructor () internal {
        _owner = msg.sender;
        _receiver = msg.sender;
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

     
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0));
        address __previousOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(__previousOwner, newOwner);
    }

     
    function changeReceiver(address payable newReceiver) external onlyOwner {
        require(newReceiver != address(0));
        address __previousReceiver = _receiver;
        _receiver = newReceiver;
        emit ReceiverChanged(__previousReceiver, newReceiver);
    }

     
    function rescueTokens(address tokenAddr, address receiver, uint256 amount) external onlyOwner {
        IERC20 _token = IERC20(tokenAddr);
        require(receiver != address(0));
        uint256 balance = _token.balanceOf(address(this));
        require(balance >= amount);

        assert(_token.transfer(receiver, amount));
    }

     
    function withdrawEther(address payable to, uint256 amount) external onlyOwner {
        require(to != address(0));
        uint256 balance = address(this).balance;
        require(balance >= amount);

        to.transfer(amount);
    }
}


 
contract Pausable is Ownable {
    bool private _paused;

    event Paused(address account);
    event Unpaused(address account);

    constructor () internal {
        _paused = false;
    }

     
    function paused() public view returns (bool) {
        return _paused;
    }

     
    modifier whenNotPaused() {
        require(!_paused, "Paused.");
        _;
    }

     
    function setPaused(bool state) external onlyOwner {
        if (_paused && !state) {
            _paused = false;
            emit Unpaused(msg.sender);
        } else if (!_paused && state) {
            _paused = true;
            emit Paused(msg.sender);
        }
    }
}


 
interface IERC20 {
    function balanceOf(address owner) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
}


 
interface ITG {
    function balanceOf(address owner) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function inWhitelist(address account) external view returns (bool);
}


 
interface ITGPublicSale {
    function status() external view returns (uint256 auditEtherPrice,
                                             uint16 stage,
                                             uint16 season,
                                             uint256 TGUsdPrice,
                                             uint256 currentTopSalesRatio,
                                             uint256 txs,
                                             uint256 TGTxs,
                                             uint256 TGBonusTxs,
                                             uint256 TGWhitelistTxs,
                                             uint256 TGIssued,
                                             uint256 TGBonus,
                                             uint256 TGWhitelist);
}


 
contract Get1002TG is Ownable, Pausable {
    using SafeMath256 for uint256;

    address TG_Addr = address(0);
    ITG public TG = ITG(TG_Addr);

    ITGPublicSale public TG_PUBLIC_SALE;

    uint256 public WEI_MIN = 1 ether;
    uint256 private TG_PER_TXN = 1002000000;  

    uint256 private _txs;

    mapping (address => bool) _alreadyGot;

    event Tx(uint256 etherPrice, uint256 vokdnUsdPrice, uint256 weiUsed);

     
    function txs() public view returns (uint256) {
        return _txs;
    }

    function setWeiMin(uint256 weiMin) public onlyOwner {
        WEI_MIN = weiMin;
    }

     
    function () external payable whenNotPaused {
        require(msg.value >= WEI_MIN);
        require(TG.balanceOf(address(this)) >= TG_PER_TXN);
        require(TG.balanceOf(msg.sender) == 0);
        require(!TG.inWhitelist(msg.sender));
        require(!_alreadyGot[msg.sender]);

        uint256 __etherPrice;
        uint256 __TGUsdPrice;
        (__etherPrice, , , __TGUsdPrice, , , , , , , ,) = TG_PUBLIC_SALE.status();

        require(__etherPrice > 0);

        uint256 __usd = TG_PER_TXN.mul(__TGUsdPrice).div(1000000);
        uint256 __wei = __usd.mul(1 ether).div(__etherPrice);

        require(msg.value >= __wei);

        if (msg.value > __wei) {
            msg.sender.transfer(msg.value.sub(__wei));
            _receiver.transfer(__wei);
        }

        _txs = _txs.add(1);
        _alreadyGot[msg.sender] = true;
        emit Tx(__etherPrice, __TGUsdPrice, __wei);

        assert(TG.transfer(msg.sender, TG_PER_TXN));
    }

     
    function setPublicSaleAddress(address _pubSaleAddr) public onlyOwner {
        TG_PUBLIC_SALE = ITGPublicSale(_pubSaleAddr);
    }

     
    function setTGAddress(address _TgAddr) public onlyOwner {
        TG_Addr = _TgAddr;
        TG = ITG(_TgAddr);
    }

}