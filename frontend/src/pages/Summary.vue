<template>
  <div class="summary">
    <div v-if="loading" class="loading">Loading configuration...</div>
    <div v-else-if="!config" class="error">Configuration not found</div>
    
    <template v-else>
      <Teleport to="#header-actions">
        <button @click="goBack" class="btn-back header-back" type="button" aria-label="Back to configurator">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
            <line x1="19" y1="12" x2="5" y2="12"></line>
            <polyline points="12 19 5 12 12 5"></polyline>
          </svg>
          <span>Back</span>
        </button>
      </Teleport>

      <div class="summary-content">
        <h2>Your Configuration</h2>

        <div class="config-layout">
          <div class="preview-col">
            <CarPreview3D
              :paintColor="config.paint?.colorCode || '#BF0012'"
              :paintName="config.paint?.name"
              :wheelColor="config.wheelColor?.colorCode || '#000000'"
              :wheelDesign="config.wheelDesign?.modelObject || 'Obj_Rim_T0A'"
              :caliperColor="config.caliperColor?.colorCode || '#990000'"
              :modelUrl="config.carModel?.modelFile || '/models/aventador.glb'"
            />
          </div>

          <div class="config-details">
          <div class="detail-row model-row">
            <span class="label">Model</span>
            <span class="value">{{ config.carModel?.brand }} {{ config.carModel?.name }}</span>
            <span class="price base-price">{{ formatPrice(config.carModel?.basePrice || 0) }}</span>
          </div>

          <div class="detail-row">
            <span class="label">Engine</span>
            <span class="value">{{ config.engine?.name }} ({{ config.engine?.horsepower }} HP)</span>
            <span class="price">{{ config.engine?.price > 0 ? '+' : '' }}{{ formatPrice(config.engine?.price || 0) }}</span>
          </div>
          
          <div class="detail-row">
            <span class="label">Paint</span>
            <span class="value">
              <span class="color-dot" :style="{ background: config.paint?.colorCode }"></span>
              {{ config.paint?.name }}
            </span>
            <span class="price">{{ formatPrice(config.paint?.price || 0) }}</span>
          </div>
          
          <div class="detail-row">
            <span class="label">Wheel Design</span>
            <span class="value">{{ config.wheelDesign?.name }}</span>
            <span class="price">{{ formatPrice(config.wheelDesign?.price || 0) }}</span>
          </div>

          <div class="detail-row">
            <span class="label">Wheel Color</span>
            <span class="value">
              <span class="color-dot" :style="{ background: config.wheelColor?.colorCode }"></span>
              {{ config.wheelColor?.name }}
            </span>
            <span class="price">{{ formatPrice(config.wheelColor?.price || 0) }}</span>
          </div>

          <div class="detail-row">
            <span class="label">Caliper Color</span>
            <span class="value">
              <span class="color-dot" :style="{ background: config.caliperColor?.colorCode }"></span>
              {{ config.caliperColor?.name }}
            </span>
            <span class="price">{{ formatPrice(config.caliperColor?.price || 0) }}</span>
          </div>
          
          <div v-if="config.equipment?.length" class="equipment-section">
            <h3>Special Equipment</h3>
            <div v-for="eq in config.equipment" :key="eq.id" class="detail-row">
              <span class="label"></span>
              <span class="value">{{ eq.name }}</span>
              <span class="price">{{ formatPrice(eq.price) }}</span>
            </div>
          </div>
          
          <div class="total-row">
            <span class="label">Total</span>
            <span class="total-price">{{ formatPrice(totalPrice) }}</span>
          </div>
          </div>
        </div>

        <div class="share-link">
          <label>Share this configuration:</label>
          <div class="link-box">
            <input type="text" :value="shareUrl" readonly ref="shareInput" />
            <button @click="copyLink" class="btn-copy">Copy</button>
          </div>
        </div>

        <div v-if="!orderSubmitted" class="order-form">
          <h3>Complete Your Order</h3>
          <div class="form-group">
            <label>Name</label>
            <input v-model="order.customerName" type="text" placeholder="Your name" />
          </div>
          <div class="form-group">
            <label>Email</label>
            <input v-model="order.customerEmail" type="email" placeholder="your@email.com" />
          </div>
          <button @click="submitOrder" class="btn-primary" :disabled="!canSubmit">
            Submit Order
          </button>
        </div>

        <div v-else class="order-success">
          <h3>Order Submitted!</h3>
          <p>Thank you for your order. We will contact you shortly.</p>
          <button @click="$router.push('/')" class="btn-secondary">
            Configure Another Vehicle
          </button>
        </div>
      </div>
    </template>
  </div>
