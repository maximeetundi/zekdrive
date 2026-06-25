<template>
  <div>
    <!-- Page Header -->
    <div class="page-header animate-fade-in">
      <div>
        <h1 class="page-title">{{ lang === 'fr' ? 'Zones géographiques' : 'Geofence Zones' }}</h1>
        <p class="page-desc">{{ lang === 'fr' ? 'Définir les limites de service, les zones restreintes et les polygones de majoration tarifaire' : 'Define service bounds, restricted corridors, and surge pricing multiplier polygons' }}</p>
      </div>
      <div class="page-actions">
        <button class="btn btn-primary flex items-center gap-2" @click="openAddModal">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width: 16px; height: 16px;">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
          </svg>
          <span>{{ lang === 'fr' ? 'Créer une zone' : 'Create New Zone' }}</span>
        </button>
      </div>
    </div>

    <!-- Zones Main Grid -->
    <div class="zones-grid animate-slide-up" style="margin-bottom: 2rem;">
      <!-- Left: Zones list table -->
      <div class="card">
        <div class="card-header" style="padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border); text-align: left;">
          <h3 class="text-base font-semibold">{{ lang === 'fr' ? 'Limites opérationnelles' : 'Operational Boundaries' }}</h3>
        </div>
        <div class="card-body" style="padding: 0;">
          <AppDataTable
            :headers="headers"
            :items="zones"
            :loading="loading"
            :currentPage="1"
            :perPage="20"
            :totalItems="zones.length"
            :totalPages="1"
          >
            <template #cell-name="{ item }">
              <div class="flex items-center gap-2" style="text-align: left;">
                <span :style="{ background: item.color, width: '12px', height: '12px', borderRadius: '3px', display: 'inline-block' }"></span>
                <span class="font-bold text-primary">{{ item.name }}</span>
              </div>
            </template>

            <template #cell-multiplier="{ item }">
              <span class="font-semibold" :class="item.multiplier > 1 ? 'text-gold' : 'text-primary'">
                {{ item.multiplier.toFixed(1) }}x
              </span>
            </template>

            <template #cell-status="{ item }">
              <AppStatusBadge :status="item.status ? 'active' : 'inactive'" />
            </template>

            <template #cell-actions="{ item }">
              <div class="flex gap-1 justify-end">
                <button class="btn btn-secondary btn-sm" @click="focusZone(item)">{{ lang === 'fr' ? 'Voir' : 'Locate' }}</button>
                <button class="btn btn-secondary btn-sm" @click="openEditModal(item)">{{ t('edit') }}</button>
                <button class="btn btn-danger btn-sm" @click="deleteZone(item.id)">{{ t('delete') }}</button>
              </div>
            </template>
          </AppDataTable>
        </div>
      </div>

      <!-- Right: Live Map Visualizer -->
      <div class="card">
        <div class="card-header flex justify-between items-center flex-wrap gap-2" style="padding: 1rem 1.25rem; border-bottom: 1px solid var(--border); text-align: left;">
          <h3 class="text-base font-semibold">{{ lang === 'fr' ? 'Carte des limites' : 'Boundary Map View' }}</h3>
          <span class="text-xs text-muted">{{ lang === 'fr' ? 'Cliquez sur la carte pour tracer une nouvelle zone' : 'Click the map to add coordinate vertices for a new zone' }}</span>
        </div>
        <div class="card-body" style="padding: 1rem;">
          <ClientOnly>
            <AppMapView
              height="450px"
              :center="mapCenter"
              :zoom="mapZoom"
              :zones="mapZones"
              @map-click="handleMapClick"
            />
            <template #fallback>
              <div class="skeleton" style="height: 450px; width: 100%; border-radius: var(--radius-md);"></div>
            </template>
          </ClientOnly>
          
          <!-- Drawing helper panel -->
          <div v-if="drawnCoordinates.length > 0" style="margin-top: 1rem; background: rgba(20,177,158,0.08); padding: 0.75rem 1rem; border-radius: var(--radius-md); border: 1px solid rgba(20,177,158,0.2);" class="flex justify-between items-center flex-wrap gap-2 text-left">
            <div class="text-xs">
              <strong class="text-primary">{{ lang === 'fr' ? 'Points tracés :' : 'Drawn Points:' }}</strong> {{ drawnCoordinates.length }} {{ lang === 'fr' ? 'sommets saisis.' : 'vertices clicked.' }}
            </div>
            <div class="flex gap-2">
              <button class="btn btn-secondary btn-sm" @click="drawnCoordinates = []">{{ lang === 'fr' ? 'Effacer' : 'Clear' }}</button>
              <button class="btn btn-primary btn-sm" @click="promoteDrawnToForm">{{ lang === 'fr' ? 'Appliquer' : 'Apply to New Zone' }}</button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Add/Edit Zone Modal -->
    <AppModal
      :show="showModal"
      :title="isEditMode ? (lang === 'fr' ? 'Modifier la zone géographique' : 'Edit Geofence Zone') : (lang === 'fr' ? 'Créer une zone géographique' : 'Create New Geofence Zone')"
      @close="showModal = false"
    >
      <form @submit.prevent="saveZone">
        <div class="form-group text-left" style="margin-bottom: 1.25rem;">
          <label class="form-label">{{ lang === 'fr' ? 'Nom de la zone' : 'Zone Name' }}</label>
          <input v-model="form.name" type="text" class="form-input" required placeholder="Dakar Plateau Center" />
        </div>

        <div class="grid grid-cols-2 gap-4 modal-form-grid" style="grid-template-columns: 1fr 1fr; margin-bottom: 1.25rem;">
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Multiplicateur de majoration' : 'Surge Multiplier' }}</label>
            <input v-model.number="form.multiplier" type="number" step="0.1" class="form-input" required min="0.5" max="3" />
          </div>
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Couleur de tracé' : 'Zone Polygon Color' }}</label>
            <div style="display: flex; gap: 0.5rem; align-items: center;">
              <input v-model="form.color" type="color" class="form-input" style="width: 50px; padding: 2px; height: 2.25rem;" />
              <input v-model="form.color" type="text" class="form-input" style="flex: 1;" placeholder="#14b19e" required />
            </div>
          </div>
        </div>

        <div class="form-group text-left" style="margin-bottom: 1.25rem;">
          <label class="form-label">{{ lang === 'fr' ? 'Coordonnées de contour' : 'Boundary Coordinates' }}</label>
          <textarea
            v-model="form.coordinatesText"
            class="form-input form-textarea"
            style="font-family: monospace; font-size: 0.8125rem; height: 100px; resize: vertical;"
            required
          />
          <span class="text-xs text-muted" style="margin-top: 4px; display: block;">
            {{ lang === 'fr' ? 'Format JSON: Tableau de paires [lat, lng]. Vous pouvez également cliquer sur la carte principale pour générer ces coordonnées automatiquement.' : 'JSON array of [lat, lng] pairs. You can also click points on the main map to build this automatically.' }}
          </span>
        </div>

        <div class="form-group text-left" style="margin-bottom: 1.5rem;">
          <label class="flex items-center gap-2 cursor-pointer">
            <input v-model="form.status" type="checkbox" />
            <span class="text-sm">{{ lang === 'fr' ? 'Activé (Pris en compte lors du dispatch)' : 'Enabled (Active in dispatching)' }}</span>
          </label>
        </div>

        <div class="modal-footer-actions" style="display: flex; justify-content: flex-end; gap: 0.75rem; margin-top: 2rem;">
          <button type="button" class="btn btn-secondary" @click="showModal = false">{{ t('cancel') }}</button>
          <button type="submit" class="btn btn-primary">{{ lang === 'fr' ? 'Enregistrer la zone' : 'Save Zone' }}</button>
        </div>
      </form>
    </AppModal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useI18n } from '~/composables/useI18n'

