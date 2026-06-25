<template>
  <div>
    <!-- Page Header -->
    <div class="page-header animate-fade-in">
      <div>
        <h1 class="page-title">{{ t('drivers_directory') }}</h1>
        <p class="page-desc">{{ t('drivers_desc') }}</p>
      </div>
    </div>

    <!-- Filter Bar -->
    <div class="card animate-fade-in" style="margin-bottom: 1.5rem; padding: 1rem;">
      <div class="filter-bar">
        <!-- Search -->
        <div style="flex: 1; min-width: 240px;">
          <input
            v-model="searchTerm"
            type="text"
            class="form-input"
            :placeholder="lang === 'fr' ? 'Rechercher par nom, plaque ou e-mail...' : 'Search by name, plate number, or email...'"
            @input="onFilterChange"
          />
        </div>
        
        <!-- Availability Filter -->
        <div style="width: 170px;">
          <select v-model="availabilityFilter" class="form-select" @change="onFilterChange">
            <option value="">{{ t('all_statuses') }}</option>
            <option value="available">{{ lang === 'fr' ? 'Disponible' : 'Available' }}</option>
            <option value="busy">{{ lang === 'fr' ? 'Occupé' : 'Busy' }}</option>
            <option value="offline">{{ lang === 'fr' ? 'Hors ligne' : 'Offline' }}</option>
          </select>
        </div>

        <!-- Approval status Filter -->
        <div style="width: 170px;">
          <select v-model="approvalFilter" class="form-select" @change="onFilterChange">
            <option value="">{{ lang === 'fr' ? 'Toutes les approbations' : 'All Approvals' }}</option>
            <option value="approved">{{ lang === 'fr' ? 'Approuvé' : 'Approved' }}</option>
            <option value="pending">{{ lang === 'fr' ? 'En attente' : 'Pending' }}</option>
            <option value="rejected">{{ lang === 'fr' ? 'Rejeté' : 'Rejected' }}</option>
          </select>
        </div>

        <button class="btn btn-secondary" style="height: 2.25rem;" @click="clearFilters">{{ t('reset') }}</button>
      </div>
    </div>

    <!-- Drivers Table Card -->
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
          <!-- Driver Details Cell -->
          <template #cell-name="{ item }">
            <div>
              <div class="font-bold text-primary">{{ item.name }}</div>
              <div class="text-xs text-muted">{{ item.email }}</div>
            </div>
          </template>

          <!-- Country Cell -->
          <template #cell-country="{ item }">
            <span class="flex items-center gap-1">
              <span>{{ item.country === 'SN' ? '🇸🇳' : item.country === 'CI' ? '🇨🇮' : item.country === 'ML' ? '🇲🇱' : '🌍' }}</span>
              <span class="text-xs font-semibold" style="margin-left: 2px;">{{ item.country || 'SN' }}</span>
            </span>
          </template>

          <!-- Vehicle Cell -->
          <template #cell-vehicle="{ item }">
            <div>
              <div>{{ item.vehicle_model }}</div>
              <div class="flex items-center gap-2" style="margin-top: 2px;">
                <span class="text-xs font-semibold text-primary">{{ item.vehicle_plate }}</span>
                <AppStatusBadge :status="item.vehicle_type" />
              </div>
            </div>
          </template>

          <!-- Availability Cell -->
          <template #cell-availability="{ item }">
            <AppStatusBadge :status="item.availability" />
          </template>

          <!-- KYC status Cell -->
          <template #cell-kyc_status="{ item }">
            <AppStatusBadge :status="item.kyc_status || 'unsubmitted'" />
          </template>

          <!-- Approval Status Cell -->
          <template #cell-approval_status="{ item }">
            <AppStatusBadge :status="item.approval_status" />
          </template>

          <!-- Rating Cell -->
          <template #cell-rating="{ item }">
            <div class="stars">
              <span v-for="i in 5" :key="i" class="star" :class="{ 'star-empty': i > Math.round(item.rating) }">★</span>
              <span class="text-xs text-muted" style="margin-left: 4px;">({{ item.rating }})</span>
            </div>
          </template>

          <!-- Earnings Cell -->
          <template #cell-earnings_total="{ item }">
            <span class="font-semibold text-green">{{ formatCurrency(item.earnings_total) }}</span>
          </template>

          <!-- Actions Cell -->
          <template #cell-actions="{ item }">
            <div class="flex gap-2">
              <button class="btn btn-secondary btn-sm" @click="openMapModal(item)">{{ lang === 'fr' ? 'Carte' : 'Map' }}</button>
              <button class="btn btn-secondary btn-sm" @click="openEditModal(item)">{{ t('edit') }}</button>
              
              <!-- Quick Approval Flow -->
              <template v-if="item.approval_status === 'pending'">
                <button class="btn btn-success btn-sm" @click="approveDriver(item.id)">{{ lang === 'fr' ? 'Approuver' : 'Approve' }}</button>
                <button class="btn btn-danger btn-sm" @click="rejectDriver(item.id)">{{ lang === 'fr' ? 'Rejeter' : 'Reject' }}</button>
              </template>
            </div>
          </template>
        </AppDataTable>
      </div>
    </div>

    <!-- Edit Driver Modal -->
    <AppModal
      :show="showEditModal"
      :title="lang === 'fr' ? 'Modifier les détails du chauffeur' : 'Edit Driver Details'"
      @close="closeEditModal"
    >
      <form @submit.prevent="saveDriver">
        <div class="form-group text-left" style="margin-bottom: 1.25rem;">
          <label class="form-label">{{ t('fullname') }}</label>
          <input v-model="editForm.name" type="text" class="form-input" required />
        </div>
        
        <div class="form-group text-left" style="margin-bottom: 1.25rem;">
          <label class="form-label">{{ t('phone') }}</label>
          <input v-model="editForm.phone" type="text" class="form-input" required />
        </div>

        <div class="grid grid-cols-2 gap-4 modal-form-grid" style="grid-template-columns: 1fr 1fr; margin-bottom: 1.25rem;">
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Modèle véhicule' : 'Vehicle Model' }}</label>
            <input v-model="editForm.vehicle_model" type="text" class="form-input" required />
          </div>
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Plaque d\'immatriculation' : 'License Plate' }}</label>
            <input v-model="editForm.vehicle_plate" type="text" class="form-input" required />
          </div>
        </div>

        <div class="grid grid-cols-2 gap-4 modal-form-grid" style="grid-template-columns: 1fr 1fr; margin-bottom: 1.25rem;">
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Catégorie véhicule' : 'Vehicle Category' }}</label>
            <select v-model="editForm.vehicle_type" class="form-select">
              <option value="car">{{ lang === 'fr' ? 'Voiture' : 'Car' }}</option>
              <option value="moto">{{ lang === 'fr' ? 'Moto' : 'Moto' }}</option>
              <option value="bicycle">{{ lang === 'fr' ? 'Vélo / Trottinette' : 'Bicycle' }}</option>
              <option value="truck">{{ lang === 'fr' ? 'Camion' : 'Truck' }}</option>
            </select>
          </div>
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Disponibilité' : 'Availability' }}</label>
            <select v-model="editForm.availability" class="form-select">
              <option value="available">{{ lang === 'fr' ? 'Disponible' : 'Available' }}</option>
              <option value="busy">{{ lang === 'fr' ? 'Occupé' : 'Busy' }}</option>
              <option value="offline">{{ lang === 'fr' ? 'Hors ligne' : 'Offline' }}</option>
            </select>
          </div>
        </div>

        <div class="grid grid-cols-2 gap-4 modal-form-grid" style="grid-template-columns: 1fr 1fr; margin-bottom: 1.25rem;">
          <div class="form-group text-left">
            <label class="form-label">{{ t('country') }}</label>
            <select v-model="editForm.country" class="form-select" required>
              <option value="SN">🇸🇳 Sénégal (SN)</option>
              <option value="CI">🇨🇮 Côte d'Ivoire (CI)</option>
              <option value="ML">🇲🇱 Mali (ML)</option>
            </select>
          </div>
          <div class="form-group text-left">
            <label class="form-label">{{ t('kyc_status') }}</label>
            <select v-model="editForm.kyc_status" class="form-select">
              <option value="unsubmitted">{{ t('unsubmitted') }}</option>
              <option value="pending">{{ t('pending') }}</option>
              <option value="approved">{{ t('approved') }}</option>
              <option value="rejected">{{ t('rejected') }}</option>
            </select>
          </div>
        </div>

        <!-- Driver License / Documents Verification -->
        <div class="kyc-verification-panel text-left animate-fade-in" style="margin-top: 1.5rem; padding: 1rem; border-radius: var(--radius-md); background: rgba(255, 255, 255, 0.03); border: 1px solid rgba(255, 255, 255, 0.08); margin-bottom: 1.25rem;">
          <h3 class="text-sm font-bold text-primary" style="margin-bottom: 0.75rem; display: flex; align-items: center; justify-content: space-between;">
            <span>🛡️ {{ lang === 'fr' ? 'Validation Permis de Conduire (KYC)' : 'Drivers License Verification (KYC)' }}</span>
            <AppStatusBadge :status="editForm.kyc_status" />
          </h3>
          
          <div v-if="editForm.kyc_document" class="kyc-doc-preview" style="margin-bottom: 1rem;">
            <div class="doc-mock-card" style="width: 100%; height: 130px; border-radius: var(--radius-sm); border: 1px dashed rgba(255, 255, 255, 0.2); display: flex; flex-direction: column; align-items: center; justify-content: center; background: rgba(0, 0, 0, 0.3); position: relative; overflow: hidden; padding: 1rem;">
              <span style="font-size: 2rem;">🪪</span>
              <span class="text-xs font-semibold text-primary" style="margin-top: 0.5rem;">{{ editForm.kyc_document }}</span>
              <span class="text-[10px] text-muted">{{ t('license_number') }} : {{ selectedDriver?.id }}</span>
            </div>
          </div>
          <div v-else style="margin-bottom: 1rem; color: var(--text-muted); font-size: 0.8125rem; font-style: italic;">
            {{ lang === 'fr' ? 'Aucun permis de conduire KYC soumis.' : 'No driver\'s license KYC document submitted.' }}
          </div>

          <div v-if="editForm.kyc_status === 'pending'" class="flex gap-2" style="justify-content: flex-end;">
            <button type="button" class="btn btn-success btn-sm" @click="editForm.kyc_status = 'approved'">
              {{ t('approve_kyc') }}
            </button>
            <button type="button" class="btn btn-danger btn-sm" @click="editForm.kyc_status = 'rejected'">
              {{ t('reject_kyc') }}
            </button>
          </div>
        </div>

        <div class="modal-footer-actions" style="display: flex; justify-content: flex-end; gap: 0.75rem; margin-top: 2rem;">
          <button type="button" class="btn btn-secondary" @click="closeEditModal">{{ t('cancel') }}</button>
          <button type="submit" class="btn btn-primary">{{ t('save_changes') }}</button>
        </div>
      </form>
    </AppModal>

    <!-- Map Location Modal -->
    <AppModal
      :show="showMapModal"
      :title="selectedDriver ? (lang === 'fr' ? 'Localisation en direct — ' : 'Live Location — ') + selectedDriver.name : (lang === 'fr' ? 'Localisation du chauffeur' : 'Driver Location')"
      size="lg"
      @close="closeMapModal"
    >
      <div v-if="selectedDriver" style="padding-bottom: 0.5rem; text-align: left;">
        <div class="flex justify-between items-center modal-map-header" style="margin-bottom: 1rem;">
          <div>
            <span class="text-sm text-muted">{{ lang === 'fr' ? 'Vu pour la dernière fois : ' : 'Last Seen: ' }}</span>
            <span class="text-sm font-semibold text-primary">{{ formatTime(selectedDriver.last_seen || '') }}</span>
          </div>
          <div class="flex items-center gap-2">
            <AppStatusBadge :status="selectedDriver.availability" />
            <AppStatusBadge :status="selectedDriver.vehicle_type" />
          </div>
        </div>
        
        <ClientOnly>
          <AppMapView
            height="400px"
            :center="{ lat: selectedDriver.lat || 14.6928, lng: selectedDriver.lng || -17.4467 }"
            :zoom="15"
            :drivers="[{
              id: selectedDriver.id,
              name: selectedDriver.name,
              lat: selectedDriver.lat || 14.6928,
              lng: selectedDriver.lng || -17.4467,
              status: selectedDriver.availability,
              vehicle_type: selectedDriver.vehicle_type
            }]"
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
import { useDriversStore, type Driver } from '~/stores/drivers'
import { useI18n } from '~/composables/useI18n'

