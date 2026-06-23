// stores/drivers.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export interface Driver {
  id: string
  name: string
  email: string
  phone: string
  vehicle_type: 'car' | 'moto' | 'bicycle' | 'truck'
  vehicle_plate: string
  vehicle_model: string
  availability: 'available' | 'busy' | 'offline'
  approval_status: 'pending' | 'approved' | 'rejected'
  rating: number
  trips_count: number
  earnings_total: number
  lat?: number
  lng?: number
  created_at: string
  last_seen?: string
}

const MOCK_DRIVERS: Driver[] = Array.from({ length: 30 }, (_, i) => {
  const names = ['Seydou Keita', 'Lamine Koné', 'Boubacar Diarra', 'Abdoulaye Cissé', 'Mamadou Barry', 'Ibrahima Sow', 'Alpha Diallo', 'Modou Fall', 'Ousmane Ndiaye', 'Samba Diouf']
  const vehicleTypes: Driver['vehicle_type'][] = ['car', 'moto', 'car', 'bicycle', 'car', 'moto', 'truck', 'car', 'moto', 'car']
  const availabilities: Driver['availability'][] = ['available', 'busy', 'offline']
  const approvals: Driver['approval_status'][] = ['approved', 'approved', 'pending', 'approved', 'rejected']

  return {
    id: `driver_${i + 1}`,
    name: names[i % names.length],
    email: `driver${i + 1}@zekdrive.com`,
    phone: `+221 7${String(Math.floor(Math.random() * 100000000)).padStart(8, '0')}`,
    vehicle_type: vehicleTypes[i % vehicleTypes.length],
    vehicle_plate: `DK ${String(1000 + i)} AA`,
    vehicle_model: ['Toyota Corolla', 'Honda Civic', 'Bajaj Boxer', 'Hyundai i10'][i % 4],
    availability: availabilities[i % availabilities.length],
    approval_status: approvals[i % approvals.length],
    rating: Math.round((3.5 + Math.random() * 1.5) * 10) / 10,
    trips_count: Math.floor(Math.random() * 500 + 20),
    earnings_total: Math.floor(Math.random() * 2000000 + 100000),
    lat: 14.6928 + (Math.random() - 0.5) * 0.12,
    lng: -17.4467 + (Math.random() - 0.5) * 0.12,
    created_at: new Date(Date.now() - i * 86400000 * 7).toISOString(),
    last_seen: new Date(Date.now() - Math.random() * 3600000).toISOString(),
  }
})

export const useDriversStore = defineStore('drivers', () => {
  const list = ref<Driver[]>([])
  const total = ref(0)
  const page = ref(1)
  const perPage = ref(15)
  const selectedDriver = ref<Driver | null>(null)
  const nearbyDrivers = ref<Driver[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)
  const filters = ref({ search: '', availability: '', approval_status: '' })

  const totalPages = computed(() => Math.ceil(total.value / perPage.value))
  const pendingDrivers = computed(() => list.value.filter(d => d.approval_status === 'pending'))

  async function fetchDrivers() {
    loading.value = true
    const { get } = useApi()

    const params = new URLSearchParams({
      page: String(page.value),
      limit: String(perPage.value),
      ...(filters.value.search ? { search: filters.value.search } : {}),
      ...(filters.value.availability ? { availability: filters.value.availability } : {}),
      ...(filters.value.approval_status ? { approval_status: filters.value.approval_status } : {}),
    })

    const { data } = await get<{ data: Driver[]; total: number }>(`/admin/drivers?${params}`)

    if (data) {
      list.value = data.data
      total.value = data.total
    } else {
      let filtered = [...MOCK_DRIVERS]
      if (filters.value.search) {
        const q = filters.value.search.toLowerCase()
        filtered = filtered.filter(d =>
          d.name.toLowerCase().includes(q) ||
          d.email.toLowerCase().includes(q) ||
          d.vehicle_plate.toLowerCase().includes(q)
        )
      }
      if (filters.value.availability) filtered = filtered.filter(d => d.availability === filters.value.availability)
      if (filters.value.approval_status) filtered = filtered.filter(d => d.approval_status === filters.value.approval_status)

      total.value = filtered.length
      const start = (page.value - 1) * perPage.value
      list.value = filtered.slice(start, start + perPage.value)
    }

    loading.value = false
  }

  async function fetchLocations() {
    const { get } = useApi()
    const { data } = await get<Driver[]>('/admin/drivers/locations')
    if (data) {
      nearbyDrivers.value = data
    } else {
      nearbyDrivers.value = MOCK_DRIVERS.filter(d => d.lat && d.lng)
    }
  }

  async function approveDriver(id: string): Promise<void> {
    const { patch } = useApi()
    await patch(`/admin/drivers/${id}/approve`, {})
    const idx = list.value.findIndex(d => d.id === id)
    if (idx !== -1) list.value[idx].approval_status = 'approved'
  }

  async function rejectDriver(id: string): Promise<void> {
    const { patch } = useApi()
    await patch(`/admin/drivers/${id}/reject`, {})
    const idx = list.value.findIndex(d => d.id === id)
    if (idx !== -1) list.value[idx].approval_status = 'rejected'
  }

  async function updateDriver(id: string, updates: Partial<Driver>): Promise<boolean> {
    const { put } = useApi()
    await put(`/admin/drivers/${id}`, updates)
    const idx = list.value.findIndex(d => d.id === id)
    if (idx !== -1) list.value[idx] = { ...list.value[idx], ...updates }
    return true
  }

  function setPage(p: number) {
    page.value = p
    fetchDrivers()
  }

  function setFilters(f: Partial<typeof filters.value>) {
    filters.value = { ...filters.value, ...f }
    page.value = 1
    fetchDrivers()
  }

  return {
    list, total, page, perPage, totalPages,
    selectedDriver, nearbyDrivers, loading, error, filters,
    pendingDrivers,
    fetchDrivers, fetchLocations, approveDriver, rejectDriver, updateDriver, setPage, setFilters,
  }
})
