<template>
  <div>
    <!-- Page Header -->
    <div class="page-header animate-fade-in">
      <div>
        <h1 class="page-title">Ride-Hailing Trips</h1>
        <p class="page-desc">Monitor customer rides, active routes, status histories, and fares</p>
      </div>
    </div>

    <!-- Filter Bar -->
    <div class="card animate-fade-in" style="margin-bottom: 1.5rem; padding: 1rem;">
      <div class="filter-bar">
        <!-- Status Filter -->
        <div style="width: 170px;">
          <select v-model="statusFilter" class="form-select" @change="onFilterChange">
            <option value="">All Statuses</option>
            <option value="pending">Pending</option>
            <option value="accepted">Accepted</option>
            <option value="ongoing">Ongoing</option>
            <option value="completed">Completed</option>
            <option value="cancelled">Cancelled</option>
          </select>
        </div>

        <!-- Zone Filter -->
        <div style="width: 170px;">
          <select v-model="zoneFilter" class="form-select" @change="onFilterChange">
            <option value="">All Zones</option>
            <option value="Dakar Centre">Dakar Centre</option>
            <option value="Dakar Ouest">Dakar Ouest</option>
            <option value="Banlieue">Banlieue</option>
            <option value="Pikine">Pikine</option>
          </select>
        </div>

        <button class="btn btn-secondary" style="height: 2.25rem;" @click="clearFilters">Reset</button>
      </div>
    </div>

    <!-- Trips Table Card -->
    <div class="card animate-slide-up">
      <div class="card-body" style="padding: 0;">
        <AppDataTable
          :headers="headers"
          :items="list"
          :loading="loading"
          :currentPage="page"
          :perPage="perPage"
          :totalItems="total"
          :totalPages="totalPages"
          @update:page="setPage"
        >
          <!-- Reference ID -->
          <template #cell-ref_id="{ item }">
            <span class="font-bold text-primary">{{ item.ref_id }}</span>
          </template>

          <!-- Route Description -->
          <template #cell-route="{ item }">
            <div style="max-width: 280px;">
              <div class="truncate text-xs text-primary" :title="item.pickup_address">
                <span class="text-green" style="margin-right: 4px;">●</span> {{ item.pickup_address }}
              </div>
              <div class="truncate text-xs text-muted" :title="item.dropoff_address" style="margin-top: 2px;">
                <span class="text-red" style="margin-right: 4px;">●</span> {{ item.dropoff_address }}
              </div>
            </div>
          </template>

          <!-- Distance & Duration -->
          <template #cell-metrics="{ item }">
            <div>
              <div class="text-xs">{{ item.distance_km }} km</div>
              <div class="text-xs text-muted">{{ item.duration_min }} mins</div>
            </div>
          </template>

          <!-- Status badge -->
          <template #cell-status="{ item }">
            <AppStatusBadge :status="item.status" />
          </template>

          <!-- Fare -->
          <template #cell-fare="{ item }">
            <span class="font-semibold text-primary">{{ formatCurrency(item.fare) }}</span>
          </template>

          <!-- Registered Date -->
          <template #cell-created_at="{ item }">
            <span>{{ formatDateTime(item.created_at) }}</span>
          </template>

          <!-- Actions -->
          <template #cell-actions="{ item }">
            <div class="flex gap-2">
              <button class="btn btn-secondary btn-sm" @click="openMapModal(item)">Map Route</button>
              <button class="btn btn-secondary btn-sm" @click="openDetailsModal(item)">Details</button>
            </div>
          </template>
        </AppDataTable>
      </div>
    </div>

    <!-- Trip Details Modal -->
    <AppModal
      :show="showDetailsModal"
      title="Trip Request Details"
      @close="closeDetailsModal"
    >
      <div v-if="selectedTrip" style="display: flex; flex-direction: column; gap: 1.25rem;">
        <!-- Header Info -->
        <div class="flex justify-between items-center" style="border-bottom: 1px solid var(--border); padding-bottom: 0.75rem;">
          <div>
            <span class="text-lg font-bold text-primary">{{ selectedTrip.ref_id }}</span>
            <div class="text-xs text-muted">Created on {{ formatDateTime(selectedTrip.created_at) }}</div>
          </div>
          <AppStatusBadge :status="selectedTrip.status" />
        </div>

        <!-- Meta Grid -->
        <div class="grid grid-cols-2 gap-4" style="grid-template-columns: 1fr 1fr;">
          <div class="info-row">
            <span class="text-xs text-muted" style="display: block;">Customer</span>
            <strong class="text-sm text-primary">{{ selectedTrip.customer_name }}</strong>
            <span class="text-xs text-muted" style="display: block;">ID: {{ selectedTrip.customer_id }}</span>
          </div>
          
          <div class="info-row">
            <span class="text-xs text-muted" style="display: block;">Assigned Driver</span>
            <strong class="text-sm text-primary">{{ selectedTrip.driver_name }}</strong>
            <span class="text-xs text-muted" style="display: block;">ID: {{ selectedTrip.driver_id }}</span>
          </div>
        </div>

        <div class="divider" style="height: 1px; background: var(--border); margin: 0.25rem 0;"></div>

        <!-- Metrics -->
        <div class="grid grid-cols-3 gap-2" style="grid-template-columns: repeat(3, 1fr); text-align: center;">
          <div style="background: rgba(255,255,255,0.02); padding: 0.5rem; border-radius: var(--radius-sm); border: 1px solid var(--border);">
            <div class="text-xs text-muted">Distance</div>
            <strong class="text-sm text-primary">{{ selectedTrip.distance_km }} km</strong>
          </div>
          <div style="background: rgba(255,255,255,0.02); padding: 0.5rem; border-radius: var(--radius-sm); border: 1px solid var(--border);">
            <div class="text-xs text-muted">Est. Duration</div>
            <strong class="text-sm text-primary">{{ selectedTrip.duration_min }} mins</strong>
          </div>
          <div style="background: rgba(255,255,255,0.02); padding: 0.5rem; border-radius: var(--radius-sm); border: 1px solid var(--border);">
            <div class="text-xs text-muted">Zone</div>
            <strong class="text-sm text-primary">{{ selectedTrip.zone || 'Dakar' }}</strong>
          </div>
        </div>

        <!-- Payment Info -->
        <div class="grid grid-cols-2 gap-4" style="grid-template-columns: 1fr 1fr;">
          <div>
            <span class="text-xs text-muted" style="display: block;">Payment Method</span>
            <span class="text-xs font-semibold text-primary" style="text-transform: uppercase;">{{ selectedTrip.payment_method }}</span>
          </div>
          <div>
            <span class="text-xs text-muted" style="display: block;">Total Fare</span>
            <span class="text-sm font-bold text-green">{{ formatCurrency(selectedTrip.fare) }}</span>
          </div>
        </div>

        <div class="divider" style="height: 1px; background: var(--border); margin: 0.25rem 0;"></div>

        <!-- State Timeline -->
        <div>
          <span class="text-xs text-muted" style="display: block; margin-bottom: 0.75rem;">Status Timeline</span>
          <div v-if="selectedTrip.status_history && selectedTrip.status_history.length > 0" class="flex flex-col gap-3">
            <div v-for="(hist, idx) in selectedTrip.status_history" :key="idx" class="flex items-start gap-3">
              <div style="position: relative; display: flex; flex-direction: column; align-items: center;">
                <div style="background-color: var(--accent-primary); width: 8px; height: 8px; border-radius: 50%; z-index: 1; margin-top: 5px;"></div>
                <div v-if="idx < selectedTrip.status_history.length - 1" style="width: 2px; height: 24px; background: var(--border); position: absolute; top: 10px;"></div>
              </div>
              <div style="flex: 1;">
                <div class="flex justify-between items-center">
                  <span class="text-xs font-semibold text-primary" style="text-transform: capitalize;">{{ hist.status }}</span>
                  <span class="text-xs text-muted">{{ formatTime(hist.timestamp) }}</span>
                </div>
                <div v-if="hist.note" class="text-xs text-muted" style="margin-top: 1px;">{{ hist.note }}</div>
              </div>
            </div>
          </div>
          <div v-else class="text-xs text-muted">No timeline status history available.</div>
        </div>

        <div style="display: flex; justify-content: flex-end; margin-top: 1.5rem;">
          <button class="btn btn-secondary" @click="closeDetailsModal">Close Details</button>
        </div>
      </div>
    </AppModal>

    <!-- Map Route Modal -->
    <AppModal
      :show="showMapModal"
      :title="selectedTrip ? 'Route Route Map — ' + selectedTrip.ref_id : 'Trip Route Map'"
      size="lg"
      @close="closeMapModal"
    >
      <div v-if="selectedTrip">
        <div style="margin-bottom: 1rem;">
          <div class="text-xs text-muted" style="margin-bottom: 2px;">Route Route:</div>
          <div class="text-xs text-primary"><span class="text-green">Pickup:</span> {{ selectedTrip.pickup_address }}</div>
          <div class="text-xs text-primary" style="margin-top: 2px;"><span class="text-red">Dropoff:</span> {{ selectedTrip.dropoff_address }}</div>
        </div>
        
        <ClientOnly>
          <AppMapView
            height="400px"
            :pickup="{ lat: selectedTrip.pickup_lat, lng: selectedTrip.pickup_lng, address: selectedTrip.pickup_address }"
            :dropoff="{ lat: selectedTrip.dropoff_lat, lng: selectedTrip.dropoff_lng, address: selectedTrip.dropoff_address }"
            :center="{ lat: (selectedTrip.pickup_lat + selectedTrip.dropoff_lat) / 2, lng: (selectedTrip.pickup_lng + selectedTrip.dropoff_lng) / 2 }"
            :zoom="12"
          />
          <template #fallback>
            <div class="skeleton" style="height: 400px; width: 100%; border-radius: var(--radius-md);"></div>
          </template>
        </ClientOnly>
      </div>
    </AppModal>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { storeToRefs } from 'pinia'
