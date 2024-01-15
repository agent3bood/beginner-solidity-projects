pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "../src/NFT.sol";

contract DeployGLDNFT is Script {
    function run() external {
        vm.startBroadcast();
        new GLDNFT();
        vm.stopBroadcast();
    }
}
