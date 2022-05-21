// SPDX-License-Identifier: MIT
//CREATED BY SUEUN CHO - sueun.dev@gmail.com
pragma solidity ^0.8.0;

import "https://github.com/sueun-dev/gomz/blob/main/contracts/openzeppelin/contracts/token/ERC721/ERC721.sol";
import "https://github.com/sueun-dev/gomz/blob/main/contracts/openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "https://github.com/sueun-dev/gomz/blob/main/contracts/openzeppelin/contracts/utils/Counters.sol";
import "https://github.com/sueun-dev/gomz/blob/main/contracts/openzeppelin/contracts/access/Ownable.sol";

contract Gomzv1 is ERC721, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    address public minterContract;
    uint16 public MAX_SUPPLY = 2022;
    string private _baseTokenURI;

    bool public revealed = false;
    string public notRevealedUri;

    modifier onlyMinter() {
        require(_msgSender() == minterContract, "only Minter error");
        _;
    }

    constructor(string memory baseTokenURI, string memory _initNotRevealedUri) ERC721("GOMZ_CLUB_NFT", "GOMZNFT") {
        _baseTokenURI = baseTokenURI;
        _tokenIdCounter.increment();
        setNotRevealedURI(_initNotRevealedUri);
    }

     function mint(address to) external virtual onlyMinter {
        require(totalSupply() < MAX_SUPPLY, "OVER MINTING");
        _mint(to, _tokenIdCounter.current());
        _tokenIdCounter.increment();
    }

    function setMinterContract(address saleContract) public onlyOwner {
        minterContract = saleContract;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
    notRevealedUri = _notRevealedURI;
    }

    function reveal() public onlyOwner {
      revealed = true;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    function getBaseURI() public view returns (string memory) {
        return _baseURI();
    }

    function _baseURI() internal view virtual override returns (string memory) {

        if(revealed) { 
        return notRevealedUri; }

        return _baseTokenURI;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}