</template>

<script>
import { getConfiguration, createOrder } from '../services/api.js'
import CarPreview3D from '../components/CarPreview3D.vue'

export default {
  components: { CarPreview3D },
  data() {
    return {
      loading: true,
      config: null,
      totalPrice: 0,
      order: { customerName: '', customerEmail: '' },
      orderSubmitted: false
    }
  },
  computed: {
    shareUrl() {
      return `${window.location.origin}/config/${this.$route.params.id}`
    },
    canSubmit() {
      return this.order.customerName && this.order.customerEmail
    }
  },
  async mounted() {
    const data = await getConfiguration(this.$route.params.id)
    if (data) {
      this.config = data.configuration
      this.totalPrice = data.totalPrice
    }
    this.loading = false
  },
  methods: {
    formatPrice(price) {
      return new Intl.NumberFormat('de-DE', {
        style: 'currency',
        currency: 'EUR'
      }).format(price)
    },
    copyLink() {
      this.$refs.shareInput.select()
      document.execCommand('copy')
    },
    goBack() {
      const id = this.$route.params.id
      if (id) {
        this.$router.push(`/config/${id}`)
      } else {
        this.$router.push('/')
      }
    },
    async submitOrder() {
      await createOrder({
        configurationId: this.$route.params.id,
        customerName: this.order.customerName,
        customerEmail: this.order.customerEmail
      })
      this.orderSubmitted = true
    }
  }
}
</script>

<style scoped>
.summary {
  max-width: 1600px;
  margin: 0 auto;
}

.config-layout {
  display: grid;
  grid-template-columns: minmax(0, 1.2fr) minmax(0, 1fr);
  gap: 2.5rem;
  align-items: start;
  margin-bottom: 2rem;
}

.preview-col {
  height: 540px;
}

.share-link,
.order-form,
.order-success {
  max-width: 700px;
}

@media (max-width: 900px) {
  .config-layout {
    grid-template-columns: 1fr;
    gap: 1.25rem;
  }
}

.loading, .error {
  text-align: center;
  padding: 4rem;
  font-size: 1.2rem;
  color: var(--color-text-muted);
}

.summary-content {
  background: var(--surface-card);
  border-radius: 16px;
  padding: 2rem;
  border: 1px solid var(--border-subtle);
  box-shadow: var(--shadow-card);
  color: var(--color-text);
}

