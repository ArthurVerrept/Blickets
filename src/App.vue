<template>
  <body>
    <index
      :address="address"
      :tokenAddress="tokenAddress"
      :message="message"
      :balance="balance"

    />
    <button @click="connectMetaMask()">connect</button>
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
  @State('address', { namespace }) address!: string
  @State('tokenAddress', { namespace }) tokenAddress!: string
  @State('message', { namespace }) message!: string
  @State('balance', { namespace }) balance!: string

  async connectMetaMask () {
    await this.linkMetaMask()
    await this.getAccounts()
  }
}
</script>
