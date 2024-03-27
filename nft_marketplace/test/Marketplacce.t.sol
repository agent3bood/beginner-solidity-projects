pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../src/Marketplace.sol";

contract NFT is ERC721 {
    constructor() ERC721("NFT", "NFT") {}

    function mint(address to, uint tokenId) public {
        _mint(to, tokenId);
    }
}

contract AuctionTest is Test {
    address public user1;
    address public user2;
    Marketplace public marketplace;
    NFT public nft;

    function setUp() public {
        user1 = vm.addr(1);
        user2 = vm.addr(2);
        marketplace = new Marketplace();
        nft = new NFT();
        nft.mint(user1, 1);
    }

    function test_Marketplace() public {
        // deal money
        vm.deal(user2, 100);

        // sell
        vm.startPrank(user1);
        nft.approve(address(marketplace), 1);
        marketplace.sell(nft, 1, 100, 100);
        vm.stopPrank();

        // buy lower price
        vm.prank(user2);
        vm.expectRevert();
        marketplace.buy{value: 99}(nft, 1);

        // buy exact price
        vm.prank(user2);
        marketplace.buy{value: 100}(nft, 1);

        // check owner
        assertEq(nft.ownerOf(1), user2);

        // check seller balance
        assertEq(user1.balance, 100);
    }
}
