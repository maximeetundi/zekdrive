<template>
  <div>
    <!-- Page Header -->
    <div class="page-header animate-fade-in">
      <div>
        <h1 class="page-title">{{ t('fleet_management') }}</h1>
        <p class="page-desc">{{ t('fleet_management_desc') }}</p>
      </div>
      <div class="page-actions">
        <button class="btn btn-primary" @click="openAddFleetModal">
          + {{ t('add_fleet') }}
        </button>
      </div>
    </div>

    <!-- Stats Row -->
    <div class="stats-grid animate-fade-in" style="grid-template-columns: repeat(4, 1fr); margin-bottom: 2rem;">
      <AppStatsCard
        :title="t('total_fleets')"
        :value="fleets.length.toString()"
        icon="🚗"
        color="blue"
      />
      <AppStatsCard
        :title="t('total_vehicles')"
        :value="totalVehicles.toString()"
        icon="🚙"
        color="green"
      />
      <AppStatsCard
        :title="t('assigned_drivers')"
        :value="assignedDrivers.toString()"
        icon="👤"
        color="purple"
      />
      <AppStatsCard
        :title="t('fleet_owners')"
        :value="fleetOwners.length.toString()"
        icon="🏢"
        color="orange"
      />
    </div>

    <!-- Tabs -->
    <div class="tabs animate-fade-in" style="margin-bottom: 1.5rem;">
      <button class="tab-item" :class="{ active: activeTab === 'fleets' }" @click="activeTab = 'fleets'">
        {{ t('fleets') }}
      </button>
      <button class="tab-item" :class="{ active: activeTab === 'vehicles' }" @click="activeTab = 'vehicles'">
        {{ t('vehicles') }}
      </button>
      <button class="tab-item" :class="{ active: activeTab === 'assignments' }" @click="activeTab = 'assignments'">
        {{ t('assignments') }}
      </button>
      <button class="tab-item" :class="{ active: activeTab === 'pro_users' }" @click="activeTab = 'pro_users'">
        {{ t('pro_users') }}
      </button>
    </div>

    <!-- 1. Fleets Tab -->
    <div v-if="activeTab === 'fleets'" class="animate-slide-up">
      <div class="card">
        <div class="card-body" style="padding: 0;">
          <AppDataTable :headers="fleetHeaders" :items="fleets" :loading="loading" :currentPage="1" :perPage="20" :totalItems="fleets.length" :totalPages="1">
            <template #cell-owner="{ item }">
              <div>
                <div class="font-semibold text-primary">{{ item.owner_name }}</div>
                <div class="text-xs text-muted">{{ item.owner_phone }}</div>
              </div>
            </template>
            <template #cell-vehicles_count="{ item }">
              <span class="badge badge-info">{{ item.vehicles?.length ?? 0 }} {{ t('vehicles') }}</span>
            </template>
            <template #cell-status="{ item }">
              <AppStatusBadge :status="item.is_active ? 'active' : 'inactive'" />
            </template>
            <template #cell-actions="{ item }">
              <div class="flex gap-2 justify-end">
                <button class="btn btn-secondary btn-sm" @click="viewFleetDetails(item)">{{ t('details') }}</button>
                <button class="btn btn-secondary btn-sm" @click="openEditFleetModal(item)">{{ t('edit') }}</button>
              </div>
            </template>
          </AppDataTable>
        </div>
      </div>
    </div>

    <!-- 2. Vehicles Tab -->
    <div v-if="activeTab === 'vehicles'" class="animate-slide-up">
      <div class="card">
        <div class="card-body" style="padding: 0;">
          <AppDataTable :headers="vehicleHeaders" :items="allVehicles" :loading="loading" :currentPage="1" :perPage="20" :totalItems="allVehicles.length" :totalPages="1">
            <template #cell-vehicle="{ item }">
              <div>
                <div class="font-semibold text-primary">{{ item.make }} {{ item.model }} ({{ item.year }})</div>
                <div class="text-xs text-muted">{{ item.plate_number }} · {{ item.color }}</div>
              </div>
            </template>
            <template #cell-type="{ item }">
              <span class="badge" :class="vehicleTypeBadge(item.type)">{{ item.type }}</span>
            </template>
            <template #cell-owner="{ item }">
              <span class="text-sm">{{ item.owner_name ?? lang === 'fr' ? 'Propriétaire direct' : 'Direct owner' }}</span>
            </template>
            <template #cell-driver="{ item }">
              <span v-if="item.driver_name" class="badge badge-ongoing">{{ item.driver_name }}</span>
              <span v-else class="badge badge-inactive">{{ lang === 'fr' ? 'Non assigné' : 'Unassigned' }}</span>
            </template>
            <template #cell-kyc="{ item }">
              <AppStatusBadge :status="item.kyc_status" />
            </template>
            <template #cell-actions="{ item }">
              <div class="flex gap-2 justify-end">
                <button class="btn btn-secondary btn-sm" @click="openAssignModal(item)">
                  {{ lang === 'fr' ? 'Assigner chauffeur' : 'Assign Driver' }}
                </button>
              </div>
            </template>
          </AppDataTable>
        </div>
      </div>
    </div>

    <!-- 3. Assignments Tab -->
    <div v-if="activeTab === 'assignments'" class="animate-slide-up">
      <div class="card">
        <div class="card-body" style="padding: 0;">
          <AppDataTable :headers="assignmentHeaders" :items="assignments" :loading="loading" :currentPage="1" :perPage="20" :totalItems="assignments.length" :totalPages="1">
            <template #cell-vehicle="{ item }">
              <div>
                <div class="font-semibold text-primary">{{ item.vehicle_make }} {{ item.vehicle_model }}</div>
                <div class="text-xs text-muted">{{ item.plate_number }}</div>
              </div>
            </template>
            <template #cell-driver="{ item }">
              <div>
                <div class="font-semibold">{{ item.driver_name }}</div>
                <div class="text-xs text-muted">{{ item.driver_phone }}</div>
              </div>
            </template>
            <template #cell-status="{ item }">
              <AppStatusBadge :status="item.is_active ? 'active' : 'inactive'" />
            </template>
            <template #cell-date="{ item }">
              <span class="text-sm text-muted">{{ formatDate(item.assigned_at) }}</span>
            </template>
          </AppDataTable>
        </div>
      </div>
    </div>

    <!-- 4. Pro Users Tab -->
    <div v-if="activeTab === 'pro_users'" class="animate-slide-up">
      <div class="card">
        <div class="card-body" style="padding: 0;">
          <AppDataTable :headers="proUserHeaders" :items="proUsers" :loading="loading" :currentPage="1" :perPage="20" :totalItems="proUsers.length" :totalPages="1">
            <template #cell-name="{ item }">
              <div>
                <div class="font-semibold text-primary">{{ item.name }}</div>
                <div class="text-xs text-muted">{{ item.email }}</div>
              </div>
            </template>
            <template #cell-profiles="{ item }">
              <div class="flex gap-1 flex-wrap">
                <span v-for="profile in item.pro_profiles" :key="profile" class="badge" :class="profileBadge(profile)">
                  {{ profileLabel(profile) }}
                </span>
              </div>
            </template>
            <template #cell-kyc="{ item }">
              <AppStatusBadge :status="item.kyc_status" />
            </template>
          </AppDataTable>
        </div>
      </div>
    </div>

    <!-- Fleet Modal -->
    <AppModal :show="showFleetModal" :title="isEditMode ? t('edit_fleet') : t('add_fleet')" @close="showFleetModal = false">
      <form @submit.prevent="saveFleet">
        <div class="form-group text-left" style="margin-bottom: 1.25rem;">
          <label class="form-label">{{ t('fleet_name') }}</label>
          <input v-model="fleetForm.name" type="text" class="form-input" required :placeholder="lang === 'fr' ? 'Ex: Parc Auto Yaoundé' : 'e.g. Yaoundé Fleet'" />
        </div>
        <div class="form-group text-left" style="margin-bottom: 1.5rem;">
          <label class="form-label">{{ t('description') }}</label>
          <input v-model="fleetForm.description" type="text" class="form-input" :placeholder="lang === 'fr' ? 'Description du parc' : 'Fleet description'" />
        </div>
        <div class="form-group text-left" style="margin-bottom: 1.5rem;">
          <label class="form-label">{{ lang === 'fr' ? 'Propriétaire (User ID)' : 'Owner (User ID)' }}</label>
          <input v-model="fleetForm.owner_id" type="text" class="form-input" required placeholder="uuid" />
        </div>
        <div class="modal-footer-actions" style="display: flex; justify-content: flex-end; gap: 0.75rem; margin-top: 2rem;">
          <button type="button" class="btn btn-secondary" @click="showFleetModal = false">{{ t('cancel') }}</button>
          <button type="submit" class="btn btn-primary">{{ t('save') }}</button>
        </div>
      </form>
    </AppModal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useI18n } from '~/composables/useI18n'
