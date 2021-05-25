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
    address payable public owner;
    string public name;
    string public eventName;
    uint public ticketAmount;
    uint public ticketPrice;
    uint public ticketIdCounter;
    
    mapping(address => uint[]) public userTickets;
    
    uint[] private newTicketIds;
    uint[] private newTicketAmounts;
    
    constructor (string memory _name, string memory _eventName, uint _ticketAmount, uint _ticketPrice, address _owner) payable ERC1155("www.someshit.com") {
        owner = payable(_owner);
        name = _name;
        eventName = _eventName;
        ticketAmount = _ticketAmount;
        ticketPrice = _ticketPrice;
        ticketIdCounter = 0;
        uri(0);
        _setURI("www.token-uri.com");
    }
    
    function buyTickets (uint purchaseAmount) public payable {
        
        require(purchaseAmount <= 10, "bought more than maximum amount of tickets");
        uint max = ticketIdCounter + purchaseAmount;
        for (uint i = ticketIdCounter; i < max; i++) {
            newTicketIds.push(i);
            newTicketAmounts.push(1);
        }
        _mintBatch(msg.sender, newTicketIds, newTicketAmounts, "");
        userTickets[msg.sender] = newTicketIds;
        ticketIdCounter = ticketIdCounter + purchaseAmount;
        delete newTicketIds;
        delete newTicketAmounts;
    }
    
    // address operator, address from, address to, uint256[] ids, uint256[] amounts, bytes data
    function _beforeTokenTransfer(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _amounts)
        public payable virtual
    {
        // if this is a transafer
        if(address(_from) != address(0) && address(_to) != address(0)) {
            require(msg.value == ticketPrice * _ids.length, "price does not match");
        }
        // if this is a mint/mintBatch
        else if(address(_from) == address(0) && address(_to) != address(0)) {
            require(msg.value == ticketPrice * _ids.length, "mint not possible wrong price");
        }
        // first from is the operator see approval in erc1155 on eips.ethereum.org
        super._beforeTokenTransfer(_from, _from, _to, _ids, _amounts, "0x0");
        
    }

    
    function getTickets () public view returns (uint[] memory) {
        return userTickets[msg.sender];
    }
}






