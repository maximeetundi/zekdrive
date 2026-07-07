<template>
  <div>
    <!-- Page Header -->
    <div class="page-header animate-fade-in">
      <div>
        <h1 class="page-title">{{ lang === 'fr' ? 'Zones géographiques' : 'Geofence Zones' }}</h1>
        <p class="page-desc">{{ lang === 'fr' ? 'Définir les limites de service, les zones actives et les tarifs/majorations par zone' : 'Define service bounds, active operational zones, and per-zone fare rates/surge multipliers' }}</p>
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
          <h3 class="text-base font-semibold">{{ lang === 'fr' ? 'Limites opérationnelles actives' : 'Active Operational Boundaries' }}</h3>
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

            <template #cell-pricing="{ item }">
              <div class="text-xs text-left" style="line-height: 1.4;">
                <div><strong>Base:</strong> {{ item.base_fare }} FCFA</div>
                <div><strong>KM:</strong> {{ item.fare_per_km }} FCFA</div>
                <div><strong>Min:</strong> {{ item.fare_per_minute }} FCFA</div>
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
                <button class="btn btn-danger btn-sm" @click="handleDeleteZone(item.id)">{{ t('delete') }}</button>
              </div>
            </template>
          </AppDataTable>
        </div>
      </div>

      <!-- Right: Live Map Visualizer (Stacked at bottom) -->
      <div class="card">
        <div class="card-header flex justify-between items-center flex-wrap gap-2" style="padding: 1rem 1.25rem; border-bottom: 1px solid var(--border); text-align: left;">
          <h3 class="text-base font-semibold">{{ lang === 'fr' ? 'Carte des limites globales' : 'Global Boundary Map View' }}</h3>
          <span class="text-xs text-muted">{{ lang === 'fr' ? 'Visualisation des polygones enregistrés en base' : 'Visualization of geofence polygons stored in the database' }}</span>
        </div>
        <div class="card-body" style="padding: 1rem;">
          <ClientOnly>
            <AppMapView
              height="450px"
              :center="mapCenter"
              :zoom="mapZoom"
              :zones="mapZones"
            />
            <template #fallback>
              <div class="skeleton" style="height: 450px; width: 100%; border-radius: var(--radius-md);"></div>
            </template>
          </ClientOnly>
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
        <!-- Zone Name -->
        <div class="form-group text-left" style="margin-bottom: 1.25rem;">
          <label class="form-label">{{ lang === 'fr' ? 'Nom de la zone' : 'Zone Name' }}</label>
          <input v-model="form.name" type="text" class="form-input" required placeholder="Yaoundé Centre" />
        </div>

        <!-- Surge and Color -->
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

        <!-- Pricing Rules for the Zone -->
        <div class="grid grid-cols-3 gap-4 modal-form-grid" style="grid-template-columns: 1fr 1fr 1fr; margin-bottom: 1.25rem;">
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Tarif de base (FCFA)' : 'Base Fare (XAF)' }}</label>
            <input v-model.number="form.base_fare" type="number" step="1" class="form-input" required min="1" />
          </div>
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Tarif par KM (FCFA)' : 'Fare per KM (XAF)' }}</label>
            <input v-model.number="form.fare_per_km" type="number" step="1" class="form-input" required min="1" />
          </div>
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Tarif par Minute (FCFA)' : 'Fare per Min (XAF)' }}</label>
            <input v-model.number="form.fare_per_minute" type="number" step="1" class="form-input" required min="0" />
          </div>
        </div>

        <!-- Coordinates Text area -->
        <div class="form-group text-left" style="margin-bottom: 1.25rem;">
          <label class="form-label">{{ lang === 'fr' ? 'Coordonnées de contour' : 'Boundary Coordinates' }}</label>
          <textarea
            v-model="form.coordinatesText"
            class="form-input form-textarea"
            style="font-family: monospace; font-size: 0.8125rem; height: 80px; resize: vertical;"
            required
            readonly
          />
          <div style="display: flex; gap: 0.5rem; margin-top: 0.5rem; flex-wrap: wrap;">
            <button type="button" class="btn btn-secondary btn-sm" @click="loadCityTemplate('yaounde')">📍 Yaoundé</button>
            <button type="button" class="btn btn-secondary btn-sm" @click="loadCityTemplate('douala')">📍 Douala</button>
          </div>
          <span class="text-xs text-muted" style="margin-top: 4px; display: block;">
            {{ lang === 'fr' ? 'Cliquez sur la carte ci-dessous pour tracer le contour de la zone.' : 'Click on the map below to trace the boundaries of the zone.' }}
          </span>
        </div>

        <!-- Tracing Map inside modal -->
        <div class="form-group text-left" style="margin-bottom: 1.25rem;">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.5rem;">
            <label class="form-label" style="margin: 0;">{{ lang === 'fr' ? 'Tracer les limites sur la carte' : 'Trace on the Map' }}</label>
            <button type="button" class="btn btn-secondary btn-sm" @click="clearFormCoordinates" style="padding: 2px 8px; font-size: 0.75rem;">
              {{ lang === 'fr' ? 'Effacer la carte' : 'Clear Map' }}
            </button>
          </div>
          <ClientOnly>
            <AppMapView
              height="300px"
              :center="modalMapCenter"
              :zoom="12"
              :zones="modalMapZones"
              @map-click="handleModalMapClick"
            />
            <template #fallback>
              <div class="skeleton" style="height: 300px; width: 100%; border-radius: var(--radius-md);"></div>
            </template>
          </ClientOnly>
        </div>

        <div class="form-group text-left" style="margin-bottom: 1.5rem;">
          <label class="flex items-center gap-2 cursor-pointer">
            <input v-model="form.status" type="checkbox" />
            <span class="text-sm">{{ lang === 'fr' ? 'Activé (Pris en compte lors du dispatch)' : 'Enabled (Active in dispatching)' }}</span>
          </label>
        </div>

        <div class="modal-footer-actions" style="display: flex; justify-content: flex-end; gap: 0.75rem; margin-top: 2rem;">
          <button type="button" class="btn btn-secondary" @click="showModal = false">{{ t('cancel') }}</button>
          <button type="submit" class="btn btn-primary" :disabled="loading">{{ lang === 'fr' ? 'Enregistrer la zone' : 'Save Zone' }}</button>
        </div>
      </form>
    </AppModal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useI18n } from '~/composables/useI18n'
