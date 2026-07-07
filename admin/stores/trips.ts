// stores/trips.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export interface TripStatusChange {
  status: string
  timestamp: string
  note?: string
}

export interface Trip {
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
  duration_min: number
  payment_method: string
  zone?: string
  created_at: string
  status_history?: TripStatusChange[]
}

const STATUSES: Trip['status'][] = ['pending', 'accepted', 'ongoing', 'completed', 'cancelled']
const PICKUPS = ['Bastos, Yaoundé', 'Centre-ville, Yaoundé', 'Mvan, Yaoundé', 'Odza, Yaoundé', 'Ngousso, Yaoundé']
const DROPOFFS = ['Aéroport NSIMALEN', 'Université I, Yaoundé', 'Marché Mokolo', 'Biyem-Assi, Yaoundé', 'Mvog-Ada, Yaoundé']
const CUSTOMERS = ['Jean-Pierre T.', 'Marie-Claire N.', 'Emmanuel F.', 'Christelle A.', 'Patrick M.']
const DRIVERS = ['Rodrigue K.', 'Blaise E.', 'Thierry D.', 'Célestin B.', 'Hermann N.']

const MOCK_TRIPS: Trip[] = Array.from({ length: 60 }, (_, i) => ({
  id: `trip_${i + 1}`,
  ref_id: `ZD-${String(1000 + i).padStart(5, '0')}`,
  customer_name: CUSTOMERS[i % CUSTOMERS.length],
  customer_id: `user_${(i % 10) + 1}`,
  driver_name: DRIVERS[i % DRIVERS.length],
  driver_id: `driver_${(i % 5) + 1}`,
  pickup_address: PICKUPS[i % PICKUPS.length],
  dropoff_address: DROPOFFS[i % DROPOFFS.length],
  // Coordonnées GPS de Yaoundé, Cameroun
  pickup_lat: 3.8480 + (Math.random() - 0.5) * 0.08,
  pickup_lng: 11.5021 + (Math.random() - 0.5) * 0.08,
  dropoff_lat: 3.8680 + (Math.random() - 0.5) * 0.08,
  dropoff_lng: 11.5221 + (Math.random() - 0.5) * 0.08,
  status: STATUSES[i % STATUSES.length],
  fare: Math.floor(Math.random() * 8000 + 1500),
  distance_km: Math.round((Math.random() * 15 + 1) * 10) / 10,
  duration_min: Math.floor(Math.random() * 40 + 5),
  payment_method: ['cash', 'orange_money', 'mtn_momo', 'card'][i % 4],
  zone: ['Yaoundé Centre', 'Yaoundé Nord', 'Yaoundé Sud', 'Douala'][i % 4],
  created_at: new Date(Date.now() - i * 3600000 * 2).toISOString(),
  status_history: [
    { status: 'pending', timestamp: new Date(Date.now() - i * 3600000 * 2).toISOString() },
    { status: 'accepted', timestamp: new Date(Date.now() - i * 3600000 * 2 + 120000).toISOString() },
    { status: STATUSES[i % STATUSES.length], timestamp: new Date(Date.now() - i * 3600000).toISOString() },
  ],
}))

export const useTripsStore = defineStore('trips', () => {
  const list = ref<Trip[]>([])
  const total = ref(0)
  const page = ref(1)
  const perPage = ref(15)
  const selectedTrip = ref<Trip | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)
  const filters = ref({
    status: '',
    zone: '',
    dateFrom: '',
    dateTo: '',
  })

  const totalPages = computed(() => Math.ceil(total.value / perPage.value))

  async function fetchTrips() {
    loading.value = true
    const { get } = useApi()

    const params = new URLSearchParams({
      page: String(page.value),
      limit: String(perPage.value),
      ...(filters.value.status ? { status: filters.value.status } : {}),
      ...(filters.value.zone ? { zone: filters.value.zone } : {}),
      ...(filters.value.dateFrom ? { date_from: filters.value.dateFrom } : {}),
      ...(filters.value.dateTo ? { date_to: filters.value.dateTo } : {}),
    })

    const { data } = await get<{ data: Trip[]; total: number }>(`/admin/trips?${params}`)

    if (data) {
      list.value = data.data
      total.value = data.total
    } else {
      let filtered = [...MOCK_TRIPS]
      if (filters.value.status) filtered = filtered.filter(t => t.status === filters.value.status)
      if (filters.value.zone) filtered = filtered.filter(t => t.zone === filters.value.zone)

      total.value = filtered.length
      const start = (page.value - 1) * perPage.value
      list.value = filtered.slice(start, start + perPage.value)
    }

    loading.value = false
  }

  async function fetchTripDetail(id: string): Promise<Trip | null> {
    const { get } = useApi()
    const { data } = await get<Trip>(`/admin/trips/${id}`)
    if (data) {
      selectedTrip.value = data
      return data
    }
    const mock = MOCK_TRIPS.find(t => t.id === id) || MOCK_TRIPS[0]
    selectedTrip.value = mock
    return mock
  }

  function setPage(p: number) {
    page.value = p
    fetchTrips()
  }

  function setFilters(f: Partial<typeof filters.value>) {
    filters.value = { ...filters.value, ...f }
    page.value = 1
    fetchTrips()
  }

  return {
    list, total, page, perPage, totalPages,
    selectedTrip, loading, error, filters,
    fetchTrips, fetchTripDetail, setPage, setFilters,
  }
})
