<template>
  <div>
    <!-- Page Header -->
    <div class="page-header animate-fade-in">
      <div>
        <h1 class="page-title">Fleet & Vehicle Classes</h1>
        <p class="page-desc">Manage pricing categories, dispatch limits, and register vehicles</p>
      </div>
      <div class="page-actions">
        <button class="btn btn-primary" @click="openAddModal">
          {{ activeTab === 'categories' ? 'Add Category' : 'Register Vehicle' }}
        </button>
      </div>
    </div>

    <!-- Tabs Wrapper -->
    <div class="tabs animate-fade-in" style="margin-bottom: 1.5rem;">
      <button class="tab-item" :class="{ active: activeTab === 'categories' }" @click="activeTab = 'categories'">
        Vehicle Categories
      </button>
      <button class="tab-item" :class="{ active: activeTab === 'vehicles' }" @click="activeTab = 'vehicles'">
        Individual Vehicles
      </button>
    </div>

    <!-- 1. Categories Tab Content -->
    <div v-if="activeTab === 'categories'" class="animate-slide-up">
      <div class="card">
        <div class="card-body" style="padding: 0;">
          <AppDataTable
            :headers="categoryHeaders"
            :items="categories"
            :loading="loading"
            :currentPage="1"
            :perPage="20"
            :totalItems="categories.length"
            :totalPages="1"
          >
            <template #cell-name="{ item }">
              <span class="font-bold text-primary">{{ item.name }}</span>
            </template>
            
            <template #cell-type="{ item }">
              <span class="badge badge-primary text-xs" style="text-transform: uppercase;">{{ item.type }}</span>
            </template>

            <template #cell-base_fare="{ item }">
              <span class="font-semibold text-primary">{{ formatCurrency(item.base_fare) }}</span>
            </template>

            <template #cell-per_km="{ item }">
              <span class="text-secondary">{{ formatCurrency(item.per_km) }}/km</span>
            </template>

            <template #cell-per_min="{ item }">
              <span class="text-secondary">{{ formatCurrency(item.per_min) }}/min</span>
            </template>

            <template #cell-min_fare="{ item }">
              <span class="font-semibold text-primary">{{ formatCurrency(item.min_fare) }}</span>
            </template>

            <template #cell-status="{ item }">
              <AppStatusBadge :status="item.status ? 'active' : 'inactive'" />
            </template>

            <template #cell-actions="{ item }">
              <div class="flex gap-2">
                <button class="btn btn-secondary btn-sm" @click="openEditCategoryModal(item)">Edit</button>
                <button class="btn btn-secondary btn-sm" @click="toggleCategoryStatus(item)">
                  {{ item.status ? 'Deactivate' : 'Activate' }}
                </button>
                <button class="btn btn-danger btn-sm" @click="deleteCategory(item.id)">Delete</button>
              </div>
            </template>
          </AppDataTable>
        </div>
      </div>
    </div>

    <!-- 2. Vehicles Tab Content -->
    <div v-else class="animate-slide-up">
      <!-- Search/Filters for vehicles -->
      <div class="card" style="margin-bottom: 1.5rem; padding: 1rem;">
        <div class="filter-bar">
          <div style="flex: 1; min-width: 240px;">
            <input v-model="vehicleSearch" type="text" class="form-control" placeholder="Search by plate number, driver name, model..." />
          </div>
          <div style="width: 170px;">
            <select v-model="vehicleCategoryFilter" class="form-select">
              <option value="">All Categories</option>
              <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
            </select>
          </div>
        </div>
      </div>

      <div class="card">
        <div class="card-body" style="padding: 0;">
          <AppDataTable
            :headers="vehicleHeaders"
            :items="filteredVehicles"
            :loading="loading"
            :currentPage="1"
            :perPage="30"
            :totalItems="filteredVehicles.length"
            :totalPages="1"
          >
            <template #cell-plate="{ item }">
              <span class="font-semibold text-primary" style="text-transform: uppercase;">{{ item.plate }}</span>
            </template>

            <template #cell-category="{ item }">
              <span class="badge badge-info text-xs">{{ getCategoryName(item.category_id) }}</span>
            </template>

            <template #cell-status="{ item }">
              <AppStatusBadge :status="item.status" />
            </template>

            <template #cell-actions="{ item }">
              <div class="flex gap-2">
                <button class="btn btn-secondary btn-sm" @click="openEditVehicleModal(item)">Edit</button>
                <button class="btn btn-secondary btn-sm" @click="toggleVehicleStatus(item)">Toggle Status</button>
                <button class="btn btn-danger btn-sm" @click="deleteVehicle(item.id)">Delete</button>
              </div>
            </template>
          </AppDataTable>
        </div>
      </div>
    </div>

    <!-- Edit Category Modal -->
    <AppModal
      :show="showCategoryModal"
      :title="isEditMode ? 'Edit Category Pricing' : 'Add Vehicle Category'"
      @close="showCategoryModal = false"
    >
      <form @submit.prevent="saveCategory">
        <div class="form-group" style="margin-bottom: 1rem;">
          <label class="form-label">Category Name</label>
          <input v-model="categoryForm.name" type="text" class="form-control" required placeholder="Sedan Standard" />
        </div>

        <div class="grid grid-cols-2 gap-4" style="grid-template-columns: 1fr 1fr; margin-bottom: 1rem;">
          <div class="form-group">
            <label class="form-label">Dispatch Code (Type)</label>
            <select v-model="categoryForm.type" class="form-select">
              <option value="car">Car (Ride-Hailing)</option>
              <option value="moto">Moto (Delivery/Ride)</option>
              <option value="bicycle">Bicycle (Food Delivery)</option>
              <option value="truck">Truck (Freight/Cargo)</option>
            </select>
          </div>
          <div class="form-group">
            <label class="form-label">Base Fare (FCFA)</label>
            <input v-model.number="categoryForm.base_fare" type="number" class="form-control" required min="0" />
          </div>
        </div>

        <div class="grid grid-cols-2 gap-4" style="grid-template-columns: 1fr 1fr; margin-bottom: 1rem;">
          <div class="form-group">
            <label class="form-label">Price per KM (FCFA)</label>
            <input v-model.number="categoryForm.per_km" type="number" class="form-control" required min="0" />
          </div>
          <div class="form-group">
            <label class="form-label">Price per Minute (FCFA)</label>
            <input v-model.number="categoryForm.per_min" type="number" class="form-control" required min="0" />
          </div>
        </div>

        <div class="grid grid-cols-2 gap-4" style="grid-template-columns: 1fr 1fr; margin-bottom: 1.5rem;">
          <div class="form-group">
            <label class="form-label">Minimum Fare (FCFA)</label>
            <input v-model.number="categoryForm.min_fare" type="number" class="form-control" required min="0" />
          </div>
          <div class="form-group flex items-center" style="margin-top: 1.75rem;">
            <label class="flex items-center gap-2 cursor-pointer">
              <input v-model="categoryForm.status" type="checkbox" />
              <span class="text-sm">Enabled</span>
            </label>
          </div>
        </div>

        <div style="display: flex; justify-content: flex-end; gap: 0.75rem; margin-top: 2rem;">
          <button type="button" class="btn btn-secondary" @click="showCategoryModal = false">Cancel</button>
          <button type="submit" class="btn btn-primary">Save Category</button>
        </div>
      </form>
    </AppModal>

    <!-- Edit Vehicle Modal -->
    <AppModal
      :show="showVehicleModal"
      :title="isEditMode ? 'Edit Vehicle Info' : 'Register Vehicle'"
      @close="showVehicleModal = false"
    >
      <form @submit.prevent="saveVehicle">
        <div class="form-group" style="margin-bottom: 1rem;">
          <label class="form-label">License Plate Number</label>
          <input v-model="vehicleForm.plate" type="text" class="form-control" required placeholder="DK 1234 AA" style="text-transform: uppercase;" />
        </div>

        <div class="form-group" style="margin-bottom: 1rem;">
          <label class="form-label">Vehicle Category Class</label>
          <select v-model="vehicleForm.category_id" class="form-select" required>
            <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
          </select>
        </div>

        <div class="grid grid-cols-2 gap-4" style="grid-template-columns: 1fr 1fr; margin-bottom: 1rem;">
          <div class="form-group">
            <label class="form-label">Brand / Model</label>
            <input v-model="vehicleForm.model" type="text" class="form-control" required placeholder="Toyota Corolla" />
          </div>
          <div class="form-group">
            <label class="form-label">Associated Driver Name</label>
            <input v-model="vehicleForm.driver" type="text" class="form-control" required placeholder="Lamine Koné" />
          </div>
        </div>

        <div class="form-group" style="margin-bottom: 1.5rem;">
          <label class="form-label">Operational Status</label>
          <select v-model="vehicleForm.status" class="form-select">
            <option value="active">Active</option>
            <option value="maintenance">Maintenance</option>
            <option value="inactive">Inactive</option>
          </select>
        </div>

        <div style="display: flex; justify-content: flex-end; gap: 0.75rem; margin-top: 2rem;">
          <button type="button" class="btn btn-secondary" @click="showVehicleModal = false">Cancel</button>
          <button type="submit" class="btn btn-primary">Register Vehicle</button>
        </div>
      </form>
    </AppModal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

