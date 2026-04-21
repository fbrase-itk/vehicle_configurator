<template>
  <div class="configurator">
    <div v-if="loading" class="loading">Loading options...</div>
    
    <template v-else>
      <!-- Step tabs + total price + CTA rendered inside the sticky app header -->
      <Teleport to="#header-actions">
        <nav class="step-nav">
          <button
            v-for="step in steps"
            :key="step.id"
            :class="['step-btn', {
              active: currentStep === step.id,
              completed: isStepCompleted(step.id),
              locked: !isStepAvailable(step.id)
            }]"
            :disabled="!isStepAvailable(step.id)"
            :title="isStepAvailable(step.id) ? '' : 'Complete the previous step first'"
            @click="goToStep(step.id)"
          >
            {{ step.label }}
          </button>
        </nav>
        <div class="header-price">
          <span class="header-price-label">Total</span>
          <span class="header-price-value">{{ formatPrice(totalPrice) }}</span>
        </div>
        <button
          @click="saveAndContinue"
          class="btn-primary header-continue"
          :disabled="!isValid"
        >
          Continue to Summary
        </button>
      </Teleport>

      <!-- 3D Car Preview (full width) -->
      <div class="preview-section">
        <CarPreview3D
          :paintColor="selectedPaint?.colorCode || '#BF0012'"
          :paintName="selectedPaint?.name"
          :wheelColor="selectedWheelColor?.colorCode || '#000000'"
          :wheelDesign="selectedWheelDesign?.modelObject || 'Obj_Rim_T0A'"
          :caliperColor="selectedCaliperColor?.colorCode || '#990000'"
          :modelUrl="selectedCarModel?.modelFile || '/models/aventador.glb'"
        />
      </div>

      <!-- Options Section (below car) -->
      <section class="options-section">
        <!-- Model/Engine Step -->
        <div v-show="currentStep === 'model'" class="step-content">
          <div class="step-grid">
            <div class="step-column">
              <h3>Model</h3>
              <div class="options-list">
                <div
                  v-for="model in options.carModels"
                  :key="model.id"
                  :class="['option-card', { selected: selected.carModelId === model.id }]"
                  @click="selectCarModel(model.id)"
                >
                  <div class="option-info">
                    <h4>{{ model.brand }} {{ model.name }}</h4>
                    <p>{{ model.description }}</p>
                  </div>
                  <span class="price">{{ formatPrice(model.basePrice) }}</span>
                </div>
              </div>
            </div>
            <div class="step-column" v-if="selected.carModelId">
              <h3>Engine</h3>
              <div class="options-list">
                <div
                  v-for="engine in modelEngines"
                  :key="engine.id"
                  :class="['option-card', { selected: selected.engineId === engine.id }]"
                  @click="select('engineId', engine.id)"
                >
                  <div class="option-info">
                    <h4>{{ engine.name }}</h4>
                    <p>{{ engine.horsepower }} HP</p>
                  </div>
                  <span class="price">{{ engine.price > 0 ? '+' : '' }}{{ formatPrice(engine.price) }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Paint Step -->
        <div v-show="currentStep === 'paint'" class="step-content">
          <h3>Exterior Color</h3>
          <div class="color-options">
            <div
              v-for="paint in options.paints"
              :key="paint.id"
              :class="['color-card', { selected: selected.paintId === paint.id }]"
              @click="select('paintId', paint.id)"
            >
              <div class="color-swatch" :style="{ background: paint.colorCode }"></div>
              <span class="color-name">{{ paint.name }}</span>
              <span class="price">{{ paint.price > 0 ? '+' + formatPrice(paint.price) : 'Included' }}</span>
            </div>
          </div>
        </div>

        <!-- Wheels Step -->
        <div v-show="currentStep === 'wheels'" class="step-content">
          <div class="wheels-grid">
            <!-- Wheel Design -->
            <div class="wheel-section">
              <h3>Wheel Design</h3>
              <div class="design-options">
                <div
                  v-for="design in options.wheelDesigns"
                  :key="design.id"
                  :class="['design-card', { selected: selected.wheelDesignId === design.id }]"
                  @click="select('wheelDesignId', design.id)"
                >
                  <h4>{{ design.name }}</h4>
                  <span class="price">{{ design.price > 0 ? '+' + formatPrice(design.price) : 'Included' }}</span>
                </div>
              </div>
            </div>

            <!-- Wheel Color -->
            <div class="wheel-section">
              <h3>Wheel Color</h3>
              <div class="color-options compact">
                <div
                  v-for="color in options.wheelColors"
                  :key="color.id"
                  :class="['color-card compact', { selected: selected.wheelColorId === color.id }]"
                  @click="select('wheelColorId', color.id)"
                >
                  <div class="color-swatch small" :style="{ background: color.colorCode }"></div>
                  <span class="color-name">{{ color.name }}</span>
                  <span class="price">{{ color.price > 0 ? '+' + formatPrice(color.price) : 'Included' }}</span>
                </div>
              </div>
            </div>

            <!-- Brake Caliper Color -->
            <div class="wheel-section">
              <h3>Brake Caliper Color</h3>
              <div class="color-options compact">
                <div
                  v-for="color in options.caliperColors"
                  :key="color.id"
                  :class="['color-card compact', { selected: selected.caliperColorId === color.id }]"
                  @click="select('caliperColorId', color.id)"
                >
                  <div class="color-swatch small" :style="{ background: color.colorCode }"></div>
                  <span class="color-name">{{ color.name }}</span>
                  <span class="price">{{ color.price > 0 ? '+' + formatPrice(color.price) : 'Included' }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Special Equipment Step -->
        <div v-show="currentStep === 'equipment'" class="step-content">
          <h3>Special Equipment <span class="hint">(select up to 5)</span></h3>
          <div class="options-list horizontal">
            <div
              v-for="eq in options.equipment"
              :key="eq.id"
              :class="['option-card', { selected: selected.equipmentIds.includes(eq.id), disabled: !selected.equipmentIds.includes(eq.id) && selected.equipmentIds.length >= 5 }]"
              @click="toggleEquipment(eq.id)"
            >
              <div class="option-info">
                <h4>{{ eq.name }}</h4>
                <p>{{ eq.description }}</p>
              </div>
              <span class="price">+{{ formatPrice(eq.price) }}</span>
            </div>
          </div>
        </div>

        <!-- Step footer: Back / Next navigation -->
        <div class="step-footer">
          <button
            v-if="prevStep"
            @click="goToPrevStep"
            class="btn-secondary"
          >
            ← Back: {{ prevStep.label }}
          </button>
          <span v-else class="step-footer-spacer"></span>

          <button
            v-if="nextStep"
            @click="goToNextStep"
            class="btn-primary step-next"
            :disabled="!isStepCompleted(currentStep)"
            :title="isStepCompleted(currentStep) ? '' : 'Complete this step to proceed'"
          >
            Next: {{ nextStep.label }} →
          </button>
        </div>
      </section>
    </template>
  </div>
</template>

<script>
import { fetchOptions, fetchEnginesForModel, getConfiguration, saveConfiguration } from '../services/api.js'
import CarPreview3D from '../components/CarPreview3D.vue'

export default {
  components: { CarPreview3D },
  data() {
    return {
      loading: true,
      currentStep: 'model',
      steps: [
        { id: 'model', label: 'Model/Engine' },
        { id: 'paint', label: 'Paint' },
        { id: 'wheels', label: 'Wheels' },
        { id: 'equipment', label: 'Special Equipment' }
      ],
      options: { carModels: [], engines: [], paints: [], wheelDesigns: [], wheelColors: [], caliperColors: [], equipment: [] },
      modelEngines: [],
      selected: { carModelId: null, engineId: null, paintId: null, wheelDesignId: null, wheelColorId: null, caliperColorId: null, equipmentIds: [] }
    }
  },
  computed: {
    selectedCarModel() {
      return this.options.carModels?.find(m => m.id === this.selected.carModelId)
    },
    selectedPaint() {
      return this.options.paints?.find(p => p.id === this.selected.paintId)
    },
    selectedWheelDesign() {
      return this.options.wheelDesigns?.find(d => d.id === this.selected.wheelDesignId)
    },
    selectedWheelColor() {
      return this.options.wheelColors?.find(c => c.id === this.selected.wheelColorId)
    },
    selectedCaliperColor() {
      return this.options.caliperColors?.find(c => c.id === this.selected.caliperColorId)
    },
    totalPrice() {
      let total = 0
      if (this.selectedCarModel) {
        total += Number(this.selectedCarModel.basePrice)
      }
      if (this.selected.engineId) {
        const engine = this.modelEngines.find(e => e.id === this.selected.engineId)
        if (engine) total += Number(engine.price)
      }
      if (this.selected.paintId) {
        const paint = this.options.paints.find(p => p.id === this.selected.paintId)
        if (paint) total += Number(paint.price)
      }
      if (this.selectedWheelDesign) {
        total += Number(this.selectedWheelDesign.price)
      }
      if (this.selectedWheelColor) {
        total += Number(this.selectedWheelColor.price)
      }
      if (this.selectedCaliperColor) {
        total += Number(this.selectedCaliperColor.price)
      }
      for (const eqId of this.selected.equipmentIds) {
        const eq = this.options.equipment.find(e => e.id === eqId)
        if (eq) total += Number(eq.price)
      }
      return total
    },
    isValid() {
      return this.selected.carModelId && this.selected.engineId && this.selected.paintId && 
             this.selected.wheelDesignId && this.selected.wheelColorId && this.selected.caliperColorId
    },
    currentStepIndex() {
      return this.steps.findIndex(s => s.id === this.currentStep)
    },
    prevStep() {
      return this.currentStepIndex > 0 ? this.steps[this.currentStepIndex - 1] : null
    },
    nextStep() {
      return this.currentStepIndex < this.steps.length - 1
        ? this.steps[this.currentStepIndex + 1]
        : null
    }
  },
  async mounted() {
    this.options = await fetchOptions()
    
    const configId = this.$route.params.id
    if (configId) {
      const data = await getConfiguration(configId)
      if (data?.configuration) {
        const config = data.configuration
        if (config.carModel?.id) {
          await this.selectCarModel(config.carModel.id)
        }
        this.selected.engineId = config.engine?.id
        this.selected.paintId = config.paint?.id
        this.selected.wheelDesignId = config.wheelDesign?.id
        this.selected.wheelColorId = config.wheelColor?.id
        this.selected.caliperColorId = config.caliperColor?.id
        this.selected.equipmentIds = config.equipment?.map(e => e.id) || []
      }
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
    isStepCompleted(stepId) {
      switch (stepId) {
        case 'model': return !!(this.selected.carModelId && this.selected.engineId)
        case 'paint': return !!this.selected.paintId
        case 'wheels': return !!(this.selected.wheelDesignId && this.selected.wheelColorId && this.selected.caliperColorId)
        case 'equipment': return this.selected.equipmentIds.length > 0
        default: return false
      }
    },
    isStepAvailable(stepId) {
      const idx = this.steps.findIndex(s => s.id === stepId)
      if (idx <= 0) return true
      return this.steps.slice(0, idx).every(s => this.isStepCompleted(s.id))
    },
    goToStep(stepId) {
      if (this.isStepAvailable(stepId)) {
        this.currentStep = stepId
      }
    },
    goToPrevStep() {
      if (this.prevStep) this.currentStep = this.prevStep.id
    },
    goToNextStep() {
      if (this.nextStep && this.isStepCompleted(this.currentStep)) {
        this.currentStep = this.nextStep.id
      }
    },
    async selectCarModel(id) {
      this.selected.carModelId = id
      this.selected.engineId = null
      this.modelEngines = await fetchEnginesForModel(id)
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
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.loading {
  text-align: center;
  padding: 4rem;
  font-size: 1.2rem;
  color: rgba(255, 255, 255, 0.6);
}

/* Step Navigation — embedded in the app header */
.step-nav {
  display: flex;
  gap: 0.4rem;
  flex-wrap: wrap;
}

.step-btn {
  padding: 0.5rem 1rem;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  color: rgba(255, 255, 255, 0.65);
  font-size: 0.85rem;
  cursor: pointer;
  transition: all 0.2s ease;
}

.step-btn:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.1);
  color: rgba(255, 255, 255, 0.9);
}

.step-btn.active {
  background: linear-gradient(90deg, rgba(0, 212, 255, 0.2), rgba(124, 58, 237, 0.2));
  border-color: #00d4ff;
  color: #fff;
}

.step-btn.completed {
  border-color: rgba(74, 222, 128, 0.5);
  color: rgba(255, 255, 255, 0.85);
}

.step-btn.completed::after {
  content: ' ✓';
  color: #4ade80;
}

.step-btn.locked,
.step-btn:disabled {
  opacity: 0.35;
  cursor: not-allowed;
  border-style: dashed;
}

.step-btn.locked::before {
  content: '🔒 ';
  font-size: 0.8em;
}

/* Header price pill */
.header-price {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  line-height: 1.1;
  padding: 0 0.5rem;
  border-left: 1px solid rgba(255, 255, 255, 0.1);
  margin-left: 0.25rem;
}

.header-price-label {
  font-size: 0.7rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: rgba(255, 255, 255, 0.5);
}

.header-price-value {
  font-size: 1.05rem;
  font-weight: 700;
  background: linear-gradient(90deg, #00d4ff, #7c3aed);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

/* Continue button (header variant) */
.btn-primary {
  padding: 0.6rem 1.2rem;
  background: linear-gradient(90deg, #00d4ff, #7c3aed);
  border: none;
  border-radius: 8px;
  color: #fff;
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.2s, opacity 0.2s;
  white-space: nowrap;
}

.btn-primary:hover:not(:disabled) {
  transform: scale(1.03);
}

.btn-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Preview (now full width below the header) */
.preview-section {
  height: 380px;
  max-width: 1100px;
  margin: 0 auto 1.5rem;
}

/* Step footer — Back/Next navigation inside the options card */
.step-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
  margin-top: 2rem;
  padding-top: 1.5rem;
  border-top: 1px solid rgba(255, 255, 255, 0.08);
}

.step-footer-spacer {
  display: inline-block;
}

.btn-secondary {
  padding: 0.6rem 1.2rem;
  background: transparent;
  border: 1px solid rgba(255, 255, 255, 0.15);
  border-radius: 8px;
  color: rgba(255, 255, 255, 0.7);
  font-size: 0.9rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
  white-space: nowrap;
}

.btn-secondary:hover {
  background: rgba(255, 255, 255, 0.06);
  border-color: rgba(255, 255, 255, 0.3);
  color: #fff;
}

.step-next {
  margin-left: auto;
}

/* Options Section */
.options-section {
  background: rgba(255, 255, 255, 0.03);
  border-radius: 16px;
  padding: 1.5rem;
  border: 1px solid rgba(255, 255, 255, 0.08);
}

.step-content h3 {
  font-size: 1.1rem;
  margin-bottom: 1rem;
  color: rgba(255, 255, 255, 0.9);
}

.step-content h3 .hint {
  font-size: 0.85rem;
  font-weight: normal;
  color: rgba(255, 255, 255, 0.5);
}

/* Step Grid (for Model/Engine) */
.step-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2rem;
}

.step-column h3 {
  font-size: 1rem;
  margin-bottom: 0.75rem;
  color: rgba(255, 255, 255, 0.7);
}

/* Options List */
.options-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.options-list.horizontal {
  flex-direction: row;
  flex-wrap: wrap;
}

.options-list.horizontal .option-card {
  flex: 1 1 250px;
  max-width: 300px;
}

.option-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: rgba(255, 255, 255, 0.05);
  border: 2px solid transparent;
  border-radius: 10px;
  padding: 1rem 1.25rem;
  cursor: pointer;
  transition: all 0.2s ease;
}

.option-card:hover {
  background: rgba(255, 255, 255, 0.08);
}

.option-card.selected {
  border-color: #00d4ff;
  background: rgba(0, 212, 255, 0.1);
}

.option-card.disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.option-info h4 {
  font-size: 0.95rem;
  font-weight: 600;
  margin-bottom: 0.25rem;
}

.option-info p {
  font-size: 0.8rem;
  color: rgba(255, 255, 255, 0.5);
  margin: 0;
}

.option-card .price {
  font-size: 0.9rem;
  color: #a78bfa;
  font-weight: 500;
  white-space: nowrap;
}

/* Color Options */
.color-options {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
}

.color-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 1rem;
  background: rgba(255, 255, 255, 0.05);
  border: 2px solid transparent;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s ease;
  min-width: 120px;
}

.color-card:hover {
  background: rgba(255, 255, 255, 0.08);
  transform: translateY(-2px);
}

.color-card.selected {
  border-color: #00d4ff;
  background: rgba(0, 212, 255, 0.1);
}

.color-swatch {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  margin-bottom: 0.75rem;
  border: 3px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
}

.color-card.selected .color-swatch {
  border-color: #00d4ff;
}

.color-name {
  font-size: 0.85rem;
  font-weight: 500;
  margin-bottom: 0.25rem;
  text-align: center;
}

.color-card .price {
  font-size: 0.75rem;
  color: rgba(255, 255, 255, 0.5);
}

/* Wheels Section */
.wheels-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 2rem;
}

.wheel-section h3 {
  font-size: 1rem;
  margin-bottom: 0.75rem;
  color: rgba(255, 255, 255, 0.8);
}

.design-options {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.design-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 1.25rem;
  background: rgba(255, 255, 255, 0.05);
  border: 2px solid transparent;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.design-card:hover {
  background: rgba(255, 255, 255, 0.08);
}

.design-card.selected {
  border-color: #00d4ff;
  background: rgba(0, 212, 255, 0.1);
}

.design-card h4 {
  font-size: 0.95rem;
  font-weight: 600;
}

.design-card .price {
  font-size: 0.85rem;
  color: #a78bfa;
}

.color-options.compact {
  flex-direction: column;
  gap: 0.5rem;
}

.color-card.compact {
  flex-direction: row;
  padding: 0.75rem 1rem;
  gap: 0.75rem;
  min-width: auto;
}

.color-swatch.small {
  width: 28px;
  height: 28px;
  margin-bottom: 0;
}

.color-card.compact .color-name {
  flex: 1;
  text-align: left;
  margin-bottom: 0;
}

.color-card.compact .price {
  white-space: nowrap;
}

@media (max-width: 1100px) {
  .wheels-grid {
    grid-template-columns: 1fr;
    gap: 1.5rem;
  }
}

@media (max-width: 900px) {
  .step-grid {
    grid-template-columns: 1fr;
  }

  .step-btn {
    padding: 0.45rem 0.8rem;
    font-size: 0.8rem;
  }

  .header-price {
    border-left: none;
    padding: 0;
  }

  .btn-primary {
    padding: 0.55rem 1rem;
    font-size: 0.85rem;
  }
}
</style>
