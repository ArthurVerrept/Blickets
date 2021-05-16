<template>
    <div>
      <p>Account Address: {{account}} </p>
      <p>Token Address: {{tokenAddress}} </p>
      <p>Balance: {{balance}} </p>
      <p>manager: {{message}} </p>
    </div>
</template>

<script lang="ts">
import Vue from 'vue'
import { Component, Prop } from 'vue-property-decorator'

  @Component({
    name: 'index'
  })

export default class HelloWorld extends Vue {
  @Prop()
  account!: string

  @Prop()
  tokenAddress!: string

  @Prop()
  balance!: string

  @Prop()
  message!: string
}
</script>
