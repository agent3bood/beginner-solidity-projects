pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {GLDToken} from "../src/Token.sol";
import {GLDNFT} from "../src/NFT.sol";

contract GLDNFTTest is Test {
    address public user;
    GLDNFT public nft;
    GLDToken public token;

    function setUp() public {
        user = address(0x1);
        nft = new GLDNFT();
        token = new GLDToken();
    }

    function test_Mint() public {
        vm.startPrank(user);
        token.mint();
        token.approve(address(nft), 1);
        assertEq(token.balanceOf(user), 10);
        assertEq(token.balanceOf(address(nft)), 0);
        nft.mint(token, 1);

        assertEq(token.balanceOf(user), 9);
        assertEq(token.balanceOf(address(nft)), 1);
        assertEq(nft.ownerOf(1), user);
    }
}
