// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./TitanPet.sol";
import "./TitanPetBoost.sol";

contract TitanPets is Ownable, ERC721("Titan Pets","TITANPET"){
    TitanPet[] public pets;
    address constant titanAddress=0x1cd2ffDb2CbDd10e1124841038A8ed6603f91016;
    uint public currentPetPrice = 10 ether; // * 10^6 if TITAN!
    
    modifier onlyPetOwner(uint p_id) {
        require (ownerOf(p_id)==msg.sender,"Sorry you don't own that pet");
        _;
    }
    
    constructor(){}
    
    function claimNewPet(string memory p_name) public {
        require (pets.length<100,"Sold out!");
        
        ERC20Burnable titanToken = ERC20Burnable(titanAddress); // TESTNET TOKEN
        require (titanToken.allowance(msg.sender, address(this)) >= currentPetPrice, "Insufficient approved TITAN balance");
        
        titanToken.transferFrom(msg.sender, address(this), currentPetPrice);
        titanToken.burn(currentPetPrice / 2);
        
        _safeMint(msg.sender,pets.length);
        pets.push(new TitanPet(p_name, pets.length));
        currentPetPrice = (currentPetPrice*103)/100;
    }
 
    function getUnHappiness(uint p_id) public view returns (int256){
        return pets[p_id].getUnHappiness();
    }
    
    function getHunger(uint p_id) public view returns (int256){
        return pets[p_id].getHunger();
    }

    function getThirst(uint p_id) public view returns (int256){
        return pets[p_id].getThirst();
    }

    function getUnHealthiness(uint p_id) public view returns (int256){
        return pets[p_id].getUnHealthiness();
    }
    
    function getTiredness(uint p_id) public view returns (int256){
        return pets[p_id].getTiredness();
    }
    
    function flipPrivate(uint p_id) public onlyPetOwner(p_id) {
        pets[p_id].flipPrivate();
    }
    
    function applyBoost(uint p_id) public onlyPetOwner(p_id) {
        // APPLY BOOST NFT 
    }
    
    function isAlive(uint p_id) public view returns (bool) {
        return pets[p_id].isAlive();
    }
    
    function isPrivate(uint p_id) public view returns (bool) {
        return pets[p_id].isPrivate();
    }
    
    function isAllowed(uint p_id) public view returns (bool) {
        if (isPrivate(p_id)) {
            return (msg.sender == ownerOf(p_id));
        }
        else {
            return true;
        }
    }
    
    function withDraw() onlyOwner external {
        ERC20Burnable titanToken = ERC20Burnable(titanAddress);
        titanToken.transfer(msg.sender,titanToken.balanceOf(address(this)));
    }
}

