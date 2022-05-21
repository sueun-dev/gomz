// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../../openzeppelin/contracts/utils/Context.sol";
import "../../openzeppelin/contracts/utils/math/SafeMath.sol";
import "../../openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../ERC721/IBBGTv1.sol";

contract BBGTSale is Context {
    using SafeMath for uint256;

    IBBGTv1 public BBGTNFTContract;
    IERC20 public BBGTTokenContract;

    uint16 MAX_SUPPLY = 100;
    uint256 PRICE_PER_POP = 9999 ether;
    uint256 PRICE_PER_BBGT = 1999 ether;

    uint256 public constant maxPurchase = 5;
    bool public isSale = false;

    address public C1;
    address public C2;
    address public C3;

    modifier mintRole(uint256 numberOfTokens) {
        require(isSale, "The sale has not started.");
        require(
            BBGTNFTContract.totalSupply() < MAX_SUPPLY,
            "Sale has already ended."
        );
        require(numberOfTokens <= maxPurchase, "Can only mint 5 NFT at a time");
        require(
            BBGTNFTContract.totalSupply().add(numberOfTokens) <= MAX_SUPPLY,
            "Purchase would exceed max supply of NFT"
        );
        _;
    }

    modifier mintRoleByPOP(uint256 numberOfTokens) {
        require(
            PRICE_PER_POP.mul(numberOfTokens) <= msg.value,
            "POP value sent is not correct"
        );
        _;
    }

    modifier mintRoleByBBGT(uint256 numberOfTokens) {
        uint256 allowanced = BBGTTokenContract.allowance(
            _msgSender(),
            address(this)
        );
        require(
            PRICE_PER_BBGT.mul(numberOfTokens) <= allowanced,
            "Not enough allowanced"
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
        address token,
        address _C1,
        address _C2,
        address _C3
    ) {
        BBGTNFTContract = IBBGTv1(nft);
        BBGTTokenContract = IERC20(token);
        C1 = _C1;
        C2 = _C2;
        C3 = _C3;
    }

    function mintByPOP(uint256 numberOfTokens)
        public
        payable
        mintRole(numberOfTokens)
        mintRoleByPOP(numberOfTokens)
    {
        for (uint256 i = 0; i < numberOfTokens; i++) {
            if (BBGTNFTContract.totalSupply() < MAX_SUPPLY) {
                BBGTNFTContract.mint(_msgSender());
            }
        }
    }

    function mintByBBGT(uint256 numberOfTokens)
        public
        mintRole(numberOfTokens)
        mintRoleByBBGT(numberOfTokens)
    {
        for (uint256 i = 0; i < numberOfTokens; i++) {
            if (BBGTNFTContract.totalSupply() < MAX_SUPPLY) {
                BBGTTokenContract.transferFrom(
                    _msgSender(),
                    address(this),
                    PRICE_PER_BBGT
                );
                BBGTNFTContract.mint(_msgSender());
            }
        }
    }

    function preMint(uint256 numberOfTokens, address receiver)
        public
        onlyCreator
    {
        require(!isSale, "The sale has started. Can't call preMint");
        for (uint256 i = 0; i < numberOfTokens; i++) {
            if (BBGTNFTContract.totalSupply() < MAX_SUPPLY) {
                BBGTNFTContract.mint(receiver);
            }
        }
    }

    function withdraw() public payable onlyCreator {
        uint256 contractPOPBalance = address(this).balance;
        uint256 percentagePOP = contractPOPBalance / 100;

        uint256 contractBBGTBalance = BBGTTokenContract.balanceOf(
            address(this)
        );
        uint256 percentageBBGT = contractBBGTBalance / 100;

        require(payable(C1).send(percentagePOP * 35));
        require(payable(C2).send(percentagePOP * 35));
        require(payable(C3).send(percentagePOP * 30));
        require(BBGTTokenContract.transfer(address(C1), percentageBBGT * 35));
        require(BBGTTokenContract.transfer(address(C2), percentageBBGT * 35));
        require(BBGTTokenContract.transfer(address(C3), percentageBBGT * 30));
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
}
