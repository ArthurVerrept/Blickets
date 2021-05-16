import { VuexModule, Module, Mutation, Action } from 'vuex-module-decorators'
import { IRootStore } from './core/store'
import { Contract } from 'web3-eth-contract'
import Web3 from 'web3'
import contractAbi from '../ethereum/abis/Lottery.json'
const abi: any = contractAbi.abi

type DevTypes = {
  contractAddress: string
  isLocal: boolean
}

const { contractAddress }:DevTypes = require('../development/contractAddress')
// const { alchemy } = require('../secrets')

@Module({
  namespaced: true
})
// eslint-disable-next-line no-use-before-define
export class helloWorldModule extends VuexModule<IRootStore> {
    account: string = ''
    tokenAddress: string = ''
    contract!: Contract
    balance: number | null = null
    web3!: Web3
    message: string = ''

    @Mutation
    setAccounts (accounts: string[]) {
      this.account = accounts[0]
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
      if (window.ethereum) {
        const web3 = new Web3(window.ethereum)
        window.ethereum.request({ method: 'eth_requestAccounts' })
        const accounts = await web3.eth.getAccounts()
        this.context.commit('setWeb3', web3)
        this.context.commit('setAccounts', accounts)
      } else {
        console.log('metamask not installed')
      }
    }

    @Action({ rawError: true })
    async getAccounts () {
      this.context.commit('setTokenAddress', contractAddress)

      const balance = await this.web3.eth.getBalance(this.account)
      this.context.commit('setBalance', parseInt(balance) / 1e18)

      const contract = new this.web3.eth.Contract(abi, contractAddress)
      this.context.commit('setContract', contract)

      const message = await contract.methods.manager().call({ from: this.account })

      this.context.commit('setMessage', message)
    }
}
