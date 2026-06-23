<template>
  <div class="map-container" :style="{ height: height }">
    <div ref="mapElement" style="width: 100%; height: 100%;"></div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch, onBeforeUnmount } from 'vue'

interface Coordinates {
  lat: number
  lng: number
  address?: string
}

interface DriverPin {
  id: string
  name: string
  lat: number
  lng: number
  status: 'available' | 'busy' | 'offline'
  vehicle_type?: string
}

interface ZonePin {
  id: string
  name: string
  color?: string
  coordinates: [number, number][]
}

const props = defineProps({
  height: {
    type: String,
    default: '450px',
  },
  center: {
    type: Object as () => { lat: number; lng: number },
    default: () => ({ lat: 14.6928, lng: -17.4467 }), // Dakar default
  },
  zoom: {
    type: Number,
    default: 13,
  },
  drivers: {
    type: Array as () => DriverPin[],
    default: () => [],
  },
  pickup: {
    type: Object as () => Coordinates | null,
    default: null,
  },
  dropoff: {
    type: Object as () => Coordinates | null,
    default: null,
  },
  zones: {
    type: Array as () => ZonePin[],
    default: () => [],
  },
  interactiveZone: {
    type: Boolean,
    default: false,
  },
})

const emit = defineEmits(['zone-created', 'map-click'])

const mapElement = ref<HTMLElement | null>(null)
let map: any = null
let Leaflet: any = null
const markersLayer = ref<any>(null)
const routesLayer = ref<any>(null)
const zonesLayer = ref<any>(null)

// Initialize map on mount (client-only)
onMounted(async () => {
  if (!process.client) return

  try {
    Leaflet = await import('leaflet')
    
    if (!mapElement.value) return

    map = Leaflet.map(mapElement.value).setView([props.center.lat, props.center.lng], props.zoom)

    // Dark-themed tiles to match the glassmorphism aesthetic
    Leaflet.tileLayer('https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>',
      subdomains: 'abcd',
      maxZoom: 20,
    }).addTo(map)

    markersLayer.value = Leaflet.layerGroup().addTo(map)
    routesLayer.value = Leaflet.layerGroup().addTo(map)
    zonesLayer.value = Leaflet.layerGroup().addTo(map)

    // Listen to click events if interactive
    map.on('click', (e: any) => {
      emit('map-click', e.latlng)
    })

    // Initial render
    renderMapData()
  } catch (error) {
    console.error('Failed to load Leaflet map:', error)
  }
})