import { useTripsStore, type Trip } from '~/stores/trips'

definePageMeta({
  middleware: 'auth',
})

const tripsStore = useTripsStore()
const { list, total, page, perPage, totalPages, loading, selectedTrip } = storeToRefs(tripsStore)

const statusFilter = ref('')
const zoneFilter = ref('')

const headers = [
  { key: 'ref_id', label: 'Reference ID' },
  { key: 'customer_name', label: 'Customer' },
  { key: 'driver_name', label: 'Driver' },
  { key: 'route', label: 'Pickup & Dropoff Route' },
  { key: 'metrics', label: 'Distance / Est' },
  { key: 'status', label: 'Status' },
  { key: 'fare', label: 'Total Fare' },
  { key: 'created_at', label: 'Created Time' },
  { key: 'actions', label: 'Actions', style: { width: '210px', textAlign: 'right' } },
]

const showDetailsModal = ref(false)
const showMapModal = ref(false)

onMounted(() => {
  tripsStore.fetchTrips()
})

function onFilterChange() {
  tripsStore.setFilters({
    status: statusFilter.value,
    zone: zoneFilter.value,
  })
}

function clearFilters() {
  statusFilter.value = ''
  zoneFilter.value = ''
  onFilterChange()
}

function setPage(p: number) {
  tripsStore.setPage(p)
}

async function openDetailsModal(trip: Trip) {
  await tripsStore.fetchTripDetail(trip.id)
  showDetailsModal.value = true
}

function closeDetailsModal() {
  showDetailsModal.value = false
}

function openMapModal(trip: Trip) {
  selectedTrip.value = trip
  showMapModal.value = true
}

function closeMapModal() {
  showMapModal.value = false
}

function formatCurrency(val: number): string {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF', maximumFractionDigits: 0 }).format(val)
}

function formatDateTime(dateStr: string): string {
  try {
    const d = new Date(dateStr)
    return d.toLocaleString('fr-FR', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })
  } catch {
    return dateStr
  }
}

function formatTime(dateStr: string): string {
  try {
    const d = new Date(dateStr)
    return d.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
  } catch {
    return dateStr
  }
}
</script>
