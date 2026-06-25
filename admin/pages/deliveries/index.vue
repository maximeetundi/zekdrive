<template>
  <div>
    <!-- Page Header -->
    <div class="page-header animate-fade-in">
      <div>
        <h1 class="page-title">{{ lang === 'fr' ? 'Coursiers & Livraisons' : 'Courier & Deliveries' }}</h1>
        <p class="page-desc">
          {{ lang === 'fr' ? 'Suivre les expéditions de colis, l\'attribution des coursiers, l\'état d\'avancement et les tarifs' : 'Monitor package shipments, courier allocations, progress statuses, and fares' }}
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

        <!-- Vehicle Type Filter -->
        <div style="width: 170px;">
          <select v-model="vehicleFilter" class="form-select" @change="onFilterChange">
            <option value="">{{ lang === 'fr' ? 'Toutes les catégories' : 'All Vehicle Classes' }}</option>
            <option value="car">{{ lang === 'fr' ? 'Voiture' : 'Car' }}</option>
            <option value="moto">{{ lang === 'fr' ? 'Moto' : 'Moto' }}</option>
            <option value="bicycle">{{ lang === 'fr' ? 'Vélo / Trottinette' : 'Bicycle' }}</option>
            <option value="truck">{{ lang === 'fr' ? 'Camion' : 'Truck' }}</option>
          </select>
        </div>

        <button class="btn btn-secondary" style="height: 2.25rem;" @click="clearFilters">{{ t('reset') }}</button>
      </div>
    </div>

    <!-- Deliveries Table Card -->
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

          <!-- Package Details -->
          <template #cell-package_description="{ item }">
            <div style="text-align: left;">
              <div class="font-semibold text-primary">{{ item.package_description }}</div>
              <div class="text-xs text-muted" style="margin-top: 1px;">
                {{ lang === 'fr' ? 'Coursier :' : 'Courier:' }} <span class="text-secondary" style="text-transform: capitalize;">{{ item.vehicle_type }}</span>
              </div>
            </div>
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

          <!-- Distance metrics -->
          <template #cell-distance_km="{ item }">
            <span class="text-xs font-semibold text-primary">{{ item.distance_km }} km</span>
          </template>

          <!-- Status badge -->
          <template #cell-status="{ item }">
            <AppStatusBadge :status="item.status" />
          </template>

          <!-- Fare -->
          <template #cell-fare="{ item }">
            <span class="font-semibold text-primary">{{ formatCurrency(item.fare) }}</span>
          </template>

          <!-- Date -->
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

    <!-- Delivery Details Modal -->
    <AppModal
      :show="showDetailsModal"
      :title="lang === 'fr' ? 'Détails de la livraison' : 'Delivery Request Details'"
      @close="closeDetailsModal"
    >
      <div v-if="selectedDelivery" style="display: flex; flex-direction: column; gap: 1.25rem; text-align: left;">
        <!-- Header Info -->
        <div class="flex justify-between items-center" style="border-bottom: 1px solid var(--border); padding-bottom: 0.75rem;">
          <div>
            <span class="text-lg font-bold text-primary">{{ selectedDelivery.ref_id }}</span>
            <div class="text-xs text-muted">{{ lang === 'fr' ? 'Créé le ' : 'Created on ' }}{{ formatDateTime(selectedDelivery.created_at) }}</div>
          </div>
          <AppStatusBadge :status="selectedDelivery.status" />
        </div>

        <!-- Parcel Info -->
        <div style="background: rgba(255,255,255,0.02); padding: 0.875rem 1rem; border-radius: var(--radius-md); border: 1px solid var(--border);">
          <div class="text-xs text-muted" style="margin-bottom: 2px;">{{ lang === 'fr' ? 'Type de colis' : 'Parcel Package Type' }}</div>
          <strong class="text-base text-primary">{{ selectedDelivery.package_description }}</strong>
          <div class="flex gap-2" style="margin-top: 6px;">
            <span class="text-xs text-muted">{{ lang === 'fr' ? 'Véhicule requis :' : 'Vehicle Class Required:' }}</span>
            <AppStatusBadge :status="selectedDelivery.vehicle_type" />
          </div>
        </div>

        <!-- Meta Grid -->
        <div class="grid grid-cols-2 gap-4 modal-info-grid" style="grid-template-columns: 1fr 1fr;">
          <div class="info-row">
            <span class="text-xs text-muted" style="display: block;">{{ lang === 'fr' ? 'Expéditeur / Client' : 'Sender / Customer' }}</span>
            <strong class="text-sm text-primary">{{ selectedDelivery.customer_name }}</strong>
            <span class="text-xs text-muted" style="display: block;">ID: {{ selectedDelivery.customer_id }}</span>
          </div>
          
          <div class="info-row">
            <span class="text-xs text-muted" style="display: block;">{{ lang === 'fr' ? 'Coursier / Chauffeur' : 'Courier / Driver' }}</span>
            <strong class="text-sm text-primary">{{ selectedDelivery.driver_name || 'N/A' }}</strong>
            <span class="text-xs text-muted" style="display: block;">ID: {{ selectedDelivery.driver_id || 'N/A' }}</span>
          </div>
        </div>

        <div class="divider" style="height: 1px; background: var(--border); margin: 0.25rem 0;"></div>

        <!-- Address List -->
        <div>
          <span class="text-xs text-muted" style="display: block; margin-bottom: 0.5rem;">{{ lang === 'fr' ? 'Détails des adresses' : 'Address Details' }}</span>
          <div class="flex flex-col gap-2">
            <div class="text-xs text-primary" style="display: flex; align-items: flex-start; gap: 0.375rem;">
              <span class="text-green" style="margin-top: 1px;">●</span>
              <div>
                <strong>{{ lang === 'fr' ? 'Départ :' : 'Pickup:' }}</strong> {{ selectedDelivery.pickup_address }}
              </div>
            </div>
            <div class="text-xs text-primary" style="display: flex; align-items: flex-start; gap: 0.375rem;">
              <span class="text-red" style="margin-top: 1px;">●</span>
              <div>
                <strong>{{ lang === 'fr' ? 'Arrivée :' : 'Dropoff:' }}</strong> {{ selectedDelivery.dropoff_address }}
              </div>
            </div>
          </div>
        </div>

        <!-- Metrics -->
        <div class="grid grid-cols-3 gap-2 modal-metrics-grid" style="grid-template-columns: repeat(3, 1fr); text-align: center; margin-top: 0.25rem;">
          <div style="background: rgba(255,255,255,0.02); padding: 0.5rem; border-radius: var(--radius-sm); border: 1px solid var(--border);">
            <div class="text-xs text-muted">Distance</div>
            <strong class="text-sm text-primary">{{ selectedDelivery.distance_km }} km</strong>
          </div>
          <div style="background: rgba(255,255,255,0.02); padding: 0.5rem; border-radius: var(--radius-sm); border: 1px solid var(--border);">
            <div class="text-xs text-muted">{{ lang === 'fr' ? 'Type coursier' : 'Courier Class' }}</div>
            <strong class="text-sm text-primary" style="text-transform: capitalize;">{{ selectedDelivery.vehicle_type }}</strong>
          </div>
          <div style="background: rgba(255,255,255,0.02); padding: 0.5rem; border-radius: var(--radius-sm); border: 1px solid var(--border);">
            <div class="text-xs text-muted">{{ lang === 'fr' ? 'Paiement' : 'Payment Type' }}</div>
            <strong class="text-sm text-primary" style="text-transform: uppercase;">{{ selectedDelivery.payment_method }}</strong>
          </div>
        </div>

        <!-- Finance details -->
        <div style="display: flex; justify-content: space-between; align-items: center; border-top: 1px solid var(--border); padding-top: 0.75rem; margin-top: 0.25rem;">
          <span class="text-sm text-muted">{{ lang === 'fr' ? 'Frais de livraison' : 'Delivery Fee' }}</span>
          <span class="text-lg font-extrabold text-green">{{ formatCurrency(selectedDelivery.fare) }}</span>
        </div>

        <div class="modal-footer-actions" style="display: flex; justify-content: flex-end; margin-top: 1rem;">
          <button class="btn btn-secondary" @click="closeDetailsModal">{{ lang === 'fr' ? 'Fermer' : 'Close Details' }}</button>
        </div>
      </div>
    </AppModal>

    <!-- Map Route Modal -->
    <AppModal
      :show="showMapModal"
      :title="selectedDelivery ? (lang === 'fr' ? 'Carte de livraison — ' : 'Delivery Route Map — ') + selectedDelivery.ref_id : (lang === 'fr' ? 'Carte de livraison' : 'Delivery Route Map')"
      size="lg"
      @close="closeMapModal"
    >
      <div v-if="selectedDelivery" style="text-align: left;">
        <div style="margin-bottom: 1rem;">
          <div class="text-xs text-muted" style="margin-bottom: 2px;">{{ lang === 'fr' ? 'Détails du trajet :' : 'Route Details:' }}</div>
          <div class="text-xs text-primary"><span class="text-green">{{ lang === 'fr' ? 'Prise en charge :' : 'Pickup Location:' }}</span> {{ selectedDelivery.pickup_address }}</div>
          <div class="text-xs text-primary" style="margin-top: 2px;"><span class="text-red">{{ lang === 'fr' ? 'Lieu de dépose :' : 'Dropoff Location:' }}</span> {{ selectedDelivery.dropoff_address }}</div>
        </div>
        
        <ClientOnly>
          <AppMapView
            height="400px"
            :pickup="{ lat: selectedDelivery.pickup_lat, lng: selectedDelivery.pickup_lng, address: selectedDelivery.pickup_address }"
            :dropoff="{ lat: selectedDelivery.dropoff_lat, lng: selectedDelivery.dropoff_lng, address: selectedDelivery.dropoff_address }"
            :center="{ lat: (selectedDelivery.pickup_lat + selectedDelivery.dropoff_lat) / 2, lng: (selectedDelivery.pickup_lng + selectedDelivery.dropoff_lng) / 2 }"
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
import { useDeliveriesStore, type Delivery } from '~/stores/deliveries'
import { useI18n } from '~/composables/useI18n'