function renderMapData() {
  if (!Leaflet || !map) return

  // Clear previous layers
  markersLayer.value.clearLayers()
  routesLayer.value.clearLayers()
  zonesLayer.value.clearLayers()

  const bounds: any[] = []

  // 1. Draw Zones Polygons
  if (props.zones && props.zones.length > 0) {
    props.zones.forEach(zone => {
      if (zone.coordinates && zone.coordinates.length > 0) {
        const poly = Leaflet.polygon(zone.coordinates, {
          color: zone.color || '#6c63ff',
          fillColor: zone.color || '#6c63ff',
          fillOpacity: 0.2,
          weight: 2,
        }).addTo(zonesLayer.value)
        poly.bindPopup(`<strong>Zone:</strong> ${zone.name}`)
      }
    })
  }

  // 2. Draw Pickup
  if (props.pickup && props.pickup.lat && props.pickup.lng) {
    const pickupIcon = Leaflet.divIcon({
      className: 'custom-map-pin green-pin',
      html: `<div style="background-color: var(--accent-secondary); width: 14px; height: 14px; border-radius: 50%; border: 3px solid #fff; box-shadow: 0 0 10px rgba(0,212,170,0.8);"></div>`,
      iconSize: [14, 14],
      iconAnchor: [7, 7],
    })
    const pickupMarker = Leaflet.marker([props.pickup.lat, props.pickup.lng], { icon: pickupIcon }).addTo(markersLayer.value)
    if (props.pickup.address) {
      pickupMarker.bindPopup(`<strong>Pickup:</strong> ${props.pickup.address}`)
    }
    bounds.push([props.pickup.lat, props.pickup.lng])
  }

  // 3. Draw Dropoff
  if (props.dropoff && props.dropoff.lat && props.dropoff.lng) {
    const dropoffIcon = Leaflet.divIcon({
      className: 'custom-map-pin red-pin',
      html: `<div style="background-color: var(--accent-warning); width: 14px; height: 14px; border-radius: 50%; border: 3px solid #fff; box-shadow: 0 0 10px rgba(255,107,107,0.8);"></div>`,
      iconSize: [14, 14],
      iconAnchor: [7, 7],
    })
    const dropoffMarker = Leaflet.marker([props.dropoff.lat, props.dropoff.lng], { icon: dropoffIcon }).addTo(markersLayer.value)
    if (props.dropoff.address) {
      dropoffMarker.bindPopup(`<strong>Dropoff:</strong> ${props.dropoff.address}`)
    }
    bounds.push([props.dropoff.lat, props.dropoff.lng])
  }

  // 4. Draw Route Line between Pickup and Dropoff
  if (props.pickup && props.dropoff) {
    const route = Leaflet.polyline([[props.pickup.lat, props.pickup.lng], [props.dropoff.lat, props.dropoff.lng]], {
      color: 'var(--accent-primary)',
      weight: 4,
      opacity: 0.8,
      dashArray: '5, 10',
    }).addTo(routesLayer.value)
  }

  // 5. Draw Active/Offline Drivers
  if (props.drivers && props.drivers.length > 0) {
    props.drivers.forEach(driver => {
      if (driver.lat && driver.lng) {
        const color = driver.status === 'available' ? 'var(--accent-secondary)' : driver.status === 'busy' ? 'var(--accent-primary)' : 'var(--text-muted)'
        const iconHtml = `
          <div style="position: relative;">
            <div style="background-color: ${color}; width: 12px; height: 12px; border-radius: 50%; border: 2px solid #111; box-shadow: 0 0 8px ${color};"></div>
            <div style="position: absolute; top: -14px; left: -10px; background: rgba(0,0,0,0.7); font-size: 8px; color: #fff; padding: 1px 4px; border-radius: 3px; border: 1px solid rgba(255,255,255,0.1); white-space: nowrap;">
              ${driver.name}
            </div>
          </div>
        `
        const driverIcon = Leaflet.divIcon({
          className: 'driver-map-pin',
          html: iconHtml,
          iconSize: [12, 12],
          iconAnchor: [6, 6],
        })

        const marker = Leaflet.marker([driver.lat, driver.lng], { icon: driverIcon }).addTo(markersLayer.value)
        marker.bindPopup(`
          <strong>Driver:</strong> ${driver.name}<br/>
          <strong>Status:</strong> ${driver.status}<br/>
          <strong>Vehicle:</strong> ${driver.vehicle_type || 'N/A'}
        `)
        
        // Only include in bounds if we don't have pickup/dropoff (which are higher priority to center on)
        if (!props.pickup && !props.dropoff) {
          bounds.push([driver.lat, driver.lng])
        }
      }
    })
  }

  // Fit bounds if we have elements
  if (bounds.length > 0) {
    map.fitBounds(bounds, { padding: [50, 50] })
  }
}

watch(() => [props.drivers, props.pickup, props.dropoff, props.zones], () => {
  renderMapData()
}, { deep: true })

onBeforeUnmount(() => {
  if (map) {
    map.remove()
  }
})
</script>

<style>
@import 'leaflet/dist/leaflet.css';

/* Fix Leaflet control overlay styling to blend with dark mode UI */
.leaflet-control-zoom {
  border: 1px solid rgba(255, 255, 255, 0.08) !important;
  box-shadow: 0 4px 12px rgba(0,0,0,0.5) !important;
}
.leaflet-control-zoom-in,
.leaflet-control-zoom-out {
  background-color: #16181f !important;
  color: var(--text-primary) !important;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08) !important;
}
.leaflet-control-zoom-in:hover,
.leaflet-control-zoom-out:hover {
  background-color: var(--bg-card-hover) !important;
  color: var(--text-primary) !important;
}
.leaflet-popup-content-wrapper {
  background: #16181f !important;
  color: var(--text-primary) !important;
  border: 1px solid rgba(255, 255, 255, 0.08) !important;
  border-radius: var(--radius-md) !important;
  box-shadow: 0 8px 24px rgba(0,0,0,0.6) !important;
}
.leaflet-popup-tip {
  background: #16181f !important;
  border: 1px solid rgba(255, 255, 255, 0.08) !important;
}
</style>
