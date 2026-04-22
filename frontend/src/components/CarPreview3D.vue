<template>
  <div class="car-preview-3d" ref="container">
    <div v-if="loading" class="loading-overlay">
      <div class="spinner"></div>
      <span>Loading 3D Model...</span>
    </div>
    <canvas ref="canvas"></canvas>
  </div>
</template>

<script>
import * as THREE from 'three'
import { OrbitControls } from 'three/addons/controls/OrbitControls.js'
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js'
import { DRACOLoader } from 'three/addons/loaders/DRACOLoader.js'
import { RGBELoader } from 'three/addons/loaders/RGBELoader.js'

export default {
  props: {
    paintColor: { type: String, default: '#cc0000' },
    paintName: { type: String, default: '' },
    wheelColor: { type: String, default: '#000000' },
    wheelDesign: { type: String, default: 'Obj_Rim_T0A' },
    caliperColor: { type: String, default: '#990000' },
    modelUrl: { type: String, default: '/models/aventador.glb' }
  },
  data() {
    return {
      loading: true
    }
  },
  created() {
    // Store Three.js objects outside Vue's reactivity system
    this.scene = null
    this.camera = null
    this.renderer = null
    this.controls = null
    this.carGroup = null
    this.bodyMaterials = []
    this.wheelMaterials = []
    this.caliperMaterials = []
    this.wheelDesignObjects = { 'Obj_Rim_T0A': [], 'Obj_Rim_T0B': [] }
    this.animationId = null
  },
  watch: {
    paintColor: {
      handler(newColor) {
        this.updateBodyColor(newColor)
      },
      immediate: false
    },
    wheelColor: {
      handler(newColor) {
        this.updateWheelColor(newColor)
      },
      immediate: false
    },
    wheelDesign: {
      handler(newDesign) {
        this.switchWheelDesign(newDesign)
      },
      immediate: false
    },
    caliperColor: {
      handler(newColor) {
        this.updateCaliperColor(newColor)
      },
      immediate: false
    }
  },
  mounted() {
    this.initScene()
    this.loadCarModel()
    this.animate()
    window.addEventListener('resize', this.onResize)

    if (typeof ResizeObserver !== 'undefined') {
      this.resizeObserver = new ResizeObserver(() => this.onResize())
      this.resizeObserver.observe(this.$refs.container)
    }
  },
  beforeUnmount() {
    window.removeEventListener('resize', this.onResize)
    if (this.resizeObserver) {
      this.resizeObserver.disconnect()
      this.resizeObserver = null
    }
    if (this.animationId) {
      cancelAnimationFrame(this.animationId)
    }
    if (this.renderer) {
      this.renderer.dispose()
    }
    if (this.controls) {
      this.controls.dispose()
    }
  },
  methods: {
    initScene() {
      const container = this.$refs.container
      const canvas = this.$refs.canvas
      const width = container.clientWidth || 800
      const height = container.clientHeight || 400

      this.scene = new THREE.Scene()

      this.camera = new THREE.PerspectiveCamera(45, width / height, 0.1, 1000)
      this.camera.position.set(0.7, 0.5, 0)  // Right side of car, 2.5 units from target (= maxDistance)

      this.renderer = new THREE.WebGLRenderer({ 
        canvas, 
        antialias: true,
        alpha: true
      })
      this.renderer.setSize(width, height)
      this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
      this.renderer.shadowMap.enabled = true
      this.renderer.shadowMap.type = THREE.PCFSoftShadowMap
      this.renderer.toneMapping = THREE.ACESFilmicToneMapping
      this.renderer.toneMappingExposure = 1.0

      this.controls = new OrbitControls(this.camera, canvas)
      this.controls.enableDamping = true
      this.controls.dampingFactor = 0.05
      this.controls.minDistance = 0
      this.controls.maxDistance = 2.5
      this.controls.target.set(-1.8, 0.5, 0)  // Center on car position
      this.controls.maxPolarAngle = Math.PI / 2.1

      this.loadEnvironment()
      this.addLights()
      this.addGround()
    },

    loadEnvironment() {
      const rgbeLoader = new RGBELoader()
      rgbeLoader.load(
        'https://dl.polyhaven.org/file/ph-assets/HDRIs/hdr/1k/kloofendal_48d_partly_cloudy_puresky_1k.hdr',
        (texture) => {
          texture.mapping = THREE.EquirectangularReflectionMapping
          this.scene.background = texture
          this.scene.environment = texture
        },
        undefined,
        () => {
          // Fallback to solid color if HDR fails to load
          this.scene.background = new THREE.Color(0x87CEEB)
        }
      )
    },

    addLights() {
      // Reduced artificial lighting since HDR environment provides natural lighting
      const ambientLight = new THREE.AmbientLight(0xffffff, 0.3)
      this.scene.add(ambientLight)

      // Main directional light for shadows
      const mainLight = new THREE.DirectionalLight(0xffffff, 1.0)
      mainLight.position.set(5, 10, 7)
      mainLight.castShadow = true
      mainLight.shadow.mapSize.width = 2048
      mainLight.shadow.mapSize.height = 2048
      mainLight.shadow.camera.near = 0.5
      mainLight.shadow.camera.far = 50
      mainLight.shadow.camera.left = -10
      mainLight.shadow.camera.right = 10
      mainLight.shadow.camera.top = 10
      mainLight.shadow.camera.bottom = -10
      this.scene.add(mainLight)
    },

    addGround() {
      // Asphalt road
      const roadGeometry = new THREE.PlaneGeometry(8, 50)
      const roadMaterial = new THREE.MeshStandardMaterial({
        color: 0x333333,
        roughness: 0.9,
        metalness: 0.1
      })
      const road = new THREE.Mesh(roadGeometry, roadMaterial)
      road.rotation.x = -Math.PI / 2
      road.position.y = -0.01
      road.receiveShadow = true
      this.scene.add(road)

      // Road center line (dashed)
      const lineGeometry = new THREE.PlaneGeometry(0.15, 2)
      const lineMaterial = new THREE.MeshBasicMaterial({ color: 0xffffff })
      for (let i = -20; i < 20; i += 5) {
        const line = new THREE.Mesh(lineGeometry, lineMaterial)
        line.rotation.x = -Math.PI / 2
        line.position.set(0, 0.001, i)
        this.scene.add(line)
      }

      // Road edge lines
      const edgeGeometry = new THREE.PlaneGeometry(0.1, 50)
      const leftEdge = new THREE.Mesh(edgeGeometry, lineMaterial)
      leftEdge.rotation.x = -Math.PI / 2
      leftEdge.position.set(-3.5, 0.001, 0)
      this.scene.add(leftEdge)

      const rightEdge = new THREE.Mesh(edgeGeometry, lineMaterial)
      rightEdge.rotation.x = -Math.PI / 2
      rightEdge.position.set(3.5, 0.001, 0)
      this.scene.add(rightEdge)

      // Grass/ground on sides
      const grassGeometry = new THREE.PlaneGeometry(50, 50)
      const grassMaterial = new THREE.MeshStandardMaterial({
        color: 0x3d5c3d,
        roughness: 1.0,
        metalness: 0
      })
      const leftGrass = new THREE.Mesh(grassGeometry, grassMaterial)
      leftGrass.rotation.x = -Math.PI / 2
      leftGrass.position.set(-29, -0.02, 0)
      leftGrass.receiveShadow = true
      this.scene.add(leftGrass)

      const rightGrass = new THREE.Mesh(grassGeometry, grassMaterial)
      rightGrass.rotation.x = -Math.PI / 2
      rightGrass.position.set(29, -0.02, 0)
      rightGrass.receiveShadow = true
      this.scene.add(rightGrass)
    },

    loadCarModel() {
      this.loadGLTFModel()
    },

    loadGLTFModel() {
      const dracoLoader = new DRACOLoader()
      dracoLoader.setDecoderPath('https://www.gstatic.com/draco/versioned/decoders/1.5.6/')
      
      const loader = new GLTFLoader()
      loader.setDRACOLoader(dracoLoader)
      loader.load(
        this.modelUrl,
        (gltf) => {
          this.carGroup = gltf.scene
          
          this.carGroup.traverse((child) => {
            if (child.isMesh) {
              child.castShadow = true
              child.receiveShadow = true
              
              const name = child.name
              const materialName = child.material?.name || ''
              
              // Aventador model specific: Mt_Body is the body material
              // Mt_MirrorCover is the side mirror material (should match body color)
              if (materialName === 'Mt_Body' || materialName.includes('Body') || 
                  materialName === 'Mt_MirrorCover' || materialName.includes('Mirror')) {
                const newMaterial = new THREE.MeshPhysicalMaterial({
                  color: new THREE.Color(this.paintColor),
                  metalness: 0.9,
                  roughness: 0.1,
                  clearcoat: 1.0,
                  clearcoatRoughness: 0.1,
                  reflectivity: 1.0
                })
                child.material = newMaterial
                this.bodyMaterials.push(newMaterial)
              }
              // Aventador model specific: Mt_AlloyWheels is the wheel material
              else if (materialName === 'Mt_AlloyWheels' || materialName.includes('Alloy') || materialName.includes('Wheel')) {
                const newMaterial = new THREE.MeshPhysicalMaterial({
                  color: new THREE.Color(this.wheelColor),
                  metalness: 0.95,
                  roughness: 0.1,
                  clearcoat: 0.5
                })
                child.material = newMaterial
                this.wheelMaterials.push(newMaterial)
              }
              // Brake calipers
              else if (materialName === 'Mt_BrakeCaliper' || materialName.includes('Caliper') || materialName.includes('Brake')) {
                const newMaterial = new THREE.MeshStandardMaterial({
                  color: new THREE.Color(this.caliperColor),
                  metalness: 0.3,
                  roughness: 0.4
                })
                child.material = newMaterial
                this.caliperMaterials.push(newMaterial)
              }
            }
            
            // Track wheel design objects for switching
            if (child.name === 'Obj_Rim_T0A' || child.name.startsWith('Obj_Rim_T0A')) {
              this.wheelDesignObjects['Obj_Rim_T0A'].push(child)
              child.visible = this.wheelDesign === 'Obj_Rim_T0A'
            } else if (child.name === 'Obj_Rim_T0B' || child.name.startsWith('Obj_Rim_T0B')) {
              this.wheelDesignObjects['Obj_Rim_T0B'].push(child)
              child.visible = this.wheelDesign === 'Obj_Rim_T0B'
            }
          })

          const box = new THREE.Box3().setFromObject(this.carGroup)
          const center = box.getCenter(new THREE.Vector3())
          const size = box.getSize(new THREE.Vector3())
          const maxDim = Math.max(size.x, size.y, size.z)
          const scale = 3 / maxDim
          this.carGroup.scale.setScalar(scale)
          
          // Rotate car to align with road direction
          this.carGroup.rotation.y = Math.PI / 2
          
          box.setFromObject(this.carGroup)
          const newCenter = box.getCenter(new THREE.Vector3())
          this.carGroup.position.x = -newCenter.x - 1.8  // Right lane (German traffic)
          this.carGroup.position.z = -newCenter.z
          
          const minY = box.min.y
          this.carGroup.position.y = -minY * scale

          this.scene.add(this.carGroup)
          this.loading = false
        },
        (progress) => {
          if (progress.total > 0) {
            const percent = (progress.loaded / progress.total) * 100
            console.log(`Loading model: ${percent.toFixed(0)}%`)
          }
        },
        (error) => {
          console.error('Failed to load GLTF model:', this.modelUrl, error)
          this.createProceduralCar()
        }
      )
    },

    createProceduralCar() {
      this.carGroup = new THREE.Group()

      const bodyMaterial = new THREE.MeshPhysicalMaterial({
        color: new THREE.Color(this.paintColor),
        metalness: 0.9,
        roughness: 0.1,
        clearcoat: 1.0,
        clearcoatRoughness: 0.1,
        reflectivity: 1.0
      })
      this.bodyMaterials.push(bodyMaterial)

      const mainBody = this.createMainBody(bodyMaterial)
      this.carGroup.add(mainBody)

      const cabin = this.createCabin(bodyMaterial)
      this.carGroup.add(cabin)

      const hood = this.createHood(bodyMaterial)
      this.carGroup.add(hood)

      const rear = this.createRear(bodyMaterial)
      this.carGroup.add(rear)

      const sidePanels = this.createSidePanels(bodyMaterial)
      this.carGroup.add(sidePanels)

      const windows = this.createWindows()
      this.carGroup.add(windows)

      const headlights = this.createHeadlights()
      this.carGroup.add(headlights)

      const taillights = this.createTaillights()
      this.carGroup.add(taillights)

      const grille = this.createGrille()
      this.carGroup.add(grille)

      const wheels = this.createWheels()
      wheels.forEach(wheel => this.carGroup.add(wheel))

      const spoiler = this.createSpoiler(bodyMaterial)
      this.carGroup.add(spoiler)

      const mirrors = this.createMirrors(bodyMaterial)
      this.carGroup.add(mirrors)

      this.carGroup.position.y = 0.35
      this.scene.add(this.carGroup)
      this.loading = false
    },

    createMainBody(material) {
      const shape = new THREE.Shape()
      shape.moveTo(-2.2, 0)
      shape.lineTo(-2.0, 0.15)
      shape.lineTo(-1.0, 0.15)
      shape.lineTo(-0.7, 0.2)
      shape.lineTo(0.7, 0.2)
      shape.lineTo(1.0, 0.15)
      shape.lineTo(2.0, 0.15)
      shape.lineTo(2.2, 0)
      shape.lineTo(2.2, -0.3)
      shape.lineTo(-2.2, -0.3)
      shape.closePath()

      const extrudeSettings = {
        steps: 1,
        depth: 1.8,
        bevelEnabled: true,
        bevelThickness: 0.05,
        bevelSize: 0.05,
        bevelSegments: 3
      }

      const geometry = new THREE.ExtrudeGeometry(shape, extrudeSettings)
      geometry.rotateX(Math.PI / 2)
      geometry.translate(0, 0.3, -0.9)
      
      const mesh = new THREE.Mesh(geometry, material)
      mesh.castShadow = true
      return mesh
    },

    createCabin(material) {
      const group = new THREE.Group()

      const roofShape = new THREE.Shape()
      roofShape.moveTo(-0.7, 0)
      roofShape.bezierCurveTo(-0.6, 0.3, 0.6, 0.3, 0.7, 0)
      roofShape.lineTo(-0.7, 0)

      const roofGeometry = new THREE.ExtrudeGeometry(roofShape, {
        steps: 1,
        depth: 1.0,
        bevelEnabled: true,
        bevelThickness: 0.02,
        bevelSize: 0.02,
        bevelSegments: 2
      })
      roofGeometry.rotateX(Math.PI / 2)
      roofGeometry.translate(0, 0.65, -0.2)

      const roof = new THREE.Mesh(roofGeometry, material)
      roof.castShadow = true
      group.add(roof)

      return group
    },

    createHood(material) {
      const hoodGeometry = new THREE.BoxGeometry(1.6, 0.12, 1.3)
      hoodGeometry.translate(1.4, 0.35, 0)
      
      const hood = new THREE.Mesh(hoodGeometry, material)
      hood.castShadow = true

      const scoopGeometry = new THREE.BoxGeometry(0.3, 0.08, 0.15)
      scoopGeometry.translate(1.5, 0.45, 0)
      const scoop = new THREE.Mesh(scoopGeometry, new THREE.MeshStandardMaterial({ color: 0x111111 }))
      
      const group = new THREE.Group()
      group.add(hood)
      group.add(scoop)
      return group
    },

    createRear(material) {
      const rearGeometry = new THREE.BoxGeometry(1.4, 0.25, 1.6)
      rearGeometry.translate(-1.5, 0.3, 0)
      
      const rear = new THREE.Mesh(rearGeometry, material)
      rear.castShadow = true
      return rear
    },

    createSidePanels(material) {
      const group = new THREE.Group()

      const panelShape = new THREE.Shape()
      panelShape.moveTo(-2.0, 0)
      panelShape.lineTo(-1.8, 0.35)
      panelShape.lineTo(-0.8, 0.5)
      panelShape.lineTo(0.5, 0.5)
      panelShape.lineTo(1.5, 0.35)
      panelShape.lineTo(2.0, 0.2)
      panelShape.lineTo(2.0, 0)
      panelShape.closePath()

      const panelGeometry = new THREE.ExtrudeGeometry(panelShape, {
        steps: 1,
        depth: 0.03,
        bevelEnabled: false
      })

      const rightPanel = new THREE.Mesh(panelGeometry, material)
      rightPanel.position.z = 0.88
      rightPanel.castShadow = true
      group.add(rightPanel)

      const leftPanel = new THREE.Mesh(panelGeometry, material)
      leftPanel.position.z = -0.91
      leftPanel.rotation.y = Math.PI
      leftPanel.castShadow = true
      group.add(leftPanel)

      return group
    },

    createWindows() {
      const group = new THREE.Group()
      const glassMaterial = new THREE.MeshPhysicalMaterial({
        color: 0x000011,
        metalness: 0,
        roughness: 0,
        transmission: 0.9,
        transparent: true,
        opacity: 0.3
      })

      const frontWindowGeom = new THREE.PlaneGeometry(1.3, 0.35)
      const frontWindow = new THREE.Mesh(frontWindowGeom, glassMaterial)
      frontWindow.position.set(0.55, 0.75, 0)
      frontWindow.rotation.x = -0.3
      frontWindow.rotation.y = Math.PI / 2
      group.add(frontWindow)

      const rearWindowGeom = new THREE.PlaneGeometry(0.9, 0.3)
      const rearWindow = new THREE.Mesh(rearWindowGeom, glassMaterial)
      rearWindow.position.set(-0.7, 0.7, 0)
      rearWindow.rotation.x = 0.4
      rearWindow.rotation.y = Math.PI / 2
      group.add(rearWindow)

      const sideWindowGeom = new THREE.PlaneGeometry(0.8, 0.3)
      
      const rightSideWindow = new THREE.Mesh(sideWindowGeom, glassMaterial)
      rightSideWindow.position.set(-0.1, 0.72, 0.87)
      group.add(rightSideWindow)

      const leftSideWindow = new THREE.Mesh(sideWindowGeom, glassMaterial)
      leftSideWindow.position.set(-0.1, 0.72, -0.87)
      leftSideWindow.rotation.y = Math.PI
      group.add(leftSideWindow)

      return group
    },

    createHeadlights() {
      const group = new THREE.Group()
      const lightMaterial = new THREE.MeshStandardMaterial({
        color: 0xffffee,
        emissive: 0xffffaa,
        emissiveIntensity: 0.5
      })

      const headlightGeom = new THREE.CylinderGeometry(0.08, 0.1, 0.05, 16)
      headlightGeom.rotateZ(Math.PI / 2)

      const rightHeadlight = new THREE.Mesh(headlightGeom, lightMaterial)
      rightHeadlight.position.set(2.15, 0.25, 0.5)
      group.add(rightHeadlight)

      const leftHeadlight = new THREE.Mesh(headlightGeom, lightMaterial)
      leftHeadlight.position.set(2.15, 0.25, -0.5)
      group.add(leftHeadlight)

      const ledStripGeom = new THREE.BoxGeometry(0.02, 0.03, 0.3)
      const ledMaterial = new THREE.MeshStandardMaterial({
        color: 0xffffff,
        emissive: 0xffffff,
        emissiveIntensity: 0.3
      })

      const rightLED = new THREE.Mesh(ledStripGeom, ledMaterial)
      rightLED.position.set(2.18, 0.3, 0.5)
      group.add(rightLED)

      const leftLED = new THREE.Mesh(ledStripGeom, ledMaterial)
      leftLED.position.set(2.18, 0.3, -0.5)
      group.add(leftLED)

      return group
    },

    createTaillights() {
      const group = new THREE.Group()
      const lightMaterial = new THREE.MeshStandardMaterial({
        color: 0xff0000,
        emissive: 0xff0000,
        emissiveIntensity: 0.5
      })

      const taillightGeom = new THREE.BoxGeometry(0.02, 0.08, 0.25)

      const rightTaillight = new THREE.Mesh(taillightGeom, lightMaterial)
      rightTaillight.position.set(-2.18, 0.35, 0.55)
      group.add(rightTaillight)

      const leftTaillight = new THREE.Mesh(taillightGeom, lightMaterial)
      leftTaillight.position.set(-2.18, 0.35, -0.55)
      group.add(leftTaillight)

      const centerLightGeom = new THREE.BoxGeometry(0.02, 0.03, 0.8)
      const centerLight = new THREE.Mesh(centerLightGeom, lightMaterial)
      centerLight.position.set(-2.18, 0.25, 0)
      group.add(centerLight)

      return group
    },

    createGrille() {
      const group = new THREE.Group()
      const grilleMaterial = new THREE.MeshStandardMaterial({
        color: 0x111111,
        metalness: 0.8,
        roughness: 0.3
      })

      const grilleGeom = new THREE.BoxGeometry(0.02, 0.2, 0.8)
      const grille = new THREE.Mesh(grilleGeom, grilleMaterial)
      grille.position.set(2.18, 0.1, 0)
      group.add(grille)

      for (let i = 0; i < 6; i++) {
        const slat = new THREE.Mesh(
          new THREE.BoxGeometry(0.01, 0.02, 0.7),
          grilleMaterial
        )
        slat.position.set(2.19, 0.02 + i * 0.03, 0)
        group.add(slat)
      }

      return group
    },

    createWheels() {
      const wheels = []
      const wheelPositions = [
        { x: 1.4, z: 0.95 },
        { x: 1.4, z: -0.95 },
        { x: -1.5, z: 0.95 },
        { x: -1.5, z: -0.95 }
      ]

      wheelPositions.forEach(pos => {
        const wheel = this.createWheel()
        wheel.position.set(pos.x, 0, pos.z)
        if (pos.z < 0) {
          wheel.rotation.y = Math.PI
        }
        wheels.push(wheel)
      })

      return wheels
    },

    createWheel() {
      const group = new THREE.Group()

      const tireMaterial = new THREE.MeshStandardMaterial({
        color: 0x1a1a1a,
        roughness: 0.9,
        metalness: 0
      })

      const tireGeom = new THREE.TorusGeometry(0.32, 0.12, 16, 32)
      tireGeom.rotateY(Math.PI / 2)
      const tire = new THREE.Mesh(tireGeom, tireMaterial)
      tire.castShadow = true
      group.add(tire)

      const rimMaterial = new THREE.MeshPhysicalMaterial({
        color: new THREE.Color(this.wheelColor),
        metalness: 0.95,
        roughness: 0.1,
        clearcoat: 0.5
      })
      this.wheelMaterials.push(rimMaterial)

      const rimGeom = new THREE.CylinderGeometry(0.25, 0.25, 0.15, 24)
      rimGeom.rotateX(Math.PI / 2)
      const rim = new THREE.Mesh(rimGeom, rimMaterial)
      rim.castShadow = true
      group.add(rim)

      const spokeCount = 5
      for (let i = 0; i < spokeCount; i++) {
        const angle = (i / spokeCount) * Math.PI * 2
        const spokeGeom = new THREE.BoxGeometry(0.04, 0.16, 0.2)
        const spoke = new THREE.Mesh(spokeGeom, rimMaterial)
        spoke.position.x = Math.cos(angle) * 0.12
        spoke.position.y = Math.sin(angle) * 0.12
        spoke.rotation.z = angle
        group.add(spoke)
      }

      const hubGeom = new THREE.CylinderGeometry(0.06, 0.06, 0.18, 16)
      hubGeom.rotateX(Math.PI / 2)
      const hubMaterial = new THREE.MeshStandardMaterial({
        color: 0x333333,
        metalness: 0.9,
        roughness: 0.2
      })
      const hub = new THREE.Mesh(hubGeom, hubMaterial)
      group.add(hub)

      const brakeMaterial = new THREE.MeshStandardMaterial({
        color: 0xcc3333,
        metalness: 0.3,
        roughness: 0.6
      })
      const brakeGeom = new THREE.CylinderGeometry(0.18, 0.18, 0.03, 24)
      brakeGeom.rotateX(Math.PI / 2)
      const brake = new THREE.Mesh(brakeGeom, brakeMaterial)
      brake.position.z = 0.05
      group.add(brake)

      return group
    },

    createSpoiler(material) {
      const group = new THREE.Group()

      const wingGeom = new THREE.BoxGeometry(0.08, 0.02, 1.4)
      const wing = new THREE.Mesh(wingGeom, material)
      wing.position.set(-2.0, 0.7, 0)
      wing.rotation.x = -0.1
      wing.castShadow = true
      group.add(wing)

      const stanchionGeom = new THREE.BoxGeometry(0.04, 0.25, 0.06)
      
      const rightStanchion = new THREE.Mesh(stanchionGeom, material)
      rightStanchion.position.set(-1.95, 0.55, 0.5)
      group.add(rightStanchion)

      const leftStanchion = new THREE.Mesh(stanchionGeom, material)
      leftStanchion.position.set(-1.95, 0.55, -0.5)
      group.add(leftStanchion)

      return group
    },

    createMirrors(material) {
      const group = new THREE.Group()
      
      const mirrorGeom = new THREE.SphereGeometry(0.06, 8, 8)
      mirrorGeom.scale(0.8, 0.5, 0.3)

      const rightMirror = new THREE.Mesh(mirrorGeom, material)
      rightMirror.position.set(0.6, 0.55, 0.95)
      rightMirror.castShadow = true
      group.add(rightMirror)

      const leftMirror = new THREE.Mesh(mirrorGeom, material)
      leftMirror.position.set(0.6, 0.55, -0.95)
      leftMirror.castShadow = true
      group.add(leftMirror)

      return group
    },

    updateBodyColor(color) {
      const threeColor = new THREE.Color(color)
      this.bodyMaterials.forEach(material => {
        if (material.color) {
          material.color.copy(threeColor)
        }
      })
    },

    updateWheelColor(color) {
      const threeColor = new THREE.Color(color)
      this.wheelMaterials.forEach(material => {
        if (material.color) {
          material.color.copy(threeColor)
        }
      })
    },

    switchWheelDesign(designName) {
      // Hide all wheel designs
      Object.values(this.wheelDesignObjects).forEach(objects => {
        objects.forEach(obj => {
          obj.visible = false
        })
      })
      // Show selected design
      if (this.wheelDesignObjects[designName]) {
        this.wheelDesignObjects[designName].forEach(obj => {
          obj.visible = true
        })
      }
    },

    updateCaliperColor(color) {
      const threeColor = new THREE.Color(color)
      this.caliperMaterials.forEach(material => {
        if (material.color) {
          material.color.copy(threeColor)
        }
      })
    },

    onResize() {
      if (!this.$refs.container || !this.camera || !this.renderer) return
      const width = this.$refs.container.clientWidth || 800
      const height = this.$refs.container.clientHeight || 400
      if (width === 0 || height === 0) return
      this.camera.aspect = width / height
      this.camera.updateProjectionMatrix()
      this.renderer.setSize(width, height)
    },

    animate() {
      this.animationId = requestAnimationFrame(this.animate)
      if (this.controls) {
        this.controls.update()
      }
      if (this.renderer && this.scene && this.camera) {
        this.renderer.render(this.scene, this.camera)
      }
    }
  }
}
</script>

<style scoped>
/* The 3D preview panel stays dark — the navy menu color frames the
   car nicely against the light page background and HDR sky. */
.car-preview-3d {
  position: relative;
  background: linear-gradient(180deg, var(--color-menu-bg) 0%, #001566 100%);
  border-radius: 16px;
  overflow: hidden;
  margin-bottom: 2rem;
  border: 1px solid var(--border-subtle);
  box-shadow: var(--shadow-card);
  min-height: 200px;
  height: 100%;
}

canvas {
  display: block;
  width: 100%;
  height: 100%;
}

.loading-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: rgba(0, 2, 51, 0.88);
  z-index: 10;
  gap: 1rem;
  color: var(--color-text-on-dark-mute);
}

.spinner {
  width: 40px;
  height: 40px;
  border: 3px solid rgba(255, 255, 255, 0.15);
  border-top-color: var(--color-icon-active);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

</style>
