 

pragma solidity ^0.4.18;

interface ENS {

     
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

     
    event Transfer(bytes32 indexed node, address owner);

     
    event NewResolver(bytes32 indexed node, address resolver);

     
    event NewTTL(bytes32 indexed node, uint64 ttl);


    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) public;
    function setResolver(bytes32 node, address resolver) public;
    function setOwner(bytes32 node, address owner) public;
    function setTTL(bytes32 node, uint64 ttl) public;
    function owner(bytes32 node) public view returns (address);
    function resolver(bytes32 node) public view returns (address);
    function ttl(bytes32 node) public view returns (uint64);

}

 
contract PublicResolver {

    bytes4 constant INTERFACE_META_ID = 0x01ffc9a7;
    bytes4 constant ADDR_INTERFACE_ID = 0x3b3b57de;
    bytes4 constant NAME_INTERFACE_ID = 0x691f3431;
    bytes4 constant ABI_INTERFACE_ID = 0x2203ab56;
    bytes4 constant PUBKEY_INTERFACE_ID = 0xc8690233;
    bytes4 constant TEXT_INTERFACE_ID = 0x59d1d43c;
    bytes4 constant CONTENTHASH_INTERFACE_ID = 0xbc1c58d1;

    event AddrChanged(bytes32 indexed node, address a);
    event NameChanged(bytes32 indexed node, string name);
    event ABIChanged(bytes32 indexed node, uint256 indexed contentType);
    event PubkeyChanged(bytes32 indexed node, bytes32 x, bytes32 y);
    event TextChanged(bytes32 indexed node, string indexedKey, string key);
    event ContenthashChanged(bytes32 indexed node, bytes hash);

    struct PublicKey {
        bytes32 x;
        bytes32 y;
    }

    struct Record {
        address addr;
        string name;
        PublicKey pubkey;
        mapping(string=>string) text;
        mapping(uint256=>bytes) abis;
        bytes contenthash;
    }

    ENS ens;

    mapping (bytes32 => Record) records;

    modifier onlyOwner(bytes32 node) {
        require(ens.owner(node) == msg.sender);
        _;
    }

     
    constructor(ENS ensAddr) public {
        ens = ensAddr;
    }

     
    function setAddr(bytes32 node, address addr) public onlyOwner(node) {
        records[node].addr = addr;
        emit AddrChanged(node, addr);
    }

     
    function setContenthash(bytes32 node, bytes hash) public onlyOwner(node) {
        records[node].contenthash = hash;
        emit ContenthashChanged(node, hash);
    }

     
    function setName(bytes32 node, string name) public onlyOwner(node) {
        records[node].name = name;
        emit NameChanged(node, name);
    }

     
    function setABI(bytes32 node, uint256 contentType, bytes data) public onlyOwner(node) {
         
        require(((contentType - 1) & contentType) == 0);

        records[node].abis[contentType] = data;
        emit ABIChanged(node, contentType);
    }

     
    function setPubkey(bytes32 node, bytes32 x, bytes32 y) public onlyOwner(node) {
        records[node].pubkey = PublicKey(x, y);
        emit PubkeyChanged(node, x, y);
    }

     
    function setText(bytes32 node, string key, string value) public onlyOwner(node) {
        records[node].text[key] = value;
        emit TextChanged(node, key, key);
    }

     
    function text(bytes32 node, string key) public view returns (string) {
        return records[node].text[key];
    }

     
    function pubkey(bytes32 node) public view returns (bytes32 x, bytes32 y) {
        return (records[node].pubkey.x, records[node].pubkey.y);
    }

     
    function ABI(bytes32 node, uint256 contentTypes) public view returns (uint256 contentType, bytes data) {
        Record storage record = records[node];
        for (contentType = 1; contentType <= contentTypes; contentType <<= 1) {
            if ((contentType & contentTypes) != 0 && record.abis[contentType].length > 0) {
                data = record.abis[contentType];
                return;
            }
        }
        contentType = 0;
    }

     
    function name(bytes32 node) public view returns (string) {
        return records[node].name;
    }

     
    function addr(bytes32 node) public view returns (address) {
        return records[node].addr;
    }

     
    function contenthash(bytes32 node) public view returns (bytes) {
        return records[node].contenthash;
    }

     
    function supportsInterface(bytes4 interfaceID) public pure returns (bool) {
        return interfaceID == ADDR_INTERFACE_ID ||
        interfaceID == NAME_INTERFACE_ID ||
        interfaceID == ABI_INTERFACE_ID ||
        interfaceID == PUBKEY_INTERFACE_ID ||
        interfaceID == TEXT_INTERFACE_ID ||
        interfaceID == CONTENTHASH_INTERFACE_ID ||
        interfaceID == INTERFACE_META_ID;
    }
}