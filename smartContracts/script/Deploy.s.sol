// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";

contract DeployScript is Script {
    // function setUp() public {}
    function run() public {
        uint privKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.rememberKey(privKey);
        console2.log("Deployer: ", deployer);
        console2.log("Deployer Nonce: ", vm.getNonce(deployer));
        // vm.broadcast();
        vm.startBroadcast();

        vm.stopBroadcast();
    }
}