import { useApi } from '~/composables/useApi'

definePageMeta({
  middleware: 'auth',
})

const { t, lang } = useI18n()
const { get, post, del } = useApi()
const loading = ref(false)

// Map parameters default center Yaounde, Cameroon
const mapCenter = ref({ lat: 3.8480, lng: 11.5021 })
const mapZoom = ref(12)

const drawnCoordinates = ref<[number, number][]>([])
const zones = ref<any[]>([])

// Load zones from backend on mount
async function fetchZones() {
  loading.value = true
  const { data, error } = await get<any[]>('/zones')
  if (data) {
    zones.value = data.map((z: any) => {
      let coords: [number, number][] = []
      // Parse PostGIS ST_AsText WKT string: POLYGON((lng lat, lng lat, ...))
      if (z.boundary) {
        try {
          const wkt = z.boundary
          const match = wkt.match(/\(\((.*)\)\)/)
          if (match && match[1]) {
            const pairs = match[1].split(',')
            coords = pairs.map((p: string) => {
              const [lngStr, latStr] = p.trim().split(' ')
              return [parseFloat(latStr), parseFloat(lngStr)] as [number, number]
            })
            // Remove closing point if duplicate of start for clean rendering
            if (coords.length > 1 && coords[0][0] === coords[coords.length-1][0] && coords[0][1] === coords[coords.length-1][1]) {
              coords.pop()
            }
          }
        } catch (e) {
          console.error("WKT parse error:", e)
        }
      }

      // Keep random color or default if not saved
      const colors = ['#ff4b4b', '#4b73ff', '#14b19e', '#00d4aa', '#ffaa00', '#ee00ff']
      const randomColor = colors[Math.abs(hashCode(z.name)) % colors.length]

      return {
        id: z.id,
        name: z.name,
        multiplier: z.surge_multiplier || 1.0,
        color: randomColor,
        status: true,
        coordinates: coords,
        base_fare: z.base_fare || 500,
        fare_per_km: z.fare_per_km || 150,
        fare_per_minute: z.fare_per_minute || 25
      }
    })
  } else if (error) {
    console.error("Error fetching zones from database:", error)
  }
  loading.value = false
}

// Utilitaire hashCode local (ne pollue pas le prototype String)
function hashCode(str: string): number {
  let hash = 0
  for (let i = 0; i < str.length; i++) {
    hash = str.charCodeAt(i) + ((hash << 5) - hash)
  }
  return hash
}

onMounted(() => {
  fetchZones()
})

const loadCityTemplate = (city: string) => {
  if (city === 'yaounde') {
    form.value.name = 'Yaoundé Centre'
    form.value.coordinatesText = JSON.stringify([
      [3.75, 11.35],
      [3.75, 11.65],
      [3.95, 11.65],
      [3.95, 11.35]
    ], null, 2)
  } else if (city === 'douala') {
    form.value.name = 'Douala Centre'
    form.value.coordinatesText = JSON.stringify([
      [3.95, 9.60],
      [3.95, 9.90],
      [4.15, 9.90],
      [4.15, 9.60]
    ], null, 2)
  }
}

const headers = computed(() => [
  { key: 'name', label: lang.value === 'fr' ? 'Nom de la Zone' : 'Zone Name' },
  { key: 'pricing', label: lang.value === 'fr' ? 'Tarifs (FCFA)' : 'Fares (XAF)' },
  { key: 'multiplier', label: lang.value === 'fr' ? 'Majoration' : 'Surge' },
  { key: 'status', label: t('status') },
  { key: 'actions', label: t('actions'), style: { width: '200px', textAlign: 'right' } }
])

