<template>
  <div>
    <!-- Page Header -->
    <div class="page-header animate-fade-in">
      <div>
        <h1 class="page-title">{{ t('users_directory') }}</h1>
        <p class="page-desc">{{ t('users_desc') }}</p>
      </div>
      <div class="page-actions">
        <button class="btn btn-primary flex items-center gap-2" @click="openCreateModal">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width: 16px; height: 16px;">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
          </svg>
          <span>{{ t('add_new_user') }}</span>
        </button>
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
            :placeholder="t('search_placeholder')"
            @input="onFilterChange"
          />
        </div>
        
        <!-- Role Filter -->
        <div style="width: 160px;">
          <select v-model="roleFilter" class="form-select" @change="onFilterChange">
            <option value="">{{ t('all_roles') }}</option>
            <option value="customer">{{ t('customer') }}</option>
            <option value="admin">{{ t('admin') }}</option>
          </select>
        </div>

        <!-- Status Filter -->
        <div style="width: 160px;">
          <select v-model="statusFilter" class="form-select" @change="onFilterChange">
            <option value="">{{ t('all_statuses') }}</option>
            <option value="active">{{ t('active') }}</option>
            <option value="inactive">{{ t('inactive') }}</option>
            <option value="banned">{{ t('banned') }}</option>
          </select>
        </div>

        <button class="btn btn-secondary" style="height: 2.25rem;" @click="clearFilters">{{ t('reset') }}</button>
      </div>
    </div>

    <!-- Users Table Card -->
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
          <!-- Custom Country Cell -->
          <template #cell-country="{ item }">
            <span class="flex items-center gap-1">
              <span>{{ item.country === 'SN' ? '🇸🇳' : item.country === 'CI' ? '🇨🇮' : item.country === 'ML' ? '🇲🇱' : '🌍' }}</span>
              <span class="text-xs font-semibold" style="margin-left: 2px;">{{ item.country || 'SN' }}</span>
            </span>
          </template>

          <!-- Custom Role Cell -->
          <template #cell-role="{ item }">
            <AppStatusBadge :status="item.role" />
          </template>

          <!-- Custom KYC Cell -->
          <template #cell-kyc_status="{ item }">
            <AppStatusBadge :status="item.kyc_status || 'unsubmitted'" />
          </template>

          <!-- Custom Status Cell -->
          <template #cell-status="{ item }">
            <AppStatusBadge :status="item.status" />
          </template>

          <!-- Custom Spent Cell -->
          <template #cell-total_spent="{ item }">
            <span class="font-semibold text-primary">{{ formatCurrency(item.total_spent || 0) }}</span>
          </template>

          <!-- Custom Created Cell -->
          <template #cell-created_at="{ item }">
            <span>{{ formatDate(item.created_at) }}</span>
          </template>

          <!-- Custom Actions Cell -->
          <template #cell-actions="{ item }">
            <div class="flex gap-2">
              <button class="btn btn-secondary btn-sm" @click="openEditModal(item)">{{ t('edit') }}</button>
              <button
                class="btn btn-sm"
                :class="item.status === 'banned' ? 'btn-success' : 'btn-danger'"
                @click="toggleUserStatus(item)"
              >
                {{ item.status === 'banned' ? t('unban') : t('ban') }}
              </button>
              <button class="btn btn-danger btn-sm" @click="confirmDelete(item)">{{ t('delete') }}</button>
            </div>
          </template>
        </AppDataTable>
      </div>
    </div>

    <!-- Create/Edit Modal -->
    <AppModal
      :show="showFormModal"
      :title="isEditMode ? t('edit_user_profile') : t('add_new_user')"
      @close="closeFormModal"
    >
      <form @submit.prevent="saveUser">
        <div class="form-group text-left" style="margin-bottom: 1.25rem;">
          <label class="form-label">{{ t('fullname') }}</label>
          <input v-model="form.name" type="text" class="form-input" required placeholder="Amadou Ba" />
        </div>
        
        <div class="form-group text-left" style="margin-bottom: 1.25rem;">
          <label class="form-label">{{ t('email') }}</label>
          <input v-model="form.email" type="email" class="form-input" required placeholder="amadou@example.com" />
        </div>

        <div class="form-group text-left" style="margin-bottom: 1.25rem;">
          <label class="form-label">{{ t('phone') }}</label>
          <input v-model="form.phone" type="text" class="form-input" required placeholder="+221 77 123 4567" />
        </div>

        <div class="grid grid-cols-2 gap-4 modal-form-grid" style="grid-template-columns: 1fr 1fr; margin-bottom: 1.25rem;">
          <div class="form-group text-left">
            <label class="form-label">{{ t('role') }}</label>
            <select v-model="form.role" class="form-select">
              <option value="customer">{{ t('customer') }}</option>
              <option value="admin">{{ t('admin') }}</option>
            </select>
          </div>
          <div class="form-group text-left">
            <label class="form-label">{{ t('status') }}</label>
            <select v-model="form.status" class="form-select">
              <option value="active">{{ t('active') }}</option>
              <option value="inactive">{{ t('inactive') }}</option>
              <option value="banned">{{ t('banned') }}</option>
            </select>
          </div>
        </div>

        <div class="grid grid-cols-2 gap-4 modal-form-grid" style="grid-template-columns: 1fr 1fr; margin-bottom: 1.25rem;">
          <div class="form-group text-left">
            <label class="form-label">{{ t('country') }}</label>
            <select v-model="form.country" class="form-select" required>
              <option value="SN">🇸🇳 Sénégal (SN)</option>
              <option value="CI">🇨🇮 Côte d'Ivoire (CI)</option>
              <option value="ML">🇲🇱 Mali (ML)</option>
            </select>
          </div>
          <div class="form-group text-left">
            <label class="form-label">{{ t('kyc_status') }}</label>
            <select v-model="form.kyc_status" class="form-select">
              <option value="unsubmitted">{{ t('unsubmitted') }}</option>
              <option value="pending">{{ t('pending') }}</option>
              <option value="approved">{{ t('approved') }}</option>
              <option value="rejected">{{ t('rejected') }}</option>
            </select>
          </div>
        </div>

        <!-- KYC Identity Verification Section -->
        <div v-if="isEditMode" class="kyc-verification-panel text-left animate-fade-in" style="margin-top: 1.5rem; padding: 1rem; border-radius: var(--radius-md); background: rgba(255, 255, 255, 0.03); border: 1px solid rgba(255, 255, 255, 0.08); margin-bottom: 1.25rem;">
          <h3 class="text-sm font-bold text-primary" style="margin-bottom: 0.75rem; display: flex; align-items: center; justify-content: space-between;">
            <span>🛡️ {{ t('verify_kyc') }}</span>
            <AppStatusBadge :status="form.kyc_status" />
          </h3>
          
          <div v-if="form.kyc_document" class="kyc-doc-preview" style="margin-bottom: 1rem;">
            <div class="doc-mock-card" style="width: 100%; height: 130px; border-radius: var(--radius-sm); border: 1px dashed rgba(255, 255, 255, 0.2); display: flex; flex-direction: column; align-items: center; justify-content: center; background: rgba(0, 0, 0, 0.3); position: relative; overflow: hidden; padding: 1rem;">
              <span style="font-size: 2rem;">🪪</span>
              <span class="text-xs font-semibold text-primary" style="margin-top: 0.5rem;">{{ form.kyc_document }}</span>
              <span class="text-[10px] text-muted">{{ lang === 'fr' ? 'Carte Nationale d\'Identité (CNI) / Passeport' : 'National Identity Card (CNI) / Passport' }}</span>
            </div>
          </div>
          <div v-else style="margin-bottom: 1rem; color: var(--text-muted); font-size: 0.8125rem; font-style: italic;">
            {{ lang === 'fr' ? 'Aucun document KYC soumis pour le moment.' : 'No KYC document submitted yet.' }}
          </div>

          <div v-if="form.kyc_status === 'pending'" class="flex gap-2" style="justify-content: flex-end;">
            <button type="button" class="btn btn-success btn-sm" @click="form.kyc_status = 'approved'">
              {{ t('approve_kyc') }}
            </button>
            <button type="button" class="btn btn-danger btn-sm" @click="form.kyc_status = 'rejected'">
              {{ t('reject_kyc') }}
            </button>
          </div>
        </div>

        <div class="modal-footer-actions" style="display: flex; justify-content: flex-end; gap: 0.75rem; margin-top: 2rem;">
          <button type="button" class="btn btn-secondary" @click="closeFormModal">{{ t('cancel') }}</button>
          <button type="submit" class="btn btn-primary">{{ t('save_changes') }}</button>
        </div>
      </form>
    </AppModal>

    <!-- Delete Confirmation Modal -->
    <AppModal
      :show="showDeleteModal"
      :title="t('confirm_delete')"
      @close="showDeleteModal = false"
    >
      <div style="padding: 0.5rem 0 1.5rem; text-align: left;">
        <p>{{ t('confirm_delete_text', { name: userToDelete?.name || '' }) }}</p>
        <p style="margin-top: 0.5rem; color: var(--accent-warning); font-size: 0.8125rem;">{{ t('confirm_delete_warning') }}</p>
      </div>
      <template #footer>
        <button class="btn btn-secondary" @click="showDeleteModal = false">{{ t('cancel') }}</button>
        <button class="btn btn-danger" @click="executeDelete">{{ t('delete') }}</button>
      </template>
    </AppModal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { storeToRefs } from 'pinia'
