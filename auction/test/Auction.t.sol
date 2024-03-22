pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../src/Auction.sol";

contract NFT is ERC721 {
    constructor() ERC721("NFT", "NFT") {}

    function mint(address to, uint tokenId) public {
        _mint(to, tokenId);
    }
}

contract AuctionTest is Test {
    address public user1;
    address public user2;
    address public user3;
    Auction public auction;
    NFT public nft;

    function setUp() public {
        user1 = vm.addr(1);
        user2 = vm.addr(2);
        user3 = vm.addr(3);
        auction = new Auction();
        nft = new NFT();
        nft.mint(user1, 1);
    }

    function test_Auction() public {
        // deal money
        vm.deal(user1, 0);
        vm.deal(user2, 100);
        vm.deal(user3, 100);


        // deposit
        vm.startPrank(user1);
        nft.approve(address(auction), 1);
        auction.deposit(nft, 1, 100, 10);
        vm.stopPrank();

        // bid user2
        vm.prank(user2);
        auction.bid{value: 20}(nft, 1);

        // bid user3
        vm.prank(user3);
        auction.bid{value: 30}(nft, 1);

        // warp
        vm.warp(101);

        // end auction
        vm.prank(user1);
        auction.sellerEndAuction(nft, 1);

        // check winner
        assertEq(nft.ownerOf(1), user3);

        // check balance
        assertEq(address(auction).balance, 0);
        assertEq(user1.balance, 30);
        assertEq(user2.balance, 100);
        assertEq(user3.balance, 70);
    }
}
