<template>
  <div>
    <!-- Page Header -->
    <div class="page-header animate-fade-in">
      <div>
        <h1 class="page-title">Users Directory</h1>
        <p class="page-desc">Manage customers, admins, account statuses, and metrics</p>
      </div>
      <div class="page-actions">
        <button class="btn btn-primary flex items-center gap-2" @click="openCreateModal">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width: 16px; height: 16px;">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
          </svg>
          <span>Add New User</span>
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
            class="form-control"
            placeholder="Search by name, email, or phone..."
            @input="onFilterChange"
          />
        </div>
        
        <!-- Role Filter -->
        <div style="width: 160px;">
          <select v-model="roleFilter" class="form-select" @change="onFilterChange">
            <option value="">All Roles</option>
            <option value="customer">Customer</option>
            <option value="admin">Admin</option>
          </select>
        </div>

        <!-- Status Filter -->
        <div style="width: 160px;">
          <select v-model="statusFilter" class="form-select" @change="onFilterChange">
            <option value="">All Statuses</option>
            <option value="active">Active</option>
            <option value="inactive">Inactive</option>
            <option value="banned">Banned</option>
          </select>
        </div>

        <button class="btn btn-secondary" style="height: 2.25rem;" @click="clearFilters">Reset</button>
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
          <!-- Custom Role Cell -->
          <template #cell-role="{ item }">
            <AppStatusBadge :status="item.role" />
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
              <button class="btn btn-secondary btn-sm" @click="openEditModal(item)">Edit</button>
              <button
                class="btn btn-sm"
                :class="item.status === 'banned' ? 'btn-success' : 'btn-danger'"
                @click="toggleUserStatus(item)"
              >
                {{ item.status === 'banned' ? 'Unban' : 'Ban' }}
              </button>
              <button class="btn btn-danger btn-sm" @click="confirmDelete(item)">Delete</button>
            </div>
          </template>
        </AppDataTable>
      </div>
    </div>

    <!-- Create/Edit Modal -->
    <AppModal
      :show="showFormModal"
      :title="isEditMode ? 'Edit User Profile' : 'Add New User'"
      @close="closeFormModal"
    >
      <form @submit.prevent="saveUser">
        <div class="form-group" style="margin-bottom: 1rem;">
          <label class="form-label">Full Name</label>
          <input v-model="form.name" type="text" class="form-control" required placeholder="Amadou Ba" />
        </div>
        
        <div class="form-group" style="margin-bottom: 1rem;">
          <label class="form-label">Email Address</label>
          <input v-model="form.email" type="email" class="form-control" required placeholder="amadou@example.com" />
        </div>

        <div class="form-group" style="margin-bottom: 1rem;">
          <label class="form-label">Phone Number</label>
          <input v-model="form.phone" type="text" class="form-control" required placeholder="+221 77 123 4567" />
        </div>

        <div class="grid grid-cols-2 gap-4" style="grid-template-columns: 1fr 1fr; margin-bottom: 1rem;">
          <div class="form-group">
            <label class="form-label">Role</label>
            <select v-model="form.role" class="form-select">
              <option value="customer">Customer</option>
              <option value="admin">Admin</option>
            </select>
          </div>
          <div class="form-group">
            <label class="form-label">Status</label>
            <select v-model="form.status" class="form-select">
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
              <option value="banned">Banned</option>
            </select>
          </div>
        </div>

        <div style="display: flex; justify-content: flex-end; gap: 0.75rem; margin-top: 2rem;">
          <button type="button" class="btn btn-secondary" @click="closeFormModal">Cancel</button>
          <button type="submit" class="btn btn-primary">Save Changes</button>
        </div>
      </form>
    </AppModal>

    <!-- Delete Confirmation Modal -->
    <AppModal
      :show="showDeleteModal"
      title="Confirm Delete"
      @close="showDeleteModal = false"
    >
      <div style="padding: 0.5rem 0 1.5rem;">
        <p>Are you sure you want to permanently delete the user account for <strong>{{ userToDelete?.name }}</strong>?</p>
        <p style="margin-top: 0.5rem; color: var(--accent-warning); font-size: 0.8125rem;">This action cannot be undone and will delete all operational references.</p>
      </div>
      <template #footer>
        <button class="btn btn-secondary" @click="showDeleteModal = false">Cancel</button>
        <button class="btn btn-danger" @click="executeDelete">Delete User</button>
      </template>
    </AppModal>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { storeToRefs } from 'pinia'
import { useUsersStore, type User } from '~/stores/users'

definePageMeta({
  middleware: 'auth',
})

const usersStore = useUsersStore()
const { list, total, page, perPage, totalPages, loading } = storeToRefs(usersStore)

const searchTerm = ref('')
const roleFilter = ref('')
const statusFilter = ref('')

const headers = [
  { key: 'name', label: 'Full Name' },
  { key: 'email', label: 'Email' },
  { key: 'phone', label: 'Phone' },
  { key: 'role', label: 'Role' },
  { key: 'status', label: 'Status' },
  { key: 'trips_count', label: 'Trips' },
  { key: 'total_spent', label: 'Total Spent' },
  { key: 'created_at', label: 'Registered' },
  { key: 'actions', label: 'Actions', style: { width: '220px', textAlign: 'right' } },
]

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
