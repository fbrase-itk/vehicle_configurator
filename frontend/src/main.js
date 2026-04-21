import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import App from './App.vue'
import Configurator from './pages/Configurator.vue'
import Summary from './pages/Summary.vue'

const routes = [
  { path: '/', component: Configurator },
  { path: '/config/:id', component: Configurator },
  { path: '/summary/:id', component: Summary }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

createApp(App).use(router).mount('#app')
