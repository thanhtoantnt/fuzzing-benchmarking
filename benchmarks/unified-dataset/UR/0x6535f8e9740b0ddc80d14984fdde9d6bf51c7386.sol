 

pragma solidity 0.4.23;

contract AssetInterface {
    function _performTransferWithReference(address _to, uint _value, string _reference, address _sender) public returns(bool);
    function _performTransferToICAPWithReference(bytes32 _icap, uint _value, string _reference, address _sender) public returns(bool);
    function _performApprove(address _spender, uint _value, address _sender) public returns(bool);
    function _performTransferFromWithReference(address _from, address _to, uint _value, string _reference, address _sender) public returns(bool);
    function _performTransferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference, address _sender) public returns(bool);
    function _performGeneric(bytes, address) public payable {
        revert();
    }
}

contract ERC20Interface {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed from, address indexed spender, uint256 value);

    function totalSupply() public view returns(uint256 supply);
    function balanceOf(address _owner) public view returns(uint256 balance);
    function transfer(address _to, uint256 _value) public returns(bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool success);
    function approve(address _spender, uint256 _value) public returns(bool success);
    function allowance(address _owner, address _spender) public view returns(uint256 remaining);

    function decimals() public view returns(uint8);
}

contract AssetProxy is ERC20Interface {
    function _forwardApprove(address _spender, uint _value, address _sender) public returns(bool);
    function _forwardTransferFromWithReference(address _from, address _to, uint _value, string _reference, address _sender) public returns(bool);
    function _forwardTransferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference, address _sender) public returns(bool);
}

contract Bytes32 {
    function _bytes32(string _input) internal pure returns(bytes32 result) {
        assembly {
            result := mload(add(_input, 32))
        }
    }
}

contract ReturnData {
    function _returnReturnData(bool _success) internal pure {
        assembly {
            let returndatastart := 0
            returndatacopy(returndatastart, 0, returndatasize)
            switch _success case 0 { revert(returndatastart, returndatasize) } default { return(returndatastart, returndatasize) }
        }
    }

    function _assemblyCall(address _destination, uint _value, bytes _data) internal returns(bool success) {
        assembly {
            success := call(gas, _destination, _value, add(_data, 32), mload(_data), 0, 0)
        }
    }
}

 
contract Asset is AssetInterface, Bytes32, ReturnData {
     
    AssetProxy public proxy;

     
    modifier onlyProxy() {
        if (proxy == msg.sender) {
            _;
        }
    }

     
    function init(AssetProxy _proxy) public returns(bool) {
        if (address(proxy) != 0x0) {
            return false;
        }
        proxy = _proxy;
        return true;
    }

     
    function _performTransferWithReference(address _to, uint _value, string _reference, address _sender) public onlyProxy() returns(bool) {
        if (isICAP(_to)) {
            return _transferToICAPWithReference(bytes32(_to) << 96, _value, _reference, _sender);
        }
        return _transferWithReference(_to, _value, _reference, _sender);
    }

     
    function _transferWithReference(address _to, uint _value, string _reference, address _sender) internal returns(bool) {
        return proxy._forwardTransferFromWithReference(_sender, _to, _value, _reference, _sender);
    }

     
    function _performTransferToICAPWithReference(bytes32 _icap, uint _value, string _reference, address _sender) public onlyProxy() returns(bool) {
        return _transferToICAPWithReference(_icap, _value, _reference, _sender);
    }

     
    function _transferToICAPWithReference(bytes32 _icap, uint _value, string _reference, address _sender) internal returns(bool) {
        return proxy._forwardTransferFromToICAPWithReference(_sender, _icap, _value, _reference, _sender);
    }

     
    function _performTransferFromWithReference(address _from, address _to, uint _value, string _reference, address _sender) public onlyProxy() returns(bool) {
        if (isICAP(_to)) {
            return _transferFromToICAPWithReference(_from, bytes32(_to) << 96, _value, _reference, _sender);
        }
        return _transferFromWithReference(_from, _to, _value, _reference, _sender);
    }

     
    function _transferFromWithReference(address _from, address _to, uint _value, string _reference, address _sender) internal returns(bool) {
        return proxy._forwardTransferFromWithReference(_from, _to, _value, _reference, _sender);
    }

     
    function _performTransferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference, address _sender) public onlyProxy() returns(bool) {
        return _transferFromToICAPWithReference(_from, _icap, _value, _reference, _sender);
    }

     
    function _transferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference, address _sender) internal returns(bool) {
        return proxy._forwardTransferFromToICAPWithReference(_from, _icap, _value, _reference, _sender);
    }

     
    function _performApprove(address _spender, uint _value, address _sender) public onlyProxy() returns(bool) {
        return _approve(_spender, _value, _sender);
    }

     
    function _approve(address _spender, uint _value, address _sender) internal returns(bool) {
        return proxy._forwardApprove(_spender, _value, _sender);
    }

     
    function _performGeneric(bytes _data, address _sender) public payable onlyProxy() {
        _generic(_data, msg.value, _sender);
    }

    modifier onlyMe() {
        if (this == msg.sender) {
            _;
        }
    }

     
    address public genericSender;
    function _generic(bytes _data, uint _value, address _msgSender) internal {
         
        require(genericSender == 0x0);
        genericSender = _msgSender;
        bool success = _assemblyCall(address(this), _value, _data);
        delete genericSender;
        _returnReturnData(success);
    }

     
    function _sender() internal view returns(address) {
        return this == msg.sender ? genericSender : msg.sender;
    }

     
    function transferToICAP(string _icap, uint _value) public returns(bool) {
        return transferToICAPWithReference(_icap, _value, '');
    }

    function transferToICAPWithReference(string _icap, uint _value, string _reference) public returns(bool) {
        return _transferToICAPWithReference(_bytes32(_icap), _value, _reference, _sender());
    }

    function transferFromToICAP(address _from, string _icap, uint _value) public returns(bool) {
        return transferFromToICAPWithReference(_from, _icap, _value, '');
    }

    function transferFromToICAPWithReference(address _from, string _icap, uint _value, string _reference) public returns(bool) {
        return _transferFromToICAPWithReference(_from, _bytes32(_icap), _value, _reference, _sender());
    }

    function isICAP(address _address) public pure returns(bool) {
        bytes32 a = bytes32(_address) << 96;
        if (a[0] != 'X' || a[1] != 'E') {
            return false;
        }
        if (a[2] < 48 || a[2] > 57 || a[3] < 48 || a[3] > 57) {
            return false;
        }
        for (uint i = 4; i < 20; i++) {
            uint char = uint(a[i]);
            if (char < 48 || char > 90 || (char > 57 && char < 65)) {
                return false;
            }
        }
        return true;
    }
}

