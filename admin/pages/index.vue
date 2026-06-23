<template>
  <div>
    <!-- Page Header -->
    <div class="page-header">
      <div>
        <h1 class="page-title">Overview Dashboard</h1>
        <p class="page-desc">Real-time status of ZekDrive ride-hailing and deliveries</p>
      </div>
      <div class="page-actions">
        <button class="btn btn-secondary flex items-center gap-2" :disabled="loading" @click="refreshData">
          <svg :class="{ 'animate-spin': loading }" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width: 16px; height: 16px;">
            <path stroke-linecap="round" stroke-linejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 1121.21 15.89M21 21v-5h-5.181" />
          </svg>
          <span>Refresh Data</span>
        </button>
      </div>
    </div>

    <!-- Stats Cards Grid -->
    <div v-if="stats" class="stats-grid animate-slide-up">
      <AppStatsCard
        label="Total Platform Users"
        :value="formatNumber(stats.totalUsers)"
        :trend="stats.userChange"
        color="var(--accent-primary)"
      >
        <template #icon>
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width: 20px; height: 20px;">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
          </svg>
        </template>
      </AppStatsCard>

      <AppStatsCard
        label="Active Drivers"
        :value="formatNumber(stats.activeDrivers)"
        :trend="stats.driverChange"
        color="var(--accent-secondary)"
      >
        <template #icon>
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width: 20px; height: 20px;">
            <path stroke-linecap="round" stroke-linejoin="round" d="M9 12a5 5 0 1110 0 5 5 0 01-10 0z" />
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 14v7m-9-4h18" />
          </svg>
        </template>
      </AppStatsCard>

      <AppStatsCard
        label="Trips Created Today"
        :value="formatNumber(stats.tripsToday)"
        :trend="stats.tripChange"
        color="var(--accent-gold)"
      >
        <template #icon>
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width: 20px; height: 20px;">
            <path stroke-linecap="round" stroke-linejoin="round" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7" />
          </svg>
        </template>
      </AppStatsCard>

      <AppStatsCard
        label="Revenue Today"
        :value="formatCurrency(stats.revenueToday)"
        :trend="stats.revenueChange"
        color="#3b82f6"
      >
        <template #icon>
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width: 20px; height: 20px;">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </template>
      </AppStatsCard>
    </div>

    <!-- Main Section: Map & Analytics -->
    <div class="grid grid-cols-2 gap-6 animate-slide-up" style="grid-template-columns: 1fr 1fr; margin-bottom: 2rem;">
      <!-- Active Drivers Map Container -->
      <div class="card">
        <div class="card-header flex justify-between items-center" style="padding: 1rem 1.25rem; border-bottom: 1px solid var(--border);">
          <h3 class="text-base font-semibold">Live Fleet Monitor</h3>
          <span class="badge badge-active flex items-center gap-1">
            <span class="badge-dot"></span> Live
          </span>
        </div>
        <div class="card-body" style="padding: 1rem;">
          <ClientOnly>
            <AppMapView height="360px" :drivers="activeDrivers" />
            <template #fallback>
              <div class="skeleton" style="height: 360px; width: 100%; border-radius: var(--radius-md);"></div>
            </template>
          </ClientOnly>
        </div>
      </div>

      <!-- Financial Chart Container -->
      <div class="card">
        <div class="card-header flex justify-between items-center" style="padding: 1rem 1.25rem; border-bottom: 1px solid var(--border);">
          <h3 class="text-base font-semibold">Revenue Evolution</h3>
          <span class="text-xs text-muted">Last 15 days</span>
        </div>
        <div class="card-body" style="padding: 1.5rem 1rem 1rem;">
          <AppRevenueChart :points="revenueChart" />
        </div>
      </div>
    </div>

    <!-- Recent Trips Data Table -->
    <div class="card animate-slide-up">
      <div class="card-header flex justify-between items-center" style="padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border);">
        <h3 class="text-base font-semibold">Recent Trip Requests</h3>
        <NuxtLink to="/trips" class="btn btn-secondary btn-sm">View All Trips</NuxtLink>
      </div>
      <div class="card-body" style="padding: 0;">
        <AppDataTable
          :headers="tripHeaders"
          :items="recentTrips"
          :loading="loading"
          :total-items="recentTrips.length"
          :totalPages="1"
          :perPage="10"
          :currentPage="1"
        >
          <template #cell-ref_id="{ item }">
            <span class="font-bold text-primary">{{ item.ref_id }}</span>
          </template>
          
          <template #cell-status="{ item }">
            <AppStatusBadge :status="item.status" />
          </template>
          
          <template #cell-fare="{ item }">
            <span class="font-semibold text-primary">{{ formatCurrency(item.fare) }}</span>
          </template>

          <template #cell-created_at="{ item }">
            <span>{{ formatTime(item.created_at) }}</span>
          </template>
        </AppDataTable>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { storeToRefs } from 'pinia'
import { useDashboardStore } from '~/stores/dashboard'

definePageMeta({
  middleware: 'auth',
})

const dashboardStore = useDashboardStore()
const { stats, revenueChart, recentTrips, activeDrivers, loading } = storeToRefs(dashboardStore)

const tripHeaders = [
  { key: 'ref_id', label: 'Reference ID' },
  { key: 'customer_name', label: 'Customer' },
  { key: 'driver_name', label: 'Driver' },
  { key: 'pickup', label: 'Pickup Location' },
  { key: 'dropoff', label: 'Dropoff Location' },
  { key: 'status', label: 'Status' },
  { key: 'fare', label: 'Fare' },
  { key: 'created_at', label: 'Time' },
]

function formatNumber(n: number): string {
  return new Intl.NumberFormat('fr-FR').format(n)
}

function formatCurrency(n: number): string {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF',
    maximumFractionDigits: 0
  }).format(n)
}

function formatTime(dStr: string): string {
  try {
    const d = new Date(dStr)
    return d.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
  } catch {
    return dStr
  }
}

async function refreshData() {
  await dashboardStore.fetchDashboard()
}

onMounted(async () => {
  await dashboardStore.fetchDashboard()
})
</script>

<style scoped>
.animate-spin {
  animation: spin 1s linear infinite;
}
@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}
</style>
