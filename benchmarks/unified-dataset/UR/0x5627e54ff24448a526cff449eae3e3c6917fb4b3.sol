 

pragma solidity ^0.4.24;



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

contract iHOME is Ownable {
  using SafeMath for uint256;

  event Transfer(address indexed from,address indexed to,uint256 _tokenId);
  event Approval(address indexed owner,address indexed approved,uint256 _tokenId);



  string public constant symbol = "iHOME";
  string public constant name = "iHOME Credits";
  uint8 public decimals = 18;

  uint256 public totalSupply = 1000000000000 * 10 ** uint256(decimals);


  mapping(address => uint256) balances;
  mapping(address => mapping (address => uint256)) allowed;





  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }


  constructor() public {
    balances[msg.sender] = totalSupply;
  }


  function approve(address _spender, uint256 _amount) public returns (bool success) {
    allowed[msg.sender][_spender] = _amount;
    emit   Approval(msg.sender, _spender, _amount);
    return true;
  }

  function allowance(address _owner, address _spender ) public view returns (uint256) {
    return allowed[_owner][_spender];
  }


  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool)
  {
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
      emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
      return true;
    }

    function decreaseApproval(address _spender,uint256 _subtractedValue) public returns (bool)
    {
      uint256 oldValue = allowed[msg.sender][_spender];
      if (_subtractedValue >= oldValue) {
        allowed[msg.sender][_spender] = 0;
        } else {
          allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
      }

    }