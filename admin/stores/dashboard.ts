// stores/dashboard.ts
import { defineStore } from 'pinia'
import { ref } from 'vue'

export interface DashboardStats {
  totalUsers: number
  activeDrivers: number
  tripsToday: number
  revenueToday: number
  userChange: number
  driverChange: number
  tripChange: number
  revenueChange: number
}

export interface RevenuePoint {
  date: string
  revenue: number
  trips: number
}

export interface TripStatusBreakdown {
  completed: number
  cancelled: number
  ongoing: number
  pending: number
}

export interface RecentTrip {
  id: string
  ref_id: string
  customer_name: string
  driver_name: string
  pickup: string
  dropoff: string
  status: string
  fare: number
  created_at: string
}

export interface ActiveDriver {
  id: string
  name: string
  lat: number
  lng: number
  status: 'available' | 'busy' | 'offline'
  vehicle_type: string
}

// Generate mock data
function generateMockRevenue(): RevenuePoint[] {
  const points: RevenuePoint[] = []
  const now = new Date()
  for (let i = 29; i >= 0; i--) {
    const d = new Date(now)
    d.setDate(d.getDate() - i)
    points.push({
      date: d.toISOString().split('T')[0],
      revenue: Math.floor(Math.random() * 500000 + 200000),
      trips: Math.floor(Math.random() * 120 + 40),
    })
  }
  return points
}

function generateMockTrips(): RecentTrip[] {
  const statuses = ['completed', 'ongoing', 'cancelled', 'pending']
  const customers = ['Amadou Ba', 'Fatoumata Diallo', 'Moussa Sow', 'Aissatou Camara', 'Omar Traoré', 'Mariama Kouyaté', 'Ibrahima Ndiaye', 'Kadiatou Bah', 'Cheikh Fall', 'Rokhaya Mbaye']
  const drivers = ['Seydou Keita', 'Lamine Koné', 'Boubacar Diarra', 'Abdoulaye Cissé', 'Mamadou Barry']
  const pickups = ['Almadies, Dakar', 'Plateau, Dakar', 'Parcelles Assainies', 'Grand Yoff', 'Mermoz, Dakar']
  const dropoffs = ['Aéroport AIBD', 'UCAD, Dakar', 'Marché Sandaga', 'Point E, Dakar', 'Yoff, Dakar']

  return Array.from({ length: 10 }, (_, i) => ({
    id: `trip_${i + 1}`,
    ref_id: `ZD-${String(1000 + i).padStart(5, '0')}`,
    customer_name: customers[i % customers.length],
    driver_name: drivers[i % drivers.length],
    pickup: pickups[i % pickups.length],
    dropoff: dropoffs[i % dropoffs.length],
    status: statuses[i % statuses.length],
    fare: Math.floor(Math.random() * 8000 + 1500),
    created_at: new Date(Date.now() - i * 3600000).toISOString(),
  }))
}

function generateMockDrivers(): ActiveDriver[] {
  const names = ['Seydou K.', 'Lamine D.', 'Boubacar C.', 'Abdoulaye B.', 'Mamadou T.', 'Ibrahima S.', 'Alpha D.', 'Modou F.']
  const statuses: ('available' | 'busy' | 'offline')[] = ['available', 'busy', 'available', 'offline', 'busy', 'available', 'offline', 'available']
  const vehicles = ['car', 'moto', 'car', 'car', 'moto', 'car', 'moto', 'car']

  return names.map((name, i) => ({
    id: `driver_${i + 1}`,
    name,
    lat: 14.6928 + (Math.random() - 0.5) * 0.1,
    lng: -17.4467 + (Math.random() - 0.5) * 0.1,
    status: statuses[i],
    vehicle_type: vehicles[i],
  }))
}

export const useDashboardStore = defineStore('dashboard', () => {
  const stats = ref<DashboardStats | null>(null)
  const revenueChart = ref<RevenuePoint[]>([])
  const tripBreakdown = ref<TripStatusBreakdown>({ completed: 0, cancelled: 0, ongoing: 0, pending: 0 })
  const recentTrips = ref<RecentTrip[]>([])
  const activeDrivers = ref<ActiveDriver[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  async function fetchDashboard() {
    loading.value = true
    error.value = null

    const { get } = useApi()

    try {
      const [statsRes, revenueRes, tripsRes, driversRes] = await Promise.allSettled([
        get<DashboardStats>('/admin/dashboard/stats'),
        get<RevenuePoint[]>('/admin/dashboard/revenue'),
        get<RecentTrip[]>('/admin/trips?limit=10&sort=created_at:desc'),
        get<ActiveDriver[]>('/admin/drivers/locations'),
      ])

      // Stats
      if (statsRes.status === 'fulfilled' && statsRes.value.data) {
        stats.value = statsRes.value.data
      } else {
        stats.value = {
          totalUsers: 12847,
          activeDrivers: 342,
          tripsToday: 1284,
          revenueToday: 8_470_000,
          userChange: 8.2,
          driverChange: 3.1,
          tripChange: 12.4,
          revenueChange: 9.7,
        }
      }

      // Revenue chart
      if (revenueRes.status === 'fulfilled' && revenueRes.value.data) {
        revenueChart.value = revenueRes.value.data
      } else {
        revenueChart.value = generateMockRevenue()
      }

      // Recent trips
      if (tripsRes.status === 'fulfilled' && tripsRes.value.data) {
        recentTrips.value = tripsRes.value.data as RecentTrip[]
      } else {
        recentTrips.value = generateMockTrips()
      }

      // Active drivers
      if (driversRes.status === 'fulfilled' && driversRes.value.data) {
        activeDrivers.value = driversRes.value.data as ActiveDriver[]
      } else {
        activeDrivers.value = generateMockDrivers()
      }

      // Compute breakdown from recent trips
      const all = recentTrips.value
      tripBreakdown.value = {
        completed: all.filter(t => t.status === 'completed').length,
        cancelled: all.filter(t => t.status === 'cancelled').length,
        ongoing: all.filter(t => t.status === 'ongoing').length,
        pending: all.filter(t => t.status === 'pending').length,
      }
    } catch (e) {
      error.value = 'Failed to load dashboard data'
    } finally {
      loading.value = false
    }
  }

  return {
    stats,
    revenueChart,
    tripBreakdown,
    recentTrips,
    activeDrivers,
    loading,
    error,
    fetchDashboard,
  }
})
