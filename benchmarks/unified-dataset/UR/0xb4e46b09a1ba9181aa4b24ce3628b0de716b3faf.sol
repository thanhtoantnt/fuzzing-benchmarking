 

 

pragma solidity ^0.5.0;

 
library SafeMath {
     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
         
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
         

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

 

pragma solidity ^0.5.0;

 
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

     
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

 

pragma solidity ^0.5.4;



 

contract Reputation is Ownable {

    uint8 public decimals = 18;              
     
    event Mint(address indexed _to, uint256 _amount);
     
    event Burn(address indexed _from, uint256 _amount);

       
       
       
    struct Checkpoint {

     
        uint128 fromBlock;

           
        uint128 value;
    }

       
       
       
    mapping (address => Checkpoint[]) balances;

       
    Checkpoint[] totalSupplyHistory;

     
    constructor(
    ) public
    {
    }

     
     
    function totalSupply() public view returns (uint256) {
        return totalSupplyAt(block.number);
    }

   
   
   
     
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balanceOfAt(_owner, block.number);
    }

       
       
       
       
    function balanceOfAt(address _owner, uint256 _blockNumber)
    public view returns (uint256)
    {
        if ((balances[_owner].length == 0) || (balances[_owner][0].fromBlock > _blockNumber)) {
            return 0;
           
        } else {
            return getValueAt(balances[_owner], _blockNumber);
        }
    }

       
       
       
    function totalSupplyAt(uint256 _blockNumber) public view returns(uint256) {
        if ((totalSupplyHistory.length == 0) || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
            return 0;
           
        } else {
            return getValueAt(totalSupplyHistory, _blockNumber);
        }
    }

       
       
       
       
    function mint(address _user, uint256 _amount) public onlyOwner returns (bool) {
        uint256 curTotalSupply = totalSupply();
        require(curTotalSupply + _amount >= curTotalSupply);  
        uint256 previousBalanceTo = balanceOf(_user);
        require(previousBalanceTo + _amount >= previousBalanceTo);  
        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
        updateValueAtNow(balances[_user], previousBalanceTo + _amount);
        emit Mint(_user, _amount);
        return true;
    }

       
       
       
       
    function burn(address _user, uint256 _amount) public onlyOwner returns (bool) {
        uint256 curTotalSupply = totalSupply();
        uint256 amountBurned = _amount;
        uint256 previousBalanceFrom = balanceOf(_user);
        if (previousBalanceFrom < amountBurned) {
            amountBurned = previousBalanceFrom;
        }
        updateValueAtNow(totalSupplyHistory, curTotalSupply - amountBurned);
        updateValueAtNow(balances[_user], previousBalanceFrom - amountBurned);
        emit Burn(_user, amountBurned);
        return true;
    }

   
   
   

       
       
       
       
    function getValueAt(Checkpoint[] storage checkpoints, uint256 _block) internal view returns (uint256) {
        if (checkpoints.length == 0) {
            return 0;
        }

           
        if (_block >= checkpoints[checkpoints.length-1].fromBlock) {
            return checkpoints[checkpoints.length-1].value;
        }
        if (_block < checkpoints[0].fromBlock) {
            return 0;
        }

           
        uint256 min = 0;
        uint256 max = checkpoints.length-1;
        while (max > min) {
            uint256 mid = (max + min + 1) / 2;
            if (checkpoints[mid].fromBlock<=_block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

       
       
       
       
    function updateValueAtNow(Checkpoint[] storage checkpoints, uint256 _value) internal {
        require(uint128(_value) == _value);  
        if ((checkpoints.length == 0) || (checkpoints[checkpoints.length - 1].fromBlock < block.number)) {
            Checkpoint storage newCheckPoint = checkpoints[checkpoints.length++];
            newCheckPoint.fromBlock = uint128(block.number);
            newCheckPoint.value = uint128(_value);
        } else {
            Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
            oldCheckPoint.value = uint128(_value);
        }
    }
}

 

pragma solidity ^0.5.0;

 
interface IERC20 {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

pragma solidity ^0.5.0;



 
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

     
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

     
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

     
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

     
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

     
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

     
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

     
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

     
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

     
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

     
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

      
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

     
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

     
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}

 

pragma solidity ^0.5.0;


 
contract ERC20Burnable is ERC20 {
     
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

     
    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }
}

 

pragma solidity ^0.5.11;





 

contract DAOToken is ERC20, ERC20Burnable, Ownable {

    string public name;
    string public symbol;
     
    uint8 public constant decimals = 18;
    uint256 public cap;

     
    constructor(string memory _name, string memory _symbol, uint256 _cap)
    public {
        name = _name;
        symbol = _symbol;
        cap = _cap;
    }

     
    function mint(address _to, uint256 _amount) public onlyOwner returns (bool) {
        if (cap > 0)
            require(totalSupply().add(_amount) <= cap);
        _mint(_to, _amount);
        return true;
    }
}

 

pragma solidity ^0.5.0;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         

        uint256 size;
         
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

 

 
pragma solidity ^0.5.11;



library SafeERC20 {
    using Address for address;

    bytes4 constant private TRANSFER_SELECTOR = bytes4(keccak256(bytes("transfer(address,uint256)")));
    bytes4 constant private TRANSFERFROM_SELECTOR = bytes4(keccak256(bytes("transferFrom(address,address,uint256)")));
    bytes4 constant private APPROVE_SELECTOR = bytes4(keccak256(bytes("approve(address,uint256)")));

    function safeTransfer(address _erc20Addr, address _to, uint256 _value) internal {

         
        require(_erc20Addr.isContract());

        (bool success, bytes memory returnValue) =
         
        _erc20Addr.call(abi.encodeWithSelector(TRANSFER_SELECTOR, _to, _value));
         
        require(success);
         
        require(returnValue.length == 0 || (returnValue.length == 32 && (returnValue[31] != 0)));
    }

    function safeTransferFrom(address _erc20Addr, address _from, address _to, uint256 _value) internal {

         
        require(_erc20Addr.isContract());

        (bool success, bytes memory returnValue) =
         
        _erc20Addr.call(abi.encodeWithSelector(TRANSFERFROM_SELECTOR, _from, _to, _value));
         
        require(success);
         
        require(returnValue.length == 0 || (returnValue.length == 32 && (returnValue[31] != 0)));
    }

    function safeApprove(address _erc20Addr, address _spender, uint256 _value) internal {

         
        require(_erc20Addr.isContract());

         
         
        require((_value == 0) || (IERC20(_erc20Addr).allowance(address(this), _spender) == 0));

        (bool success, bytes memory returnValue) =
         
        _erc20Addr.call(abi.encodeWithSelector(APPROVE_SELECTOR, _spender, _value));
         
        require(success);
         
        require(returnValue.length == 0 || (returnValue.length == 32 && (returnValue[31] != 0)));
    }
}

 

pragma solidity ^0.5.11;







 
contract Avatar is Ownable {
    using SafeERC20 for address;

    string public orgName;
    DAOToken public nativeToken;
    Reputation public nativeReputation;

    event GenericCall(address indexed _contract, bytes _data, uint _value, bool _success);
    event SendEther(uint256 _amountInWei, address indexed _to);
    event ExternalTokenTransfer(address indexed _externalToken, address indexed _to, uint256 _value);
    event ExternalTokenTransferFrom(address indexed _externalToken, address _from, address _to, uint256 _value);
    event ExternalTokenApproval(address indexed _externalToken, address _spender, uint256 _value);
    event ReceiveEther(address indexed _sender, uint256 _value);
    event MetaData(string _metaData);

     
    constructor(string memory _orgName, DAOToken _nativeToken, Reputation _nativeReputation) public {
        orgName = _orgName;
        nativeToken = _nativeToken;
        nativeReputation = _nativeReputation;
    }

     
    function() external payable {
        emit ReceiveEther(msg.sender, msg.value);
    }

     
    function genericCall(address _contract, bytes memory _data, uint256 _value)
    public
    onlyOwner
    returns(bool success, bytes memory returnValue) {
       
        (success, returnValue) = _contract.call.value(_value)(_data);
        emit GenericCall(_contract, _data, _value, success);
    }

     
    function sendEther(uint256 _amountInWei, address payable _to) public onlyOwner returns(bool) {
        _to.transfer(_amountInWei);
        emit SendEther(_amountInWei, _to);
        return true;
    }

     
    function externalTokenTransfer(IERC20 _externalToken, address _to, uint256 _value)
    public onlyOwner returns(bool)
    {
        address(_externalToken).safeTransfer(_to, _value);
        emit ExternalTokenTransfer(address(_externalToken), _to, _value);
        return true;
    }

     
    function externalTokenTransferFrom(
        IERC20 _externalToken,
        address _from,
        address _to,
        uint256 _value
    )
    public onlyOwner returns(bool)
    {
        address(_externalToken).safeTransferFrom(_from, _to, _value);
        emit ExternalTokenTransferFrom(address(_externalToken), _from, _to, _value);
        return true;
    }

     
    function externalTokenApproval(IERC20 _externalToken, address _spender, uint256 _value)
    public onlyOwner returns(bool)
    {
        address(_externalToken).safeApprove(_spender, _value);
        emit ExternalTokenApproval(address(_externalToken), _spender, _value);
        return true;
    }

     
    function metaData(string memory _metaData) public onlyOwner returns(bool) {
        emit MetaData(_metaData);
        return true;
    }


}

 

pragma solidity ^0.5.11;


contract GlobalConstraintInterface {

    enum CallPhase { Pre, Post, PreAndPost }

    function pre( address _scheme, bytes32 _params, bytes32 _method ) public returns(bool);
    function post( address _scheme, bytes32 _params, bytes32 _method ) public returns(bool);
     
    function when() public returns(CallPhase);
}

 

pragma solidity ^0.5.11;



 
interface ControllerInterface {

     
    function mintReputation(uint256 _amount, address _to, address _avatar)
    external
    returns(bool);

     
    function burnReputation(uint256 _amount, address _from, address _avatar)
    external
    returns(bool);

     
    function mintTokens(uint256 _amount, address _beneficiary, address _avatar)
    external
    returns(bool);

   
    function registerScheme(address _scheme, bytes32 _paramsHash, bytes4 _permissions, address _avatar)
    external
    returns(bool);

     
    function unregisterScheme(address _scheme, address _avatar)
    external
    returns(bool);

     
    function unregisterSelf(address _avatar) external returns(bool);

     
    function addGlobalConstraint(address _globalConstraint, bytes32 _params, address _avatar)
    external returns(bool);

     
    function removeGlobalConstraint (address _globalConstraint, address _avatar)
    external  returns(bool);

   
    function upgradeController(address _newController, Avatar _avatar)
    external returns(bool);

     
    function genericCall(address _contract, bytes calldata _data, Avatar _avatar, uint256 _value)
    external
    returns(bool, bytes memory);

   
    function sendEther(uint256 _amountInWei, address payable _to, Avatar _avatar)
    external returns(bool);

     
    function externalTokenTransfer(IERC20 _externalToken, address _to, uint256 _value, Avatar _avatar)
    external
    returns(bool);

     
    function externalTokenTransferFrom(
    IERC20 _externalToken,
    address _from,
    address _to,
    uint256 _value,
    Avatar _avatar)
    external
    returns(bool);

     
    function externalTokenApproval(IERC20 _externalToken, address _spender, uint256 _value, Avatar _avatar)
    external
    returns(bool);

     
    function metaData(string calldata _metaData, Avatar _avatar) external returns(bool);

     
    function getNativeReputation(address _avatar)
    external
    view
    returns(address);

    function isSchemeRegistered( address _scheme, address _avatar) external view returns(bool);

    function getSchemeParameters(address _scheme, address _avatar) external view returns(bytes32);

    function getGlobalConstraintParameters(address _globalConstraint, address _avatar) external view returns(bytes32);

    function getSchemePermissions(address _scheme, address _avatar) external view returns(bytes4);

     
    function globalConstraintsCount(address _avatar) external view returns(uint, uint);

    function isGlobalConstraintRegistered(address _globalConstraint, address _avatar) external view returns(bool);
}

 

pragma solidity ^0.5.11;

 


contract Agreement {

    bytes32 private agreementHash;

    modifier onlyAgree(bytes32 _agreementHash) {
        require(_agreementHash == agreementHash, "Sender must send the right agreementHash");
        _;
    }

     
    function getAgreementHash() external  view returns(bytes32)
    {
        return agreementHash;
    }

     
    function setAgreementHash(bytes32 _agreementHash) internal
    {
        require(agreementHash == bytes32(0), "Can not set agreement twice");
        agreementHash = _agreementHash;
    }


}

 

pragma solidity ^0.5.11;





 


contract Auction4Reputation is Agreement {
    using SafeMath for uint256;
    using SafeERC20 for address;

    event Bid(address indexed _bidder, uint256 indexed _auctionId, uint256 _amount);
    event Redeem(uint256 indexed _auctionId, address indexed _beneficiary, uint256 _amount);

    struct Auction {
        uint256 totalBid;
         
        mapping(address=>uint) bids;
    }

     
    mapping(uint=>Auction) public auctions;

    Avatar public avatar;
    uint256 public reputationRewardLeft;
    uint256 public auctionsEndTime;
    uint256 public auctionsStartTime;
    uint256 public numberOfAuctions;
    uint256 public auctionReputationReward;
    uint256 public auctionPeriod;
    uint256 public redeemEnableTime;
    IERC20 public token;
    address public wallet;

     
    function initialize(
        Avatar _avatar,
        uint256 _auctionReputationReward,
        uint256 _auctionsStartTime,
        uint256 _auctionPeriod,
        uint256 _numberOfAuctions,
        uint256 _redeemEnableTime,
        IERC20 _token,
        address _wallet,
        bytes32 _agreementHash )
    external
    {
        require(avatar == Avatar(0), "can be called only one time");
        require(_avatar != Avatar(0), "avatar cannot be zero");
        require(_numberOfAuctions > 0, "number of auctions cannot be zero");
         
        require(_auctionPeriod > 15, "auctionPeriod should be > 15");
        auctionPeriod = _auctionPeriod;
        auctionsEndTime = _auctionsStartTime + _auctionPeriod.mul(_numberOfAuctions);
        require(_redeemEnableTime >= auctionsEndTime, "_redeemEnableTime >= auctionsEndTime");
        token = _token;
        avatar = _avatar;
        auctionsStartTime = _auctionsStartTime;
        numberOfAuctions = _numberOfAuctions;
        wallet = _wallet;
        auctionReputationReward = _auctionReputationReward;
        reputationRewardLeft = _auctionReputationReward.mul(_numberOfAuctions);
        redeemEnableTime = _redeemEnableTime;
        super.setAgreementHash(_agreementHash);
    }

     
    function redeem(address _beneficiary, uint256 _auctionId) public returns(uint256 reputation) {
         
        require(now > redeemEnableTime, "now > redeemEnableTime");
        Auction storage auction = auctions[_auctionId];
        uint256 bid = auction.bids[_beneficiary];
        require(bid > 0, "bidding amount should be > 0");
        auction.bids[_beneficiary] = 0;
        uint256 repRelation = bid.mul(auctionReputationReward);
        reputation = repRelation.div(auction.totalBid);
         
        reputationRewardLeft = reputationRewardLeft.sub(reputation);
        require(
        ControllerInterface(avatar.owner())
        .mintReputation(reputation, _beneficiary, address(avatar)), "mint reputation should succeed");
        emit Redeem(_auctionId, _beneficiary, reputation);
    }

     
    function bid(uint256 _amount, uint256 _auctionId, bytes32 _agreementHash)
    public
    onlyAgree(_agreementHash)
    returns(uint256 auctionId)
    {
        require(_amount > 0, "bidding amount should be > 0");
         
        require(now < auctionsEndTime, "bidding should be within the allowed bidding period");
         
        require(now >= auctionsStartTime, "bidding is enable only after bidding auctionsStartTime");
        address(token).safeTransferFrom(msg.sender, address(this), _amount);
         
        auctionId = (now - auctionsStartTime) / auctionPeriod;
        require(auctionId == _auctionId, "auction is not active");
        Auction storage auction = auctions[auctionId];
        auction.totalBid = auction.totalBid.add(_amount);
        auction.bids[msg.sender] = auction.bids[msg.sender].add(_amount);
        emit Bid(msg.sender, auctionId, _amount);
    }

     
    function transferToWallet() public {
       
        require(now > auctionsEndTime, "now > auctionsEndTime");
        uint256 tokenBalance = token.balanceOf(address(this));
        address(token).safeTransfer(wallet, tokenBalance);
    }

     
    function getBid(address _bidder, uint256 _auctionId) public view returns(uint256) {
        return auctions[_auctionId].bids[_bidder];
    }

}