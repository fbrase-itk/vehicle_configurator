<template>
  <div class="car-preview">
    <svg viewBox="0 0 400 160" xmlns="http://www.w3.org/2000/svg">
      <!-- Car body -->
      <path 
        class="car-body"
        :fill="paintColor"
        d="M50,100 
           L60,100 
           L70,70 
           L120,50 
           L280,50 
           L320,70 
           L340,100 
           L350,100 
           L355,105 
           L355,120 
           L340,125 
           L310,125 
           L300,115 
           L100,115 
           L90,125 
           L60,125 
           L45,120 
           L45,105 
           Z"
      />
      
      <!-- Windows -->
      <path 
        class="windows"
        fill="rgba(135, 206, 250, 0.6)"
        d="M125,55 
           L135,70 
           L190,70 
           L190,55 
           Z"
      />
      <path 
        class="windows"
        fill="rgba(135, 206, 250, 0.6)"
        d="M195,55 
           L195,70 
           L275,70 
           L275,55 
           Z"
      />
      <path 
        class="windows"
        fill="rgba(135, 206, 250, 0.6)"
        d="M280,55 
           L280,70 
           L310,70 
           L295,55 
           Z"
      />
      
      <!-- Window frames -->
      <path 
        fill="none"
        stroke="#333"
        stroke-width="2"
        d="M125,55 L135,70 L310,70 L295,55 Z M190,55 L190,70 M275,55 L275,70"
      />
      
      <!-- Headlights -->
      <ellipse cx="345" cy="95" rx="8" ry="6" fill="#fff9c4" stroke="#333" stroke-width="1"/>
      <ellipse cx="55" cy="95" rx="8" ry="6" fill="#ff8a80" stroke="#333" stroke-width="1"/>
      
      <!-- Door handle -->
      <rect x="200" y="85" width="25" height="4" rx="2" fill="#333"/>
      
      <!-- Side mirror -->
      <ellipse cx="130" cy="65" rx="8" ry="5" :fill="paintColor" stroke="#333" stroke-width="1"/>
      
      <!-- Front wheel -->
      <g class="wheel front-wheel">
        <circle cx="95" cy="120" r="25" fill="#333"/>
        <circle cx="95" cy="120" r="20" fill="#444"/>
        <circle cx="95" cy="120" r="15" :fill="wheelColor" stroke="#666" stroke-width="2"/>
        <circle cx="95" cy="120" r="5" fill="#333"/>
        <!-- Wheel spokes -->
        <g stroke="#555" stroke-width="2">
          <line x1="95" y1="105" x2="95" y2="110"/>
          <line x1="95" y1="130" x2="95" y2="135"/>
          <line x1="80" y1="120" x2="85" y2="120"/>
          <line x1="105" y1="120" x2="110" y2="120"/>
          <line x1="84" y1="109" x2="88" y2="113"/>
          <line x1="102" y1="127" x2="106" y2="131"/>
          <line x1="84" y1="131" x2="88" y2="127"/>
          <line x1="102" y1="113" x2="106" y2="109"/>
        </g>
      </g>
      
      <!-- Rear wheel -->
      <g class="wheel rear-wheel">
        <circle cx="305" cy="120" r="25" fill="#333"/>
        <circle cx="305" cy="120" r="20" fill="#444"/>
        <circle cx="305" cy="120" r="15" :fill="wheelColor" stroke="#666" stroke-width="2"/>
        <circle cx="305" cy="120" r="5" fill="#333"/>
        <!-- Wheel spokes -->
        <g stroke="#555" stroke-width="2">
          <line x1="305" y1="105" x2="305" y2="110"/>
          <line x1="305" y1="130" x2="305" y2="135"/>
          <line x1="290" y1="120" x2="295" y2="120"/>
          <line x1="315" y1="120" x2="320" y2="120"/>
          <line x1="294" y1="109" x2="298" y2="113"/>
          <line x1="312" y1="127" x2="316" y2="131"/>
          <line x1="294" y1="131" x2="298" y2="127"/>
          <line x1="312" y1="113" x2="316" y2="109"/>
        </g>
      </g>
      
      <!-- Ground shadow -->
      <ellipse cx="200" cy="148" rx="160" ry="8" fill="rgba(0,0,0,0.3)"/>
    </svg>
    
    <div class="preview-label">
      <span v-if="paintName">{{ paintName }}</span>
      <span v-if="wheelName"> · {{ wheelName }}</span>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    paintColor: { type: String, default: '#666666' },
    paintName: { type: String, default: '' },
    wheelColor: { type: String, default: '#888888' },
    wheelName: { type: String, default: '' }
  }
}
</script>

<style scoped>
.car-preview {
  background: linear-gradient(180deg, rgba(255,255,255,0.05) 0%, rgba(255,255,255,0.02) 100%);
  border-radius: 16px;
  padding: 2rem;
  margin-bottom: 2rem;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.car-preview svg {
  width: 100%;
  max-width: 500px;
  height: auto;
  display: block;
  margin: 0 auto;
  filter: drop-shadow(0 4px 20px rgba(0, 0, 0, 0.3));
}

.car-body {
  transition: fill 0.3s ease;
}

.wheel {
  transition: all 0.3s ease;
}

.preview-label {
  text-align: center;
  margin-top: 1rem;
  font-size: 0.875rem;
  color: rgba(255, 255, 255, 0.6);
}
</style>
