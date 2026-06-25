<template>
  <div>
    <!-- Page Header -->
    <div class="page-header animate-fade-in">
      <div>
        <h1 class="page-title">{{ lang === 'fr' ? 'Courses de VTC' : 'Ride-Hailing Trips' }}</h1>
        <p class="page-desc">
          {{ lang === 'fr' ? 'Suivre les trajets clients, les itinéraires actifs, l\'historique des statuts et les tarifs' : 'Monitor customer rides, active routes, status histories, and fares' }}
        </p>
      </div>
    </div>

    <!-- Filter Bar -->
    <div class="card animate-fade-in" style="margin-bottom: 1.5rem; padding: 1rem;">
      <div class="filter-bar">
        <!-- Status Filter -->
        <div style="width: 170px;">
          <select v-model="statusFilter" class="form-select" @change="onFilterChange">
            <option value="">{{ t('all_statuses') }}</option>
            <option value="pending">{{ lang === 'fr' ? 'En attente' : 'Pending' }}</option>
            <option value="accepted">{{ lang === 'fr' ? 'Accepté' : 'Accepted' }}</option>
            <option value="ongoing">{{ lang === 'fr' ? 'En cours' : 'Ongoing' }}</option>
            <option value="completed">{{ lang === 'fr' ? 'Terminé' : 'Completed' }}</option>
            <option value="cancelled">{{ lang === 'fr' ? 'Annulé' : 'Cancelled' }}</option>
          </select>
        </div>

        <!-- Zone Filter -->
        <div style="width: 170px;">
          <select v-model="zoneFilter" class="form-select" @change="onFilterChange">
            <option value="">{{ lang === 'fr' ? 'Toutes les zones' : 'All Zones' }}</option>
            <option value="Dakar Centre">Dakar Centre</option>
            <option value="Dakar Ouest">Dakar Ouest</option>
            <option value="Banlieue">Banlieue</option>
            <option value="Pikine">Pikine</option>
          </select>
        </div>

        <button class="btn btn-secondary" style="height: 2.25rem;" @click="clearFilters">{{ t('reset') }}</button>
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
            <div style="max-width: 280px; text-align: left;">
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
              <button class="btn btn-secondary btn-sm" @click="openMapModal(item)">{{ lang === 'fr' ? 'Trajet' : 'Map Route' }}</button>
              <button class="btn btn-secondary btn-sm" @click="openDetailsModal(item)">{{ lang === 'fr' ? 'Détails' : 'Details' }}</button>
            </div>
          </template>
        </AppDataTable>
      </div>
    </div>

    <!-- Trip Details Modal -->
    <AppModal
      :show="showDetailsModal"
      :title="lang === 'fr' ? 'Détails de la course' : 'Trip Request Details'"
      @close="closeDetailsModal"
    >
      <div v-if="selectedTrip" style="display: flex; flex-direction: column; gap: 1.25rem; text-align: left;">
        <!-- Header Info -->
        <div class="flex justify-between items-center" style="border-bottom: 1px solid var(--border); padding-bottom: 0.75rem;">
          <div>
            <span class="text-lg font-bold text-primary">{{ selectedTrip.ref_id }}</span>
            <div class="text-xs text-muted">{{ lang === 'fr' ? 'Créé le ' : 'Created on ' }}{{ formatDateTime(selectedTrip.created_at) }}</div>
          </div>
          <AppStatusBadge :status="selectedTrip.status" />
        </div>

        <!-- Meta Grid -->
        <div class="grid grid-cols-2 gap-4 modal-info-grid" style="grid-template-columns: 1fr 1fr;">
          <div class="info-row">
            <span class="text-xs text-muted" style="display: block;">{{ lang === 'fr' ? 'Client' : 'Customer' }}</span>
            <strong class="text-sm text-primary">{{ selectedTrip.customer_name }}</strong>
            <span class="text-xs text-muted" style="display: block;">ID: {{ selectedTrip.customer_id }}</span>
          </div>
          
          <div class="info-row">
            <span class="text-xs text-muted" style="display: block;">{{ lang === 'fr' ? 'Chauffeur assigné' : 'Assigned Driver' }}</span>
            <strong class="text-sm text-primary">{{ selectedTrip.driver_name || 'N/A' }}</strong>
            <span class="text-xs text-muted" style="display: block;">ID: {{ selectedTrip.driver_id || 'N/A' }}</span>
          </div>
        </div>

        <div class="divider" style="height: 1px; background: var(--border); margin: 0.25rem 0;"></div>

        <!-- Metrics -->
        <div class="grid grid-cols-3 gap-2 modal-metrics-grid" style="grid-template-columns: repeat(3, 1fr); text-align: center;">
          <div style="background: rgba(255,255,255,0.02); padding: 0.5rem; border-radius: var(--radius-sm); border: 1px solid var(--border);">
            <div class="text-xs text-muted">Distance</div>
            <strong class="text-sm text-primary">{{ selectedTrip.distance_km }} km</strong>
          </div>
          <div style="background: rgba(255,255,255,0.02); padding: 0.5rem; border-radius: var(--radius-sm); border: 1px solid var(--border);">
            <div class="text-xs text-muted">{{ lang === 'fr' ? 'Durée est.' : 'Est. Duration' }}</div>
            <strong class="text-sm text-primary">{{ selectedTrip.duration_min }} mins</strong>
          </div>
          <div style="background: rgba(255,255,255,0.02); padding: 0.5rem; border-radius: var(--radius-sm); border: 1px solid var(--border);">
            <div class="text-xs text-muted">Zone</div>
            <strong class="text-sm text-primary">{{ selectedTrip.zone || 'Dakar' }}</strong>
          </div>
        </div>

        <!-- Payment Info -->
        <div class="grid grid-cols-2 gap-4 modal-info-grid" style="grid-template-columns: 1fr 1fr;">
          <div>
            <span class="text-xs text-muted" style="display: block;">{{ lang === 'fr' ? 'Mode de paiement' : 'Payment Method' }}</span>
            <span class="text-xs font-semibold text-primary" style="text-transform: uppercase;">{{ selectedTrip.payment_method }}</span>
          </div>
          <div>
            <span class="text-xs text-muted" style="display: block;">{{ lang === 'fr' ? 'Tarif total' : 'Total Fare' }}</span>
            <span class="text-sm font-bold text-green">{{ formatCurrency(selectedTrip.fare) }}</span>
          </div>
        </div>

        <div class="divider" style="height: 1px; background: var(--border); margin: 0.25rem 0;"></div>

        <!-- State Timeline -->
        <div>
          <span class="text-xs text-muted" style="display: block; margin-bottom: 0.75rem;">{{ lang === 'fr' ? 'Chronologie du statut' : 'Status Timeline' }}</span>
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
          <div v-else class="text-xs text-muted">{{ lang === 'fr' ? 'Aucun historique de statut disponible.' : 'No timeline status history available.' }}</div>
        </div>

        <div class="modal-footer-actions" style="display: flex; justify-content: flex-end; margin-top: 1.5rem;">
          <button class="btn btn-secondary" @click="closeDetailsModal">{{ lang === 'fr' ? 'Fermer' : 'Close Details' }}</button>
        </div>
      </div>
    </AppModal>

    <!-- Map Route Modal -->
    <AppModal
      :show="showMapModal"
      :title="selectedTrip ? (lang === 'fr' ? 'Carte du trajet — ' : 'Trip Route Map — ') + selectedTrip.ref_id : (lang === 'fr' ? 'Carte du trajet' : 'Trip Route Map')"
      size="lg"
      @close="closeMapModal"
    >
      <div v-if="selectedTrip" style="text-align: left;">
        <div style="margin-bottom: 1rem;">
          <div class="text-xs text-muted" style="margin-bottom: 2px;">{{ lang === 'fr' ? 'Itinéraire :' : 'Route Details:' }}</div>
          <div class="text-xs text-primary"><span class="text-green">{{ lang === 'fr' ? 'Départ :' : 'Pickup:' }}</span> {{ selectedTrip.pickup_address }}</div>
          <div class="text-xs text-primary" style="margin-top: 2px;"><span class="text-red">{{ lang === 'fr' ? 'Arrivée :' : 'Dropoff:' }}</span> {{ selectedTrip.dropoff_address }}</div>
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
import { ref, computed, onMounted } from 'vue'
import { storeToRefs } from 'pinia'
import { useTripsStore, type Trip } from '~/stores/trips'
import { useI18n } from '~/composables/useI18n'