import { useApi } from '~/composables/useApi'

definePageMeta({ middleware: 'auth' })

const { t, lang } = useI18n()
const { get, post } = useApi()
const loading = ref(false)
const activeTab = ref<'fleets' | 'vehicles' | 'assignments' | 'pro_users'>('fleets')

// ── Data ─────────────────────────────────────────────────────────────────────

const fleets = ref([
  {
    id: 'fl_1',
    owner_id: 'u_1',
    owner_name: 'Kamgang Jules',
    owner_phone: '+237 681 234 567',
    name: 'Parc Auto Yaoundé Centre',
    description: '5 véhicules économiques et premium',
    is_active: true,
    vehicles: [{ id: 'v_1' }, { id: 'v_2' }, { id: 'v_3' }]
  },
  {
    id: 'fl_2',
    owner_id: 'u_2',
    owner_name: 'Manga Etienne',
    owner_phone: '+237 686 789 012',
    name: 'Fleet Bastos & Golf',
    description: '3 VTC premium + 1 véhicule de livraison',
    is_active: true,
    vehicles: [{ id: 'v_4' }, { id: 'v_5' }]
  }
])

const allVehicles = ref([
  { id: 'v_1', make: 'Toyota', model: 'Corolla', year: 2018, plate_number: 'LT-123-YA', color: 'Jaune', type: 'economy', owner_name: 'Kamgang Jules', driver_name: 'Nkeng Fabrice', kyc_status: 'approved' },
  { id: 'v_2', make: 'Toyota', model: 'Prado', year: 2020, plate_number: 'CE-456-OU', color: 'Noir', type: 'premium', owner_name: 'Kamgang Jules', driver_name: null, kyc_status: 'pending' },
  { id: 'v_3', make: 'Yamaha', model: 'Crypton', year: 2021, plate_number: 'LT-789-CM', color: 'Rouge', type: 'delivery', owner_name: 'Kamgang Jules', driver_name: 'Tsanga Régine', kyc_status: 'approved' },
  { id: 'v_4', make: 'Mercedes', model: 'Classe E', year: 2021, plate_number: 'DL-001-OU', color: 'Noir', type: 'premium', owner_name: 'Manga Etienne', driver_name: 'Fosso Brigitte', kyc_status: 'approved' },
  { id: 'v_5', make: 'Toyota', model: 'Camry', year: 2019, plate_number: 'DL-003-OU', color: 'Argent', type: 'economy', owner_name: 'Manga Etienne', driver_name: null, kyc_status: 'unsubmitted' },
])

