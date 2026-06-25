<template>
  <div class="dashboard-page">
    <!-- Page Header -->
    <div class="page-header animate-fade-in">
      <div>
        <h1 class="page-title">{{ lang === 'fr' ? 'Tableau de bord' : 'Dashboard' }}</h1>
        <p class="page-desc">{{ lang === 'fr' ? 'Aperçu en temps réel de la plateforme ZekDrive' : 'Real-time overview of the ZekDrive platform' }}</p>
      </div>
      <div class="page-actions">
        <button class="btn btn-secondary flex items-center gap-2" :disabled="loading" @click="refreshData">
          <svg :class="{ 'spin-icon': loading }" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width: 16px; height: 16px;">
            <path stroke-linecap="round" stroke-linejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 1121.21 15.89M21 21v-5h-5.181" />
          </svg>
          <span>{{ lang === 'fr' ? 'Actualiser' : 'Refresh' }}</span>
        </button>
      </div>
    </div>

    <!-- Stats Cards Grid -->
    <div v-if="stats" class="stats-grid animate-slide-up" style="margin-bottom: 2rem;">
      <AppStatsCard
        :label="lang === 'fr' ? 'Utilisateurs inscrits' : 'Registered Users'"
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
        :label="lang === 'fr' ? 'Chauffeurs actifs' : 'Active Drivers'"
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
        :label="lang === 'fr' ? 'Courses aujourd\'hui' : 'Trips Today'"
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
        :label="lang === 'fr' ? 'Revenus du jour' : 'Revenue Today'"
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

    <!-- Quick Links Row -->
    <div class="quick-links animate-slide-up" style="margin-bottom: 2rem;">
      <NuxtLink to="/fleet" class="quick-link-card">
        <div class="quick-link-icon" style="background: rgba(20,177,158,0.12); color: var(--accent-primary);">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width:22px;height:22px">
            <path stroke-linecap="round" stroke-linejoin="round" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7" />
          </svg>
        </div>
        <div class="quick-link-text" style="text-align: left;">
          <div class="quick-link-title">{{ t('live_fleet') }}</div>
          <div class="quick-link-sub">{{ lang === 'fr' ? 'Carte GPS des chauffeurs' : 'GPS map of drivers' }}</div>
        </div>
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" class="quick-link-arrow">
          <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7" />
        </svg>
      </NuxtLink>

      <NuxtLink to="/analytics" class="quick-link-card">
        <div class="quick-link-icon" style="background: rgba(59,130,246,0.12); color: #3b82f6;">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width:22px;height:22px">
            <path stroke-linecap="round" stroke-linejoin="round" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
          </svg>
        </div>
        <div class="quick-link-text" style="text-align: left;">
          <div class="quick-link-title">{{ lang === 'fr' ? 'Statistiques & Revenus' : 'Analytics & Earnings' }}</div>
          <div class="quick-link-sub">{{ lang === 'fr' ? 'Graphiques et analyses' : 'Charts and analyses' }}</div>
        </div>
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" class="quick-link-arrow">
          <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7" />
        </svg>
      </NuxtLink>

      <NuxtLink to="/trips" class="quick-link-card">
        <div class="quick-link-icon" style="background: rgba(255,215,0,0.12); color: var(--accent-gold);">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width:22px;height:22px">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </div>
        <div class="quick-link-text" style="text-align: left;">
          <div class="quick-link-title">{{ lang === 'fr' ? 'Toutes les courses' : 'All Trips' }}</div>
          <div class="quick-link-sub">{{ lang === 'fr' ? 'Historique complet' : 'Full trip history' }}</div>
        </div>
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" class="quick-link-arrow">
          <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7" />
        </svg>
      </NuxtLink>

      <NuxtLink to="/drivers" class="quick-link-card">
        <div class="quick-link-icon" style="background: rgba(0,212,170,0.12); color: var(--accent-secondary);">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width:22px;height:22px">
            <path stroke-linecap="round" stroke-linejoin="round" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
        </div>
        <div class="quick-link-text" style="text-align: left;">
          <div class="quick-link-title">{{ t('drivers') }}</div>
          <div class="quick-link-sub">{{ lang === 'fr' ? 'Gestion des chauffeurs' : 'Manage drivers' }}</div>
        </div>
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" class="quick-link-arrow">
          <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7" />
        </svg>
      </NuxtLink>
    </div>

    <!-- Recent Trips Data Table -->
    <div class="card animate-slide-up">
      <div class="card-header flex justify-between items-center" style="padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border); text-align: left;">
        <h3 class="text-base font-semibold">{{ lang === 'fr' ? 'Courses récentes' : 'Recent Trips' }}</h3>
        <NuxtLink to="/trips" class="btn btn-secondary btn-sm">{{ lang === 'fr' ? 'Voir tout' : 'View All' }}</NuxtLink>
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
import { onMounted, computed } from 'vue'
import { storeToRefs } from 'pinia'
import { useDashboardStore } from '~/stores/dashboard'
import { useI18n } from '~/composables/useI18n'

definePageMeta({
  middleware: 'auth',
})

const dashboardStore = useDashboardStore()
const { stats, recentTrips, loading } = storeToRefs(dashboardStore)
const { t, lang } = useI18n()

const tripHeaders = computed(() => [
  { key: 'ref_id', label: lang.value === 'fr' ? 'Réf.' : 'Ref.' },
  { key: 'customer_name', label: lang.value === 'fr' ? 'Client' : 'Customer' },
  { key: 'driver_name', label: lang.value === 'fr' ? 'Chauffeur' : 'Driver' },
  { key: 'status', label: t('status') },
  { key: 'fare', label: lang.value === 'fr' ? 'Tarif' : 'Fare' },
  { key: 'created_at', label: lang.value === 'fr' ? 'Heure' : 'Time' },
])

function formatNumber(n: number): string {
  return new Intl.NumberFormat(lang.value === 'fr' ? 'fr-FR' : 'en-US').format(n)
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
    return new Date(dStr).toLocaleTimeString(lang.value === 'fr' ? 'fr-FR' : 'en-US', { hour: '2-digit', minute: '2-digit' })
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
.dashboard-page { }

/* Quick links row */
.quick-links {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 1rem;
}

.quick-link-card {
  display: flex;
  align-items: center;
  gap: 0.875rem;
  padding: 1rem 1.25rem;
  background: var(--bg-card);
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
  text-decoration: none;
  color: var(--text-primary);
  transition: var(--transition);
  cursor: pointer;
}

.quick-link-card:hover {
  background: var(--bg-card-hover);
  border-color: var(--border-hover);
  transform: translateY(-2px);
  box-shadow: var(--shadow-glow);
}

.quick-link-icon {
  width: 44px;
  height: 44px;
  border-radius: var(--radius-sm);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.quick-link-text {
  flex: 1;
  min-width: 0;
}

.quick-link-title {
  font-size: 0.875rem;
  font-weight: 600;
  color: var(--text-primary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.quick-link-sub {
  font-size: 0.75rem;
  color: var(--text-muted);
  margin-top: 0.125rem;
}

.quick-link-arrow {
  width: 16px;
  height: 16px;
  color: var(--text-muted);
  flex-shrink: 0;
  transition: var(--transition);
}

.quick-link-card:hover .quick-link-arrow {
  color: var(--accent-primary);
  transform: translateX(2px);
}

.spin-icon {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

@media (max-width: 1100px) {
  .quick-links { grid-template-columns: repeat(2, 1fr); }
}

@media (max-width: 640px) {
  .quick-links { grid-template-columns: 1fr; }
}
</style>
