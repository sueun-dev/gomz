// SPDX-License-Identifier: MIT
// Developer : Sueun-dev, junha-ahn 
// BBGT-v2 released

pragma solidity ^0.8.0;

interface Token {
  function balanceOf(address _owner) external view returns (uint256); 		
  function transfer(address to, uint256 value) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BuyBBGT {
  Token public tokenInstance;
  address public owner;
  uint256 public requiredBlock;

  constructor(address _tokenAddress) {
    tokenInstance = Token(_tokenAddress);
    owner = msg.sender;
    requiredBlock = block.number + 8640;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function getBalance() public view returns(uint256) {
    return tokenInstance.balanceOf(address(this));
  }

  function transferEthToOnwer() onlyOwner public {
    payable(owner).transfer(address(this).balance);
  }

  function transferTokenToOnwer() onlyOwner public {
    tokenInstance.transfer(address(owner), tokenInstance.balanceOf(address(this)));
  }

  function kill() onlyOwner public {
		transferTokenToOnwer();
    selfdestruct(payable(owner));
  }

  function buy() payable public { 
    require(block.number > requiredBlock);
    require(msg.value > 0, "amount must bigger than ZERO");
    uint256 amountTobuy = msg.value;
    uint256 dexBalance = tokenInstance.balanceOf(address(this));
    require(amountTobuy > 0, "You need to send some ether");
    require(amountTobuy <= dexBalance, "Not enough tokens in the reserve");
    tokenInstance.transfer(msg.sender, (amountTobuy * 2));
  }

}
