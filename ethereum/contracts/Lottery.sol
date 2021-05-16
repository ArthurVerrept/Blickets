// SPDX-License-Identifier: MIT
pragma solidity >=0.7.5;


contract Lottery {
    address public manager;
    
    // create array of type payable address
    // the payable keyword attaches functions 
    // like transfer & send which are not on 
    // the default array function
    address payable[] public players;
    
    constructor () {
        // set manager of raffle to creator of contract
        manager = msg.sender;
    }
    
    function enter() public payable {
        // amount of ether required to enter the raffle
        require(msg.value > .01 ether);
        // add player into pool
        players.push(payable(msg.sender));
    }
    
    
    function pickWinner() public onlyManager{
        
        // pick an index from the winner array
        uint index = random() % players.length;
        
        // gets the payable address
        // it then transfers the entire balance of address (THIS) contract
        payable(players[index]).transfer(address(this).balance);
        
        // reset contract to origional state
        // create a new dynamic array of payable type address with an initial size of zero
        players = new address payable[](0);
    }
    
    
    //  get all players
    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }
    
    
    // this is a Function Modifier
    // solely used as a means to reduce the amount of code we need to write
    // this means that we can use this on any function
    modifier onlyManager() {
        // ensure that caller is the manager of contract to pick a winner
        require(msg.sender == manager);
        
        // this tells the compiler where to put the code of the fuction we are modifying
        // it simply puts it where the underscore is
        _;
    }
    
    
    // this is just a jank random number generator
    function random() private view returns (uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players)));
    }
}