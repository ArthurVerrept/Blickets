const { assert } = require('chai')

/* eslint-disable no-undef */
const Lottery = artifacts.require('../contracts/Lottery.sol')

require('chai')
  .use(require('chai-as-promised'))
  .should()

contract('Lottery Test', () => {
  let contract
  let web3Contract
  let accounts

  beforeEach(async () => {
    contract = await Lottery.new()
    accounts = await web3.eth.getAccounts()
    // use contract deployed in test context abi and address
    web3Contract = new web3.eth.Contract(contract.abi, contract.address)
  })

  describe('Deployment', async () => {
    it('deploys successfully', async () => {
      const address = contract.address
      assert.notEqual(address, '')
      assert.notEqual(address, 0x0)
      assert.notEqual(address, null)
      assert.notEqual(address, undefined)
    })
  })

  describe('Smart contract methods', async () => {
    it('allows one account to enter the lottery', async () => {
      // enter account 0 from ganace and lottery with value (amount to enter with in ether converted to wei)
      await web3Contract.methods.enter().send({
        from: accounts[0],
        value: web3.utils.toWei('0.02', 'ether')
      })
      const players = await web3Contract.methods.getPlayers().call({ from: accounts[0] })
      // test that account entered is correct
      assert.equal(accounts[0], players[0])
      assert.equal(players.length, 1)
    })

    it('allows multiple account to enter the lottery', async () => {
      await web3Contract.methods.enter().send({
        from: accounts[0],
        value: web3.utils.toWei('0.02', 'ether')
      })

      await web3Contract.methods.enter().send({
        from: accounts[1],
        value: web3.utils.toWei('0.02', 'ether')
      })
      const players = await web3Contract.methods.getPlayers().call({ from: accounts[0] })
      // test that account entered is correct
      assert.equal(accounts[0], players[0])
      assert.equal(accounts[1], players[1])
      assert.equal(players.length, 2)
    })

    it('requires more than 0.01 ether to enter', async () => {
      await web3Contract.methods.enter().send({
        from: accounts[1],
        value: web3.utils.toWei('0.009', 'ether')
      }).should.be.rejected
    })

    it('only allows manager (contract creator) to use the pick winner function', async () => {
      // have to enter for test to not fail for some reason
      await web3Contract.methods.enter().send({
        from: accounts[0],
        value: web3.utils.toWei('0.02', 'ether')
      })
      await web3Contract.methods.pickWinner().send({
        from: accounts[1]
      }).should.be.rejected
    })

    it('sends money to the winner and resets the players array', async () => {
      await web3Contract.methods.enter().send({
        from: accounts[0],
        value: web3.utils.toWei('2', 'ether')
      })

      // check balance before picking winner (98 eth after entering 2)
      const initialBalance = await web3.eth.getBalance(accounts[0])

      // pick winner from players (only one)
      await web3Contract.methods.pickWinner().send({ from: accounts[0] })

      // get final balance (98 + winnings of 2 ether minus gas fees)
      const finalBalance = await web3.eth.getBalance(accounts[0])

      // get difference (amount returned from winnings)
      const difference = finalBalance - initialBalance

      // make sure its around 2 ether minus gas fees (greater than 1.8 ether)
      assert(difference > web3.utils.toWei('1.8', 'ether'))

      // check players are reset
      const players = await web3Contract.methods.getPlayers().call({ from: accounts[0] })
      assert.equal(players.length, 0)

      // check contract has balance of 0
      const contractBalance = await web3.eth.getBalance(contract.address)
      assert.equal(contractBalance, 0)
    })
  })
})
