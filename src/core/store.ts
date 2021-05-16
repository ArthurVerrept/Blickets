import Vue from 'vue'
import Vuex from 'vuex'

import { helloWorldModule } from '../store'

Vue.use(Vuex)

export interface IRootStore {
    hello: helloWorldModule
}

export default new Vuex.Store<IRootStore>({
  modules: {
    hello: helloWorldModule
  }
})
