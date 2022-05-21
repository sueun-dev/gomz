// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/sueun-dev/gomz/blob/main/src/contracts/openzeppelin/contracts/utils/Context.sol";
import "https://github.com/sueun-dev/gomz/blob/main/src/contracts/openzeppelin/contracts/utils/math/SafeMath.sol";
import "https://github.com/sueun-dev/gomz/blob/main/src/contracts/openzeppelin/contracts/token/ERC20/IERC20.sol";
import "https://github.com/sueun-dev/gomz/blob/main/src/contracts/ERC721/IGomzV1.sol";

contract GomzSale is Context {
    using SafeMath for uint256;

    IGomzV1 public GomzNFTContract;

    uint16 MAX_SUPPLY = 2022;
    uint256 PRICE_PER_ETH = 0.8 ether;

    mapping(address => bool) public whitelisted;
    uint256 public numWhitelisted;
    //N개 까지! (600개는 먼저 가져가고 600개는 후 화리 컨트렉트)
    uint16 WL_MAX_SUPPLY = 1200;
    uint256 WL_PRICE_PER_ETH = 0.5 ether;

    uint256 public constant maxPurchase = 3;

    bool public isSale = false;
    bool public WLisSale = false;

    address public C1;

    modifier mintRole(uint256 numberOfTokens) {
        require(isSale, "The sale has not started.");
        require(
            GomzNFTContract.totalSupply() < MAX_SUPPLY,
            "Sale has already ended."
        );
        require(numberOfTokens <= maxPurchase, "Can only mint 3 NFT at a time");
        require(
            GomzNFTContract.totalSupply().add(numberOfTokens) <= MAX_SUPPLY,
            "Purchase would exceed max supply of NFT"
        );
        _;
    }

    modifier WLmintRole(uint256 numberOfTokens) {
        require(whitelisted[msg.sender] == true, "You are not white list");
        require(WLisSale, "The sale has not started.");
        require(
            GomzNFTContract.totalSupply() < WL_MAX_SUPPLY,
            "Sale has already ended."
        );
        require(numberOfTokens <= maxPurchase, "Can only mint 3 NFT at a time");
        require(
            GomzNFTContract.totalSupply().add(numberOfTokens) <= WL_MAX_SUPPLY,
            "Purchase would exceed max supply of NFT"
        );
        _;
    }

    modifier mintRoleByETH(uint256 numberOfTokens) {
        require(
            PRICE_PER_ETH.mul(numberOfTokens) <= msg.value,
            "ETH value sent is not correct"
        );
        _;
    }

    modifier WLmintRoleByETH(uint256 numberOfTokens) {
        require(
            WL_PRICE_PER_ETH.mul(numberOfTokens) <= msg.value,
            "ETH value sent is not correct"
        );
        _;
    }

    //C1 = Creator1
    modifier onlyCreator() {
        require(
            C1 == _msgSender(),
            "onlyCreator: caller is not the creator"
        );
        _;
    }

    modifier onlyC1() {
        require(C1 == _msgSender(), "only C1: caller is not the C1");
        _;
    }

    constructor(
        address nft,
        address _C1
    ) {
        GomzNFTContract = IGomzV1(nft);
        C1 = _C1;
    }

    function mintByETH(uint256 numberOfTokens)
        public
        payable
        mintRole(numberOfTokens)
        mintRoleByETH(numberOfTokens)
    {
        for (uint256 i = 0; i < numberOfTokens; i++) {
            if (GomzNFTContract.totalSupply() < MAX_SUPPLY) {
                GomzNFTContract.mint(_msgSender());
            }
        }
    }

    function WLmintByETH(uint256 numberOfTokens)
        public
        payable
        WLmintRole(numberOfTokens)
        WLmintRoleByETH(numberOfTokens)
    {
        for (uint256 i = 0; i < numberOfTokens; i++) {
            if (GomzNFTContract.totalSupply() < WL_MAX_SUPPLY) {
                GomzNFTContract.mint(_msgSender());
            }
        }
    }

    function developerPreMint(uint256 numberOfTokens, address receiver)
        public
        onlyCreator
    {
        require(!isSale, "The sale has started. Can't call preMint");
        for (uint256 i = 0; i < numberOfTokens; i++) {
            if (GomzNFTContract.totalSupply() < MAX_SUPPLY) {
                GomzNFTContract.mint(receiver);
            }
        }
    }

    function withdraw() public payable onlyCreator {
        uint256 contractETHBalance = address(this).balance;
        uint256 percentageETH = contractETHBalance;

        require(payable(C1).send(percentageETH));
    }

    function setC1(address changeAddress) public onlyC1 {
        C1 = changeAddress;
    }

    function setSale() public onlyCreator {
        isSale = !isSale;
    }

    function WLsetSale() public onlyCreator {
        WLisSale = !WLisSale;
    }

    function publicSale() public onlyCreator{
        PRICE_PER_ETH = 0.8 ether;
    }

    function WLpublicSale() public onlyCreator { 
        WL_PRICE_PER_ETH = 0.5 ether;
    }

    function getWLpublicSale() public view returns (uint256) {
        return WL_PRICE_PER_ETH;
    }

    function getpublicSale() public view returns (uint256) {
        return PRICE_PER_ETH;
    }

    function increasePrice() public onlyCreator {
        PRICE_PER_ETH += 0.2 ether;
    }

    function addWhitelist(address[] memory _users) public onlyCreator {
        uint size = _users.length;
        
        for (uint256 i=0; i< size; i++){
          address user = _users[i];
          whitelisted[user] = true;
        }
        numWhitelisted += _users.length;
    }

    function removeWhitelist(address[] memory _users) public onlyCreator {
        uint size = _users.length;
        
        for (uint256 i=0; i< size; i++){
          address user = _users[i];
          whitelisted[user] = false;
        }
    }
}