definePageMeta({
  middleware: 'auth',
})

const activeTab = ref<'categories' | 'vehicles'>('categories')
const loading = ref(false)

// Vehicle Search
const vehicleSearch = ref('')
const vehicleCategoryFilter = ref('')

// Categories Mock list
const categories = ref([
  { id: 'cat_moto', name: 'ZekMoto Courier', type: 'moto', base_fare: 400, per_km: 150, per_min: 20, min_fare: 600, status: true },
  { id: 'cat_sedan', name: 'ZekClassic Sedan', type: 'car', base_fare: 700, per_km: 250, per_min: 30, min_fare: 1000, status: true },
  { id: 'cat_premium', name: 'ZekPremium Comfort', type: 'car', base_fare: 1200, per_km: 350, per_min: 40, min_fare: 1500, status: true },
  { id: 'cat_delivery', name: 'ZekBox Delivery Van', type: 'car', base_fare: 800, per_km: 280, per_min: 35, min_fare: 1200, status: true },
  { id: 'cat_cargo', name: 'ZekCargo Truck', type: 'truck', base_fare: 4000, per_km: 700, per_min: 80, min_fare: 6000, status: true },
])

// Vehicles Mock list
const vehicles = ref([
  { id: 'veh_1', plate: 'DK-2005-AB', model: 'Toyota Corolla 2018', category_id: 'cat_sedan', driver: 'Seydou Keita', status: 'active' },
  { id: 'veh_2', plate: 'TH-4903-AA', model: 'Yamaha Boxer 150', category_id: 'cat_moto', driver: 'Lamine Koné', status: 'active' },
  { id: 'veh_3', plate: 'DK-0920-BC', model: 'Hyundai Elantra 2020', category_id: 'cat_sedan', driver: 'Boubacar Diarra', status: 'active' },
  { id: 'veh_4', plate: 'SL-7821-AC', model: 'Peugeot Partner', category_id: 'cat_delivery', driver: 'Abdoulaye Cissé', status: 'maintenance' },
  { id: 'veh_5', plate: 'DK-5512-AZ', model: 'Mercedes C-Class 2019', category_id: 'cat_premium', driver: 'Mamadou Barry', status: 'active' },
  { id: 'veh_6', plate: 'DK-1049-M', model: 'Haojue Express 125', category_id: 'cat_moto', driver: 'Ibrahima Sow', status: 'inactive' },
  { id: 'veh_7', plate: 'TH-0239-B', model: 'Mitsubishi Fuso Cargo', category_id: 'cat_cargo', driver: 'Alpha Diallo', status: 'active' },
])

