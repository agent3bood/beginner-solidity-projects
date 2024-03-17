pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../src/Swapper.sol";

contract Token is ERC721 {
    constructor() ERC721("Token", "TKN") {}

    function mint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }
}

contract SwapperTest is Test {
    address public address_a = address(1);
    address public address_b = address(2);
    uint256 public id_a = 1;
    uint256 public id_b = 2;

    Token public token;
    Swapper public swapper;

    function setUp() public {
        token = new Token();
        token.mint(address_a, id_a);
        token.mint(address_b, id_b);
        swapper = new Swapper();
    }

    // it revert if the owner has not approved the swapper to transfer the token
    function test_Offer_revert() public {
        vm.prank(address_a);
        vm.expectRevert();
        swapper.offer(token, id_a, token, id_b);
    }

    // it revert if the owner has not made an offer to exchange the token
    function test_Execute_revert() public {
        vm.prank(address_a);
        vm.expectRevert();
        swapper.execute(token, id_a, token, id_b);
    }

    // it success when both tokens owners has approved the swapper to transfer the tokens
    // and both tokens owners has made an offer to exchange the tokens
    function test_Execute() public {
        vm.startPrank(address_a);
        token.approve(address(swapper), id_a);
        swapper.offer(token, id_a, token, id_b);

        vm.startPrank(address_b);
        token.approve(address(swapper), id_b);
        swapper.offer(token, id_a, token, id_b);

        // execute and check new owners
        swapper.execute(token, id_a, token, id_b);
        assertEq(token.ownerOf(id_a), address_b);
        assertEq(token.ownerOf(id_b), address_a);
    }
}
