pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";
import "../src/Funder.sol";

contract FunderTest is Test {
    Funder private funder;
    address private user = vm.addr(1);
    address private donator_1 = vm.addr(2);
    address private donator_2 = vm.addr(3);

    function setUp() public {
        funder = new Funder();
    }

    function test_CreateFundraiser_create() public {
        vm.prank(user);
        uint256 id = funder.createFundraiser(1, block.timestamp + 1000);
        (address owner, uint256 goal, uint256 deadline, uint256 balance) = funder.fundraisers(id);
        assertEq(owner, user);
        assertEq(goal, 1);
        assertEq(deadline, block.timestamp + 1000);
        assertEq(balance, 0);
    }

    function test_Fund() public {
        vm.prank(user);
        uint256 id = funder.createFundraiser(1, block.timestamp + 1000);

        vm.deal(donator_1, 100);
        vm.prank(donator_1);
        funder.fund{value: 100}(id);
        vm.deal(donator_2, 100);
        vm.prank(donator_2);
        funder.fund{value: 100}(id);

        // check balance
        (address _owner, uint256 _goal, uint256 _deadline, uint256 balance) = funder.fundraisers(id);
        assertEq(balance, 200);
    }

    function test_Withdraw() public {
        vm.prank(user);
        uint256 id = funder.createFundraiser(1, block.timestamp + 1000);

        vm.deal(donator_1, 100);
        vm.prank(donator_1);
        funder.fund{value: 100}(id);
        vm.deal(donator_2, 100);
        vm.prank(donator_2);
        funder.fund{value: 100}(id);

        // cannot withdraw before deadline
        vm.prank(user);
        vm.expectRevert();
        funder.withdraw(id);

        // warp to deadline
        vm.warp(1002);

        // withdraw and check balance
        vm.prank(user);
        funder.withdraw(id);
        assertEq(user.balance, 200);
    }

    function test_Refund_goal_not_met() public {
        vm.prank(user);
        uint256 id = funder.createFundraiser(100, block.timestamp + 1000);

        vm.deal(donator_1, 10);
        vm.prank(donator_1);
        funder.fund{value: 10}(id);

        // deadline reached, goal not met
        vm.warp(1002);
        vm.prank(donator_1);
        funder.refund(id);
        assertEq(donator_1.balance, 10);
    }
}
