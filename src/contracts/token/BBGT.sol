// SPDX-License-Identifier: MIT
// import openzeppelin
// Developer : Sueun-dev, junha-ahn 
// Token Name : Bbaguette
// Symbol : BBGT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract BBGT is ERC20 {
    constructor(uint256 amount) ERC20("Bbagutte Token", "BBGT") { 
        _mint(msg.sender, amount);
    }
}
