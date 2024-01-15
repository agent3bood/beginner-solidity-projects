pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "../src/Token.sol";

contract DeployGLDToken is Script {
    function run() external {
        vm.startBroadcast();
        new GLDToken();
        vm.stopBroadcast();
    }
}
