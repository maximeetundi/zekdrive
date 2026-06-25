<template>
  <div>
    <!-- Page Header -->
    <div class="page-header animate-fade-in">
      <div>
        <h1 class="page-title">{{ lang === 'fr' ? 'Flotte & Catégories' : 'Fleet & Vehicle Classes' }}</h1>
        <p class="page-desc">{{ lang === 'fr' ? 'Gérer les tarifs par catégories, les attributions et enregistrer les véhicules' : 'Manage pricing categories, dispatch limits, and register vehicles' }}</p>
      </div>
      <div class="page-actions">
        <button class="btn btn-primary animate-fade-in" @click="openAddModal">
          {{ activeTab === 'categories' ? (lang === 'fr' ? 'Ajouter une catégorie' : 'Add Category') : (lang === 'fr' ? 'Enregistrer un véhicule' : 'Register Vehicle') }}
        </button>
      </div>
    </div>

    <!-- Tabs Wrapper -->
    <div class="tabs animate-fade-in" style="margin-bottom: 1.5rem;">
      <button class="tab-item" :class="{ active: activeTab === 'categories' }" @click="activeTab = 'categories'">
        {{ lang === 'fr' ? 'Catégories de véhicules' : 'Vehicle Categories' }}
      </button>
      <button class="tab-item" :class="{ active: activeTab === 'vehicles' }" @click="activeTab = 'vehicles'">
        {{ lang === 'fr' ? 'Véhicules individuels' : 'Individual Vehicles' }}
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
                <button class="btn btn-secondary btn-sm" @click="openEditCategoryModal(item)">{{ t('edit') }}</button>
                <button class="btn btn-secondary btn-sm" @click="toggleCategoryStatus(item)">
                  {{ item.status ? (lang === 'fr' ? 'Désactiver' : 'Deactivate') : (lang === 'fr' ? 'Activer' : 'Activate') }}
                </button>
                <button class="btn btn-danger btn-sm" @click="deleteCategory(item.id)">{{ t('delete') }}</button>
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
            <input v-model="vehicleSearch" type="text" class="form-input" :placeholder="lang === 'fr' ? 'Rechercher par plaque, nom chauffeur, modèle...' : 'Search by plate number, driver name, model...'" />
          </div>
          <div style="width: 170px;">
            <select v-model="vehicleCategoryFilter" class="form-select">
              <option value="">{{ lang === 'fr' ? 'Toutes les catégories' : 'All Categories' }}</option>
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

            <template #cell-kyc_status="{ item }">
              <AppStatusBadge :status="item.kyc_status || 'unsubmitted'" />
            </template>

            <template #cell-status="{ item }">
              <AppStatusBadge :status="item.status" />
            </template>

            <template #cell-actions="{ item }">
              <div class="flex gap-2">
                <button class="btn btn-secondary btn-sm" @click="openEditVehicleModal(item)">{{ t('edit') }}</button>
                <button class="btn btn-secondary btn-sm" @click="toggleVehicleStatus(item)">{{ lang === 'fr' ? 'Changer statut' : 'Toggle Status' }}</button>
                <button class="btn btn-danger btn-sm" @click="deleteVehicle(item.id)">{{ t('delete') }}</button>
              </div>
            </template>
          </AppDataTable>
        </div>
      </div>
    </div>

    <!-- Edit Category Modal -->
    <AppModal
      :show="showCategoryModal"
      :title="isEditMode ? (lang === 'fr' ? 'Modifier la tarification' : 'Edit Category Pricing') : (lang === 'fr' ? 'Ajouter une catégorie' : 'Add Vehicle Category')"
      @close="showCategoryModal = false"
    >
      <form @submit.prevent="saveCategory">
        <div class="form-group text-left" style="margin-bottom: 1.25rem;">
          <label class="form-label">{{ lang === 'fr' ? 'Nom de la catégorie' : 'Category Name' }}</label>
          <input v-model="categoryForm.name" type="text" class="form-input" required placeholder="Sedan Standard" />
        </div>

        <div class="grid grid-cols-2 gap-4 modal-form-grid" style="grid-template-columns: 1fr 1fr; margin-bottom: 1.25rem;">
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Type d\'attribution' : 'Dispatch Code (Type)' }}</label>
            <select v-model="categoryForm.type" class="form-select">
              <option value="car">{{ lang === 'fr' ? 'Voiture (Course VTC)' : 'Car (Ride-Hailing)' }}</option>
              <option value="moto">{{ lang === 'fr' ? 'Moto (Livraison/Course)' : 'Moto (Delivery/Ride)' }}</option>
              <option value="bicycle">{{ lang === 'fr' ? 'Vélo / Trottinette (Livraison repas)' : 'Bicycle (Food Delivery)' }}</option>
              <option value="truck">{{ lang === 'fr' ? 'Camion (Fret/Cargo)' : 'Truck (Freight/Cargo)' }}</option>
            </select>
          </div>
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Tarif de base (FCFA)' : 'Base Fare (FCFA)' }}</label>
            <input v-model.number="categoryForm.base_fare" type="number" class="form-input" required min="0" />
          </div>
        </div>

        <div class="grid grid-cols-2 gap-4 modal-form-grid" style="grid-template-columns: 1fr 1fr; margin-bottom: 1.25rem;">
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Tarif par KM (FCFA)' : 'Price per KM (FCFA)' }}</label>
            <input v-model.number="categoryForm.per_km" type="number" class="form-input" required min="0" />
          </div>
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Tarif par Minute (FCFA)' : 'Price per Minute (FCFA)' }}</label>
            <input v-model.number="categoryForm.per_min" type="number" class="form-input" required min="0" />
          </div>
        </div>

        <div class="grid grid-cols-2 gap-4 modal-form-grid" style="grid-template-columns: 1fr 1fr; margin-bottom: 1.5rem;">
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Tarif Minimum (FCFA)' : 'Minimum Fare (FCFA)' }}</label>
            <input v-model.number="categoryForm.min_fare" type="number" class="form-input" required min="0" />
          </div>
          <div class="form-group flex items-center text-left" style="margin-top: 1.75rem;">
            <label class="flex items-center gap-2 cursor-pointer">
              <input v-model="categoryForm.status" type="checkbox" />
              <span class="text-sm">{{ lang === 'fr' ? 'Activé' : 'Enabled' }}</span>
            </label>
          </div>
        </div>

        <div class="modal-footer-actions" style="display: flex; justify-content: flex-end; gap: 0.75rem; margin-top: 2rem;">
          <button type="button" class="btn btn-secondary" @click="showCategoryModal = false">{{ t('cancel') }}</button>
          <button type="submit" class="btn btn-primary">{{ lang === 'fr' ? 'Enregistrer la catégorie' : 'Save Category' }}</button>
        </div>
      </form>
    </AppModal>

    <!-- Edit Vehicle Modal -->
    <AppModal
      :show="showVehicleModal"
      :title="isEditMode ? (lang === 'fr' ? 'Modifier le véhicule' : 'Edit Vehicle Info') : (lang === 'fr' ? 'Enregistrer un véhicule' : 'Register Vehicle')"
      @close="showVehicleModal = false"
    >
      <form @submit.prevent="saveVehicle">
        <div class="form-group text-left" style="margin-bottom: 1.25rem;">
          <label class="form-label">{{ lang === 'fr' ? 'Numéro de plaque' : 'License Plate Number' }}</label>
          <input v-model="vehicleForm.plate" type="text" class="form-input" required placeholder="DK 1234 AA" style="text-transform: uppercase;" />
        </div>

        <div class="form-group text-left" style="margin-bottom: 1.25rem;">
          <label class="form-label">{{ lang === 'fr' ? 'Catégorie du véhicule' : 'Vehicle Category Class' }}</label>
          <select v-model="vehicleForm.category_id" class="form-select" required>
            <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
          </select>
        </div>

        <div class="grid grid-cols-2 gap-4 modal-form-grid" style="grid-template-columns: 1fr 1fr; margin-bottom: 1.25rem;">
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Marque / Modèle' : 'Brand / Model' }}</label>
            <input v-model="vehicleForm.model" type="text" class="form-input" required placeholder="Toyota Corolla" />
          </div>
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Chauffeur associé' : 'Associated Driver Name' }}</label>
            <input v-model="vehicleForm.driver" type="text" class="form-input" required placeholder="Lamine Koné" />
          </div>
        </div>

        <div class="grid grid-cols-2 gap-4 modal-form-grid" style="grid-template-columns: 1fr 1fr; margin-bottom: 1.25rem;">
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Statut opérationnel' : 'Operational Status' }}</label>
            <select v-model="vehicleForm.status" class="form-select">
              <option value="active">{{ lang === 'fr' ? 'Actif' : 'Active' }}</option>
              <option value="maintenance">{{ lang === 'fr' ? 'Maintenance' : 'Maintenance' }}</option>
              <option value="inactive">{{ lang === 'fr' ? 'Inactif' : 'Inactive' }}</option>
            </select>
          </div>
          <div class="form-group text-left">
            <label class="form-label">{{ t('kyc_status') }}</label>
            <select v-model="vehicleForm.kyc_status" class="form-select">
              <option value="unsubmitted">{{ t('unsubmitted') }}</option>
              <option value="pending">{{ t('pending') }}</option>
              <option value="approved">{{ t('approved') }}</option>
              <option value="rejected">{{ t('rejected') }}</option>
            </select>
          </div>
        </div>

        <!-- Vehicle Carte Grise & Assurance Validation -->
        <div v-if="isEditMode" class="kyc-verification-panel text-left animate-fade-in" style="margin-top: 1.5rem; padding: 1rem; border-radius: var(--radius-md); background: rgba(255, 255, 255, 0.03); border: 1px solid rgba(255, 255, 255, 0.08); margin-bottom: 1.25rem;">
          <h3 class="text-sm font-bold text-primary" style="margin-bottom: 0.75rem; display: flex; align-items: center; justify-content: space-between;">
            <span>🛡️ {{ lang === 'fr' ? 'Validation Carte Grise & Assurance' : 'Registration & Insurance Validation' }}</span>
            <AppStatusBadge :status="vehicleForm.kyc_status" />
          </h3>
          
          <div v-if="vehicleForm.kyc_document" class="kyc-doc-preview" style="margin-bottom: 1rem;">
            <div class="doc-mock-card" style="width: 100%; height: 120px; border-radius: var(--radius-sm); border: 1px dashed rgba(255, 255, 255, 0.2); display: flex; flex-direction: column; align-items: center; justify-content: center; background: rgba(0, 0, 0, 0.3); position: relative; overflow: hidden; padding: 1rem;">
              <span style="font-size: 2rem;">📄</span>
              <span class="text-xs font-semibold text-primary" style="margin-top: 0.4rem;">{{ vehicleForm.kyc_document }}</span>
              <span class="text-[10px] text-muted">{{ lang === 'fr' ? 'Certificat d\'immatriculation & Assurance valide' : 'Registration & Valid Insurance Document' }}</span>
            </div>
          </div>
          <div v-else style="margin-bottom: 1rem; color: var(--text-muted); font-size: 0.8125rem; font-style: italic;">
            {{ lang === 'fr' ? 'Aucun document de véhicule soumis pour le moment.' : 'No vehicle documents submitted yet.' }}
          </div>

          <div v-if="vehicleForm.kyc_status === 'pending'" class="flex gap-2" style="justify-content: flex-end;">
            <button type="button" class="btn btn-success btn-sm" @click="vehicleForm.kyc_status = 'approved'">
              {{ t('approve_kyc') }}
            </button>
            <button type="button" class="btn btn-danger btn-sm" @click="vehicleForm.kyc_status = 'rejected'">
              {{ t('reject_kyc') }}
            </button>
          </div>
        </div>

        <div class="modal-footer-actions" style="display: flex; justify-content: flex-end; gap: 0.75rem; margin-top: 2rem;">
          <button type="button" class="btn btn-secondary" @click="showVehicleModal = false">{{ t('cancel') }}</button>
          <button type="submit" class="btn btn-primary">{{ lang === 'fr' ? 'Enregistrer le véhicule' : 'Register Vehicle' }}</button>
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
  { id: 'veh_1', plate: 'DK-2005-AB', model: 'Toyota Corolla 2018', category_id: 'cat_sedan', driver: 'Seydou Keita', status: 'active', kyc_status: 'approved', kyc_document: '/uploads/kyc/carte_grise_1.pdf' },
  { id: 'veh_2', plate: 'TH-4903-AA', model: 'Yamaha Boxer 150', category_id: 'cat_moto', driver: 'Lamine Koné', status: 'active', kyc_status: 'approved', kyc_document: '/uploads/kyc/carte_grise_2.pdf' },
  { id: 'veh_3', plate: 'DK-0920-BC', model: 'Hyundai Elantra 2020', category_id: 'cat_sedan', driver: 'Boubacar Diarra', status: 'active', kyc_status: 'pending', kyc_document: '/uploads/kyc/carte_grise_3.pdf' },
  { id: 'veh_4', plate: 'SL-7821-AC', model: 'Peugeot Partner', category_id: 'cat_delivery', driver: 'Abdoulaye Cissé', status: 'maintenance', kyc_status: 'unsubmitted', kyc_document: '' },
  { id: 'veh_5', plate: 'DK-5512-AZ', model: 'Mercedes C-Class 2019', category_id: 'cat_premium', driver: 'Mamadou Barry', status: 'active', kyc_status: 'approved', kyc_document: '/uploads/kyc/carte_grise_5.pdf' },
  { id: 'veh_6', plate: 'DK-1049-M', model: 'Haojue Express 125', category_id: 'cat_moto', driver: 'Ibrahima Sow', status: 'inactive', kyc_status: 'rejected', kyc_document: '/uploads/kyc/carte_grise_6.pdf' },
  { id: 'veh_7', plate: 'TH-0239-B', model: 'Mitsubishi Fuso Cargo', category_id: 'cat_cargo', driver: 'Alpha Diallo', status: 'active', kyc_status: 'approved', kyc_document: '/uploads/kyc/carte_grise_7.pdf' },
])