definePageMeta({
  middleware: 'auth',
})

const driversStore = useDriversStore()
const { list, total, page, perPage, totalPages, loading } = storeToRefs(driversStore)
const { t, lang } = useI18n()

const searchTerm = ref('')
const availabilityFilter = ref('')
const approvalFilter = ref('')

const headers = computed(() => [
  { key: 'name', label: lang.value === 'fr' ? 'Détails Chauffeur' : 'Driver Details' },
  { key: 'phone', label: t('phone') },
  { key: 'country', label: t('country') },
  { key: 'vehicle', label: lang.value === 'fr' ? 'Détails Véhicule' : 'Vehicle details' },
  { key: 'availability', label: lang.value === 'fr' ? 'Disponibilité' : 'Availability' },
  { key: 'approval_status', label: lang.value === 'fr' ? 'Approbation' : 'Approval' },
  { key: 'kyc_status', label: t('kyc_status') },
  { key: 'rating', label: lang.value === 'fr' ? 'Note' : 'Rating' },
  { key: 'earnings_total', label: lang.value === 'fr' ? 'Gains Totaux' : 'Total Earnings' },
  { key: 'actions', label: t('actions'), style: { width: '260px', textAlign: 'right' } },
])

// Modal control state
const showEditModal = ref(false)
const showMapModal = ref(false)
const selectedDriver = ref<Driver | null>(null)

