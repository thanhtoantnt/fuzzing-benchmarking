 

pragma solidity ^0.4.24;
 
interface token {
    function transfer(address receiver, uint amount);
    function burn(uint256 _value) returns (bool);
    function balanceOf(address _address) returns (uint256);
}
contract owned {  
	address public owner;

	function owned() public {
	owner = msg.sender;
	}

	modifier onlyOwner {
	require(msg.sender == owner);
	_;
	}

	function transferOwnership(address newOwner) onlyOwner public {
	owner = newOwner;
	}
}

contract SafeMath {
     

    function safeMul(uint a, uint b) internal returns(uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeSub(uint a, uint b) internal returns(uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal returns(uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
        return c;
    }

}

contract Crowdsale is owned, SafeMath {
    address public beneficiary;
    uint public fundingGoal;
    uint public amountRaised;   
    uint public deadline;  
    uint public rate;  
    uint public tokenDecimals;
    token public tokenReward;  
    uint public tokensSold = 0;   
    uint public start;  
    uint public bonusEndDate;
    mapping(address => uint256) public balanceOf;   
    bool crowdsaleClosed = false;  

    event GoalReached(address beneficiary, uint capital);
    event FundTransfer(address backer, uint amount, bool isContribution);

     
    function Crowdsale( ) {
        beneficiary = 0xe579891b98a3f58e26c4b2edb54e22250899363c;
        rate = 250000;  
        tokenDecimals=8;
        fundingGoal = 7500000000 * (10 ** tokenDecimals); 
        start = 1536688800;  
        deadline = 1539356400;  
        bonusEndDate =1539356400;
        tokenReward = token(0x2DC5b9F85a5EcCC24A3abd396F9d0c43dF3D284c);  
    }    

     
      
    function () payable {
        uint amount = msg.value;   
        uint numTokens;  
        numTokens = getNumTokens(amount);    
        require(numTokens>0 && !crowdsaleClosed && now > start && now < deadline);
        balanceOf[msg.sender] = safeAdd(balanceOf[msg.sender], amount);
        amountRaised = safeAdd(amountRaised, amount);  
        tokensSold += numTokens;  
        tokenReward.transfer(msg.sender, numTokens);  
        beneficiary.transfer(amount);                
        FundTransfer(msg.sender, amount, true);
    }
     
    function getNumTokens(uint _value) internal returns(uint numTokens) {
        require(_value>=10000000000000000 * 1 wei);  
        numTokens = safeMul(_value,rate)/(10 ** tokenDecimals);  
        
        if(now <= bonusEndDate){
            if(_value>= 0.5 ether && _value< 5 * 1 ether){  
                numTokens += safeMul(numTokens,10)/100;
            }else if(_value>=1 * 1 ether){               
                numTokens += safeMul(numTokens,20)/100;
            }
        }

        return numTokens;
    }

    function changeBeneficiary(address newBeneficiary) onlyOwner {
        beneficiary = newBeneficiary;
    }

    modifier afterDeadline() { if (now >= deadline) _; }

     
    function checkGoalReached() afterDeadline {
        require(msg.sender == owner);  
        if (tokensSold >=fundingGoal){
            GoalReached(beneficiary, amountRaised);
        }
        tokenReward.burn(tokenReward.balanceOf(this));  
        crowdsaleClosed = true;  
    }



}