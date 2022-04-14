pragma solidity ^0.8.0;
import "./Ownable.sol";

contract ZombieFactory is Ownable {

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;
    uint cooldown = 1 days;

    //properties of a single zombie
    struct Zombie {
        string name;
        uint dna;
        uint32 level;       //they are gonna be aggregated in memory = less gas
        uint32 readyTime;
        uint16 winCount;    //uint16 = 2^16 = 65536 as max number
        uint16 lossCount;
    }

    //data
    Zombie[] public zombies;                            //array of struct, private
    mapping (uint => address) public zombieToOwner;     //it's a dictionary: key = integer, value = ETH address
    mapping (address => uint) ownerZombieCount;         //SAME access syntax as array. Ex: ownerZombieCount[addr] = ...

    //events
    event NewZombie(uint zombieId, string name, uint id);   //declare an event with the params, it's callable

    //underscore: private method or parameters
    //every param string must need memory type: memory (volatile), storage (persistent inside blockchain)
    function _createZombie(string memory _name, uint _dna) internal {   //interna = private + access also to son classes
        zombies.push(Zombie(_name, _dna, 1, uint32(block.timestamp + cooldown), 0, 0));  //add zombie to array
        uint id = zombies.length - 1;       //get zombie ID, so array length - 1

        zombieToOwner[id] = msg.sender;     //associate ID of new zombie with address of the creator
        ownerZombieCount[msg.sender]++;     //increment number of zombie for caller
        emit NewZombie(id, _name, _dna);    //raise event, notification to front-end
    } 

    //view = not modify the variables, only read, pure = not even read variables
    function _generateRandomDna(string memory _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));    //create an hash sha-256 and convert it into uint
        return rand % dnaModulus;   //obtain only 16 digits
    }

    //public function, create zombie and add it to array
    function createRandomZombie(string memory _name) public {
        //request needs to be true. It prevents a user to create more than one zombie with same address.
        require(ownerZombieCount[msg.sender] == 0, "Zombie already generated for this address.");     //check if the caller owns 0 zombie.

        uint randDna = _generateRandomDna(_name);       //generate random DNA and call private function
        _createZombie(_name, randDna);
    }   

}