const editForm = ref({
  name: '',
  phone: '',
  vehicle_model: '',
  vehicle_plate: '',
  vehicle_type: 'car' as Driver['vehicle_type'],
  availability: 'offline' as Driver['availability'],
  country: 'SN',
  kyc_status: 'unsubmitted' as Driver['kyc_status'],
  kyc_document: '',
})

onMounted(() => {
  driversStore.fetchDrivers()
})

function onFilterChange() {
  driversStore.setFilters({
    search: searchTerm.value,
    availability: availabilityFilter.value,
    approval_status: approvalFilter.value,
  })
}

function clearFilters() {
  searchTerm.value = ''
  availabilityFilter.value = ''
  approvalFilter.value = ''
  onFilterChange()
}

function setPage(p: number) {
  driversStore.setPage(p)
}

function openEditModal(driver: Driver) {
  selectedDriver.value = driver
  editForm.value = {
    name: driver.name,
    phone: driver.phone,
    vehicle_model: driver.vehicle_model,
    vehicle_plate: driver.vehicle_plate,
    vehicle_type: driver.vehicle_type,
    availability: driver.availability,
    country: driver.country || 'SN',
    kyc_status: driver.kyc_status || 'unsubmitted',
    kyc_document: driver.kyc_document || '',
  }
  showEditModal.value = true
}

