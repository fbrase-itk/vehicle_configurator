<template>
  <div class="configurator">
    <div v-if="loading" class="loading">Loading options...</div>
    
    <template v-else>
      <div class="config-grid">
        <section class="option-section">
          <h2>Engine</h2>
          <div class="options">
            <div
              v-for="engine in options.engines"
              :key="engine.id"
              :class="['option-card', { selected: selected.engineId === engine.id }]"
              @click="select('engineId', engine.id)"
            >
              <h3>{{ engine.name }}</h3>
              <p>{{ engine.horsepower }} HP</p>
              <span class="price">{{ formatPrice(engine.price) }}</span>
            </div>
          </div>
        </section>

        <section class="option-section">
          <h2>Paint</h2>
          <div class="options">
            <div
              v-for="paint in options.paints"
              :key="paint.id"
              :class="['option-card paint-card', { selected: selected.paintId === paint.id }]"
              @click="select('paintId', paint.id)"
            >
              <div class="color-swatch" :style="{ background: paint.colorCode }"></div>
              <h3>{{ paint.name }}</h3>
              <span class="price">{{ formatPrice(paint.price) }}</span>
            </div>
          </div>
        </section>

        <section class="option-section">
          <h2>Wheels</h2>
          <div class="options">
            <div
              v-for="wheel in options.wheels"
              :key="wheel.id"
              :class="['option-card', { selected: selected.wheelId === wheel.id }]"
              @click="select('wheelId', wheel.id)"
            >
              <h3>{{ wheel.name }}</h3>
              <p>{{ wheel.size }}</p>
              <span class="price">{{ formatPrice(wheel.price) }}</span>
            </div>
          </div>
        </section>

        <section class="option-section">
          <h2>Special Equipment (max 5)</h2>
          <div class="options">
            <div
              v-for="eq in options.equipment"
              :key="eq.id"
              :class="['option-card', { selected: selected.equipmentIds.includes(eq.id), disabled: !selected.equipmentIds.includes(eq.id) && selected.equipmentIds.length >= 5 }]"
              @click="toggleEquipment(eq.id)"
            >
              <h3>{{ eq.name }}</h3>
              <p>{{ eq.description }}</p>
              <span class="price">{{ formatPrice(eq.price) }}</span>
            </div>
          </div>
        </section>
      </div>

      <aside class="price-summary">
        <h2>Total Price</h2>
        <div class="total">{{ formatPrice(totalPrice) }}</div>
        <button @click="saveAndContinue" class="btn-primary" :disabled="!isValid">
          Continue to Summary
        </button>
      </aside>
    </template>
  </div>
</template>

<script>
import { fetchOptions, getConfiguration, saveConfiguration } from '../services/api.js'

export default {
  data() {
    return {
      loading: true,
      options: { engines: [], paints: [], wheels: [], equipment: [] },
      selected: { engineId: null, paintId: null, wheelId: null, equipmentIds: [] }
    }
  },
  computed: {
    totalPrice() {
      let total = 0
      if (this.selected.engineId) {
        const engine = this.options.engines.find(e => e.id === this.selected.engineId)
        if (engine) total += Number(engine.price)
      }
      if (this.selected.paintId) {
        const paint = this.options.paints.find(p => p.id === this.selected.paintId)
        if (paint) total += Number(paint.price)
      }
      if (this.selected.wheelId) {
        const wheel = this.options.wheels.find(w => w.id === this.selected.wheelId)
        if (wheel) total += Number(wheel.price)
      }
      for (const eqId of this.selected.equipmentIds) {
        const eq = this.options.equipment.find(e => e.id === eqId)
        if (eq) total += Number(eq.price)
      }
      return total
    },
    isValid() {
      return this.selected.engineId && this.selected.paintId && this.selected.wheelId
    }
  },
  async mounted() {
    this.options = await fetchOptions()
    
    const configId = this.$route.params.id
    if (configId) {
      const data = await getConfiguration(configId)
      if (data?.configuration) {
        const config = data.configuration
        this.selected.engineId = config.engine?.id
        this.selected.paintId = config.paint?.id
        this.selected.wheelId = config.wheel?.id
        this.selected.equipmentIds = config.equipment?.map(e => e.id) || []
      }
    }
    
    this.loading = false
  },
  methods: {
    formatPrice(price) {
      return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD'
      }).format(price)
    },
    select(key, id) {
      this.selected[key] = id
    },
    toggleEquipment(id) {
      const idx = this.selected.equipmentIds.indexOf(id)
      if (idx > -1) {
        this.selected.equipmentIds.splice(idx, 1)
      } else if (this.selected.equipmentIds.length < 5) {
        this.selected.equipmentIds.push(id)
      }
    },
    async saveAndContinue() {
      const result = await saveConfiguration(this.selected)
      this.$router.push(`/summary/${result.id}`)
    }
  }
}
</script>

<style scoped>
.configurator {
  display: grid;
  grid-template-columns: 1fr 300px;
  gap: 2rem;
}

.loading {
  grid-column: 1 / -1;
  text-align: center;
  padding: 4rem;
  font-size: 1.2rem;
  color: rgba(255, 255, 255, 0.6);
}

.config-grid {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.option-section h2 {
  font-size: 1.2rem;
  margin-bottom: 1rem;
  color: rgba(255, 255, 255, 0.9);
}

.options {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 1rem;
}

.option-card {
  background: rgba(255, 255, 255, 0.05);
  border: 2px solid transparent;
  border-radius: 12px;
  padding: 1.25rem;
  cursor: pointer;
  transition: all 0.2s ease;
}

.option-card:hover {
  background: rgba(255, 255, 255, 0.1);
  transform: translateY(-2px);
}

.option-card.selected {
  border-color: #00d4ff;
  background: rgba(0, 212, 255, 0.1);
}

.option-card.disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.option-card h3 {
  font-size: 1rem;
  margin-bottom: 0.5rem;
}

.option-card p {
  font-size: 0.875rem;
  color: rgba(255, 255, 255, 0.6);
  margin-bottom: 0.75rem;
}

.option-card .price {
  display: inline-block;
  padding: 0.25rem 0.75rem;
  background: rgba(124, 58, 237, 0.2);
  border-radius: 20px;
  font-size: 0.875rem;
  color: #a78bfa;
}

.paint-card {
  text-align: center;
}

.color-swatch {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  margin: 0 auto 1rem;
  border: 3px solid rgba(255, 255, 255, 0.2);
}

.price-summary {
  position: sticky;
  top: 2rem;
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(10px);
  border-radius: 16px;
  padding: 1.5rem;
  height: fit-content;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.price-summary h2 {
  font-size: 1rem;
  color: rgba(255, 255, 255, 0.6);
  margin-bottom: 0.5rem;
}

.price-summary .total {
  font-size: 2rem;
  font-weight: 700;
  background: linear-gradient(90deg, #00d4ff, #7c3aed);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  margin-bottom: 1.5rem;
}

.btn-primary {
  width: 100%;
  padding: 1rem;
  background: linear-gradient(90deg, #00d4ff, #7c3aed);
  border: none;
  border-radius: 8px;
  color: #fff;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.2s, opacity 0.2s;
}

.btn-primary:hover:not(:disabled) {
  transform: scale(1.02);
}

.btn-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

@media (max-width: 900px) {
  .configurator {
    grid-template-columns: 1fr;
  }
  
  .price-summary {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    border-radius: 16px 16px 0 0;
    z-index: 100;
  }
}
</style>
