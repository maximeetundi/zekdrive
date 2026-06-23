<template>
  <div>
    <!-- Page Header -->
    <div class="page-header animate-fade-in">
      <div>
        <h1 class="page-title">Surge & Pricing Rules</h1>
        <p class="page-desc">Define smart surcharges, holiday fees, and peak-hour multipliers</p>
      </div>
      <div class="page-actions">
        <button class="btn btn-primary flex items-center gap-2" @click="openAddModal">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width: 16px; height: 16px;">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
          </svg>
          <span>Add Pricing Rule</span>
        </button>
      </div>
    </div>

    <!-- Pricing Rules Table -->
    <div class="card animate-slide-up">
      <div class="card-body" style="padding: 0;">
        <AppDataTable
          :headers="headers"
          :items="rules"
          :loading="loading"
          :currentPage="1"
          :perPage="20"
          :totalItems="rules.length"
          :totalPages="1"
        >
          <template #cell-name="{ item }">
            <div>
              <div class="font-bold text-primary">{{ item.name }}</div>
              <div class="text-xs text-muted">{{ item.description }}</div>
            </div>
          </template>

          <template #cell-type="{ item }">
            <span class="badge" :class="item.type === 'multiplier' ? 'badge-ongoing' : 'badge-completed'" style="text-transform: uppercase;">
              {{ item.type }}
            </span>
          </template>

          <template #cell-value="{ item }">
            <span class="font-bold" :class="item.type === 'multiplier' ? 'text-gold' : 'text-green'">
              {{ item.type === 'multiplier' ? item.value.toFixed(2) + 'x' : '+' + formatCurrency(item.value) }}
            </span>
          </template>

          <template #cell-schedule="{ item }">
            <div class="text-xs">
              <div>{{ item.schedule_days }}</div>
              <div class="text-muted" style="margin-top: 1px;">{{ item.schedule_hours }}</div>
            </div>
          </template>

          <template #cell-status="{ item }">
            <AppStatusBadge :status="item.status ? 'active' : 'inactive'" />
          </template>

          <template #cell-actions="{ item }">
            <div class="flex gap-2 justify-end">
              <button class="btn btn-secondary btn-sm" @click="openEditModal(item)">Edit</button>
              <button class="btn btn-secondary btn-sm" @click="toggleRuleStatus(item)">
                {{ item.status ? 'Disable' : 'Enable' }}
              </button>
              <button class="btn btn-danger btn-sm" @click="deleteRule(item.id)">Delete</button>
            </div>
          </template>
        </AppDataTable>
      </div>
    </div>

    <!-- Rule Add/Edit Modal -->
    <AppModal
      :show="showModal"
      :title="isEditMode ? 'Edit Pricing Rule' : 'Create Pricing Rule'"
      @close="showModal = false"
    >
      <form @submit.prevent="saveRule">
        <div class="form-group" style="margin-bottom: 1rem;">
          <label class="form-label">Rule Title</label>
          <input v-model="form.name" type="text" class="form-control" required placeholder="Late Night Surcharge" />
        </div>

        <div class="form-group" style="margin-bottom: 1rem;">
          <label class="form-label">Description</label>
          <input v-model="form.description" type="text" class="form-control" required placeholder="Applied on rides taken during late night shifts" />
        </div>

        <div class="grid grid-cols-2 gap-4" style="grid-template-columns: 1fr 1fr; margin-bottom: 1rem;">
          <div class="form-group">
            <label class="form-label">Surcharge Metric</label>
            <select v-model="form.type" class="form-select">
              <option value="multiplier">Surge Multiplier (x)</option>
              <option value="flat">Flat Surcharge (FCFA)</option>
            </select>
          </div>
          <div class="form-group">
            <label class="form-label">Metric Value</label>
            <input v-model.number="form.value" type="number" step="0.05" class="form-control" required min="0" />
          </div>
        </div>

        <div class="grid grid-cols-2 gap-4" style="grid-template-columns: 1fr 1fr; margin-bottom: 1rem;">
          <div class="form-group">
            <label class="form-label">Schedule Days</label>
            <input v-model="form.schedule_days" type="text" class="form-control" required placeholder="Everyday / Mon-Fri" />
          </div>
          <div class="form-group">
            <label class="form-label">Schedule Hours</label>
            <input v-model="form.schedule_hours" type="text" class="form-control" required placeholder="22:00 - 05:00 / 17:00-19:00" />
          </div>
        </div>

        <div class="form-group flex items-center" style="margin-bottom: 1.5rem;">
          <label class="flex items-center gap-2 cursor-pointer">
            <input v-model="form.status" type="checkbox" />
            <span class="text-sm">Enabled & Live</span>
          </label>
        </div>

        <div style="display: flex; justify-content: flex-end; gap: 0.75rem; margin-top: 2rem;">
          <button type="button" class="btn btn-secondary" @click="showModal = false">Cancel</button>
          <button type="submit" class="btn btn-primary">Save Rule</button>
        </div>
      </form>
    </AppModal>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

