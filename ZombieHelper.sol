pragma solidity ^0.8.0;

import "./ZombieFeeding.sol";

contract ZombieHelper is ZombieFeeding {

    uint levelUpFree = 0.01 ether;

    //check that a defined zombie has an equal/greater level than what passed
    modifier aboveLevel(uint _level, uint _zombieId) {
        require(zombies[_zombieId].level >= _level, "Level is not enough.");
        _;
    }

    //change name, only if LEVEL is at least 2 (2 modifier)
    function changeName(uint _zombieId, string memory _newName) external aboveLevel(2, _zombieId) ownerOf(_zombieId) {
        zombies[_zombieId].name = _newName;                  //change name

    }

    //change DNA, only if level >= 20
    function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) ownerOf(_zombieId){
        zombies[_zombieId].dna = _newDna;
    }

    //view all the zombie owned by an address, return arrays of ID
    function getZombiesByOwner(address _owner) external view returns (uint[] memory){
        uint size = ownerZombieCount[_owner];       //get number of zombie of that address
        uint[] memory result = new uint[](size);    //fixed length
        uint counter = 0;

        //add to the array (in memory = free) all the zombie of that address
        for(uint i=0; i<zombies.length; i++)
        {
            if(zombieToOwner[i] == _owner)
            {
                result[counter] = i;
                counter++;
            }    
        }
        return result;
    }

    //level up the given zombie by paying 0.01 ETH
    //payble functions are always external = callable only from outside of this contract
    function levelUp(uint _zombieId) external payable {
        require(msg.value >= levelUpFree, "Not enough ether");  //check if there is enough ETH
        zombies[_zombieId].level++;
    }

    //function for withdrawing the ETH inside the contract
    //callable only from outside the contract AND onlly from the owner
    //address is not enough, need to cast it to payable type
    function withdraw() external onlyOwner {
        address _owner = owner();
        payable(_owner).transfer(address(this).balance);
    }

    //set new fee, only onwer
    function setLevelUpFee(uint _fee) external onlyOwner {
        levelUpFree = _fee;
    }

    //get contract balance
    function getBalance() public view returns (uint) {
        return address(this).balance;  //to get ETH number, / 10**18
    }
}

//left:  https://cryptozombies.io/it/lesson/4/chapter/1
