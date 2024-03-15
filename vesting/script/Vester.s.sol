pragma solidity ^0.8.23;

import {Script} from "forge-std/Script.sol";
import {Vester} from "../src/Vester.sol";

contract DeployVester is Script {
    function run() external {
        vm.startBroadcast();
        new Vester();
        vm.stopBroadcast();
    }
}
