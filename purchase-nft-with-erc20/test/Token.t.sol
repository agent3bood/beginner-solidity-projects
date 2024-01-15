pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {GLDToken} from "../src/Token.sol";

contract GLDTokenTest is Test {
    GLDToken public token;

    function setUp() public {
        token = new GLDToken();
    }

    function test_Mint() public {
        token.mint();
        assertEq(token.balanceOf(address(this)), 10);
    }
}
