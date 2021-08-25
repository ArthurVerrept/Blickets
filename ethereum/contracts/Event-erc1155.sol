// SPDX-License-Identifier: MIT
pragma solidity >=0.7.5;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract EventFactory {
    address[] public deployedEvents;

    function createEvent(string memory _name, string memory _eventName, uint _ticketAmount, uint _ticketPrice) public {
        address newCampaign = address(new Event(_name, _eventName, _ticketAmount, _ticketPrice, msg.sender));
        deployedEvents.push(newCampaign);
    }

    function getDeployedEvents() public view returns (address[] memory) {
        return deployedEvents;
    }
}

contract Event is ERC1155 {
    bool private locked;
    address payable public owner;
    address payable public approver;
    string public name;
    string public eventName;
    uint public ticketAmount;
    uint public ticketPrice;
    uint public ticketIdCounter;
    uint[] public ticketsForSale;
    
    mapping(uint => address) public userTickets;
    mapping(uint => address) private ticketForSaleOwner;
    
    uint[] private newTicketIds;
    uint[] private newTicketAmounts;
    
    constructor (string memory _name, string memory _eventName, uint _ticketAmount, uint _ticketPrice, address _owner) payable ERC1155("https://gateway.pinata.cloud/ipfs/QmdwgewVHvfCMT8HhJ6oYf4hCQWzPQHrrf7dEvBaaM5Vyj/{id}.json") {
        owner = payable(_owner);
        name = _name;
        eventName = _eventName;
        ticketAmount = _ticketAmount;
        ticketPrice = _ticketPrice;
        ticketIdCounter = 0;
        locked = true;
    }
    
    function buyTickets (uint purchaseAmount) public payable {
        // only let each client buy a certain amount of tickets
        require(purchaseAmount <= 10, "bought more than maximum amount of tickets");
        
        // only let tickets be bought if price of ticket is paid
        require(msg.value == purchaseAmount * ticketPrice, "price paid for ticket is incorrect");
        
        // create array of id's and array of amounts to use for minting
        for (uint i = ticketIdCounter; i < ticketIdCounter + purchaseAmount; i++) {
            newTicketIds.push(i);
            newTicketAmounts.push(1);
            userTickets[i] = msg.sender;
        }
        _mintBatch(msg.sender, newTicketIds, newTicketAmounts, "");
        
        // set ticket counter to correct amount
        ticketIdCounter = ticketIdCounter + purchaseAmount;
        
        // reset arrays
        delete newTicketIds;
        delete newTicketAmounts;
    }
    
    function setTicketsForSale (uint[] memory sellIds, address payable _approver) public payable {
        for (uint i = 0; i < sellIds.length; i++) {
            require(balanceOf(msg.sender, sellIds[i]) == 1, "Must own ticket to for sell");
            ticketsForSale.push(sellIds[i]);
            ticketForSaleOwner[sellIds[i]] = msg.sender;
        }
        approver = _approver;
        setApprovalForAll(_approver, true);
    }
    
    function transferTickets (uint[] memory buyIds, address payable _to) public payable {
        // only let tickets be bought if price of ticket is paid (+ add event profit after)
        require(msg.value == buyIds.length * ticketPrice, "price paid for ticket is incorrect");
        for (uint i = 0; i < buyIds.length; i++) {
            // require owner has set this ticket for sale
            require(ticketForSaleOwner[buyIds[i]] != address(0));
            TransferSingle(approver, ticketForSaleOwner[buyIds[i]], _to, buyIds[i], 1);
            userTickets[buyIds[i]] = msg.sender;
        }
        delete newTicketAmounts;
    }

    
    function getTickets () public view returns (uint[] memory) {
        uint[] storage userTicketsArray;
        for (uint i = 0; i < ticketIdCounter; i++) {
            if(userTickets[i] == msg.sender){
                userTicketsArray.push(i);
            }
        }
    }
    
    // in the future these two functions would only be "locked" before the event had taken place
    // once the event is done, these functions would be allowed by anything to essentially "unlock"
    // tickets from the original site and ticket price restrictions etc
    
    // this could be done with chainlink, or you could have the eventFactory contract be the only one who can
    // "unlock" contracts, this would mean saving the date the event is finished in a database of some sort,
    // and on that date "unlocking" the functions
    
    // block to owner as it won't be used and we don't want it as a loophole to send tickets
    function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public override ownerOrUnlocked {
        
    }
    
    // block to owner transferFrom as it won't be used and we don't want it as a loophole to send tickets
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) public override ownerOrUnlocked {
        
    }
    
    // If not owner or "unlocked" disallow
    modifier ownerOrUnlocked() {
        require(msg.sender == owner || locked == false, "ModifiedAccessControl: cannot use function unless owner or event has finished");
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






