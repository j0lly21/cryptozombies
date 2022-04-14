pragma solidity ^0.8.0;
import "./ZombieFactory.sol";

//cryptoKitties interface 
interface KittyInterface {
  function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  );
}


// inherit from previous class all the methods and attributes
contract ZombieFeeding is ZombieFactory {

    //STATIC METHOD TO ACCESS TO A CONTRACT
    //address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;     //cryptoKitties address STATIC
    //KittyInterface public kittyContract = KittyInterface(ckAddress);           //pointer to the external contract
    
    //DYNAMIC METHOD
    KittyInterface kittyContract;

    //set and change kitty contract address, in case of bug (callable only by the owner of the contract)
    function setKittyContractAddress(address _address) external onlyOwner {
        kittyContract = KittyInterface(_address);
    }

    //modifier for checking zombie ownership
    modifier ownerOf(uint _zombieId){
        require(msg.sender == zombieToOwner[_zombieId], "This address doesn't own the selected zombie."); 
        _;
    }

    //zombieId = position of zombie inside the array, callable only from intern
    function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) internal ownerOf(_zombieId){   
       
        Zombie storage myZombie = zombies[_zombieId];   //it's a pointer to another zombie into the array, so it's "storage"
        require(_isReady(myZombie));                    //must be ok with ready time    
        _targetDna = _targetDna % dnaModulus;           //check if _targetDna is 16 digit length
        
        
        uint newDna = (myZombie.dna + _targetDna) / 2;  //generate new dna and create new zombie

        //check if species is a "kitty"
        if(keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty")))
            newDna = newDna - newDna % 100 + 99;        //substitute last 2 digit with 99 if it's a kitty

        _createZombie("NoName", newDna);
        _triggerCooldown(myZombie);                     //set new readyTime on that zombie
    }

    //interact with external contract and get genes of cryptokitties
    function feedOnKitty(uint _zombieId, uint _kittyId) public {
        uint kittyDna;
        (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId); //gene is the 10th element
        feedAndMultiply(_zombieId, kittyDna, "kitty");                
    }

    //set new readytime, after it eats
    function _triggerCooldown(Zombie storage _zombie) internal {
        _zombie.readyTime = uint32(block.timestamp + cooldown);
    }

    //check if the zombie is ready to eat another time
    function _isReady(Zombie storage _zombie) internal view returns (bool) {
        return (_zombie.readyTime <= block.timestamp);
    }
}