const categoryHeaders = computed(() => [
  { key: 'name', label: lang.value === 'fr' ? 'Nom Catégorie' : 'Category Name' },
  { key: 'type', label: lang.value === 'fr' ? 'Type Véhicule' : 'Vehicle type' },
  { key: 'base_fare', label: lang.value === 'fr' ? 'Tarif de base' : 'Base Fare' },
  { key: 'per_km', label: lang.value === 'fr' ? 'Par KM' : 'Per KM' },
  { key: 'per_min', label: lang.value === 'fr' ? 'Par Min' : 'Per Min' },
  { key: 'min_fare', label: lang.value === 'fr' ? 'Tarif Min' : 'Min Fare' },
  { key: 'status', label: t('status') },
  { key: 'actions', label: t('actions'), style: { width: '220px', textAlign: 'right' } },
])

const vehicleHeaders = computed(() => [
  { key: 'plate', label: lang.value === 'fr' ? 'License Plaque' : 'License Plate' },
  { key: 'model', label: lang.value === 'fr' ? 'Modèle' : 'Model' },
  { key: 'category', label: lang.value === 'fr' ? 'Catégorie' : 'Category Class' },
  { key: 'driver', label: lang.value === 'fr' ? 'Chauffeur' : 'Assigned Driver' },
  { key: 'kyc_status', label: t('kyc_status') },
  { key: 'status', label: lang.value === 'fr' ? 'Statut Opérationnel' : 'Operational Status' },
  { key: 'actions', label: t('actions'), style: { width: '220px', textAlign: 'right' } },
])

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
  kyc_status: 'unsubmitted',
  kyc_document: '',
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
      kyc_status: 'unsubmitted',
      kyc_document: '',
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
  vehicleForm.value = {
    plate: veh.plate,
    model: veh.model,
    category_id: veh.category_id,
    driver: veh.driver,
    status: veh.status,
    kyc_status: veh.kyc_status || 'unsubmitted',
    kyc_document: veh.kyc_document || '',
  }
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

// Fixed operational variables
function deleteVehicle(id: string) {
  vehicles.value = vehicles.value.filter(v => v.id !== id)
}

function formatCurrency(val: number): string {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF', maximumFractionDigits: 0 }).format(val)
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
}
</style>