.summary-content h2 {
  font-size: 1.5rem;
  margin-bottom: 1.5rem;
  background: var(--gradient-primary);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.header-back {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.6rem 1.2rem;
  background: var(--gradient-primary);
  border: none;
  border-radius: 8px;
  color: var(--color-white);
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.2s, opacity 0.2s, box-shadow 0.2s;
  white-space: nowrap;
  box-shadow: 0 2px 8px rgba(15, 138, 43, 0.35);
}

.header-back:hover:not(:disabled) {
  transform: scale(1.03);
  box-shadow: 0 4px 14px rgba(15, 138, 43, 0.45);
}

.header-back:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.header-back svg {
  display: block;
}

.config-details {
  margin-bottom: 2rem;
}

.detail-row {
  display: grid;
  grid-template-columns: 100px 1fr auto;
  gap: 1rem;
  padding: 0.75rem 0;
  border-bottom: 1px solid var(--border-subtle);
  align-items: center;
}

.detail-row .label {
  color: var(--color-text-muted);
  font-size: 0.875rem;
}

.detail-row .value {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: var(--color-text);
}

.detail-row .price {
  color: var(--color-button-primary);
  font-weight: 600;
}

.model-row {
  background: var(--surface-selected-soft);
  padding: 0.75rem 1rem;
  border-radius: 8px;
  border-bottom: none;
  margin-bottom: 0.25rem;
}

.base-price {
  color: var(--color-button-primary) !important;
  font-weight: 700;
}

.color-dot {
  width: 16px;
  height: 16px;
  border-radius: 50%;
  border: 2px solid var(--border-strong);
}

.equipment-section h3 {
  font-size: 0.875rem;
  color: var(--color-text-muted);
  margin: 1rem 0 0.5rem;
}

.total-row {
  display: flex;
  justify-content: space-between;
  padding: 1.5rem 0 0;
  margin-top: 0.5rem;
  border-top: 1px solid var(--border-subtle);
}

.total-row .label {
  font-size: 1.25rem;
  font-weight: 600;
  color: var(--color-text);
}

.total-price {
  font-size: 1.5rem;
  font-weight: 700;
  background: var(--gradient-primary);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.share-link {
  margin-bottom: 2rem;
}

.share-link label {
  display: block;
  font-size: 0.875rem;
  color: var(--color-text-muted);
  margin-bottom: 0.5rem;
}

.link-box {
  display: flex;
  gap: 0.5rem;
}

.link-box input {
  flex: 1;
  padding: 0.75rem 1rem;
  background: var(--color-app-bg);
  border: 1px solid var(--border-subtle);
  border-radius: 8px;
  color: var(--color-text);
  font-size: 0.875rem;
}

.btn-copy {
  padding: 0.75rem 1.5rem;
  background: var(--color-white);
  border: 1px solid var(--border-strong);
  border-radius: 8px;
  color: var(--color-button-primary);
  cursor: pointer;
  font-weight: 500;
  transition: all 0.2s;
}

.btn-copy:hover {
  background: var(--surface-card-hover);
  border-color: var(--color-button-primary);
}

.order-form h3 {
  font-size: 1.25rem;
  margin-bottom: 1rem;
  color: var(--color-text);
}

.form-group {
  margin-bottom: 1rem;
}

.form-group label {
  display: block;
  font-size: 0.875rem;
  color: var(--color-text-muted);
  margin-bottom: 0.5rem;
}

.form-group input {
  width: 100%;
  padding: 0.75rem 1rem;
  background: var(--color-app-bg);
  border: 1px solid var(--border-subtle);
  border-radius: 8px;
  color: var(--color-text);
  font-size: 1rem;
  transition: border-color 0.2s, background 0.2s;
}

.form-group input:focus {
  outline: none;
  border-color: var(--color-button-primary);
  background: var(--color-white);
}

.btn-primary {
  width: 100%;
  padding: 1rem;
  margin-top: 1rem;
  background: var(--gradient-primary);
  border: none;
  border-radius: 8px;
  color: var(--color-white);
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.2s, opacity 0.2s, box-shadow 0.2s;
  box-shadow: 0 2px 8px rgba(15, 138, 43, 0.35);
}

.btn-primary:hover:not(:disabled) {
  transform: scale(1.02);
  box-shadow: 0 4px 14px rgba(15, 138, 43, 0.45);
}

.btn-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.order-success {
  text-align: center;
  padding: 2rem 0;
}

.order-success h3 {
  font-size: 1.5rem;
  color: var(--color-green-dark);
  margin-bottom: 0.5rem;
}

.order-success p {
  color: var(--color-text-muted);
  margin-bottom: 1.5rem;
}

.btn-secondary {
  padding: 1rem 2rem;
  background: var(--color-white);
  border: 1px solid var(--border-strong);
  border-radius: 8px;
  color: var(--color-button-primary);
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-secondary:hover {
  background: var(--surface-card-hover);
  border-color: var(--color-button-primary);
}
</style>
