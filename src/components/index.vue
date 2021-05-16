<template>
  <v-container>
    <div>
      <p>Account Address: {{address}} </p>
      <p>Token Address: {{tokenAddress}} </p>
      <p>Balance: {{balance}} </p>
      <p>message: {{message}} </p>
      <!-- <p>Current Message: {{Message}} </p> -->
    </div>
  </v-container>
</template>

<script lang="ts">
import Vue from 'vue'
import { Component, Prop } from 'vue-property-decorator'

  @Component({
    name: 'index'
  })

export default class HelloWorld extends Vue {
  @Prop()
  address!: string

  @Prop()
  tokenAddress!: string

  @Prop()
  balance!: string

  @Prop()
  message!: string
}
</script>