function closeEditModal() {
  showEditModal.value = false
  selectedDriver.value = null
}

async function saveDriver() {
  if (selectedDriver.value) {
    await driversStore.updateDriver(selectedDriver.value.id, editForm.value)
  }
  showEditModal.value = false
  selectedDriver.value = null
}

function openMapModal(driver: Driver) {
  selectedDriver.value = driver
  showMapModal.value = true
}

function closeMapModal() {
  showMapModal.value = false
  selectedDriver.value = null
}

async function approveDriver(id: string) {
  await driversStore.approveDriver(id)
  const idx = list.value.findIndex(d => d.id === id)
  if (idx !== -1) {
    list.value[idx].kyc_status = 'approved'
    list.value[idx].approval_status = 'approved'
  }
}

async function rejectDriver(id: string) {
  await driversStore.rejectDriver(id)
  const idx = list.value.findIndex(d => d.id === id)
  if (idx !== -1) {
    list.value[idx].kyc_status = 'rejected'
    list.value[idx].approval_status = 'rejected'
  }
}

function formatCurrency(val: number): string {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF', maximumFractionDigits: 0 }).format(val)
}

function formatTime(dateStr: string): string {
  if (!dateStr) return lang.value === 'fr' ? 'Hors ligne' : 'Offline'
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
  .modal-map-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
}
</style>
