// stores/users.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export interface User {
  id: string
  name: string
  email: string
  phone: string
  role: 'customer' | 'admin'
  status: 'active' | 'inactive' | 'banned'
  avatar?: string
  created_at: string
  trips_count?: number
  total_spent?: number
  country?: string
  kyc_status?: 'unsubmitted' | 'pending' | 'approved' | 'rejected'
  kyc_document?: string
}

export interface UserFilters {
  search: string
  role: string
  status: string
}

const MOCK_USERS: User[] = Array.from({ length: 40 }, (_, i) => {
  const names = ['Amadou Ba', 'Fatoumata Diallo', 'Moussa Sow', 'Aissatou Camara', 'Omar Traoré', 'Mariama Kouyaté', 'Ibrahima Ndiaye', 'Kadiatou Bah', 'Cheikh Fall', 'Rokhaya Mbaye']
  const statuses: User['status'][] = ['active', 'active', 'active', 'inactive', 'banned']
  const countries = ['SN', 'CI', 'ML']
  const kycStatuses: User['kyc_status'][] = ['approved', 'pending', 'unsubmitted', 'rejected']
  return {
    id: `user_${i + 1}`,
    name: names[i % names.length] + (i >= names.length ? ` ${Math.floor(i / names.length) + 1}` : ''),
    email: `user${i + 1}@example.com`,
    phone: `+221 7${String(Math.floor(Math.random() * 100000000)).padStart(8, '0')}`,
    role: i < 3 ? 'admin' : 'customer',
    status: statuses[i % statuses.length],
    created_at: new Date(Date.now() - i * 86400000 * 3).toISOString(),
    trips_count: Math.floor(Math.random() * 50),
    total_spent: Math.floor(Math.random() * 200000),
    country: countries[i % countries.length],
    kyc_status: kycStatuses[i % kycStatuses.length],
    kyc_document: i % 4 !== 2 ? `/uploads/kyc/cni_user_${i + 1}.jpg` : '',
  }
})

export const useUsersStore = defineStore('users', () => {
  const list = ref<User[]>([])
  const total = ref(0)
  const page = ref(1)
  const perPage = ref(15)
  const selectedUser = ref<User | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)
  const filters = ref<UserFilters>({ search: '', role: '', status: '' })

  const totalPages = computed(() => Math.ceil(total.value / perPage.value))

  async function fetchUsers() {
    loading.value = true
    const { get } = useApi()

    const params = new URLSearchParams({
      page: String(page.value),
      limit: String(perPage.value),
      ...(filters.value.search ? { search: filters.value.search } : {}),
      ...(filters.value.role ? { role: filters.value.role } : {}),
      ...(filters.value.status ? { status: filters.value.status } : {}),
    })

    const { data, error: err } = await get<{ data: User[]; total: number }>(`/admin/users?${params}`)

    if (data) {
      list.value = data.data
      total.value = data.total
    } else {
      // Mock fallback
      let filtered = [...MOCK_USERS]
      if (filters.value.search) {
        const q = filters.value.search.toLowerCase()
        filtered = filtered.filter(u =>
          u.name.toLowerCase().includes(q) ||
          u.email.toLowerCase().includes(q) ||
          u.phone.includes(q)
        )
      }
      if (filters.value.role) filtered = filtered.filter(u => u.role === filters.value.role)
      if (filters.value.status) filtered = filtered.filter(u => u.status === filters.value.status)

      total.value = filtered.length
      const start = (page.value - 1) * perPage.value
      list.value = filtered.slice(start, start + perPage.value)
    }

    error.value = err
    loading.value = false
  }

  async function updateUser(id: string, updates: Partial<User>): Promise<boolean> {
    const { put } = useApi()
    const { error: err } = await put(`/admin/users/${id}`, updates)
    if (!err) {
      const idx = list.value.findIndex(u => u.id === id)
      if (idx !== -1) list.value[idx] = { ...list.value[idx], ...updates }
      return true
    }
    // Mock update
    const idx = list.value.findIndex(u => u.id === id)
    if (idx !== -1) list.value[idx] = { ...list.value[idx], ...updates }
    return true
  }

  async function deleteUser(id: string): Promise<boolean> {
    const { del } = useApi()
    await del(`/admin/users/${id}`)
    list.value = list.value.filter(u => u.id !== id)
    total.value = Math.max(0, total.value - 1)
    return true
  }

  async function toggleStatus(id: string): Promise<void> {
    const user = list.value.find(u => u.id === id)
    if (!user) return
    const newStatus = user.status === 'active' ? 'inactive' : 'active'
    await updateUser(id, { status: newStatus })
  }

  function setPage(p: number) {
    page.value = p
    fetchUsers()
  }

  function setFilters(f: Partial<UserFilters>) {
    filters.value = { ...filters.value, ...f }
    page.value = 1
    fetchUsers()
  }

  return {
    list, total, page, perPage, totalPages,
    selectedUser, loading, error, filters,
    fetchUsers, updateUser, deleteUser, toggleStatus, setPage, setFilters,
  }
})
