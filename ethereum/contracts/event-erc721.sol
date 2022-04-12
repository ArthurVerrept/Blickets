// SPDX-License-Identifier: MIT
pragma solidity >=0.7.5;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract EventFactory {
    address[] public deployedEvents;

    function createEvent(string memory _name, string memory _eventName, uint _ticketAmount, uint _ticketPrice, uint _resaleCost, string memory _tokenURI) public {
        address newCampaign = address(new Event(_name, _eventName, _ticketAmount, _ticketPrice, _resaleCost, _tokenURI, msg.sender));
        deployedEvents.push(newCampaign);
    }

    function getDeployedEvents() public view returns (address[] memory) {
        return deployedEvents;
    }
}

contract Event is ERC721URIStorage {
    bool private locked;
    address payable public owner;
    string public eventName;
    uint public ticketAmount;
    uint public ticketPrice;
    uint public ticketResalePrice;
    uint public resaleCost;
    uint public ticketIdCounter;
    string public tokenURI;
    uint[] public ticketsForSale;
    
    mapping(uint=>uint) indexOfAsset;

    
    uint[] private newTicketIds;
    uint[] private newTicketAmounts;
    
    constructor (string memory _name, string memory _eventName, uint _ticketAmount, uint _ticketPrice, uint _resaleCost, string memory _tokenURI, address _owner) payable ERC721(_name, "symbol") {
        // TODO: allow contract be setup with eth in already for resales
        // needs to be at least ticketAmount * ticketPrice + a lil bit for gas fees
        owner = payable(_owner);
        eventName = _eventName;
        ticketAmount = _ticketAmount;
        ticketPrice = _ticketPrice;
        resaleCost = _resaleCost;
        ticketResalePrice = ticketPrice + resaleCost;
        ticketIdCounter = 0;
        tokenURI = _tokenURI;
        locked = true;
    }
    
    function buyTickets (uint purchaseAmount, string memory URI) public payable {
        // only let each client buy a certain amount of tickets
        require(purchaseAmount <= ticketAmount, "bought more than maximum amount of tickets");
        
        // only let tickets be bought if price of ticket is paid
        require(msg.value == purchaseAmount * ticketPrice, "price paid for ticket is incorrect");
        
        // create array of id's and array of amounts to use for minting
        for (uint i = ticketIdCounter; i < ticketIdCounter + purchaseAmount; i++) {
            // safeMint mints tokens and if token already exists reverts
            _safeMint(msg.sender, i);
            _setTokenURI(i, URI);
        }
       

        
        // set ticket counter to correct amount
        ticketIdCounter = ticketIdCounter + purchaseAmount;
    }
    
    
    function setTicketsForSale (uint[] memory sellIds) public payable {
        require(isContractApprovedForAll(sellIds) == true, "Ticket must approved with contract to list for sale");
        require(isOwnerOfAll(sellIds, msg.sender) != address(0), "Must be owner of all tickets being set for sale");
        // TODO: require token is valid
        for (uint i = 0; i < sellIds.length; i++) {
            indexOfAsset[sellIds[i]] = ticketsForSale.length;
            ticketsForSale.push(sellIds[i]);
        }
    }
    
    
    function buyFromMarket (uint[] memory buyIds) external payable {
        require(isContractApprovedForAll(buyIds) == true, "Ticket must approved with contract to list for sale");
        // TODO: require token is valid
        // only let tickets be bought if price of ticket * amount of tickets + resale cost is paid
        require(msg.value >= buyIds.length * ticketPrice + resaleCost, "Price paid for ticket is incorrect");
        payable(ownerOf(buyIds[0])).transfer(buyIds.length * ticketPrice);
        for (uint i = 0; i < buyIds.length; i++) {
            
            // TODO: add to total made from resale
            // TODO: add to total count of resales
            
            // get the index of the id to remove from array
             uint index = indexOfAsset[buyIds[i]];
             
            //  if there is more than one ticket for sale
             if (ticketsForSale.length > 1) {
                //  find the ticket's id and replace it with the id in last position
                ticketsForSale[index] = ticketsForSale[ticketsForSale.length - 1];
             }
             
            //  remove last which is duplicate now
            ticketsForSale.pop();

            _transfer(ownerOf(buyIds[i]), msg.sender, buyIds[i]);
        }
        delete newTicketAmounts;
    }
    
    function isOwnerOfAll (uint[] memory tickets, address checkAddress) private view returns (address){
        address a;
        for (uint i=0; i < tickets.length; i++) {
            a = ownerOf(tickets[i]);
            if(a != checkAddress) {
                return address(0);
            }
        }
        return a;
    }
    
    function isContractApprovedForAll (uint[] memory tickets) private view returns (bool){
        address a;
        for (uint i=0; i < tickets.length; i++) {
            a = getApproved(tickets[i]);
            if(a != address(this)) {
                return false;
            }
        }
        return true;
    }
    
    function isTicketSellableAll (uint[] memory tickets) private view returns (bool){
        address a;
        for (uint i=0; i < tickets.length; i++) {
            a = getApproved(tickets[i]);
            if(a != address(this)) {
                return false;
            }
        }
        return true;
    }
    
    function eventBalance () public view returns (uint){
        return address(this).balance;
    }
    
    function getTicketsForSale () public view returns (uint[] memory){
        return ticketsForSale;
    }
    
    
    
    // in the future these two functions would only be "locked" before the event had taken place
    // once the event is done, these functions would be allowed by anything to essentially "unlock"
    // tickets from the original site and ticket price restrictions etc
    
    // this could be done with chainlink, or you could have the eventFactory contract be the only one who can
    // "unlock" contracts, this would mean saving the date the event is finished in a database of some sort,
    // and on that date "unlocking" the functions
    
    // block to owner as it won't be used and we don't want it as a loophole to send tickets
    function safeTransferFrom(address from, address to, uint256 tokenId) public override ownerOrUnlocked {
        super.safeTransferFrom(from, to, tokenId);
    }
    
    // block to owner as it won't be used and we don't want it as a loophole to send tickets
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override ownerOrUnlocked {
        super.safeTransferFrom(from, to, tokenId, data);
    }
    
    // block to owner transferFrom as it won't be used and we don't want it as a loophole to send tickets
    function transferFrom(address from, address to, uint256 tokenId) public override ownerOrUnlocked {
        super.transferFrom(from, to, tokenId);
    }
    
    // If not owner or "unlocked" disallow
    modifier ownerOrUnlocked() {
        require(msg.sender == address(this) || msg.sender == owner || locked == false, "ModifiedAccessControl: cannot use function unless you are tbe owner, or the event has finished/ tickets have been unlocked");
        // Otherwise, it continues.
        _;                              
    }
    
    // If owner
    modifier onlyOwner() {
        require(msg.sender == owner);
        // Otherwise, it continues.
        _;                              
    } 
}
