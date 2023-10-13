// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Registry {

    struct DNSData {
        // address nftAddress; //identifier
        uint256 tokenId;    //identifier
        string domainName;
        address ownerAddress; //modifiable
        
        uint256 expiryDate; //ex: 1728458112

        string nameserver1; //modifiable
        string nameserver2; //modifiable
        string keytag; //modifiable
        string algorithm; //modifiable
        string digestType; //modifiable
        string digest; //modifiable

    }
    mapping(uint256 => DNSData) public registry;

    struct DomainData{
        string domainName;
        uint256 tokenId;
        uint256 expiryDate;
    }

    mapping(string => DomainData[]) public domainNameList;

    uint256 public registryLength = 0; // Variable to keep track of the number of elements in the mapping

    modifier checkExpiration(uint256 _expiryDate) {
        require(_expiryDate >= block.timestamp, "Domain has expired");
        _;
    }

    function getCurrentTime()public view returns(uint){
        return block.timestamp;
    }

    function getBalance() public view returns (uint256) {
        return address(msg.sender).balance;
    }

    function registerDNS(
        string memory _domainName,
        uint256 expiryPrice
        // address _nftAddress
        // string memory _nameserver,
        // string memory _keytag,
        // string memory _algorithm,
        // string memory _digestType
    ) public payable returns(uint256){
        // check if the domainName is already active or not
        DomainData[] storage existingDomains = domainNameList[_domainName];
        // Check if there are existing domains and if they are all expired
        bool allExpired = true;
        for (uint256 i = 0; i < existingDomains.length; i++) {
            if (existingDomains[i].expiryDate >= block.timestamp) {
                allExpired = false;
                break;
            }
        }
        // Register the domain only if all existing domains are expired
        require(allExpired, "Cannot register domain until existing domains expire");

        uint256 _expiryDate;
        uint256 _price;

        if (expiryPrice == 1) {
            _expiryDate = block.timestamp + 2592000; // 30 days
            _price = 10**16; // 0.01 ether in wei
        } else if (expiryPrice == 2) {
            _expiryDate = block.timestamp + 7776000; // 90 days
            _price = 25 * 10**15; // 0.025 ether in wei
        } else if (expiryPrice == 3) {
            _expiryDate = block.timestamp + 31536000; // 365 days
            _price = 50 * 10**15; // 0.05 ether in wei
        } else if (expiryPrice == 4) {
            _expiryDate = block.timestamp + 63072000; // 730 days
            _price = 10**17; // 0.1 ether in wei
        } else {
            revert("Invalid expiry price ID");
        }

        require(address(msg.sender).balance >= _price, "Insufficient contract balance");

        registryLength++;
        DNSData memory newDNSData = DNSData({
            domainName: _domainName,
            ownerAddress: msg.sender, // Set the owner to the sender of the transaction
            tokenId: registryLength,
            expiryDate: _expiryDate,

            nameserver1: "",
            nameserver2: "",
            keytag:      "",
            algorithm:   "",
            digestType:  "",
            digest:      ""
        });
        registry[registryLength] = newDNSData;

        DomainData memory newDomainData = DomainData(
            _domainName,
            registryLength,
            _expiryDate
        );
        // domainNameList[_domainName] = newDomainData;
        domainNameList[_domainName].push(newDomainData);
        
        //ACCEPT PAYMENT TO DEFAULT WALLET
        payable(address(0x1A10A9331F011D44eF360A3D416Ea8763e95F2C8)).transfer(_price);

        return registryLength;
    }


    function updateDNSData(
        uint256 _tokenId,
        // uint256 _expiryDate,
        string memory _newNameserver1,
        string memory _newNameserver2,
        string memory _newKeytag,
        string memory _newAlgorithm,
        string memory _newDigestType,
        string memory _newDigest
    ) public {
        DNSData storage dnsData = registry[_tokenId];
        require(msg.sender == dnsData.ownerAddress, "Only owner can update NFT data");
        require(registry[_tokenId].expiryDate >= block.timestamp, "Domain has expired");// if its not expired, can update

        dnsData.nameserver1 = _newNameserver1;
        dnsData.nameserver2 = _newNameserver2;
        dnsData.keytag = _newKeytag;
        dnsData.algorithm = _newAlgorithm;
        dnsData.digestType = _newDigestType;
        dnsData.digest = _newDigest;

    }

 // as long as owner owns the nft and domain name is still active, can update expiry date
    function updateExpiryDate(uint256 _tokenId, uint256 newExpiryDate) public checkExpiration(registry[_tokenId].expiryDate){ 
        //as long as owner owns the nft and not expired then can update
        require(registry[_tokenId].ownerAddress == msg.sender, "Only owner can update expiry date");
        require(registry[_tokenId].expiryDate >= block.timestamp, "Domain has expired");// if its not expired, can update

        //update registry expiry date
        DNSData storage dnsData = registry[_tokenId];
        dnsData.expiryDate = newExpiryDate;

        //imagine 2 same domain names
        //update domainNameList expiry date
        // DomainData storage domainData = domainNameList[dnsData.domainName];
        // domainData.expiryDate = newExpiryDate;

        // domainNameList[registry[_nftAddress].domainName][_nftAddress].expiryDate = newExpiryDate;

        DomainData[] storage domains = domainNameList[dnsData.domainName];
        for (uint256 i = 0; i < domains.length; i++) {
            if (domains[i].tokenId == _tokenId) {
                domains[i].expiryDate= newExpiryDate;
                break;
            }
        }
    }

    //change owner of the domain name
    function updateOwner(uint256 _tokenId, address newOwnerAddress) public checkExpiration(registry[_tokenId].expiryDate){
        // require(registry[_tokenId].expiryDate >= block.timestamp, "Domain has expired");// if its not expired, can update
        DNSData storage dnsData = registry[_tokenId];
        dnsData.ownerAddress = newOwnerAddress;
    }

    function showDNSdata(uint256 _tokenId) public view returns(DNSData memory) {
        return registry[_tokenId];
    }

//////////////////////////////////////////////////////////////////
/////////////////////ADDITIONAL FUNCTIONS/////////////////////////
//////////////////////////////////////////////////////////////////

    function getDomainsByDomainName(string memory domainName) public view returns (DomainData[] memory) {
        return domainNameList[domainName];
    }

    function getOwnerAddressByTokenId(uint256 _tokenId) public view returns (address) {
        return registry[_tokenId].ownerAddress;
    }

    function getDNSData(uint256 _tokenId) public view returns (DNSData memory) {
        return registry[_tokenId];
    }

    function getDomainName(uint256 _tokenId) public view returns (string memory) {
        return registry[_tokenId].domainName;
    }

    function checkDomainNameListExpiry(uint256 _tokenId, string memory _domainName) public view returns(uint256){
        DomainData[] storage domains = domainNameList[_domainName];
        for (uint256 i = 0; i < domains.length; i++) {
            if (domains[i].tokenId == _tokenId) {
                return domains[i].expiryDate;
            }
        }
        return 0;
    }

    function isExpiredDomainName(uint256 _tokenId) public view returns(string memory){
        if (registry[_tokenId].expiryDate >= block.timestamp){
            return "Domain name is still active";
        } else {
            return "Domain name has expired";
        }
    }

    function checkActiveDomainName(string memory _domainName) public view returns(uint256){
        DomainData[] storage domains = domainNameList[_domainName];
        for (uint256 i = 0; i < domains.length; i++) {
            if(domains[i].expiryDate>=block.timestamp){
                return domains[i].expiryDate;
            }
        }
        return 0;
    }
}