contract Ambi2 {
    function claimFor(address _address, address _owner) public returns(bool);
    function hasRole(address _from, bytes32 _role, address _to) public view returns(bool);
    function isOwner(address _node, address _owner) public view returns(bool);
}

contract Ambi2Enabled {
    Ambi2 ambi2;

    modifier onlyRole(bytes32 _role) {
        if (address(ambi2) != 0x0 && ambi2.hasRole(this, _role, msg.sender)) {
            _;
        }
    }

     
    function setupAmbi2(Ambi2 _ambi2) public returns(bool) {
        if (address(ambi2) != 0x0) {
            return false;
        }

        ambi2 = _ambi2;
        return true;
    }
}

contract Ambi2EnabledFull is Ambi2Enabled {
     
    function setupAmbi2(Ambi2 _ambi2) public returns(bool) {
        if (address(ambi2) != 0x0) {
            return false;
        }
        if (!_ambi2.claimFor(this, msg.sender) && !_ambi2.isOwner(this, msg.sender)) {
            return false;
        }

        ambi2 = _ambi2;
        return true;
    }
}

contract AssetWithAmbi is Asset, Ambi2EnabledFull {
    modifier onlyRole(bytes32 _role) {
        if (address(ambi2) != 0x0 && (ambi2.hasRole(this, _role, _sender()))) {
            _;
        }
    }
}

 
contract AssetWithWhitelist is AssetWithAmbi {
    mapping(address => bool) public whitelist;
    uint public restrictionExpiraton;
    bool public restrictionRemoved;

    event Error(bytes32 _errorText);

    function allowTransferFrom(address _from) public onlyRole('admin') returns(bool) {
        whitelist[_from] = true;
        return true;
    }

    function blockTransferFrom(address _from) public onlyRole('admin') returns(bool) {
        whitelist[_from] = false;
        return true;
    }

    function transferIsAllowed(address _from) public view returns(bool) {
        return restrictionRemoved || whitelist[_from] || (now >= restrictionExpiraton);
    }

    function removeRestriction() public onlyRole('admin') returns(bool) {
        restrictionRemoved = true;
        return true;
    }

    modifier transferAllowed(address _sender) {
        if (!transferIsAllowed(_sender)) {
            emit Error('Transfer not allowed');
            return;
        }
        _;
    }

    function setExpiration(uint _time) public onlyRole('admin') returns(bool) {
        if (restrictionExpiraton != 0) {
            emit Error('Expiration time already set');
            return false;
        }
        if (_time < now) {
            emit Error('Expiration time invalid');
            return false;
        }
        restrictionExpiraton = _time;
        return true;
    }

     
    function _transferWithReference(address _to, uint _value, string _reference, address _sender)
        transferAllowed(_sender)
        internal
        returns(bool)
    {
        return super._transferWithReference(_to, _value, _reference, _sender);
    }

    function _transferToICAPWithReference(bytes32 _icap, uint _value, string _reference, address _sender)
        transferAllowed(_sender)
        internal
        returns(bool)
    {
        return super._transferToICAPWithReference(_icap, _value, _reference, _sender);
    }

    function _transferFromWithReference(address _from, address _to, uint _value, string _reference, address _sender)
        transferAllowed(_from)
        internal
        returns(bool)
    {
        return super._transferFromWithReference(_from, _to, _value, _reference, _sender);
    }

    function _transferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference, address _sender)
        transferAllowed(_from)
        internal
        returns(bool)
    {
        return super._transferFromToICAPWithReference(_from, _icap, _value, _reference, _sender);
    }
}

 
contract AssetWithTimelock is AssetWithAmbi {
    mapping(address => uint) public unlockDate;

    event Error(bytes32 message);
    event TimelockAllowed(address addr);
    event Timelocked(address addr, uint unlockDate);

    function isTimelockAllowed(address _address) public view returns(bool) {
        return unlockDate[_address] > 0;
    }

    function isTimelocked(address _address) public view returns(bool) {
        return unlockDate[_address] > 1;
    }

    function isTransferAllowed(address _from) public view returns(bool) {
        return now > unlockDate[_from];
    }

    function allowTimelock() public returns(bool) {
        _allowTimelock(_sender());
        return true;
    }

    function _allowTimelock(address _address) internal {
        if (isTimelockAllowed(_address)) {
            return;
        }
        unlockDate[_address] = 1;
        emit TimelockAllowed(_address);
    }

    function () public {
        require(msg.data.length == 0);
        allowTimelock();
    }

    function transferWithLock(address _to, uint _value, uint _unlockDate) onlyRole('locker') public returns(bool) {
        address sender = _sender();
        if (_unlockDate == 0) {
            emit Error('Invalid unlock date');
            return false;
        }
        if (not(isTimelockAllowed(_to))) {
            emit Error('Timelock not allowed');
            return false;
        }
        if (not(_transferWithReference(_to, _value, 'Timelocked', sender))) {
            emit Error('Failed transfer with lock');
            return false;
        }
        if (not(isTimelocked(_to))) {
            unlockDate[_to] = _unlockDate;
            emit Timelocked(_to, _unlockDate);
        }
        return true;
    }

    modifier onlyUnlocked(address _from) {
        if (not(isTransferAllowed(_from))) {
            emit Error('Sender is timelocked');
            return;
        }
        _;
    }

    function not(bool _condition) internal pure returns(bool) {
        return !_condition;
    }

     
    function _transferWithReference(address _to, uint _value, string _reference, address _sender)
        onlyUnlocked(_sender)
        internal
        returns(bool)
    {
        if (_value == 0) {
            _allowTimelock(_sender);
            return true;
        }
        return super._transferWithReference(_to, _value, _reference, _sender);
    }

    function _transferToICAPWithReference(bytes32 _icap, uint _value, string _reference, address _sender)
        onlyUnlocked(_sender)
        internal
        returns(bool)
    {
        return super._transferToICAPWithReference(_icap, _value, _reference, _sender);
    }

    function _transferFromWithReference(address _from, address _to, uint _value, string _reference, address _sender)
        onlyUnlocked(_from)
        internal
        returns(bool)
    {
        return super._transferFromWithReference(_from, _to, _value, _reference, _sender);
    }

    function _transferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference, address _sender)
        onlyUnlocked(_from)
        internal
        returns(bool)
    {
        return super._transferFromToICAPWithReference(_from, _icap, _value, _reference, _sender);
    }
}

contract AssetWithTimelockAndWhitelist is AssetWithWhitelist, AssetWithTimelock {}