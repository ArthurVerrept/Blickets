
// This file simple chooses whether to use the contract address from
// local blockchain or from rinkeby depending on where it has been deployed
const localTicket = require('../abis/Ticket.json')
const rinkebyAddress = '0xE18D4b51248b6D6c50519d41A1548e6F0391322A'

// @ts-ignore
const contractAddress = process.env.NODE_ENV === 'true' ? localTicket.networks['5777'].address : rinkebyAddress
const isLocal = process.env.NODE_ENV === 'true'

module.exports = { isLocal, contractAddress }
