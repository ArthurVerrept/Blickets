// SPDX-License-Identifier: MIT
pragma solidity >=0.7.5;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract EventFactory {
    address[] public deployedEvents;

    function createEvent(string memory _name, string memory _symbol, string memory _eventName, uint _ticketAmount, uint _ticketPrice) public {
        address newCampaign = address(new Event(_name, _symbol, _eventName, _ticketAmount, _ticketPrice, msg.sender));
        deployedEvents.push(newCampaign);
    }

    function getDeployedEvents() public view returns (address[] memory) {
        return deployedEvents;
    }
}

contract Event is ERC721URIStorage {
    address payable public owner;
    string public eventName;
    string public tokenUri;
    uint public ticketAmount;
    uint public ticketPrice;
    uint public tokenCounter;
    
    mapping(address => uint[]) private userTickets;
    
    constructor (string memory _name, string memory _symbol, string memory _eventName, uint _ticketAmount, uint _ticketPrice, address _owner) payable ERC721(_name, _symbol) {
        owner = payable(_owner);
        ticketAmount = _ticketAmount;
        ticketPrice = _ticketPrice;
        eventName = _eventName;
        tokenUri = "www.pinata.com/tokenPicture";
        tokenCounter = 0;
    }
    
    function buyTickets (uint purchaseAmount) public payable {
        require(msg.value == ticketPrice * purchaseAmount, "mint not possible wrong price");
        require(purchaseAmount <= 10, "10 tickets maximum per person");
        require(tokenCounter + purchaseAmount <= ticketAmount, "tickets sold out");
        uint newTokenId = tokenCounter;
        for (uint i = 0; i < purchaseAmount; i++) {
            _mint(msg.sender, newTokenId);
            _setTokenURI(newTokenId, tokenUri);
            userTickets[msg.sender].push(newTokenId);
            newTokenId++;
            tokenCounter++;
        }
    }
    
    function setTicketsForSale (uint[] memory sellIds) public payable {
        for (uint i = 0; i < sellIds.length; i++) {
            approve(owner, sellIds[i]);
            
            // TODO - remove ids from userTickets mapping
        }
    }
    
    function transferTickets (uint[] memory buyIds, address payable _to) public payable {
        for (uint i = 0; i < buyIds.length; i++) {
            safeTransferFrom(owner, _to, buyIds[i]);
            userTickets[_to].push(buyIds[i]);
        }
    }
    
    function getTickets () public view returns (uint[] memory) {
        return userTickets[msg.sender];
    }
    
    // in the future these two functions would only be "locked" before the event had taken place
    // once the event is done, these functions would be allowed by anything to essentially "unlock"
    // tickets from the original site and ticket price restrictions etc
    
    // this could be done with chainlink, or you could have the eventFactory contract be the only one who can
    // "unlock" contracts, this would mean saving the date the event is finished in a database of some sort,
    // and on that date "unlocking" the functions
    
    // block to owner as it won't be used and we don't want it as a loophole to send tickets
    function safeTransferFrom(address from, address to, uint256 tokenId) public override onlyOwner {

    }
    
    // block to owner transferFrom as it won't be used and we don't want it as a loophole to send tickets
    function transferFrom(address from, address to, uint256 tokenId) public override onlyOwner {
        
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner); // If it is incorrect here, it reverts.
        _;                              // Otherwise, it continues.
    } 
    
    
    // block COMPLETELY this as it won't be used and we don't want it as a loophole to send tickets
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
        revert("ModifiedAccessControl: cannot safeTransferFrom with bytes - use safeTransferFrom with no bytes parameter");
    }
}