// Convert zones to the format expected by the map
const mapZones = computed(() => {
  return zones.value.map(z => ({
    id: z.id,
    name: z.name + ` (${z.multiplier}x)`,
    color: z.color,
    coordinates: z.coordinates
  }))
})

// Modal states
const showModal = ref(false)
const isEditMode = ref(false)
const editingId = ref<string | null>(null)
const form = ref({
  name: '',
  multiplier: 1.0,
  color: '#14b19e',
  coordinatesText: '[]',
  status: true,
  base_fare: 500,
  fare_per_km: 150,
  fare_per_minute: 25
})

// Modal Interactive Map Computeds
const modalMapCenter = computed(() => {
  try {
    const coords = JSON.parse(form.value.coordinatesText)
    if (Array.isArray(coords) && coords.length > 0) {
      const lats = coords.map((c: any) => c[0])
      const lngs = coords.map((c: any) => c[1])
      const avgLat = lats.reduce((a: number, b: number) => a + b, 0) / lats.length
      const avgLng = lngs.reduce((a: number, b: number) => a + b, 0) / lngs.length
      return { lat: avgLat, lng: avgLng }
    }
  } catch (e) {}
  return { lat: 3.8480, lng: 11.5021 } // Yaoundé fallback
})

const modalMapZones = computed(() => {
  let coords: [number, number][] = []
  try {
    const parsed = JSON.parse(form.value.coordinatesText)
    if (Array.isArray(parsed)) {
      coords = parsed as [number, number][]
    }
  } catch (e) {}

  return [
    {
      id: 'editing_zone',
      name: form.value.name || (lang.value === 'fr' ? 'Nouvelle Zone' : 'New Zone'),
      color: form.value.color || '#14b19e',
      coordinates: coords
    }
  ]
})

function handleModalMapClick(latlng: { lat: number; lng: number }) {
  let coords: [number, number][] = []
  try {
    const parsed = JSON.parse(form.value.coordinatesText)
    if (Array.isArray(parsed)) {
      coords = parsed as [number, number][]
    }
  } catch (e) {}

  coords.push([Number(latlng.lat.toFixed(6)), Number(latlng.lng.toFixed(6))])
  form.value.coordinatesText = JSON.stringify(coords, null, 2)
}

function clearFormCoordinates() {
  form.value.coordinatesText = '[]'
}

function openAddModal() {
  isEditMode.value = false
  editingId.value = null
  form.value = {
    name: '',
    multiplier: 1.0,
    color: '#14b19e',
    coordinatesText: '[]',
    status: true,
    base_fare: 500,
    fare_per_km: 150,
    fare_per_minute: 25
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
    coordinatesText: JSON.stringify(zone.coordinates, null, 2),
    status: zone.status,
    base_fare: zone.base_fare,
    fare_per_km: zone.fare_per_km,
    fare_per_minute: zone.fare_per_minute
  }
  showModal.value = true
}

async function saveZone() {
  try {
    const parsedCoords = JSON.parse(form.value.coordinatesText)
    if (!Array.isArray(parsedCoords) || parsedCoords.length < 3) {
      throw new Error('Coordinates must be an array of at least 3 [lat, lng] pairs to form a polygon.')
    }

    // Format to WKT POLYGON((lng lat, lng lat, ...))
    // Note that PostGIS expects closed loops (first point = last point)
    const points = [...parsedCoords]
    if (points[0][0] !== points[points.length-1][0] || points[0][1] !== points[points.length-1][1]) {
      points.push(points[0])
    }
    // WKT expects longitude latitude
    const boundaryWkt = `POLYGON((${points.map(p => `${p[1]} ${p[0]}`).join(',')}))`

    const payload = {
      name: form.value.name,
      boundary: boundaryWkt,
      base_fare: Number(form.value.base_fare),
      fare_per_km: Number(form.value.fare_per_km),
      fare_per_minute: Number(form.value.fare_per_minute),
      surge_multiplier: Number(form.value.multiplier)
    }

    loading.value = true
    if (isEditMode.value && editingId.value) {
      // API has no PUT route for full zone update, so we delete and recreate to keep db consistent
      const delRes = await del(`/zones/${editingId.value}`)
      if (delRes.error) {
        throw new Error(delRes.error)
      }
    }

    const { data, error } = await post<any>('/zones', payload)
    if (error) {
      throw new Error(error)
    }

    showModal.value = false
    await fetchZones()
  } catch (err: any) {
    alert(lang.value === 'fr' ? 'Erreur : ' + err.message : 'Error: ' + err.message)
  } finally {
    loading.value = false
  }
}

async function handleDeleteZone(id: string) {
  if (confirm(lang.value === 'fr' ? 'Supprimer cette zone ?' : 'Delete this zone?')) {
    loading.value = true
    const { error } = await del(`/zones/${id}`)
    if (error) {
      alert(error)
    } else {
      await fetchZones()
    }
    loading.value = false
  }
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
</script>

<style scoped>
.text-left {
  text-align: left;
}

.zones-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1.5rem;
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
