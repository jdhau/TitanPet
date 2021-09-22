// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "./titanPet.sol";
import "./cubanToken.sol";

contract titanPetHouse is Ownable{
    TitanPet currentPet;
    address[] public graveyard;
    ERC20Burnable titanToken;
    CubanToken cubanToken;
    uint256 basePriceUnit;
    
    constructor(){
        currentPet = new TitanPet("Mark Cuban");
        titanToken = ERC20Burnable(0x1cd2ffDb2CbDd10e1124841038A8ed6603f91016); // TESTNET TOKEN
        cubanToken = new CubanToken();
        basePriceUnit = 1 ether; // 1000000 ether for main net!
    }
    
    modifier costs(uint256 p_price) {
        require (titanToken.allowance(msg.sender, address(this)) >= basePriceUnit * p_price, "Insufficient approved TITAN balance");
        titanToken.transferFrom(msg.sender, address(this), basePriceUnit * p_price);
        titanToken.burn(basePriceUnit * p_price / 2);
        _;
    }
    
    function birthNewPet(string memory p_name) public costs(5) {
        require (!currentPet.isAlive(),"Alive");
        require (currentPet.isBuried(),"Dead, but not buried");
        currentPet = new TitanPet(p_name);
    }
 
    function getHappiness() public view returns (uint256){
        return currentPet.getHappiness();
    }
    
    function isAlive() public view returns (bool) {
        return currentPet.isAlive();
    }
    
    function isBuried() public view returns (bool) {
        return currentPet.isBuried();
    }
    
    function getCurrentPet() public view returns (address) {
        return address(currentPet);
    }
    
    function buryPet(string memory p_eulogy) public costs(5) {
        require (!currentPet.isAlive());
        currentPet.bury(p_eulogy);
        graveyard.push(address(currentPet));
    }
    
    function mintCuban(address p_address, uint256 p_amount) internal {
        cubanToken.mint(p_address, p_amount);
    }

    function setBasePriceUnit(uint256 p_priceUnit) onlyOwner external {
        basePriceUnit = p_priceUnit;
    }
    
    function withDraw() onlyOwner external {
        titanToken.transfer(msg.sender,titanToken.balanceOf(address(this)));
    }
}

