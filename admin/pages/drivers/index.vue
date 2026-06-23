<template>
  <div>
    <!-- Page Header -->
    <div class="page-header animate-fade-in">
      <div>
        <h1 class="page-title">Drivers Registry</h1>
        <p class="page-desc">Monitor driver approvals, vehicle classes, earnings, and locations</p>
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
            class="form-control"
            placeholder="Search by name, plate number, or email..."
            @input="onFilterChange"
          />
        </div>
        
        <!-- Availability Filter -->
        <div style="width: 170px;">
          <select v-model="availabilityFilter" class="form-select" @change="onFilterChange">
            <option value="">All Statuses</option>
            <option value="available">Available</option>
            <option value="busy">Busy</option>
            <option value="offline">Offline</option>
          </select>
        </div>

        <!-- Approval status Filter -->
        <div style="width: 170px;">
          <select v-model="approvalFilter" class="form-select" @change="onFilterChange">
            <option value="">All Approvals</option>
            <option value="approved">Approved</option>
            <option value="pending">Pending</option>
            <option value="rejected">Rejected</option>
          </select>
        </div>

        <button class="btn btn-secondary" style="height: 2.25rem;" @click="clearFilters">Reset</button>
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
              <button class="btn btn-secondary btn-sm" @click="openMapModal(item)">Map</button>
              <button class="btn btn-secondary btn-sm" @click="openEditModal(item)">Edit</button>
              
              <!-- Quick Approval Flow -->
              <template v-if="item.approval_status === 'pending'">
                <button class="btn btn-success btn-sm" @click="approveDriver(item.id)">Approve</button>
                <button class="btn btn-danger btn-sm" @click="rejectDriver(item.id)">Reject</button>
              </template>
            </div>
          </template>
        </AppDataTable>
      </div>
    </div>

    <!-- Edit Driver Modal -->
    <AppModal
      :show="showEditModal"
      title="Edit Driver Details"
      @close="closeEditModal"
    >
      <form @submit.prevent="saveDriver">
        <div class="form-group" style="margin-bottom: 1rem;">
          <label class="form-label">Full Name</label>
          <input v-model="editForm.name" type="text" class="form-control" required />
        </div>
        
        <div class="form-group" style="margin-bottom: 1rem;">
          <label class="form-label">Phone Number</label>
          <input v-model="editForm.phone" type="text" class="form-control" required />
        </div>

        <div class="grid grid-cols-2 gap-4" style="grid-template-columns: 1fr 1fr; margin-bottom: 1rem;">
          <div class="form-group">
            <label class="form-label">Vehicle Model</label>
            <input v-model="editForm.vehicle_model" type="text" class="form-control" required />
          </div>
          <div class="form-group">
            <label class="form-label">License Plate</label>
            <input v-model="editForm.vehicle_plate" type="text" class="form-control" required />
          </div>
        </div>

        <div class="grid grid-cols-2 gap-4" style="grid-template-columns: 1fr 1fr; margin-bottom: 1rem;">
          <div class="form-group">
            <label class="form-label">Vehicle Category</label>
            <select v-model="editForm.vehicle_type" class="form-select">
              <option value="car">Car</option>
              <option value="moto">Moto</option>
              <option value="bicycle">Bicycle</option>
              <option value="truck">Truck</option>
            </select>
          </div>
          <div class="form-group">
            <label class="form-label">Availability</label>
            <select v-model="editForm.availability" class="form-select">
              <option value="available">Available</option>
              <option value="busy">Busy</option>
              <option value="offline">Offline</option>
            </select>
          </div>
        </div>

        <div style="display: flex; justify-content: flex-end; gap: 0.75rem; margin-top: 2rem;">
          <button type="button" class="btn btn-secondary" @click="closeEditModal">Cancel</button>
          <button type="submit" class="btn btn-primary">Save Changes</button>
        </div>
      </form>
    </AppModal>

    <!-- Map Location Modal -->
    <AppModal
      :show="showMapModal"
      :title="selectedDriver ? 'Location Map — ' + selectedDriver.name : 'Driver Location'"
      size="lg"
      @close="closeMapModal"
    >
      <div v-if="selectedDriver" style="padding-bottom: 0.5rem;">
        <div class="flex justify-between items-center" style="margin-bottom: 1rem;">
          <div>
            <span class="text-sm text-muted">Last Seen: </span>
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
import { ref, onMounted } from 'vue'
import { storeToRefs } from 'pinia'
import { useDriversStore, type Driver } from '~/stores/drivers'

definePageMeta({
  middleware: 'auth',
})

const driversStore = useDriversStore()
const { list, total, page, perPage, totalPages, loading } = storeToRefs(driversStore)

const searchTerm = ref('')
const availabilityFilter = ref('')
const approvalFilter = ref('')

const headers = [
  { key: 'name', label: 'Driver Details' },
  { key: 'phone', label: 'Phone' },
  { key: 'vehicle', label: 'Vehicle details' },
  { key: 'availability', label: 'Availability' },
  { key: 'approval_status', label: 'Approval' },
  { key: 'rating', label: 'Rating' },
  { key: 'earnings_total', label: 'Total Earnings' },
  { key: 'actions', label: 'Actions', style: { width: '260px', textAlign: 'right' } },
]

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
}

async function rejectDriver(id: string) {
  await driversStore.rejectDriver(id)
}

function formatCurrency(val: number): string {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF', maximumFractionDigits: 0 }).format(val)
}

function formatTime(dateStr: string): string {
  if (!dateStr) return 'Offline'
  try {
    const d = new Date(dateStr)
    return d.toLocaleString('fr-FR', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })
  } catch {
    return dateStr
  }
}
</script>
