/* eslint-disable no-undef */
const { assert } = require('chai')
const Ticket = artifacts.require('../contracts/Ticket')
const ticket = require('../abis/Ticket.json')
const { contractAddress } = require('../development/contractAddress')

require('chai')
  .use(require('chai-as-promised'))
  .should()

contract('Color', () => {
  let contract
  let web3Contract
  // let accounts

  beforeEach(async () => {
    contract = await Ticket.new()
    web3Contract = new web3.eth.Contract(ticket.abi, contractAddress)
  })

  describe('deployment', async () => {
    it('deploys successfully', async () => {
      const address = contract.address
      assert.notEqual(address, '')
      assert.notEqual(address, 0x0)
      assert.notEqual(address, null)
      assert.notEqual(address, undefined)
    })

    it('has a name', async () => {
      const name = await web3Contract.methods.message().call()
      assert.equal(name, 'this has been set up')
    })
  })
})