import { useUsersStore, type User } from '~/stores/users'
import { useI18n } from '~/composables/useI18n'

definePageMeta({
  middleware: 'auth',
})

const usersStore = useUsersStore()
const { list, total, page, perPage, totalPages, loading } = storeToRefs(usersStore)
const { t } = useI18n()

const searchTerm = ref('')
const roleFilter = ref('')
const statusFilter = ref('')

const headers = computed(() => [
  { key: 'name', label: t('fullname') },
  { key: 'email', label: t('email') },
  { key: 'phone', label: t('phone') },
  { key: 'country', label: t('country') },
  { key: 'role', label: t('role') },
  { key: 'kyc_status', label: t('kyc_status') },
  { key: 'status', label: t('status') },
  { key: 'trips_count', label: t('trips') },
  { key: 'total_spent', label: t('total_spent') },
  { key: 'created_at', label: t('registered') },
  { key: 'actions', label: t('actions'), style: { width: '220px', textAlign: 'right' } },
])

// Form Modal State
const showFormModal = ref(false)
const isEditMode = ref(false)
const editingUserId = ref<string | null>(null)
const form = ref({
  name: '',
  email: '',
  phone: '',
  role: 'customer' as User['role'],
  status: 'active' as User['status'],
  country: 'SN',
  kyc_status: 'unsubmitted' as User['kyc_status'],
  kyc_document: '',
})

