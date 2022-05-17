// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../openzeppelin/contracts/utils/Context.sol";
import "../../openzeppelin/contracts/utils/math/SafeMath.sol";
import "../../openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../ERC721/IGomzV1.sol";

contract GomzSale is Context {
    using SafeMath for uint256;

    uint256 blocknumber;
    uint256 blockDifficult;

    IGomzV1 public GomzNFTContract;

    uint16 MAX_SUPPLY = 2022;
    uint256 PRICE_PER_ETH = 0.02 ether;

    mapping(address => bool) public whitelisted;
    uint256 public numWhitelisted;
    uint16 WL_MAX_SUPPLY = 7;
    uint256 WL_PRICE_PER_ETH = 0.01 ether;

    uint256 public constant maxPurchase = 3;

    bool public isSale = false;
    bool public WLisSale = false;

    address public C1;
    address public C2;
    address public C3;

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
        //MAX_SUPPLY 는 4개로 설정
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

    // C1: Developer, C2: Developer, C3: Artist
    modifier onlyCreator() {
        require(
            C1 == _msgSender() || C2 == _msgSender() || C3 == _msgSender(),
            "onlyCreator: caller is not the creator"
        );
        _;
    }

    modifier onlyC1() {
        require(C1 == _msgSender(), "only C1: caller is not the C1");
        _;
    }

    modifier onlyC2() {
        require(C2 == _msgSender(), "only C2: caller is not the C2");
        _;
    }

    modifier onlyC3() {
        require(C3 == _msgSender(), "only C3: caller is not the C3");
        _;
    }

    constructor(
        address nft,
        address _C1,
        address _C2,
        address _C3
    ) {
        GomzNFTContract = IGomzV1(nft);
        C1 = _C1;
        C2 = _C2;
        C3 = _C3;
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
        uint256 percentageETH = contractETHBalance / 100;

        require(payable(C1).send(percentageETH * 35));
        require(payable(C2).send(percentageETH * 35));
        require(payable(C3).send(percentageETH * 30));
    }

    function setC1(address changeAddress) public onlyC1 {
        C1 = changeAddress;
    }

    function setC2(address changeAddress) public onlyC2 {
        C2 = changeAddress;
    }

    function setC3(address changeAddress) public onlyC3 {
        C3 = changeAddress;
    }

    function setSale() public onlyCreator {
        isSale = !isSale;
    }

    function WLsetSale() public onlyCreator {
        WLisSale = !WLisSale;
    }

    function publicSale() public onlyCreator{
        PRICE_PER_ETH = 0.02 ether;
    }

    function WLpublicSale() public onlyCreator { 
        WL_PRICE_PER_ETH = 0.01 ether;
    }

    function getWLpublicSale() public view returns (uint256) {
        return WL_PRICE_PER_ETH;
    }

    function getpublicSale() public view returns (uint256) {
        return PRICE_PER_ETH;
    }

    function increasePrice(uint256 increaPrice) public onlyCreator {
        increaPrice = increaPrice * (1 ether);
        PRICE_PER_ETH += increaPrice;
    }

    function decreasePrice(uint256 decreaPrice) public onlyCreator {
        decreaPrice = decreaPrice * (1 ether);
        PRICE_PER_ETH -= decreaPrice;
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

  /*  function BlockNumber() public onlyCreator { 
        blocknumber = block.number;
    }

    function getBlockNumber() public view returns (uint256) {
        return blocknumber;
    }

    function BlockDifficulty() public onlyCreator { 
        blockDifficult = block.difficulty;
    }

    function getBlockDifficulty() public view returns (uint256) {
        return blockDifficult;
    } */

    

}