import { VuexModule, Module, Mutation, Action } from 'vuex-module-decorators'
import { IRootStore } from './core/store'
import { Contract } from 'web3-eth-contract'
import Web3 from 'web3'
import contractAbi from '../abis/Ticket.json'

type DevTypes = {
  contractAddress: string
  isLocal: boolean
}

const { contractAddress, isLocal }:DevTypes = require('../development/contractAddress')
const { alchemy } = require('../secrets')

@Module({
  namespaced: true
})
// eslint-disable-next-line no-use-before-define
export class helloWorldModule extends VuexModule<IRootStore> {
    address: string = ''
    tokenAddress: string = ''
    contract!: Contract
    balance: number | null = null
    web3!: Web3
    message: string = ''

    @Mutation
    setAddress (address: string[]) {
      this.address = address[0]
    }

    @Mutation
    setBalance (balance: number) {
      this.balance = balance
    }

    @Mutation
    setMessage (message: string) {
      this.message = message
    }

    @Mutation
    setTokenAddress (tokenAddress: string) {
      this.tokenAddress = tokenAddress
    }

    @Mutation
    setContract (contract: Contract) {
      this.contract = contract
    }

    @Mutation
    setWeb3 (web3: Web3) {
      this.web3 = web3
    }

    @Action({ rawError: true })
    async linkMetaMask () {
      console.log(isLocal)
      if (isLocal === false) {
        const web3 = new Web3(alchemy)
        this.context.commit('setWeb3', web3)
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' })
        this.context.commit('setAddress', accounts)
      } else {
        const web3 = new Web3(window.web3.currentProvider) as Web3
        this.context.commit('setWeb3', web3)
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' })
        this.context.commit('setAddress', accounts)
      }
    }

    @Action({ rawError: true })
    async getAccounts () {
      if (this.address.length) {
        const abi: any = contractAbi.abi
        this.context.commit('setTokenAddress', contractAddress)

        const balance = await this.web3.eth.getBalance(this.address)
        this.context.commit('setBalance', parseInt(balance) / 1e18)

        const contract = new this.web3.eth.Contract(abi, contractAddress)
        this.context.commit('setContract', contract)

        const message = await contract.methods.message().call()
        console.log(message)
        this.context.commit('setMessage', message)
      } else {
        throw new Error('Smart contract not deployed to detected network')
      }
    }
}
