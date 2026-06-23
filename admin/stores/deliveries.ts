// stores/deliveries.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export interface Delivery {
  id: string
  ref_id: string
  customer_name: string
  customer_id: string
  driver_name: string
  driver_id: string
  pickup_address: string
  dropoff_address: string
  pickup_lat: number
  pickup_lng: number
  dropoff_lat: number
  dropoff_lng: number
  status: 'pending' | 'accepted' | 'ongoing' | 'completed' | 'cancelled'
  fare: number
  distance_km: number
  vehicle_type: 'car' | 'moto' | 'bicycle' | 'truck'
  package_description: string
  payment_method: string
  created_at: string
}

const VEHICLE_TYPES: Delivery['vehicle_type'][] = ['car', 'moto', 'bicycle', 'truck']
const STATUSES: Delivery['status'][] = ['pending', 'accepted', 'ongoing', 'completed', 'cancelled']
const PACKAGES = ['Documents', 'Colis médium', 'Nourriture', 'Électronique', 'Vêtements', 'Pharmacie']
const CUSTOMERS = ['Rokhaya Mbaye', 'Coumba Sarr', 'Pape Diop', 'Ndéye Fall', 'Babacar Ndiaye']
const DRIVERS = ['Alpha D.', 'Modou F.', 'Ousmane N.', 'Samba D.', 'Abdou K.']
const PICKUPS = ['Marché HLM', 'Liberté 6', 'Médina, Dakar', 'Fann Résidence', 'Les Almadies']
const DROPOFFS = ['Thiès Centre', 'Rufisque', 'Bargny', 'Sébikhotane', 'Keur Massar']

const MOCK_DELIVERIES: Delivery[] = Array.from({ length: 50 }, (_, i) => ({
  id: `del_${i + 1}`,
  ref_id: `ZD-DEL-${String(2000 + i).padStart(5, '0')}`,
  customer_name: CUSTOMERS[i % CUSTOMERS.length],
  customer_id: `user_${(i % 10) + 1}`,
  driver_name: DRIVERS[i % DRIVERS.length],
  driver_id: `driver_${(i % 5) + 6}`,
  pickup_address: PICKUPS[i % PICKUPS.length],
  dropoff_address: DROPOFFS[i % DROPOFFS.length],
  pickup_lat: 14.6928 + (Math.random() - 0.5) * 0.1,
  pickup_lng: -17.4467 + (Math.random() - 0.5) * 0.1,
  dropoff_lat: 14.8428 + (Math.random() - 0.5) * 0.1,
  dropoff_lng: -17.5567 + (Math.random() - 0.5) * 0.1,
  status: STATUSES[i % STATUSES.length],
  fare: Math.floor(Math.random() * 5000 + 800),
  distance_km: Math.round((Math.random() * 25 + 2) * 10) / 10,
  vehicle_type: VEHICLE_TYPES[i % VEHICLE_TYPES.length],
  package_description: PACKAGES[i % PACKAGES.length],
  payment_method: ['cash', 'orange_money', 'wave'][i % 3],
  created_at: new Date(Date.now() - i * 3600000 * 3).toISOString(),
}))

export const useDeliveriesStore = defineStore('deliveries', () => {
  const list = ref<Delivery[]>([])
  const total = ref(0)
  const page = ref(1)
  const perPage = ref(15)
  const selectedDelivery = ref<Delivery | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)
  const filters = ref({
    status: '',
    vehicle_type: '',
    dateFrom: '',
    dateTo: '',
  })

  const totalPages = computed(() => Math.ceil(total.value / perPage.value))

  async function fetchDeliveries() {
    loading.value = true
    const { get } = useApi()

    const params = new URLSearchParams({
      page: String(page.value),
      limit: String(perPage.value),
      ...(filters.value.status ? { status: filters.value.status } : {}),
      ...(filters.value.vehicle_type ? { vehicle_type: filters.value.vehicle_type } : {}),
      ...(filters.value.dateFrom ? { date_from: filters.value.dateFrom } : {}),
      ...(filters.value.dateTo ? { date_to: filters.value.dateTo } : {}),
    })

    const { data } = await get<{ data: Delivery[]; total: number }>(`/admin/deliveries?${params}`)

    if (data) {
      list.value = data.data
      total.value = data.total
    } else {
      let filtered = [...MOCK_DELIVERIES]
      if (filters.value.status) filtered = filtered.filter(d => d.status === filters.value.status)
      if (filters.value.vehicle_type) filtered = filtered.filter(d => d.vehicle_type === filters.value.vehicle_type)

      total.value = filtered.length
      const start = (page.value - 1) * perPage.value
      list.value = filtered.slice(start, start + perPage.value)
    }

    loading.value = false
  }

  function setPage(p: number) {
    page.value = p
    fetchDeliveries()
  }

  function setFilters(f: Partial<typeof filters.value>) {
    filters.value = { ...filters.value, ...f }
    page.value = 1
    fetchDeliveries()
  }

  return {
    list, total, page, perPage, totalPages,
    selectedDelivery, loading, error, filters,
    fetchDeliveries, setPage, setFilters,
  }
})
