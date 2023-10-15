#!/bin/bash

# Load the variables in .env file 
source .env

forge script script/DeployMantle.s.sol:MantleDeployScript --rpc-url $MANTLE_TESTNET_RPC --private-key $PRIVATE_KEY --broadcast --verify  -vvvv --legacy

forge script script/Deploy.s.sol:DeployScript --rpc-url $MANTLE_TESTNET_RPC --private-key $PRIVATE_KEY --broadcast --verify  -vvvv --legacy

forge script script/Deploy.s.sol:DeployScript --rpc-url $TAIKO_TESTNET_RPC --private-key $PRIVATE_KEY --broadcast --verify -vvvv --legacy

# forge script script/Registry.s.sol:RegistryScript --rpc-url $MANTLE_TESTNET_RPC --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $TAIKO_ETHERSCAN_API_KEY --watch
# forge script script/Registry.s.sol:RegistryScript --rpc-url $MANTLE_TESTNET_RPC --private-key $PRIVATE_KEY --broadcast -vvvv --legacy
# forge script script/PostAndResolver.s.sol:Deploy --rpc-url $ARB_GOERLI_RPC --private-key $PRIVATE_KEY --broadcast --verify --verifier-url https://api-goerli.arbiscan.io/api -vvvvx


# forge script script/Deploy.s.sol:Deploy --rpc-url $MANTLE_TESTNET_RPC --private-key $PRIVATE_KEY --broadcast --verify  -vvvv --legacy