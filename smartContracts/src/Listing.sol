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

    function setRegistryContract(address _registry) public{
        require(_registry != address(0), "Invalid registry address");
        registryContract = Registry(_registry);
    }
    
    function getRegistryContract() public view returns(address){
        return address(registryContract);
    }

    function list(uint256 _tokenId, uint256 _price) public{ //add
        //if expired cannot list
        require(registryContract.checkDomainNameListExpiry(_tokenId, registryContract.getDomainName(_tokenId))> block.timestamp, "Domain name expired");
        DomainName memory newListingData = DomainName({
            tokenId: _tokenId,
            price: _price
        });
        listing[_tokenId] = newListingData;
    }
    
    function relist(uint256 _tokenId, uint256 _newPrice) public{ //change price of the dns
        //if expired cannot list
        require(registryContract.checkDomainNameListExpiry(_tokenId, registryContract.getDomainName(_tokenId))> block.timestamp, "Domain name expired");
        require(listing[_tokenId].tokenId != 0, "Domain name is not listed");
        listing[_tokenId].price = _newPrice;
    }

    function delist(uint256 _tokenId) public{ //remove from marketplace
        require(listing[_tokenId].tokenId != 0, "Domain name is not listed");
        // listing[_tokenId].tokenId = 0;
        delete listing[_tokenId];
    }

    function getBalance() public view returns (uint256) {
        return address(msg.sender).balance;
    }

    function buy(uint256 _tokenId) public payable{  //buy the dns
        //if domain name expired, buyer cant buy
        DomainName memory domainName = listing[_tokenId];
        require(registryContract.checkDomainNameListExpiry(_tokenId, registryContract.getDomainName(_tokenId))> block.timestamp, "Domain name expired");
        require(msg.value >= domainName.price, "Insufficient funds");
        require(domainName.tokenId != 0, "Domain name is not listed");
        // payable registryContract.getAddressByDomainName(_tokenId).transfer(domainName.price);

        address payable seller = payable(registryContract.getOwnerAddressByTokenId(_tokenId));
        seller.transfer(domainName.price);

        registryContract.updateOwner(_tokenId, msg.sender);
        // listing[_tokenId].tokenId = 0;
        delete listing[_tokenId];
    }

    function getListingData(uint256 _tokenId) public view returns(uint256){
        return (listing[_tokenId].price);
    }

}
