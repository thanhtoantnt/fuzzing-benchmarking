 

pragma solidity 0.4.20;

 
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
    uint256 c = a / b;
     
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20 {
  function totalSupply()public view returns (uint total_Supply);
  function balanceOf(address who)public view returns (uint256);
  function allowance(address owner, address spender)public view returns (uint);
  function transferFrom(address from, address to, uint value)public returns (bool ok);
  function approve(address spender, uint value)public returns (bool ok);
  function transfer(address to, uint value)public returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}


contract SPCoin is ERC20
{ using SafeMath for uint256;
     
    string public constant name = "SP Coin";

     
    string public constant symbol = "SPS";
    uint8 public constant decimals = 18;
    uint public _totalsupply = 2500000000 *10 ** 18;  
    address public owner;
    uint256 constant public _price_tokn = 20000 ; 
    uint256 no_of_tokens;
    uint256 bonus_token;
    uint256 total_token;
    bool stopped = false;
    uint256 public pre_startdate;
    uint256 public ico_startdate;
    uint256 pre_enddate;
    uint256 ico_enddate;
    uint256 maxCap_PRE;
    uint256 maxCap_ICO;
    bool public icoRunningStatus = true;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    address ethFundMain = 0x649BbCF5625E78f8A1dE1AE07d9D5E3E0fDCa932;  
    mapping (address => bool) public whitelisted;
    uint256 public Numtokens;
    uint256 public bonustokn;
    uint256 public ethreceived;
    uint constant public minimumInvestment = 1 ether;  
    uint bonusCalculationFactor;
    uint public bonus;
    uint x ;
    
     enum Stages {
        NOTSTARTED,
        PREICO,
        ICO,
        ENDED
    }
    Stages public stage;
    
    modifier atStage(Stages _stage) {
        if (stage != _stage)
             
            revert();
        _;
    }
    
     modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }
  
    function SPCoin() public
    {
        owner = msg.sender;
        balances[owner] = 1250000000 *10 ** 18;   
        stage = Stages.NOTSTARTED;
        Transfer(0, owner, balances[owner]);
    }
  
    function () public payable 
    {
        require(stage != Stages.ENDED && msg.value >= minimumInvestment);
        require(!stopped && msg.sender != owner);
        require(whitelisted[msg.sender]);
    if( stage == Stages.PREICO && now <= pre_enddate )
        {  
            no_of_tokens =(msg.value).mul(_price_tokn);
            ethreceived = ethreceived.add(msg.value);
            bonus= bonuscalpre();
            bonus_token = ((no_of_tokens).mul(bonus)).div(100);   
            total_token = no_of_tokens + bonus_token;
            Numtokens= Numtokens.add(no_of_tokens);
             bonustokn= bonustokn.add(bonus_token);
            transferTokens(msg.sender,total_token);
         }
         
         
    else
    if(stage == Stages.ICO && now <= ico_enddate )
        {
             
            no_of_tokens =((msg.value).mul(_price_tokn));
            ethreceived = ethreceived.add(msg.value);
          bonus= bonuscalico(msg.value);
            bonus_token = ((no_of_tokens).mul(bonus)).div(100);   
            total_token = no_of_tokens + bonus_token;
           Numtokens= Numtokens.add(no_of_tokens);
             bonustokn= bonustokn.add(bonus_token);
            transferTokens(msg.sender,total_token);
        
        }
    else {
            revert();
        }
       
    }

    
     
     function bonuscalpre() private returns (uint256 cp)
        {
          uint bon = 30;
             bonusCalculationFactor = (block.timestamp.sub(pre_startdate)).div(86400);  
            if(bonusCalculationFactor == 0)
            {
                bon = 30;
            }
          else if(bonusCalculationFactor >= 15)
            {
              bon = 2;
            }
            else{
                 bon -= bonusCalculationFactor* 2;
            }
            return bon;
          
        }
         
  function bonuscalico(uint256 y) private returns (uint256 cp){
     x = y/(10**18);
     uint bon;
      if (x>=2 && x <5){
          bon = 1;
      }
      else  if (x>=5 && x <15){
          bon = 2;
      }
      else  if (x>=15 && x <25){
          bon = 3;
      }
      else  if (x>=25 && x <40){
          bon = 4;
      }
      else  if (x>=40 && x <60){
          bon = 5;
      }
      else  if (x>=60 && x <70){
          bon = 6;
      }
      else  if (x>=70 && x <80){
          bon = 7;
      }
      else  if (x>=80 && x <90){
          bon = 8;
      }
     else  if (x>=90 && x <100){
          bon = 9;
      }
      else  if (x>=100){
          bon = 10;
      }
      else{
      bon = 0;
      }
      
      return bon;
  }
    
     function start_PREICO() public onlyOwner atStage(Stages.NOTSTARTED)
      {
          stage = Stages.PREICO;
          stopped = false;
          maxCap_PRE = 350000000 * 10 ** 18;   
          balances[address(this)] = maxCap_PRE;
          pre_startdate = now;
          pre_enddate = now + 20 days;  
          Transfer(0, address(this), balances[address(this)]);
          }
    
    
      function start_ICO() public onlyOwner atStage(Stages.PREICO)
      {
          stage = Stages.ICO;
          stopped = false;
          maxCap_ICO = 900000000 * 10 **18;    
          balances[address(this)] = balances[address(this)].add(maxCap_ICO);
         ico_startdate = now;
         ico_enddate = now + 25 days;  
          Transfer(0, address(this), balances[address(this)]);
          }
          
   
     
    function StopICO() external onlyOwner  {
        stopped = true;
      
    }

     
    function releaseICO() external onlyOwner
    {
        stopped = false;
      
    }
    
       
    function setWhiteListAddresses(address _investor) external onlyOwner{
           whitelisted[_investor] = true;
       }
       
      
     function end_ICO() external onlyOwner atStage(Stages.ICO)
     {
         require(now > ico_enddate);
         stage = Stages.ENDED;
         icoRunningStatus= false;
        _totalsupply = (_totalsupply).sub(balances[address(this)]);
         balances[address(this)] = 0;
         Transfer(address(this), 0 , balances[address(this)]);
         
     }
       
        function fixSpecications(bool RunningStatus ) external onlyOwner
        {
           icoRunningStatus = RunningStatus;
        }
     
     
     function totalSupply() public view returns (uint256 total_Supply) {
         total_Supply = _totalsupply;
     }
    
     
     function balanceOf(address _owner)public view returns (uint256 balance) {
         return balances[_owner];
     }
    
     
      
      
      
      
      
     function transferFrom( address _from, address _to, uint256 _amount )public returns (bool success) {
     require( _to != 0x0);
     require(balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount >= 0);
     balances[_from] = (balances[_from]).sub(_amount);
     allowed[_from][msg.sender] = (allowed[_from][msg.sender]).sub(_amount);
     balances[_to] = (balances[_to]).add(_amount);
     Transfer(_from, _to, _amount);
     return true;
         }
    
    
      
     function approve(address _spender, uint256 _amount)public returns (bool success) {
         require(!icoRunningStatus);
         require( _spender != 0x0);
         allowed[msg.sender][_spender] = _amount;
         Approval(msg.sender, _spender, _amount);
         return true;
     }
  
     function allowance(address _owner, address _spender)public view returns (uint256 remaining) {
         require( _owner != 0x0 && _spender !=0x0);
         return allowed[_owner][_spender];
   }
     
     function transfer(address _to, uint256 _amount) public returns (bool success) {
         if(icoRunningStatus && msg.sender == owner)
         {
            require(balances[owner] >= _amount && _amount >= 0 && balances[_to] + _amount > balances[_to]);
            balances[owner] = (balances[owner]).sub(_amount);
            balances[_to] = (balances[_to]).add(_amount);
            Transfer(owner, _to, _amount);
            return true;
         }
       
         else if(!icoRunningStatus)
         {
            require(balances[msg.sender] >= _amount && _amount >= 0 && balances[_to] + _amount > balances[_to]);
            balances[msg.sender] = (balances[msg.sender]).sub(_amount);
            balances[_to] = (balances[_to]).add(_amount);
            Transfer(msg.sender, _to, _amount);
            return true;
         } 
         
         else 
         revert();
     }
  

           
    function transferTokens(address _to, uint256 _amount) private returns(bool success) {
        require( _to != 0x0);       
        require(balances[address(this)] >= _amount && _amount > 0);
        balances[address(this)] = (balances[address(this)]).sub(_amount);
        balances[_to] = (balances[_to]).add(_amount);
        Transfer(address(this), _to, _amount);
        return true;
        }
    
 
    	 
	function transferOwnership(address newOwner)public onlyOwner
	{
	    balances[newOwner] = (balances[newOwner]).add(balances[owner]);
	    balances[owner] = 0;
	    owner = newOwner;
	}

    
    function drain() external onlyOwner {
        ethFundMain.transfer(this.balance);
    }
    
}