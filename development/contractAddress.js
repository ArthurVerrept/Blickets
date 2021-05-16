
// This file simple chooses whether to use the contract address from
// local blockchain or from rinkeby depending on where it has been deployed
const localTicket = require('../abis/Lottery.json')
const rinkebyAddress = '0x183864E8c3945369E0e484bA32b6De44F627abA3'

// @ts-ignore
const contractAddress = process.env.NODE_ENV === 'true' ? localTicket.networks['5777'].address : rinkebyAddress
const isLocal = process.env.NODE_ENV === 'true'

module.exports = { isLocal, contractAddress }
