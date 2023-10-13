// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import {Registry} from "./Registry.sol";
import {Registry} from "./Registry.sol";

contract Listing{
    Registry public registryContract;

    constructor(address _registry) {
        // require(_registry != address(0), "Invalid registry address");
        registryContract = Registry(_registry);
    }

    struct DomainName{
        uint256 tokenId;
        uint256 price;
    }
    
    mapping(uint256 => DomainName) public listing;

}