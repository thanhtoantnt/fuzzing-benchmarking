 

pragma solidity ^0.4.13;

  

 
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


 
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
     
    uint256 c = a / b;
     
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}



 
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

   
  function transfer(address _to, uint _value) public returns (bool) {
    require(_to != address(0));

     
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


 
contract StandardToken is ERC20, BasicToken {
    
     mapping (address => mapping (address => uint256)) allowed;

   
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    
    var _allowance = allowed[_from][msg.sender];

     
     

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }
  
     
  function approve(address _spender, uint256 _value) returns (bool) {

     
     
     
     
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

 
contract Ownable {
  address public owner;

   
  function Ownable() {
    owner = msg.sender;
  }


   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

}



  

contract FornicoinToken is StandardToken, Ownable {
  using SafeMath for uint256;

  string public constant name = "Fornicoin";
  string public constant symbol = "FXX";
  uint8 public constant decimals = 18;

   
  uint256 public constant MAX_SUPPLY = 100000000 * (10 ** uint256(decimals));
  
   
  address public admin;
  uint256 public teamTokens = 25000000 * (10 ** 18);
  
   
  uint256 public minBalanceForTxFee = 55000 * 3 * 10 ** 9 wei;  
   
  uint256 public sellPrice = 800; 
  
  event Refill(uint256 amount);
  
  modifier onlyAdmin() {
    require(msg.sender == admin);
    _;
  }

  function FornicoinToken(address _admin) {
    totalSupply = teamTokens;
    balances[msg.sender] = MAX_SUPPLY;
    admin =_admin;
  }
  
  function setSellPrice(uint256 _price) public onlyAdmin {
      require(_price >= 0);
       
      require(_price <= sellPrice);
      
      sellPrice = _price;
  }
  
   
  function updateTotalSupply(uint256 additions) onlyOwner {
      require(totalSupply.add(additions) <= MAX_SUPPLY);
      totalSupply += additions;
  }
  
  function setMinTxFee(uint256 _balance) public onlyAdmin {
      require(_balance >= 0);
       
      require(_balance > minBalanceForTxFee);
      
      minBalanceForTxFee = _balance;
  }
  
  function refillTxFeeMinimum() public payable onlyAdmin {
      Refill(msg.value);
  }
  
   
   
  function transfer(address _to, uint _value) public returns (bool) {
         
        require (_to != 0x0);
         
        require (balanceOf(_to) + _value > balanceOf(_to));
         
        if(msg.sender.balance < minBalanceForTxFee && 
        balances[msg.sender].sub(_value) >= minBalanceForTxFee * sellPrice && 
        this.balance >= minBalanceForTxFee){
            sellFXX((minBalanceForTxFee.sub(msg.sender.balance)) *                                 
                             sellPrice);
    	        }
         
        balances[msg.sender] = balances[msg.sender].sub(_value);
         
        balances[_to] = balances[_to].add(_value); 
         
        Transfer(msg.sender, _to, _value);
        return true;
    }

     
    function sellFXX(uint amount) internal returns (uint revenue){
         
        require(balanceOf(msg.sender) >= amount);  
         
        balances[admin] = balances[admin].add(amount);          
         
        balances[msg.sender] = balances[msg.sender].sub(amount);   
         
        revenue = amount / sellPrice;
        msg.sender.transfer(revenue);
         
        Transfer(msg.sender, this, amount); 
         
        return revenue;                                   
    }
}