const assignments = ref([
  { id: 'a_1', fleet_id: 'fl_1', vehicle_id: 'v_1', vehicle_make: 'Toyota', vehicle_model: 'Corolla', plate_number: 'LT-123-YA', driver_name: 'Nkeng Fabrice', driver_phone: '+237 674 567 890', is_active: true, assigned_at: new Date(Date.now() - 7 * 86400000).toISOString() },
  { id: 'a_2', fleet_id: 'fl_1', vehicle_id: 'v_3', vehicle_make: 'Yamaha', vehicle_model: 'Crypton', plate_number: 'LT-789-CM', driver_name: 'Tsanga Régine', driver_phone: '+237 677 890 123', is_active: true, assigned_at: new Date(Date.now() - 2 * 86400000).toISOString() },
  { id: 'a_3', fleet_id: 'fl_2', vehicle_id: 'v_4', vehicle_make: 'Mercedes', vehicle_model: 'Classe E', plate_number: 'DL-001-OU', driver_name: 'Fosso Brigitte', driver_phone: '+237 675 678 901', is_active: true, assigned_at: new Date(Date.now() - 86400000).toISOString() },
])

const proUsers = ref([
  { id: 'u_1', name: 'Kamgang Jules', email: 'kamgang@jules.cm', phone: '+237 681 234 567', pro_profiles: ['driver', 'fleet_owner'], kyc_status: 'approved' },
  { id: 'u_2', name: 'Manga Etienne', email: 'manga@etienne.cm', phone: '+237 686 789 012', pro_profiles: ['fleet_owner'], kyc_status: 'approved' },
  { id: 'u_3', name: 'Ngono Patrick', email: 'ngono@patrick.cm', phone: '+237 678 901 234', pro_profiles: ['driver', 'merchant'], kyc_status: 'pending' },
  { id: 'u_4', name: 'Tabe Christiane', email: 'tabe@christiane.cm', phone: '+237 685 678 901', pro_profiles: ['merchant'], kyc_status: 'approved' },
])

const fleetOwners = computed(() => proUsers.value.filter(u => u.pro_profiles.includes('fleet_owner')))
const totalVehicles = computed(() => allVehicles.value.length)
const assignedDrivers = computed(() => allVehicles.value.filter(v => v.driver_name).length)

// ── Load from API ─────────────────────────────────────────────────────────────

