 

pragma solidity ^0.4.25;

 
contract Smartolution {

    struct User {
        uint value;
        uint index;
        uint atBlock;
    }

    mapping (address => User) public users;
    
    uint public total;
    uint public advertisement;
    uint public team;
   
    address public teamAddress;
    address public advertisementAddress;

    constructor(address _advertisementAddress, address _teamAddress) public {
        advertisementAddress = _advertisementAddress;
        teamAddress = _teamAddress;
    }

    function () public payable {
        require(msg.value == 0.00001111 ether || (msg.value >= 0.01 ether && msg.value <= 5 ether), "Min: 0.01 ether, Max: 5 ether, Exit: 0.00001111 eth");

        User storage user = users[msg.sender];  

        if (msg.value != 0.00001111 ether) {
            total += msg.value;                  
            advertisement += msg.value / 30;     
            team += msg.value / 200;             
            
            if (user.value == 0) { 
                user.value = msg.value;
                user.atBlock = block.number;
                user.index = 1;     
            } else {
                require(block.number - user.atBlock >= 5900, "Too soon, try again later");

                uint idx = ++user.index;
                uint amount = msg.value > user.value ? user.value : msg.value;
                
                if (idx == 45) {
                    user.value = 0;  
                } else {
                     
                     
                    if (block.number - user.atBlock - 5900 < 984) { 
                        user.atBlock += 5900;
                    } else {
                        user.atBlock = block.number - 984;
                    }
                }

                 
                msg.sender.transfer(amount * idx * idx * (24400 - 500 * amount / 1 ether) / 10000000);
            }
        } else {
            require(user.index <= 10, "It's too late to request a refund at this point");

            msg.sender.transfer(user.index * user.value * 70 / 100);
            user.value = 0;
        }
        
    }

      
    function claim(uint amount) public {
        if (msg.sender == advertisementAddress) {
            require(amount > 0 && amount <= advertisement, "Can't claim more than was reserved");

            advertisement -= amount;
            msg.sender.transfer(amount);
        } else 
        if (msg.sender == teamAddress) {
            require(amount > 0 && amount <= team, "Can't claim more than was reserved");

            team -= amount;
            msg.sender.transfer(amount);
        }
    }
}