definePageMeta({
  middleware: 'auth',
})

const { t, lang } = useI18n()
const loading = ref(false)

// Map parameters default center Dakar
const mapCenter = ref({ lat: 14.6928, lng: -17.4467 })
const mapZoom = ref(12)

const drawnCoordinates = ref<[number, number][]>([])

// Zones default mock database
const zones = ref([
  {
    id: 'zone_1',
    name: 'Dakar Plateau Center',
    multiplier: 1.4,
    color: '#14b19e',
    status: true,
    coordinates: [
      [14.670, -17.440],
      [14.690, -17.420],
      [14.660, -17.410],
      [14.650, -17.430]
    ] as [number, number][]
  },
  {
    id: 'zone_2',
    name: 'Les Almadies / Ngor',
    multiplier: 1.6,
    color: '#00d4aa',
    status: true,
    coordinates: [
      [14.730, -17.525],
      [14.750, -17.510],
      [14.745, -17.490],
      [14.715, -17.505]
    ] as [number, number][]
  },
  {
    id: 'zone_3',
    name: 'AIBD Airport Corridor',
    multiplier: 1.0,
    color: '#ffd700',
    status: true,
    coordinates: [
      [14.660, -17.100],
      [14.685, -17.060],
      [14.640, -17.050],
      [14.620, -17.085]
    ] as [number, number][]
  }
])

