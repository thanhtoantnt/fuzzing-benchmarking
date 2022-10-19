 

pragma solidity ^0.4.13;

contract ApproveAndCallReceiver {
    function receiveApproval(
        address _from, 
        uint256 _amount, 
        address _token, 
        bytes _data
    );
}

contract Controlled {
     
     
    modifier onlyController { 
        require(msg.sender == controller); 
        _; 
    }

     
    address public controller;

    function Controlled() {
       
      controller = msg.sender;
       
    }

     
     
    function changeController(address _newController) onlyController {
        controller = _newController;
    }
}

contract ERC20Token {
     
     
    function totalSupply() constant returns (uint256 balance);

     
     
    function balanceOf(address _owner) constant returns (uint256 balance);

     
     
     
     
    function transfer(address _to, uint256 _value) returns (bool success);

     
     
     
     
     
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

     
     
     
     
    function approve(address _spender, uint256 _value) returns (bool success);

     
     
     
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract TNBTokenI is ERC20Token, Controlled {

    string public name;                 
    uint8 public decimals;              
    string public symbol;               
    string public version = "MMT_0.1";  

 
 
 

     
     
     
     
     
     
     
    function approveAndCall(
        address _spender,
        uint256 _amount,
        bytes _extraData
    ) returns (bool success);

 
 
 

     
     
     
     
    function balanceOfAt(
        address _owner,
        uint _blockNumber
    ) constant returns (uint);

     
     
     
    function totalSupplyAt(uint _blockNumber) constant returns(uint);

 
 
 

     
     
     
     
    function generateTokens(address _owner, uint _amount) returns (bool);


     
     
     
     
    function destroyTokens(address _owner, uint _amount) returns (bool);

 
 
 

     
     
    function enableTransfers(bool _transfersEnabled);

 
 
 

     
     
     
     
    function claimTokens(address _token);

 
 
 

    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
}

contract TNBToken is TNBTokenI {

    string public name;                 
    uint8 public decimals;              
    string public symbol;               
    string public version = "TNB_0.2";  
    uint256 public maximumTNB = 60 * 10**8 * 10**18;
     
    struct Checkpoint {

         
        uint128 fromBlock;

         
        uint128 value;
    }

     
    uint public creationBlock;

     
     
     
    mapping (address => Checkpoint[]) balances;

     
    mapping (address => uint256) frozen;
    bool public isFrozen = false;
     
    uint[] forbidenEndTime;

     
    mapping (address => mapping (address => uint256)) allowed;

     
    Checkpoint[] totalSupplyHistory;

     
    bool public transfersEnabled;


 
 
 

     
     
     
     
     
     
     
     
     
     
     
     
     
    function TNBToken(
         
         
         
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    ) {
        name = _tokenName;                                  
        decimals = _decimalUnits;                           
        symbol = _tokenSymbol;                              
        transfersEnabled = _transfersEnabled;
        creationBlock = block.number;
    }

 
 
 

     
     
     
     
    function transfer(address _to, uint256 _amount) returns (bool success) {
        require(transfersEnabled);
        return doTransfer(msg.sender, _to, _amount);
    }

     
     
     
     
     
     
    function transferFrom(address _from, address _to, uint256 _amount) returns (bool success) {

         
         
         
         
        if (msg.sender != controller) {
            require(transfersEnabled);

             
            if (allowed[_from][msg.sender] < _amount) {
                return false;
            }
            allowed[_from][msg.sender] -= _amount;
        }
        return doTransfer(_from, _to, _amount);
    }

     
     
     
     
     
     
    function doTransfer(address _from, address _to, uint _amount) internal returns(bool) {

        if (_amount == 0) {
            return true;
        }

         

         
        require((_to != 0) && (_to != address(this)));

         
         
        var previousBalanceFrom = balanceOfAt(_from, block.number);
        if (previousBalanceFrom < _amount) {
            return false;
        }

         
        if (isContract(controller)) {
            bool onTransfer = TokenController(controller).onTransfer(_from, _to, _amount);
            require(onTransfer);
        }

         
         
        updateValueAtNow(balances[_from], previousBalanceFrom - _amount);

         
         
        var previousBalanceTo = balanceOfAt(_to, block.number);
        require(previousBalanceTo + _amount >= previousBalanceTo);  
        updateValueAtNow(balances[_to], previousBalanceTo + _amount);

         
        Transfer(_from, _to, _amount);

        return true;
    }

     
     
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balanceOfAt(_owner, block.number);
    }

     
     
     
     
     
     
    function approve(address _spender, uint256 _amount) returns (bool success) {
        require(transfersEnabled);

         
         
         
         
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

         
        if (isContract(controller)) {
            bool onApprove = TokenController(controller).onApprove(msg.sender, _spender, _amount);
            require(onApprove);
        }

        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

     
     
     
     
     
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

     
     
     
     
     
     
     
    function approveAndCall(address _spender, uint256 _amount, bytes _extraData) returns (bool success) {
        require(approve(_spender, _amount));

        ApproveAndCallReceiver(_spender).receiveApproval(
            msg.sender,
            _amount,
            this,
            _extraData
        );

        return true;
    }

     
     
    function totalSupply() constant returns (uint) {
        return totalSupplyAt(block.number);
    }

 
 
 

     
     
     
     
    function balanceOfAt(address _owner, uint _blockNumber) constant returns (uint) {

         
         
         
         
         
        if ((balances[_owner].length == 0) || (balances[_owner][0].fromBlock > _blockNumber)) {
             
             
             
                 
                return 0;
             

         
        } else {
            return getValueAt(balances[_owner], _blockNumber);
        }
    }

     
     
     
    function totalSupplyAt(uint _blockNumber) constant returns(uint) {

         
         
         
         
         
        if ((totalSupplyHistory.length == 0) || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
             
             
             
                return 0;
             

         
        } else {
            return getValueAt(totalSupplyHistory, _blockNumber);
        }
    }

 
 
 

     
     
     
     
    function generateTokens(address _owner, uint _amount) onlyController returns (bool) {
        uint curTotalSupply = totalSupply();
        uint256 newTotalSupply = curTotalSupply + _amount;
        require(newTotalSupply >= curTotalSupply);  
        require(newTotalSupply <= maximumTNB);
        uint previousBalanceTo = balanceOf(_owner);
        require(previousBalanceTo + _amount >= previousBalanceTo);  
        updateValueAtNow(totalSupplyHistory, newTotalSupply);
        updateValueAtNow(balances[_owner], previousBalanceTo + _amount);
        Transfer(0, _owner, _amount);
        return true;
    }

     
     
     
     
    function destroyTokens(address _owner, uint _amount) onlyController returns (bool) {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply >= _amount);
        uint previousBalanceFrom = balanceOf(_owner);
        require(previousBalanceFrom >= _amount);
        updateValueAtNow(totalSupplyHistory, curTotalSupply - _amount);
        updateValueAtNow(balances[_owner], previousBalanceFrom - _amount);
        Transfer(_owner, 0, _amount);
        return true;
    }

 
 
 

     
     
    function enableTransfers(bool _transfersEnabled) onlyController {
        transfersEnabled = _transfersEnabled;
    }

 
 
 

     
     
     
     
    function getValueAt(Checkpoint[] storage checkpoints, uint _block) constant internal returns (uint) {
        if (checkpoints.length == 0) {
            return 0;
        }

         
        if (_block >= checkpoints[checkpoints.length-1].fromBlock)
            return checkpoints[checkpoints.length-1].value;
        if (_block < checkpoints[0].fromBlock) {
            return 0;
        }

         
        uint min = 0;
        uint max = checkpoints.length-1;
        while (max > min) {
            uint mid = (max + min + 1) / 2;
            if (checkpoints[mid].fromBlock<=_block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

     
     
     
     
    function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value) internal {
        if ((checkpoints.length == 0) || (checkpoints[checkpoints.length - 1].fromBlock < block.number)) {
            Checkpoint storage newCheckPoint = checkpoints[checkpoints.length++];
            newCheckPoint.fromBlock = uint128(block.number);
            newCheckPoint.value = uint128(_value);
        } else {
            Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
            oldCheckPoint.value = uint128(_value);
        }
    }

     
     
     
    function isContract(address _addr) constant internal returns(bool) {
        uint size;
        if (_addr == 0) {
            return false;
        }
        assembly {
            size := extcodesize(_addr)
        }
        return size>0;
    }

     
    function min(uint a, uint b) internal returns (uint) {
        return a < b ? a : b;
    }

     
     
     
    function ()  payable {
         
        require(isContract(controller));
        bool proxyPayment = TokenController(controller).proxyPayment.value(msg.value)(msg.sender);
        require(proxyPayment);
    }

 
 
 

     
     
     
     
    function claimTokens(address _token) onlyController {
        if (_token == 0x0) {
            controller.transfer(this.balance);
            return;
        }

        TNBToken token = TNBToken(_token);
        uint balance = token.balanceOf(this);
        token.transfer(controller, balance);
        ClaimedTokens(_token, controller, balance);
    }

 
 
 
    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
    );
}

contract TokenController {
     
     
     
    function proxyPayment(address _owner) payable returns(bool);

     
     
     
     
     
     
    function onTransfer(address _from, address _to, uint _amount) returns(bool);

     
     
     
     
     
     
    function onApprove(address _owner, address _spender, uint _amount) returns(bool);
}