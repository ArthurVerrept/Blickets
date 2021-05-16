// SPDX-License-Identifier: MIT

pragma solidity >=0.7.5;

contract Ticket {
    string public message;

    constructor () {
        message = 'this has been set up';
    }
    
    function setMessage(string memory newMessage) public {
        message = newMessage;
    }
}