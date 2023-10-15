// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {RegistryMNT} from "./RegistryMNT.sol";

contract ListingMNT{
    RegistryMNT public registryContract;

    constructor(address _registry) {
        // require(_registry != address(0), "Invalid registry address");
        registryContract = RegistryMNT(_registry);
    }

    struct DomainName{
        uint256 tokenId;
        uint256 price;
    }
    
    mapping(uint256 => DomainName) public listing;

    //1=Taiko
    //2=Mantle all wei * 5000

    //FUNCTIONS THAT NEED NETWORK PARAMETER
    // list
    // buy

    function setRegistryContract(address _registry) public{
        require(_registry != address(0), "Invalid registry address");
        registryContract = RegistryMNT(_registry);
    }
    
    function getRegistryContract() public view returns(address){
        return address(registryContract);
    }

    //_price in wei
    function list(uint256 _tokenId, uint256 _price) public{ //add
        //check if _price is 0
        require(_price != 0, "Price cannot be 0");
        //check if domain name is already listed
        require(listing[_tokenId].tokenId == 0, "Domain name is already listed");
        //check if domain name is in registry
        require(registryContract.checkDomainNameListExpiry(_tokenId, registryContract.getDomainName(_tokenId))!=0, "Domain name is not in registry");
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
        require(domainName.tokenId != 0, "Domain name is not listed");
        //owner cannot buy own domain name
        require(registryContract.getOwnerAddressByTokenId(_tokenId) != msg.sender, "Owner cannot buy own domain name");
        require(registryContract.checkDomainNameListExpiry(_tokenId, registryContract.getDomainName(_tokenId))> block.timestamp, "Domain name expired");
        require(msg.value >= domainName.price, "Insufficient funds");

        address payable seller = payable(registryContract.getOwnerAddressByTokenId(_tokenId));
        seller.transfer(domainName.price);

        registryContract.updateOwner(_tokenId, msg.sender);
        // listing[_tokenId].tokenId = 0;
        delete listing[_tokenId];
    }

    function getListingPrice(uint256 _tokenId) public view returns(uint256){
        return (listing[_tokenId].price);
    }

    //give function the token id and return the 
    //tokenid, price, domain name, owner address
    function getListingData(uint256 _tokenId)public view returns(uint256, uint256, string memory, address){
        DomainName memory domainName = listing[_tokenId];
        require(domainName.tokenId != 0, "Domain name is not listed");

        //return the tokenid, price, domain name, owner address
        return (listing[_tokenId].tokenId, 
        listing[_tokenId].price, 
        registryContract.getDomainName(_tokenId), 
        registryContract.getOwnerAddressByTokenId(_tokenId));
    }

    //NEED FIXES
    //type domain name return tokenId
    // function getListingTokenId(string memory _domainName) public view returns(uint256){
    //     return registryContract.getTokenIdByDomainName(_domainName);
    // }
}
