 

pragma solidity ^0.4.24;

 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 
library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
     
     
     
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    return a / b;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

   
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

 
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

   
  modifier onlyPayloadSize(uint size) {
     if(msg.data.length < size + 4) {
       revert();
     }
     _;
  }
  
  uint256 totalSupply_;

   
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

   
  function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

 
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


   
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    onlyPayloadSize(3 * 32)
    public
    returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

   
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

   
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

 
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


   
  constructor() public {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

   
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

   
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

 
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


   
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

   
  modifier whenPaused() {
    require(paused);
    _;
  }

   
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

   
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }

}

contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint _value) whenNotPaused public returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint _value) whenNotPaused public returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }    
    
}

contract UnionTokens is PausableToken {
    string public constant name = "UnionTokens";
    string public constant symbol = "UNION";
    uint8 public constant decimals = 6;

    address public team1 = address(0x843Cd7E69185cDd4d8F75Bf5E7feB289C7F5723D);
    address public team2 = address(0xb05F50E620f36A17687339559d3d1f0f9E65F641);
    address public foundation = address(0x9871ed8Fd953E58F2D47a5D8618D8EBF2F49bb51);
    address public partner = address(0x5548fF44542Df0013dffE60B2B09eCa900131DBD);
    address public ido = address(0x6Ec9C85f330D58218C3d4001F32FD8f997BAE880);
    address public operate = address(0x39fdd5daD0971EB881025E9Da55dC84a104a56A6);
    
    constructor() public {
        totalSupply_ = 10 * (10 ** 8) * (10 ** uint256(decimals));	 
        balances[team1] = totalSupply_ * 15 / 100;					 
        balances[team2] = totalSupply_ * 5 / 100;				     
        balances[foundation] = totalSupply_ * 5 / 100;			     
        balances[partner] = totalSupply_ * 10 / 100;                 
        balances[ido] = totalSupply_ * 20 / 100;				     
        balances[operate] = totalSupply_ * 45 / 100;				 
        emit Transfer(address(0), team1, balances[team1]);
        emit Transfer(address(0), team2, balances[team2]);
        emit Transfer(address(0), foundation, balances[foundation]);
        emit Transfer(address(0), partner, balances[partner]);
        emit Transfer(address(0), ido, balances[ido]);
        emit Transfer(address(0), operate, balances[operate]);
    }

    function batchTransfer(address[] _receivers, uint _value) whenNotPaused public {
        uint cnt = _receivers.length;
        require(cnt>0);
        for(uint i=0; i<cnt; i++){
            address _to = _receivers[i];
            require(_to!=address(0) && _value<=balances[msg.sender]);
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);
            emit Transfer(msg.sender, _to, _value);
        }
    }
    
    function batchTransfers(address[] _receivers, uint[] _values) whenNotPaused public {
        uint cnt = _receivers.length;
        require(cnt>0 && cnt==_values.length);
        for(uint i=0; i<cnt; i++){
            address _to = _receivers[i];
            uint _value = _values[i];
            require(_to!=address(0) && _value<=balances[msg.sender]);
            balances[msg.sender] = balances[msg.sender].sub(_values[i]);
            balances[_to] = balances[_to].add(_values[i]);
            emit Transfer(msg.sender, _to, _values[i]);
        }
    }

	 
	function () external {
		revert();
	}
 
}