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
          <input v-model="fleetForm.name" type="text" class="form-input" required :placeholder="lang === 'fr' ? 'Ex: Parc Auto Dakar' : 'e.g. Dakar Fleet'" />
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
    owner_name: 'Mamadou Sy',
    owner_phone: '+221 77 123 45 67',
    name: 'Parc Auto Dakar Centre',
    description: '12 véhicules économiques et premium',
    is_active: true,
    vehicles: [{ id: 'v_1' }, { id: 'v_2' }, { id: 'v_3' }]
  },
  {
    id: 'fl_2',
    owner_id: 'u_2',
    owner_name: 'Fatou Diallo',
    owner_phone: '+221 78 456 78 90',
    name: 'Fleet Plateau & Almadies',
    description: '5 VTC premium + 2 véhicules de livraison',
    is_active: true,
    vehicles: [{ id: 'v_4' }, { id: 'v_5' }]
  }
])

const allVehicles = ref([
  { id: 'v_1', make: 'Toyota', model: 'Corolla', year: 2021, plate_number: 'DK-2345-A', color: 'Blanc', type: 'economy', owner_name: 'Mamadou Sy', driver_name: 'Cheikh Fall', kyc_status: 'approved' },
  { id: 'v_2', make: 'Mercedes', model: 'E-Class', year: 2022, plate_number: 'DK-8821-B', color: 'Noir', type: 'premium', owner_name: 'Mamadou Sy', driver_name: null, kyc_status: 'pending' },
  { id: 'v_3', make: 'Renault', model: 'Kangoo', year: 2020, plate_number: 'DK-4412-C', color: 'Gris', type: 'delivery', owner_name: 'Mamadou Sy', driver_name: 'Ibrahima Diop', kyc_status: 'approved' },
  { id: 'v_4', make: 'BMW', model: 'X5', year: 2023, plate_number: 'DK-1100-D', color: 'Noir', type: 'premium', owner_name: 'Fatou Diallo', driver_name: 'Moussa Kane', kyc_status: 'approved' },
  { id: 'v_5', make: 'Peugeot', model: '508', year: 2021, plate_number: 'DK-3310-E', color: 'Bleu', type: 'economy', owner_name: 'Fatou Diallo', driver_name: null, kyc_status: 'unsubmitted' },
])

const assignments = ref([
  { id: 'a_1', fleet_id: 'fl_1', vehicle_id: 'v_1', vehicle_make: 'Toyota', vehicle_model: 'Corolla', plate_number: 'DK-2345-A', driver_name: 'Cheikh Fall', driver_phone: '+221 77 900 00 01', is_active: true, assigned_at: new Date(Date.now() - 7 * 86400000).toISOString() },
  { id: 'a_2', fleet_id: 'fl_1', vehicle_id: 'v_3', vehicle_make: 'Renault', vehicle_model: 'Kangoo', plate_number: 'DK-4412-C', driver_name: 'Ibrahima Diop', driver_phone: '+221 77 900 00 02', is_active: true, assigned_at: new Date(Date.now() - 2 * 86400000).toISOString() },
  { id: 'a_3', fleet_id: 'fl_2', vehicle_id: 'v_4', vehicle_make: 'BMW', vehicle_model: 'X5', plate_number: 'DK-1100-D', driver_name: 'Moussa Kane', driver_phone: '+221 77 900 00 03', is_active: true, assigned_at: new Date(Date.now() - 86400000).toISOString() },
])

const proUsers = ref([
  { id: 'u_1', name: 'Mamadou Sy', email: 'mamadou@example.com', phone: '+221 77 123 45 67', pro_profiles: ['driver', 'fleet_owner'], kyc_status: 'approved' },
  { id: 'u_2', name: 'Fatou Diallo', email: 'fatou@example.com', phone: '+221 78 456 78 90', pro_profiles: ['fleet_owner'], kyc_status: 'approved' },
  { id: 'u_3', name: 'Omar Ndiaye', email: 'omar@example.com', phone: '+221 70 111 22 33', pro_profiles: ['driver', 'merchant'], kyc_status: 'pending' },
  { id: 'u_4', name: 'Aissatou Ba', email: 'aissatou@example.com', phone: '+221 76 444 55 66', pro_profiles: ['merchant'], kyc_status: 'approved' },
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
