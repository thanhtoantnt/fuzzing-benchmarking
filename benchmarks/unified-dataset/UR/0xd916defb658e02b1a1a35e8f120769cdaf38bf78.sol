 

pragma solidity 0.4.24;


 
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


contract EternalStorageInterface {
    function getShipById(uint256 _shipId) public view returns(uint256, string, uint256, uint256, uint256);
    function buyItem(uint256 _itemId, address _newOwner, string _itemTitle, string _itemTypeTitle) public returns(uint256);
    function getItemPriceById(string _itemType, uint256 _itemId) public view returns(uint256);
    function getOwnerByItemTypeAndId(string _itemType, uint256 _itemId) public view returns(address);
    function getItemTypeIdByTypeAndId(string _itemType, uint256 _itemId) public view returns(uint256);
    function setNewPriceToItem(string _itemType, uint256 _itemTypeId, uint256 _newPrice) public;
    function addReferrer(address _referrerWalletAddress, uint256 referrerPrize) public;
    function widthdrawRefunds(address _referrerWalletAddress) public returns(uint256);
    function checkRefundExistanceByOwner(address _ownerAddress) public view returns(uint256);
}

contract ItemsStorageInterface {
    function getShipsIds() public view returns(uint256[]);
    function getRadarsIds() public view returns(uint256[]);
    function getScannersIds() public view returns(uint256[]);
    function getDroidsIds() public view returns(uint256[]);
    function getFuelsIds() public view returns(uint256[]);
    function getGeneratorsIds() public view returns(uint256[]);
    function getEnginesIds() public view returns(uint256[]);
    function getGunsIds() public view returns(uint256[]);
    function getMicroModulesIds() public view returns(uint256[]);
    function getArtefactsIds() public view returns(uint256[]);

    function getUsersShipsIds() public view returns(uint256[]);
    function getUsersRadarsIds() public view returns(uint256[]);
    function getUsersScannersIds() public view returns(uint256[]);
    function getUsersDroidsIds() public view returns(uint256[]);
    function getUsersEnginesIds() public view returns(uint256[]);
    function getUsersFuelsIds() public view returns(uint256[]);
    function getUsersGeneratorsIds() public view returns(uint256[]);
    function getUsersGunsIds() public view returns(uint256[]);
    function getUsersMicroModulesIds() public view returns(uint256[]);
    function getUsersArtefactsIds() public view returns(uint256[]);
}

contract LogicContract is Ownable {

     

    event ShipWasBought(uint256 shipId);

    EternalStorageInterface private eternalStorageContract;
    ItemsStorageInterface private itemsStorageContract;

    constructor() public {
        eternalStorageContract = EternalStorageInterface(0xdb289A6c489Ea324564E64783eCCcb0d7fa9d00f);
        itemsStorageContract = ItemsStorageInterface(0x27B95A9231a022923e9b52d71bEB662Fdd5d6cbc);
    }

     

    modifier addressIsNotNull(address _newOwner) {
		require(_newOwner != address(0));
		_;
	}

     

    function destroyLogicContract() public onlyOwner {
        selfdestruct(0xd135377eB20666725D518c967F23e168045Ee11F);
    }

     
	function buyShip(uint256 _shipId, address _referrerWalletAddress) public payable addressIsNotNull(msg.sender)  {
        uint256 referrerPrize = 0;

        uint256 price = eternalStorageContract.getItemPriceById("ships", _shipId);
        require(msg.value == price);

        if (_referrerWalletAddress != address(0) && _referrerWalletAddress != msg.sender && price > 0) {
            referrerPrize = SafeMath.div(price, 10);
            if (referrerPrize < price) {
                eternalStorageContract.addReferrer(_referrerWalletAddress, referrerPrize);
            }
        }

        _buyShip(_shipId, msg.sender);
	}

    function _buyShip(uint256 _shipId, address _newOwner) private {
        uint256 myShipId = eternalStorageContract.buyItem(_shipId, _newOwner, "ship", "ship_types");
        emit ShipWasBought(myShipId);
    }

    function withdrawRefund(address _owner) public addressIsNotNull(_owner) {
        uint256 curRefVal = eternalStorageContract.checkRefundExistanceByOwner(_owner);
        if (curRefVal > 0 && address(this).balance > curRefVal && SafeMath.sub(address(this).balance, curRefVal) > 0) {
            uint256 refund = eternalStorageContract.widthdrawRefunds(_owner);
            _owner.transfer(refund);
        }
    }

    function checkRefundExistanceByOwner(address _owner) public addressIsNotNull(_owner) view returns(uint256) {
        return eternalStorageContract.checkRefundExistanceByOwner(_owner);
    }

     

    function getOwnerByShipId(uint256 _shipId) public view returns(address) {
        return eternalStorageContract.getOwnerByItemTypeAndId("ship", _shipId);
    }

    function getShipType(uint256 _shipId) public view returns(uint256) {
        return eternalStorageContract.getItemTypeIdByTypeAndId("ship_types", _shipId);
    }

     

     
    function getUsersShipsIds() public view returns(uint256[]) {
        return itemsStorageContract.getUsersShipsIds();
    }

     

     
    function getShipPriceById(uint256 _shipId) public view returns(uint256) {
        return eternalStorageContract.getItemPriceById("ships", _shipId);
    }

     
    function getShipsIds() public view returns(uint256[]) {
        return itemsStorageContract.getShipsIds();
    }

    function getShipById(uint256 _shipId) public view returns(
        uint256,
        string,
        uint256,
        uint256,
        uint256
    ) {
        return eternalStorageContract.getShipById(_shipId);
    }

     

    function getBalanceOfLogicContract() public onlyOwner view returns(uint256) {
        return address(this).balance;
    }

    function getPayOut() public onlyOwner returns(uint256) {
		_getPayOut();
	}

	function _getPayOut() private returns(uint256){
		if (msg.sender != address(0)) {
			msg.sender.transfer(address(this).balance);
            return address(this).balance;
		}
	}

    function setNewPriceToItem(string _itemType, uint256 _itemTypeId, uint256 _newPrice) public onlyOwner {
        eternalStorageContract.setNewPriceToItem(_itemType, _itemTypeId, _newPrice);
    }
}