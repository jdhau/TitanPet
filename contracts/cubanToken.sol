// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CubanToken is ERC20Burnable, Ownable {
    constructor()
    ERC20("Cuban Token","CUBAN"){
    }
    
    function mint(address p_account, uint256 p_amount) public onlyOwner {
        _mint(p_account, p_amount);
    }
}