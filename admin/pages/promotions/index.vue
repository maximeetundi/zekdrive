<template>
  <div>
    <!-- Page Header -->
    <div class="page-header animate-fade-in">
      <div>
        <h1 class="page-title">{{ lang === 'fr' ? 'Codes promotionnels' : 'Coupons & Campaigns' }}</h1>
        <p class="page-desc">{{ lang === 'fr' ? 'Gérer les codes de réduction, les limites d\'utilisation et les campagnes de promotion' : 'Manage promotional discount codes, usage limits, and campaign dates' }}</p>
      </div>
      <div class="page-actions">
        <button class="btn btn-primary flex items-center gap-2" @click="openAddModal">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width: 16px; height: 16px;">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
          </svg>
          <span>{{ lang === 'fr' ? 'Créer un coupon' : 'Create Coupon' }}</span>
        </button>
      </div>
    </div>

    <!-- Coupons Table Card -->
    <div class="card animate-slide-up">
      <div class="card-body" style="padding: 0;">
        <AppDataTable
          :headers="headers"
          :items="coupons"
          :loading="loading"
          :currentPage="1"
          :perPage="20"
          :totalItems="coupons.length"
          :totalPages="1"
        >
          <!-- Code cell (monospaced) -->
          <template #cell-code="{ item }">
            <span style="font-family: monospace; font-size: 0.9375rem; font-weight: 700; color: var(--accent-primary); letter-spacing: 0.05em; background: rgba(20, 177, 158, 0.08); padding: 0.25rem 0.5rem; border-radius: var(--radius-sm); border: 1px dashed rgba(20,177,158,0.2);">
              {{ item.code }}
            </span>
          </template>

          <template #cell-type="{ item }">
            <span class="text-xs font-semibold text-secondary" style="text-transform: capitalize;">
              {{ item.type === 'percent' ? (lang === 'fr' ? 'Pourcentage (%)' : 'Percentage (%)') : (lang === 'fr' ? 'Montant Fixe' : 'Fixed Amount') }}
            </span>
          </template>

          <template #cell-value="{ item }">
            <span class="font-bold text-primary">
              {{ item.type === 'percent' ? item.value + '%' : formatCurrency(item.value) }}
            </span>
          </template>

          <!-- Usage limit/count cell -->
          <template #cell-usage="{ item }">
            <span class="text-xs text-primary">
              <strong>{{ item.usage_count }}</strong> / <span class="text-muted">{{ item.usage_limit }}</span>
            </span>
          </template>

          <template #cell-expiry_date="{ item }">
            <span class="text-xs" :class="isExpired(item.expiry_date) ? 'text-red' : 'text-primary'">
              {{ formatDate(item.expiry_date) }}
              <span v-if="isExpired(item.expiry_date)" class="text-xs block" style="font-weight: 500;">{{ lang === 'fr' ? '(Expiré)' : '(Expired)' }}</span>
            </span>
          </template>

          <template #cell-status="{ item }">
            <AppStatusBadge :status="item.status && !isExpired(item.expiry_date) ? 'active' : 'inactive'" />
          </template>

          <template #cell-actions="{ item }">
            <div class="flex gap-2 justify-end">
              <button class="btn btn-secondary btn-sm" @click="openEditModal(item)">{{ t('edit') }}</button>
              <button class="btn btn-secondary btn-sm" @click="toggleStatus(item)">
                {{ item.status ? (lang === 'fr' ? 'Désactiver' : 'Deactivate') : (lang === 'fr' ? 'Activer' : 'Activate') }}
              </button>
              <button class="btn btn-danger btn-sm" @click="deleteCoupon(item.id)">{{ t('delete') }}</button>
            </div>
          </template>
        </AppDataTable>
      </div>
    </div>

    <!-- Create/Edit Modal -->
    <AppModal
      :show="showModal"
      :title="isEditMode ? (lang === 'fr' ? 'Modifier le coupon' : 'Edit Coupon Parameters') : (lang === 'fr' ? 'Créer un coupon promo' : 'Create Promo Coupon')"
      @close="showModal = false"
    >
      <form @submit.prevent="saveCoupon">
        <div class="form-group text-left" style="margin-bottom: 1rem;">
          <label class="form-label">{{ lang === 'fr' ? 'Code promotionnel' : 'Promotional Code' }}</label>
          <input v-model="form.code" type="text" class="form-input" style="text-transform: uppercase;" required placeholder="WELCOME250" />
        </div>

        <div class="grid grid-cols-2 gap-4 modal-form-grid" style="grid-template-columns: 1fr 1fr; margin-bottom: 1rem;">
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Méthode de réduction' : 'Discount Method' }}</label>
            <select v-model="form.type" class="form-select">
              <option value="percent">{{ lang === 'fr' ? 'Pourcentage (%)' : 'Percentage (%)' }}</option>
              <option value="flat">{{ lang === 'fr' ? 'Montant fixe (FCFA)' : 'Fixed Amount (FCFA)' }}</option>
            </select>
          </div>
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Valeur de la réduction' : 'Discount Value' }}</label>
            <input v-model.number="form.value" type="number" class="form-input" required min="1" />
          </div>
        </div>

        <div class="grid grid-cols-2 gap-4 modal-form-grid" style="grid-template-columns: 1fr 1fr; margin-bottom: 1rem;">
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Limite d\'utilisations' : 'Usage Limit (Max Rides)' }}</label>
            <input v-model.number="form.usage_limit" type="number" class="form-input" required min="1" />
          </div>
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Date d\'expiration' : 'Expiration Date' }}</label>
            <input v-model="form.expiry_date" type="date" class="form-input" required />
          </div>
        </div>

        <div class="form-group text-left" style="margin-bottom: 1.5rem;">
          <label class="flex items-center gap-2 cursor-pointer">
            <input v-model="form.status" type="checkbox" />
            <span class="text-sm">{{ lang === 'fr' ? 'Activé et utilisable' : 'Enabled & Redeemable' }}</span>
          </label>
        </div>

        <div class="modal-footer-actions" style="display: flex; justify-content: flex-end; gap: 0.75rem; margin-top: 2rem;">
          <button type="button" class="btn btn-secondary" @click="showModal = false">{{ t('cancel') }}</button>
          <button type="submit" class="btn btn-primary">{{ lang === 'fr' ? 'Enregistrer le coupon' : 'Save Coupon' }}</button>
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
const loading = ref(false)

