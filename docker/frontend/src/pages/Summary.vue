<template>
  <div class="summary">
    <div v-if="loading" class="loading">Loading configuration...</div>
    <div v-else-if="!config" class="error">Configuration not found</div>
    
    <template v-else>
      <div class="summary-content">
        <h2>Your Configuration</h2>
        
        <div class="config-details">
          <div class="detail-row">
            <span class="label">Engine</span>
            <span class="value">{{ config.engine?.name }} ({{ config.engine?.horsepower }} HP)</span>
            <span class="price">{{ formatPrice(config.engine?.price || 0) }}</span>
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
            <span class="label">Wheels</span>
            <span class="value">{{ config.wheel?.name }}</span>
            <span class="price">{{ formatPrice(config.wheel?.price || 0) }}</span>
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

export default {
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
      return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD'
      }).format(price)
    },
    copyLink() {
      this.$refs.shareInput.select()
      document.execCommand('copy')
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
  max-width: 700px;
  margin: 0 auto;
}

.loading, .error {
  text-align: center;
  padding: 4rem;
  font-size: 1.2rem;
  color: rgba(255, 255, 255, 0.6);
}

.summary-content {
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(10px);
  border-radius: 16px;
  padding: 2rem;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.summary-content h2 {
  font-size: 1.5rem;
  margin-bottom: 1.5rem;
  background: linear-gradient(90deg, #00d4ff, #7c3aed);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.config-details {
  margin-bottom: 2rem;
}

.detail-row {
  display: grid;
  grid-template-columns: 100px 1fr auto;
  gap: 1rem;
  padding: 0.75rem 0;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  align-items: center;
}

.detail-row .label {
  color: rgba(255, 255, 255, 0.6);
  font-size: 0.875rem;
}

.detail-row .value {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.detail-row .price {
  color: #a78bfa;
}

.color-dot {
  width: 16px;
  height: 16px;
  border-radius: 50%;
  border: 2px solid rgba(255, 255, 255, 0.3);
}

.equipment-section h3 {
  font-size: 0.875rem;
  color: rgba(255, 255, 255, 0.6);
  margin: 1rem 0 0.5rem;
}

.total-row {
  display: flex;
  justify-content: space-between;
  padding: 1.5rem 0 0;
  margin-top: 0.5rem;
}

.total-row .label {
  font-size: 1.25rem;
  font-weight: 600;
}

.total-price {
  font-size: 1.5rem;
  font-weight: 700;
  background: linear-gradient(90deg, #00d4ff, #7c3aed);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.share-link {
  margin-bottom: 2rem;
}

.share-link label {
  display: block;
  font-size: 0.875rem;
  color: rgba(255, 255, 255, 0.6);
  margin-bottom: 0.5rem;
}

.link-box {
  display: flex;
  gap: 0.5rem;
}

.link-box input {
  flex: 1;
  padding: 0.75rem 1rem;
  background: rgba(0, 0, 0, 0.3);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  color: #fff;
  font-size: 0.875rem;
}

.btn-copy {
  padding: 0.75rem 1.5rem;
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 8px;
  color: #fff;
  cursor: pointer;
  transition: background 0.2s;
}

.btn-copy:hover {
  background: rgba(255, 255, 255, 0.2);
}

.order-form h3 {
  font-size: 1.25rem;
  margin-bottom: 1rem;
}

.form-group {
  margin-bottom: 1rem;
}

.form-group label {
  display: block;
  font-size: 0.875rem;
  color: rgba(255, 255, 255, 0.6);
  margin-bottom: 0.5rem;
}

.form-group input {
  width: 100%;
  padding: 0.75rem 1rem;
  background: rgba(0, 0, 0, 0.3);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  color: #fff;
  font-size: 1rem;
}

.form-group input:focus {
  outline: none;
  border-color: #00d4ff;
}

.btn-primary {
  width: 100%;
  padding: 1rem;
  margin-top: 1rem;
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

.order-success {
  text-align: center;
  padding: 2rem 0;
}

.order-success h3 {
  font-size: 1.5rem;
  color: #4ade80;
  margin-bottom: 0.5rem;
}

.order-success p {
  color: rgba(255, 255, 255, 0.6);
  margin-bottom: 1.5rem;
}

.btn-secondary {
  padding: 1rem 2rem;
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 8px;
  color: #fff;
  font-size: 1rem;
  cursor: pointer;
  transition: background 0.2s;
}

.btn-secondary:hover {
  background: rgba(255, 255, 255, 0.2);
}
</style>
