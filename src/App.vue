<template>
  <body>
    <div v-if="!isMetaInstalled">
      <p>{{'DOWNLOAD META MASK BRUH'}}</p>
      <a href="https://metamask.io/" target="blank">download</a>
    </div>
    <div v-else>
    <index
      :account="account"
      :tokenAddress="tokenAddress"
      :message="message"
      :balance="balance"

    />
    <button @click="connectMetaMask()">connect</button>
    </div>
  </body>
</template>

<script lang="ts">
import Vue from 'vue'
import index from './components/index.vue'
import { Component } from 'vue-property-decorator'

import { Action, State } from 'vuex-class'

const namespace = 'hello'

@Component({
  name: 'App',
  components: {
    index
  }
})
export default class App extends Vue {
  @Action('linkMetaMask', { namespace }) linkMetaMask!: any
  @Action('getAccounts', { namespace }) getAccounts!: any
  @State('account', { namespace }) account!: string
  @State('tokenAddress', { namespace }) tokenAddress!: string
  @State('message', { namespace }) message!: string
  @State('balance', { namespace }) balance!: string

  isMetaInstalled = false

  beforeMount () {
    if (!window.ethereum) {
      this.isMetaInstalled = false
    } else {
      this.isMetaInstalled = true
      // Watching for metamask changes
      window.ethereum.on('accountsChanged', () => {
        // If new account selected in metamask
        location.reload()
      })
      window.ethereum.on('chainChanged', () => {
        // If new network selected in metamask
        location.reload()
      })
    }
  }

  async connectMetaMask () {
    await this.linkMetaMask()
    await this.getAccounts()
  }
}
</script>