const coupons = ref([
  {
    id: 'coupon_1',
    code: 'WELCOME250',
    type: 'flat',
    value: 2000,
    usage_limit: 1000,
    usage_count: 247,
    expiry_date: '2026-12-31',
    status: true
  },
  {
    id: 'coupon_2',
    code: 'DKR20PERCENT',
    type: 'percent',
    value: 20,
    usage_limit: 500,
    usage_count: 182,
    expiry_date: '2026-08-31',
    status: true
  },
  {
    id: 'coupon_3',
    code: 'TABASKI2026',
    type: 'flat',
    value: 3000,
    usage_limit: 200,
    usage_count: 200,
    expiry_date: '2026-06-20', // Expired
    status: true
  },
  {
    id: 'coupon_4',
    code: 'WAVEPROMO',
    type: 'percent',
    value: 10,
    usage_limit: 2000,
    usage_count: 820,
    expiry_date: '2026-10-15',
    status: false
  }
])

const headers = computed(() => [
  { key: 'code', label: lang.value === 'fr' ? 'Code Promo' : 'Promo Code' },
  { key: 'type', label: 'Type' },
  { key: 'value', label: lang.value === 'fr' ? 'Valeur Réduction' : 'Discount Value' },
  { key: 'usage', label: lang.value === 'fr' ? 'Utilisations' : 'Redemptions' },
  { key: 'expiry_date', label: lang.value === 'fr' ? 'Expiration' : 'Expiration' },
  { key: 'status', label: t('status') },
  { key: 'actions', label: t('actions'), style: { width: '220px', textAlign: 'right' } }
])

// Modal Control
const showModal = ref(false)
const isEditMode = ref(false)
const editingId = ref<string | null>(null)
const form = ref({
  code: '',
  type: 'percent',
  value: 10,
  usage_limit: 100,
  expiry_date: '',
  status: true
})

function openAddModal() {
  isEditMode.value = false
  editingId.value = null
  // Set default expiry date as 30 days from now
  const expiry = new Date()
  expiry.setDate(expiry.getDate() + 30)
  form.value = {
    code: '',
    type: 'percent',
    value: 15,
    usage_limit: 500,
    expiry_date: expiry.toISOString().split('T')[0],
    status: true
  }
  showModal.value = true
}

function openEditModal(coupon: any) {
  isEditMode.value = true
  editingId.value = coupon.id
  form.value = {
    code: coupon.code,
    type: coupon.type,
    value: coupon.value,
    usage_limit: coupon.usage_limit,
    expiry_date: coupon.expiry_date,
    status: coupon.status
  }
  showModal.value = true
}

function saveCoupon() {
  const payload = {
    code: form.value.code.toUpperCase(),
    type: form.value.type,
    value: form.value.value,
    usage_limit: form.value.usage_limit,
    expiry_date: form.value.expiry_date,
    status: form.value.status
  }

  if (isEditMode.value && editingId.value) {
    const idx = coupons.value.findIndex(c => c.id === editingId.value)
    if (idx !== -1) {
      coupons.value[idx] = {
        ...coupons.value[idx],
        ...payload
      }
    }
  } else {
    coupons.value.unshift({
      id: 'coupon_' + Date.now(),
      usage_count: 0,
      ...payload
    })
  }

  showModal.value = false
}

function toggleStatus(coupon: any) {
  coupon.status = !coupon.status
}

// Operational methods
function deleteCoupon(id: string) {
  coupons.value = coupons.value.filter(c => c.id !== id)
}

function isExpired(dateStr: string): boolean {
  return new Date(dateStr) < new Date()
}

function formatDate(dateStr: string): string {
  try {
    const d = new Date(dateStr)
    return d.toLocaleDateString(lang.value === 'fr' ? 'fr-FR' : 'en-US', { year: 'numeric', month: 'short', day: 'numeric' })
  } catch {
    return dateStr
  }
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