definePageMeta({
  middleware: 'auth',
})

const loading = ref(false)

const rules = ref([
  {
    id: 'rule_night',
    name: 'Late Night Surge',
    description: 'Increases price during night shifts to incentivize drivers',
    type: 'multiplier',
    value: 1.25,
    schedule_days: 'Everyday',
    schedule_hours: '22:00 - 05:00',
    status: true
  },
  {
    id: 'rule_rush_h',
    name: 'Dakar Rush Hour',
    description: 'Peak traffic hours weekday adjustments',
    type: 'multiplier',
    value: 1.3,
    schedule_days: 'Mon - Fri',
    schedule_hours: '07:30-09:30, 16:30-19:30',
    status: true
  },
  {
    id: 'rule_airport',
    name: 'Airport Base Flat Fee',
    description: 'Fixed toll & access tariff for AIBD pickups',
    type: 'flat',
    value: 2000,
    schedule_days: 'Everyday',
    schedule_hours: '24 Hours',
    status: true
  },
  {
    id: 'rule_rain',
    name: 'Rain & Wet Conditions',
    description: 'Weather adjustor triggered in heavy rain storm conditions',
    type: 'multiplier',
    value: 1.15,
    schedule_days: 'On Rain Event',
    schedule_hours: 'Flexible',
    status: false
  }
])

const headers = [
  { key: 'name', label: 'Rule Detail' },
  { key: 'type', label: 'Type' },
  { key: 'value', label: 'Surge Value' },
  { key: 'schedule', label: 'Target Schedule' },
  { key: 'status', label: 'Status' },
  { key: 'actions', label: 'Actions', style: { width: '220px', textAlign: 'right' } }
]

// Modal states
const showModal = ref(false)
const isEditMode = ref(false)
const editingId = ref<string | null>(null)
const form = ref({
  name: '',
  description: '',
  type: 'multiplier',
  value: 1.0,
  schedule_days: '',
  schedule_hours: '',
  status: true
})

function openAddModal() {
  isEditMode.value = false
  editingId.value = null
  form.value = {
    name: '',
    description: '',
    type: 'multiplier',
    value: 1.1,
    schedule_days: 'Everyday',
    schedule_hours: '00:00 - 24:00',
    status: true
  }
  showModal.value = true
}

function openEditModal(rule: any) {
  isEditMode.value = true
  editingId.value = rule.id
  form.value = { ...rule }
  showModal.value = true
}

function saveRule() {
  const payload = {
    name: form.value.name,
    description: form.value.description,
    type: form.value.type,
    value: form.value.value,
    schedule_days: form.value.schedule_days,
    schedule_hours: form.value.schedule_hours,
    status: form.value.status
  }

  if (isEditMode.value && editingId.value) {
    const idx = rules.value.findIndex(r => r.id === editingId.value)
    if (idx !== -1) {
      rules.value[idx] = { id: editingId.value, ...payload }
    }
  } else {
    rules.value.push({
      id: 'rule_' + Date.now(),
      ...payload
    })
  }

  showModal.value = false
}

function toggleRuleStatus(rule: any) {
  rule.status = !rule.status
}

function deleteRule(id: string) {
  rules.value = rules.value.filter(r => r.id !== id)
}

function formatCurrency(val: number): string {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF', maximumFractionDigits: 0 }).format(val)
}
</script>