onMounted(async () => {
  loading.value = true
  const [fleetsRes, vehiclesRes] = await Promise.all([
    get<any[]>('/api/admin/fleets'),
    get<any[]>('/api/admin/vehicles'),
  ])
  if (fleetsRes.data) fleets.value = fleetsRes.data
  if (vehiclesRes.data) allVehicles.value = vehiclesRes.data
  loading.value = false
})

// ── Table headers ─────────────────────────────────────────────────────────────

const fleetHeaders = computed(() => [
  { key: 'name', label: lang.value === 'fr' ? 'Nom du Parc' : 'Fleet Name' },
  { key: 'owner', label: lang.value === 'fr' ? 'Propriétaire' : 'Owner' },
  { key: 'vehicles_count', label: lang.value === 'fr' ? 'Véhicules' : 'Vehicles' },
  { key: 'status', label: t('status') },
  { key: 'actions', label: t('actions'), style: { width: '200px', textAlign: 'right' } },
])

const vehicleHeaders = computed(() => [
  { key: 'vehicle', label: lang.value === 'fr' ? 'Véhicule' : 'Vehicle' },
  { key: 'type', label: 'Type' },
  { key: 'owner', label: lang.value === 'fr' ? 'Propriétaire' : 'Owner' },
  { key: 'driver', label: lang.value === 'fr' ? 'Chauffeur assigné' : 'Assigned Driver' },
  { key: 'kyc', label: 'KYC' },
  { key: 'actions', label: t('actions'), style: { width: '180px', textAlign: 'right' } },
])

const assignmentHeaders = computed(() => [
  { key: 'vehicle', label: lang.value === 'fr' ? 'Véhicule' : 'Vehicle' },
  { key: 'driver', label: lang.value === 'fr' ? 'Chauffeur' : 'Driver' },
  { key: 'status', label: t('status') },
  { key: 'date', label: lang.value === 'fr' ? 'Depuis' : 'Since' },
])

const proUserHeaders = computed(() => [
  { key: 'name', label: lang.value === 'fr' ? 'Utilisateur Pro' : 'Pro User' },
  { key: 'phone', label: lang.value === 'fr' ? 'Téléphone' : 'Phone' },
  { key: 'profiles', label: lang.value === 'fr' ? 'Profils actifs' : 'Active Profiles' },
  { key: 'kyc', label: 'KYC' },
])

// ── Modals ────────────────────────────────────────────────────────────────────

const showFleetModal = ref(false)
const isEditMode = ref(false)
const editingId = ref<string | null>(null)

const fleetForm = ref({
  name: '',
  description: '',
  owner_id: '',
  is_active: true
})

function openAddFleetModal() {
  isEditMode.value = false
  editingId.value = null
  fleetForm.value = { name: '', description: '', owner_id: '', is_active: true }
  showFleetModal.value = true
}

function openEditFleetModal(fleet: any) {
  isEditMode.value = true
  editingId.value = fleet.id
  fleetForm.value = { name: fleet.name, description: fleet.description, owner_id: fleet.owner_id, is_active: fleet.is_active }
  showFleetModal.value = true
}

async function saveFleet() {
  if (isEditMode.value && editingId.value) {
    const idx = fleets.value.findIndex(f => f.id === editingId.value)
    if (idx !== -1) Object.assign(fleets.value[idx], fleetForm.value)
  } else {
    fleets.value.push({ ...fleetForm.value, id: `fl_${Date.now()}`, owner_name: '', owner_phone: '', vehicles: [] })
  }
  showFleetModal.value = false
}

function viewFleetDetails(fleet: any) {
  activeTab.value = 'vehicles'
}

function openAssignModal(vehicle: any) {
  // Could open a modal to select a driver - simplified here
  alert(`Assign driver to ${vehicle.make} ${vehicle.model}`)
}

// ── Helpers ───────────────────────────────────────────────────────────────────

function vehicleTypeBadge(type: string) {
  const map: Record<string, string> = { economy: 'badge-info', premium: 'badge-ongoing', delivery: 'badge-truck' }
  return map[type] ?? 'badge-info'
}

function profileBadge(profile: string) {
  const map: Record<string, string> = { driver: 'badge-ongoing', fleet_owner: 'badge-info', merchant: 'badge-truck' }
  return map[profile] ?? 'badge-info'
}

function profileLabel(profile: string) {
  const labels: Record<string, Record<string, string>> = {
    driver: { fr: 'Chauffeur', en: 'Driver' },
    fleet_owner: { fr: 'Propriétaire de Parc', en: 'Fleet Owner' },
    merchant: { fr: 'Gérant Commerce', en: 'Merchant' },
  }
  return labels[profile]?.[lang.value] ?? profile
}

function formatDate(dateStr: string) {
  return new Date(dateStr).toLocaleDateString(lang.value === 'fr' ? 'fr-FR' : 'en-GB')
}
</script>