const headers = computed(() => [
  { key: 'name', label: lang.value === 'fr' ? 'Nom de la Zone' : 'Zone Name' },
  { key: 'multiplier', label: lang.value === 'fr' ? 'Multiplicateur' : 'Multiplier' },
  { key: 'status', label: t('status') },
  { key: 'actions', label: t('actions'), style: { width: '200px', textAlign: 'right' } }
])

// Convert zones to the format expected by the map
const mapZones = computed(() => {
  const activeZones = zones.value.map(z => ({
    id: z.id,
    name: z.name + ` (${z.multiplier}x)`,
    color: z.color,
    coordinates: z.coordinates
  }))

  if (drawnCoordinates.value.length > 2) {
    activeZones.push({
      id: 'drawn_zone',
      name: lang.value === 'fr' ? 'Tracé en cours...' : 'Currently Drawing...',
      color: '#ff6b6b',
      coordinates: drawnCoordinates.value
    })
  }

  return activeZones
})

// Modal states
const showModal = ref(false)
const isEditMode = ref(false)
const editingId = ref<string | null>(null)
const form = ref({
  name: '',
  multiplier: 1.0,
  color: '#14b19e',
  coordinatesText: '',
  status: true
})

function openAddModal() {
  isEditMode.value = false
  editingId.value = null
  form.value = {
    name: '',
    multiplier: 1.0,
    color: '#14b19e',
    coordinatesText: JSON.stringify(drawnCoordinates.value),
    status: true
  }
  showModal.value = true
}

function openEditModal(zone: any) {
  isEditMode.value = true
  editingId.value = zone.id
  form.value = {
    name: zone.name,
    multiplier: zone.multiplier,
    color: zone.color,
    coordinatesText: JSON.stringify(zone.coordinates),
    status: zone.status
  }
  showModal.value = true
}

function saveZone() {
  try {
    const parsedCoords = JSON.parse(form.value.coordinatesText)
    if (!Array.isArray(parsedCoords) || parsedCoords.some(c => !Array.isArray(c) || c.length !== 2)) {
      throw new Error('Coordinates must be an array of [lat, lng] pairs.')
    }

    const payload = {
      name: form.value.name,
      multiplier: form.value.multiplier,
      color: form.value.color,
      coordinates: parsedCoords as [number, number][],
      status: form.value.status
    }

    if (isEditMode.value && editingId.value) {
      const idx = zones.value.findIndex(z => z.id === editingId.value)
      if (idx !== -1) {
        zones.value[idx] = { id: editingId.value, ...payload }
      }
    } else {
      zones.value.push({
        id: 'zone_' + Date.now(),
        ...payload
      })
      drawnCoordinates.value = [] // Clear drawing map trace
    }

    showModal.value = false
  } catch (err: any) {
    alert(lang.value === 'fr' ? 'Format de coordonnées invalide: ' + err.message : 'Invalid coordinates format: ' + err.message)
  }
}

function deleteZone(id: string) {
  zones.value = zones.value.filter(z => z.id !== id)
}

function focusZone(zone: any) {
  if (zone.coordinates && zone.coordinates.length > 0) {
    // Find average coordinate to center on
    const lats = zone.coordinates.map((c: any) => c[0])
    const lngs = zone.coordinates.map((c: any) => c[1])
    const avgLat = lats.reduce((a: number, b: number) => a + b, 0) / lats.length
    const avgLng = lngs.reduce((a: number, b: number) => a + b, 0) / lngs.length

    mapCenter.value = { lat: avgLat, lng: avgLng }
    mapZoom.value = 14
  }
}

function handleMapClick(latlng: { lat: number; lng: number }) {
  drawnCoordinates.value.push([latlng.lat, latlng.lng])
}

function promoteDrawnToForm() {
  openAddModal()
}
</script>

<style scoped>
.text-left {
  text-align: left;
}

.zones-grid {
  display: grid;
  grid-template-columns: 1fr 1.2fr;
  gap: 1.5rem;
}

@media (max-width: 900px) {
  .zones-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 640px) {
  .modal-form-grid {
    grid-template-columns: 1fr !important;
    gap: 1rem !important;
  }
  .modal-footer-actions {
    flex-direction: column;
    align-items: stretch;
    gap: 0.5rem !important;
  }
  .modal-footer-actions .btn {
    width: 100%;
  }
}
</style>
