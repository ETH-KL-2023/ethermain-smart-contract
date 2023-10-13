// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Registry} from "../src/Registry.sol";
import {Listing} from "../src/Listing.sol";

contract DeployScript is Script {
    // function setUp() public {}
    function run() public {
        // uint privKey = vm.envUint("PRIVATE_KEY");
        // address deployer = vm.rememberKey(privKey);
        // console2.log("Deployer: ", deployer);
        // console2.log("Deployer Nonce: ", vm.getNonce(deployer));
        // // vm.broadcast();
        vm.startBroadcast();

        Listing listing = new Listing(address(0));

        Registry registry = new Registry();
        
        listing.setRegistryContract(address(registry));

        vm.stopBroadcast();

        listing.setRegistryContract(address(registry));
        console2.log("Registry Contract Address: ", address(registry));
        console2.log("Listing Contract Address: ", address(listing));
    }
}
