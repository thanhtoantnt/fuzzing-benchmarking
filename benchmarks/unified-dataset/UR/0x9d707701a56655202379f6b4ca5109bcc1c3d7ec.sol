 

pragma solidity ^ 0.5 .11;


library SafeMath {
     
    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

     
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

     
    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

     
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
         
        require(b > 0, errorMessage);
        uint256 c = a / b;
         

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns(uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

     
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
contract Context {
     
     
    constructor() internal {}
     

    function _msgSender() internal view returns(address) {
        return msg.sender;
    }

    function _msgData() internal view returns(bytes memory) {
        this;  
        return msg.data;
    }
}


 
contract Ownable is Context {
    address payable public _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }


     
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

     
    function isOwner() public view returns(bool) {
        return _msgSender() == _owner;
    }


     
    function transferOwnership(address payable newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address payable newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}


 
contract ERC20Basic {
    uint256 public totalSupply;

    function balanceOf(address account) external view returns(uint256);

    function transfer(address recipient, uint256 amount) external returns(bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


 
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns(uint256);

    function transferFrom(address from, address to, uint256 value) public returns(bool);

    function approve(address spender, uint256 value) public returns(bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


 
contract STAKDStandard {
    uint256 public stakeStartTime;
    uint256 public stakeMinAge;
    uint256 public stakeMaxAge;

    function mint() public returns(bool);

    function coinAge() public view returns(uint256);

    function annualInterest() public view returns(uint256);
    event Mint(address indexed _address, uint _reward);
}
contract ForeignToken {
    function balanceOf(address _owner) view public returns(uint256);

    function transfer(address _to, uint256 _value) public returns(bool);
}


contract STAKDToken is ERC20, STAKDStandard, Ownable {
    using SafeMath
    for uint256;

    string public name = "STAKD";
    string public symbol = "SKD";
    uint public decimals = 18;

    uint public chainStartTime;  
    uint public chainStartBlockNumber;  
    uint public stakeStartTime;  
    uint public stakeMinAge = 2 days;  
    uint public stakeMaxAge = 90 days;  
    uint public maxMintProofOfStake = 10 ** 17;  

    uint public totalSupply;
    uint public maxTotalSupply;
    uint public totalInitialSupply;

    address public treasury;

    struct transferInStruct {
        uint128 amount;
        uint64 time;
    }


    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping(address => transferInStruct[]) transferIns;

    event TreasuryChange(address caller, address treasury);
    event Burn(address indexed burner, uint256 value);

     
    modifier onlyPayloadSize(uint size) {
        require(msg.data.length >= size + 4);
        _;
    }

    modifier onlyTreasury() {
        require(msg.sender == treasury);
        _;
    }


    modifier canPoSMint() {
        require(totalSupply < maxTotalSupply);
        _;
    }

    function getTokenBalance(address tokenAddress, address who) view public returns(uint) {
        ForeignToken t = ForeignToken(tokenAddress);
        uint bal = t.balanceOf(who);
        return bal;
    }

    function depositETH() public payable {
        require(msg.value > 0);
    }

    function() external payable {
        depositETH();
    }


    function withdraw() onlyOwner public {

        _owner.transfer(address(this).balance);
    }

    function withdrawForeignTokens(address _tokenContract) onlyOwner public returns(bool) {
        ForeignToken token = ForeignToken(_tokenContract);
        uint256 amount = token.balanceOf(address(this));
        return token.transfer(_owner, amount);
    }


    constructor(address _treasury) public payable {
        maxTotalSupply = 10 ** 25;  
        totalInitialSupply = 10 ** 24;  

        chainStartTime = now;
        chainStartBlockNumber = block.number;

        treasury = _treasury;
        balances[msg.sender] = totalInitialSupply;
        totalSupply = totalInitialSupply;
    }

    function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) public returns(bool) {
        if (msg.sender == _to) return mint();
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        if (transferIns[msg.sender].length > 0) delete transferIns[msg.sender];
        uint64 _now = uint64(now);
        transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]), _now));
        transferIns[_to].push(transferInStruct(uint128(_value), _now));
        return true;
    }

    function changeTreasury(address _treasury) public onlyTreasury returns(bool) {
        treasury = _treasury;
        emit TreasuryChange(msg.sender, treasury);
        return true;
    }

    function balanceOf(address _owner) public view returns(uint256 balance) {
        return balances[_owner];
    }

    function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3 * 32) public returns(bool) {
        require(_to != address(0));

        uint256 _allowance = allowed[_from][msg.sender];

         
         

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        emit Transfer(_from, _to, _value);
        if (transferIns[_from].length > 0) delete transferIns[_from];
        uint64 _now = uint64(now);
        transferIns[_from].push(transferInStruct(uint128(balances[_from]), _now));
        transferIns[_to].push(transferInStruct(uint128(_value), _now));
        return true;
    }

    function approve(address _spender, uint256 _value) public returns(bool) {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns(uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function mint() canPoSMint public returns(bool) {
        if (balances[msg.sender] <= 0) return false;
        if (transferIns[msg.sender].length <= 0) return false;

        uint reward = getProofOfStakeReward(msg.sender);
        if (reward <= 0) return false;

        uint senderReward = (reward * 90).div(100);  
        uint treasuryReward = reward - senderReward;

        totalSupply = totalSupply.add(reward);
        balances[msg.sender] = balances[msg.sender].add(senderReward);
        balances[treasury] = balances[treasury].add(treasuryReward);

        delete transferIns[msg.sender];
        transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]), uint64(now)));

        emit Mint(msg.sender, reward);
        return true;
    }

    function getBlockNumber() public view returns(uint blockNumber) {
        blockNumber = block.number.sub(chainStartBlockNumber);
    }

    function coinAge() public view returns(uint myCoinAge) {
        myCoinAge = getCoinAge(msg.sender, now);
    }

    function annualInterest() public view returns(uint interest) {
        uint _now = now;
        interest = maxMintProofOfStake;
        if ((_now.sub(stakeStartTime)).div(365 days) == 0) {
            interest = (770 * maxMintProofOfStake).div(100);
        } else if ((_now.sub(stakeStartTime)).div(365 days) == 1) {
            interest = (435 * maxMintProofOfStake).div(100);
        }
    }

    function getProofOfStakeReward(address _address) internal view returns(uint) {
        require((now >= stakeStartTime) && (stakeStartTime > 0));

        uint _now = now;
        uint _coinAge = getCoinAge(_address, _now);
        if (_coinAge <= 0) return 0;

        uint interest = maxMintProofOfStake;
         
         
        if ((_now.sub(stakeStartTime)).div(365 days) == 0) {
             
            interest = (770 * maxMintProofOfStake).div(100);
        } else if ((_now.sub(stakeStartTime)).div(365 days) == 1) {
             
            interest = (435 * maxMintProofOfStake).div(100);
        }

        return (_coinAge * interest).div(365 * (10 ** decimals));
    }

    function getCoinAge(address _address, uint _now) internal view returns(uint _coinAge) {
        if (transferIns[_address].length <= 0) return 0;

        for (uint i = 0; i < transferIns[_address].length; i++) {
            if (_now < uint(transferIns[_address][i].time).add(stakeMinAge)) continue;

            uint nCoinSeconds = _now.sub(uint(transferIns[_address][i].time));
            if (nCoinSeconds > stakeMaxAge) nCoinSeconds = stakeMaxAge;

            _coinAge = _coinAge.add(uint(transferIns[_address][i].amount) * nCoinSeconds.div(1 days));
        }
    }

    function ownerSetStakeStartTime(uint timestamp) public onlyOwner {
        require((stakeStartTime <= 0) && (timestamp >= chainStartTime));
        stakeStartTime = timestamp;
    }

    function ownerBurnToken(uint _value) public onlyOwner {
        require(_value > 0);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        delete transferIns[msg.sender];
        transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]), uint64(now)));

        totalSupply = totalSupply.sub(_value);
        totalInitialSupply = totalInitialSupply.sub(_value);
        maxTotalSupply = maxTotalSupply.sub(_value * 10);

        emit Burn(msg.sender, _value);
    }

     
    function batchTransfer(address[] memory _recipients, uint[] memory _values) public onlyOwner returns(bool) {
        require(_recipients.length > 0 && _recipients.length == _values.length);

        uint total = 0;
        for (uint i = 0; i < _values.length; i++) {
            total = total.add(_values[i]);
        }
        require(total <= balances[msg.sender]);

        uint64 _now = uint64(now);
        for (uint j = 0; j < _recipients.length; j++) {
            balances[_recipients[j]] = balances[_recipients[j]].add(_values[j]);
            transferIns[_recipients[j]].push(transferInStruct(uint128(_values[j]), _now));
            emit Transfer(msg.sender, _recipients[j], _values[j]);
        }

        balances[msg.sender] = balances[msg.sender].sub(total);
        if (transferIns[msg.sender].length > 0) delete transferIns[msg.sender];
        if (balances[msg.sender] > 0) transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]), _now));

        return true;
    }
}