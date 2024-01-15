pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";
import "../src/Vester.sol";
import "../src/Token.sol";

contract VesterTest is Test {
    address private manager = address(1);
    address private employee = address(2);
    Token private token;
    Vester private vester;

    function setUp() public {
        vm.prank(manager);
        token = new Token();
        vester = new Vester();
    }

    function test_Deposit_require_approve() public {
        vm.prank(manager);
        vm.expectRevert();
        vester.deposit(token, employee, 1);
    }

    function test_Deposit_set_amount_time() public {
        vm.startPrank(manager);
        token.approve(address(vester), 2_000);
        vester.deposit(token, employee, 200);
        (uint256 amount, uint256 time) = vester.deposits(employee);
        assertEq(amount, 200);
        assertEq(time / 60 / 60 / 24, block.timestamp / 60 / 60 / 24);
    }

    function test_Deposit_cannot_twice() public {
        vm.startPrank(manager);
        token.approve(address(vester), 2_000);
        vester.deposit(token, employee, 200);
        vm.expectRevert();
        vester.deposit(token, employee, 200);
    }

    function test_Withdraw_amount() public {
        vm.startPrank(manager);
        token.approve(address(vester), 2_000);
        vester.deposit(token, employee, 200);
        (uint256 amount, uint256 time) = vester.deposits(employee);
        vm.stopPrank();

        vm.startPrank(employee);

        vm.expectRevert();
        vester.withdraw(token, 2);

        vm.warp(block.timestamp + 86400);

        vester.withdraw(token, 2);
        assertEq(token.balanceOf(employee), 2);

        vm.expectRevert();
        vester.withdraw(token, 2);
    }
}