const categoryHeaders = [
  { key: 'name', label: 'Category Name' },
  { key: 'type', label: 'Vehicle type' },
  { key: 'base_fare', label: 'Base Fare' },
  { key: 'per_km', label: 'Per KM' },
  { key: 'per_min', label: 'Per Min' },
  { key: 'min_fare', label: 'Min Fare' },
  { key: 'status', label: 'Status' },
  { key: 'actions', label: 'Actions', style: { width: '220px', textAlign: 'right' } },
]

const vehicleHeaders = [
  { key: 'plate', label: 'License Plate' },
  { key: 'model', label: 'Model' },
  { key: 'category', label: 'Category Class' },
  { key: 'driver', label: 'Assigned Driver' },
  { key: 'status', label: 'Operational Status' },
  { key: 'actions', label: 'Actions', style: { width: '220px', textAlign: 'right' } },
]

const filteredVehicles = computed(() => {
  return vehicles.value.filter(v => {
    const q = vehicleSearch.value.toLowerCase()
    const matchesSearch =
      v.plate.toLowerCase().includes(q) ||
      v.model.toLowerCase().includes(q) ||
      v.driver.toLowerCase().includes(q)
      
    const matchesCategory = !vehicleCategoryFilter.value || v.category_id === vehicleCategoryFilter.value
    return matchesSearch && matchesCategory
  })
})