definePageMeta({
  middleware: 'auth',
})

const deliveriesStore = useDeliveriesStore()
const { list, total, page, perPage, totalPages, loading, selectedDelivery } = storeToRefs(deliveriesStore)
const { t, lang } = useI18n()

const statusFilter = ref('')
const vehicleFilter = ref('')

const headers = computed(() => [
  { key: 'ref_id', label: lang.value === 'fr' ? 'ID Référence' : 'Reference ID' },
  { key: 'customer_name', label: lang.value === 'fr' ? 'Expéditeur' : 'Sender' },
  { key: 'driver_name', label: lang.value === 'fr' ? 'Coursier' : 'Courier' },
  { key: 'package_description', label: lang.value === 'fr' ? 'Type de colis' : 'Package Type' },
  { key: 'route', label: lang.value === 'fr' ? 'Détails de l\'itinéraire' : 'Route Details' },
  { key: 'distance_km', label: lang.value === 'fr' ? 'Distance' : 'Distance' },
  { key: 'status', label: lang.value === 'fr' ? 'Statut' : 'Status' },
  { key: 'fare', label: lang.value === 'fr' ? 'Frais de livraison' : 'Delivery Fee' },
  { key: 'created_at', label: lang.value === 'fr' ? 'Créé le' : 'Created Time' },
  { key: 'actions', label: t('actions'), style: { width: '210px', textAlign: 'right' } },
])

const showDetailsModal = ref(false)
const showMapModal = ref(false)

onMounted(() => {
  deliveriesStore.fetchDeliveries()
})

function onFilterChange() {
  deliveriesStore.setFilters({
    status: statusFilter.value,
    vehicle_type: vehicleFilter.value,
  })
}

function clearFilters() {
  statusFilter.value = ''
  vehicleFilter.value = ''
  onFilterChange()
}

function setPage(p: number) {
  deliveriesStore.setPage(p)
}

function openDetailsModal(delivery: Delivery) {
  selectedDelivery.value = delivery
  showDetailsModal.value = true
}

function closeDetailsModal() {
  showDetailsModal.value = false
  selectedDelivery.value = null
}

function openMapModal(delivery: Delivery) {
  selectedDelivery.value = delivery
  showMapModal.value = true
}

function closeMapModal() {
  showMapModal.value = false
  selectedDelivery.value = null
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
