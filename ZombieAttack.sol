pragma solidity ^0.8.0;
import "./ZombieHelper.sol";

contract ZombieAttack is ZombieHelper {
    
    uint randNonce = 0;
    uint attackVictoryProbability = 70;

    //generates casual number, NOT totally secure and random, for a game it's ok !!!
    function randMod(uint _modulus) internal returns (uint) {
        uint result = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce)));
        randNonce++;
        return (result % _modulus);
    }

    //attack function between zombies
    function attack(uint _zombieId, uint _targetId) external ownerOf(_zombieId) {
        Zombie storage myZombie = zombies[_zombieId];       //type storage because the array is written on the blockchain
        Zombie storage enemyZombie = zombies[_targetId];    
        uint rand = randMod(100);                           //used to choose the winner

        if(rand <= attackVictoryProbability)    //win zombieId
        {
            myZombie.winCount++;
            myZombie.level++;
            enemyZombie.lossCount++;
            feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");  //multiply the zombie with dna of the loser
        }
        else
        {
            myZombie.lossCount++;
            enemyZombie.winCount++;
            _triggerCooldown(myZombie);     //reset timer, this func is included in feedandmultiply
        }
    }
}