definePageMeta({
  middleware: 'auth',
})

const tripsStore = useTripsStore()
const { list, total, page, perPage, totalPages, loading, selectedTrip } = storeToRefs(tripsStore)
const { t, lang } = useI18n()

const statusFilter = ref('')
const zoneFilter = ref('')

const headers = computed(() => [
  { key: 'ref_id', label: lang.value === 'fr' ? 'ID Référence' : 'Reference ID' },
  { key: 'customer_name', label: lang.value === 'fr' ? 'Client' : 'Customer' },
  { key: 'driver_name', label: lang.value === 'fr' ? 'Chauffeur' : 'Driver' },
  { key: 'route', label: lang.value === 'fr' ? 'Prise en charge & Dépose' : 'Pickup & Dropoff Route' },
  { key: 'metrics', label: lang.value === 'fr' ? 'Distance / Durée' : 'Distance / Est' },
  { key: 'status', label: lang.value === 'fr' ? 'Statut' : 'Status' },
  { key: 'fare', label: lang.value === 'fr' ? 'Tarif Total' : 'Total Fare' },
  { key: 'created_at', label: lang.value === 'fr' ? 'Date de création' : 'Created Time' },
  { key: 'actions', label: t('actions'), style: { width: '210px', textAlign: 'right' } },
])

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
    return d.toLocaleString(lang.value === 'fr' ? 'fr-FR' : 'en-US', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })
  } catch {
    return dateStr
  }
}

function formatTime(dateStr: string): string {
  try {
    const d = new Date(dateStr)
    return d.toLocaleTimeString(lang.value === 'fr' ? 'fr-FR' : 'en-US', { hour: '2-digit', minute: '2-digit' })
  } catch {
    return dateStr
  }
}
</script>

<style scoped>
.text-left {
  text-align: left;
}

@media (max-width: 640px) {
  .modal-info-grid {
    grid-template-columns: 1fr !important;
    gap: 1rem !important;
  }
  .modal-metrics-grid {
    grid-template-columns: 1fr !important;
    gap: 0.5rem !important;
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
