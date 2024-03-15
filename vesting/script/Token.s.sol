pragma solidity ^0.8.23;

import {Script} from "forge-std/Script.sol";
import {Token} from "../src/Token.sol";

contract DeployToken is Script {
    function run() external {
        vm.startBroadcast();
        new Token();
        vm.stopBroadcast();
    }
}