// Delete Modal State
const showDeleteModal = ref(false)
const userToDelete = ref<User | null>(null)

// Refresh users list
onMounted(() => {
  usersStore.fetchUsers()
})

function onFilterChange() {
  usersStore.setFilters({
    search: searchTerm.value,
    role: roleFilter.value,
    status: statusFilter.value,
  })
}

function clearFilters() {
  searchTerm.value = ''
  roleFilter.value = ''
  statusFilter.value = ''
  onFilterChange()
}

function setPage(p: number) {
  usersStore.setPage(p)
}

function openCreateModal() {
  isEditMode.value = false
  editingUserId.value = null
  form.value = {
    name: '',
    email: '',
    phone: '',
    role: 'customer',
    status: 'active',
    country: 'SN',
    kyc_status: 'unsubmitted',
    kyc_document: '',
  }
  showFormModal.value = true
}

function openEditModal(user: User) {
  isEditMode.value = true
  editingUserId.value = user.id
  form.value = {
    name: user.name,
    email: user.email,
    phone: user.phone,
    role: user.role,
    status: user.status,
    country: user.country || 'SN',
    kyc_status: user.kyc_status || 'unsubmitted',
    kyc_document: user.kyc_document || '',
  }
  showFormModal.value = true
}

function closeFormModal() {
  showFormModal.value = false
}

async function saveUser() {
  if (isEditMode.value && editingUserId.value) {
    await usersStore.updateUser(editingUserId.value, form.value)
  } else {
    // Add user mock flow helper
    const newUser: Partial<User> = {
      id: `user_new_${Date.now()}`,
      ...form.value,
      created_at: new Date().toISOString(),
      trips_count: 0,
      total_spent: 0,
    }
    usersStore.list.unshift(newUser as User)
    usersStore.total += 1
  }
  showFormModal.value = false
}

async function toggleUserStatus(user: User) {
  const nextStatus = user.status === 'banned' ? 'active' : 'banned'
  await usersStore.updateUser(user.id, { status: nextStatus })
}

function confirmDelete(user: User) {
  userToDelete.value = user
  showDeleteModal.value = true
}

async function executeDelete() {
  if (userToDelete.value) {
    await usersStore.deleteUser(userToDelete.value.id)
  }
  showDeleteModal.value = false
  userToDelete.value = null
}

function formatCurrency(val: number): string {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF', maximumFractionDigits: 0 }).format(val)
}

function formatDate(dateStr: string): string {
  try {
    const d = new Date(dateStr)
    return d.toLocaleDateString('fr-FR', { year: 'numeric', month: 'short', day: 'numeric' })
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
}
</style>
