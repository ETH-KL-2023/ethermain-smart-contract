// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {RegistryMNT} from "../src/RegistryMNT.sol";
import {ListingMNT} from "../src/ListingMNT.sol";

contract MantleDeployScript is Script {
    function run() public {
        vm.startBroadcast();

        ListingMNT listing = new ListingMNT(address(0));

        RegistryMNT registry = new RegistryMNT();
        
        listing.setRegistryContract(address(registry));
 
        vm.stopBroadcast();

        listing.setRegistryContract(address(registry));
        console2.log("Mantle Registry Contract Address: ", address(registry));
        console2.log("Mantle Listing Contract Address: ", address(listing));
    }
}