function getCategoryName(catId: string): string {
  return categories.value.find(c => c.id === catId)?.name || 'Unknown'
}

// Modal forms state
const showCategoryModal = ref(false)
const showVehicleModal = ref(false)
const isEditMode = ref(false)
const editingId = ref<string | null>(null)

const categoryForm = ref({
  name: '',
  type: 'car',
  base_fare: 500,
  per_km: 200,
  per_min: 25,
  min_fare: 800,
  status: true,
})

const vehicleForm = ref({
  plate: '',
  model: '',
  category_id: '',
  driver: '',
  status: 'active',
})

function openAddModal() {
  isEditMode.value = false
  editingId.value = null
  if (activeTab.value === 'categories') {
    categoryForm.value = {
      name: '',
      type: 'car',
      base_fare: 500,
      per_km: 200,
      per_min: 25,
      min_fare: 800,
      status: true,
    }
    showCategoryModal.value = true
  } else {
    vehicleForm.value = {
      plate: '',
      model: '',
      category_id: categories.value[0]?.id || '',
      driver: '',
      status: 'active',
    }
    showVehicleModal.value = true
  }
}

function openEditCategoryModal(cat: any) {
  isEditMode.value = true
  editingId.value = cat.id
  categoryForm.value = { ...cat }
  showCategoryModal.value = true
}

function openEditVehicleModal(veh: any) {
  isEditMode.value = true
  editingId.value = veh.id
  vehicleForm.value = { ...veh }
  showVehicleModal.value = true
}

function saveCategory() {
  if (isEditMode.value && editingId.value) {
    const idx = categories.value.findIndex(c => c.id === editingId.value)
    if (idx !== -1) categories.value[idx] = { ...categories.value[idx], ...categoryForm.value }
  } else {
    categories.value.push({
      id: `cat_${Date.now()}`,
      ...categoryForm.value,
    })
  }
  showCategoryModal.value = false
}

function saveVehicle() {
  if (isEditMode.value && editingId.value) {
    const idx = vehicles.value.findIndex(v => v.id === editingId.value)
    if (idx !== -1) vehicles.value[idx] = { ...vehicles.value[idx], ...vehicleForm.value }
  } else {
    vehicles.value.unshift({
      id: `veh_${Date.now()}`,
      ...vehicleForm.value,
    })
  }
  showVehicleModal.value = false
}

function toggleCategoryStatus(cat: any) {
  cat.status = !cat.status
}

function toggleVehicleStatus(veh: any) {
  const next: Record<string, string> = { active: 'maintenance', maintenance: 'inactive', inactive: 'active' }
  veh.status = next[veh.status] || 'active'
}

function deleteCategory(id: string) {
  categories.value = categories.value.filter(c => c.id !== id)
}

function deleteVehicle(id: string) {
  vehicles.value = vehicles.value.filter(v => v.id !== id)
}

function formatCurrency(val: number): string {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF', maximumFractionDigits: 0 }).format(val)
}
</script>
