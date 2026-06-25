<template>
  <div>
    <div class="page-header animate-fade-in">
      <div>
        <h1 class="page-title">{{ lang === 'fr' ? 'Statistiques & Revenus' : 'Analytics & Earnings' }}</h1>
        <p class="page-desc">{{ lang === 'fr' ? 'Analyse des performances financières et opérationnelles' : 'Analysis of financial and operational performance' }}</p>
      </div>
      <div class="page-actions">
        <select class="form-select" v-model="period" style="width:160px;">
          <option value="7">{{ lang === 'fr' ? '7 derniers jours' : 'Last 7 days' }}</option>
          <option value="15">{{ lang === 'fr' ? '15 derniers jours' : 'Last 15 days' }}</option>
          <option value="30">{{ lang === 'fr' ? '30 derniers jours' : 'Last 30 days' }}</option>
        </select>
      </div>
    </div>

    <!-- KPI Summary -->
    <div class="stats-grid animate-slide-up" style="margin-bottom: 2rem;">
      <AppStatsCard :label="lang === 'fr' ? 'Revenu total' : 'Total Revenue'" :value="formatCurrency(totalRevenue)" :trend="8.4" color="#3b82f6">
        <template #icon>
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width: 20px; height: 20px;">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </template>
      </AppStatsCard>

      <AppStatsCard :label="lang === 'fr' ? 'Courses totales' : 'Total Trips'" :value="formatNumber(totalTrips)" :trend="12.1" color="var(--accent-gold)">
        <template #icon>
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width: 20px; height: 20px;">
            <path stroke-linecap="round" stroke-linejoin="round" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7" />
          </svg>
        </template>
      </AppStatsCard>

      <AppStatsCard :label="lang === 'fr' ? 'Revenu moyen / course' : 'Avg Revenue / Trip'" :value="formatCurrency(avgRevenue)" :trend="3.2" color="var(--accent-primary)">
        <template #icon>
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width: 20px; height: 20px;">
            <path stroke-linecap="round" stroke-linejoin="round" d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
          </svg>
        </template>
      </AppStatsCard>

      <AppStatsCard :label="lang === 'fr' ? 'Taux de complétion' : 'Completion Rate'" :value="completionRate + '%'" :trend="1.5" color="var(--accent-secondary)">
        <template #icon>
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width: 20px; height: 20px;">
            <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </template>
      </AppStatsCard>
    </div>

    <!-- Revenue Chart -->
    <div class="card animate-slide-up" style="margin-bottom: 1.5rem;">
      <div class="card-header flex justify-between items-center" style="padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border);">
        <div style="text-align: left;">
          <h3 class="text-base font-semibold">{{ lang === 'fr' ? 'Évolution des revenus' : 'Revenue Trend' }}</h3>
          <p class="text-xs text-muted" style="margin-top: 2px;">{{ lang === 'fr' ? "Chiffre d'affaires et volume de courses" : 'Revenue and trip volume' }}</p>
        </div>
        <div class="badge" style="background: rgba(59,130,246,0.12); color: #3b82f6; border: 1px solid rgba(59,130,246,0.25);">
          {{ period }} {{ lang === 'fr' ? 'jours' : 'days' }}
        </div>
      </div>
      <div class="card-body" style="padding: 1.5rem 1rem 1rem;">
        <ClientOnly>
          <AppRevenueChart :points="filteredChart" />
          <template #fallback>
            <div class="skeleton" style="height: 280px; border-radius: var(--radius-md);"></div>
          </template>
        </ClientOnly>
      </div>
    </div>

    <!-- Breakdown table -->
    <div class="card animate-slide-up">
      <div class="card-header" style="padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border); text-align: left;">
        <h3 class="text-base font-semibold">{{ lang === 'fr' ? 'Détail jour par jour' : 'Day-by-Day Breakdown' }}</h3>
      </div>
      <div class="card-body" style="padding: 0;">
        <div class="table-wrap">
          <table class="table">
            <thead>
              <tr>
                <th style="text-align: left;">Date</th>
                <th>{{ lang === 'fr' ? 'Courses' : 'Trips' }}</th>
                <th>{{ lang === 'fr' ? 'Revenu' : 'Revenue' }}</th>
                <th>{{ lang === 'fr' ? 'Moy./Course' : 'Avg/Trip' }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="point in filteredChart" :key="point.date">
                <td style="text-align: left;">{{ formatDate(point.date) }}</td>
                <td>{{ point.trips }}</td>
                <td><span class="font-semibold" style="color: #3b82f6;">{{ formatCurrency(point.revenue) }}</span></td>
                <td>{{ formatCurrency(point.trips ? Math.round(point.revenue / point.trips) : 0) }}</td>
              </tr>
              <tr v-if="filteredChart.length === 0">
                <td colspan="4" style="text-align:center; padding: 2rem; color: var(--text-muted);">{{ lang === 'fr' ? 'Aucune donnée disponible' : 'No data available' }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { storeToRefs } from 'pinia'
import { useDashboardStore } from '~/stores/dashboard'
import { useI18n } from '~/composables/useI18n'

definePageMeta({ middleware: 'auth' })

const store = useDashboardStore()
const { revenueChart, loading } = storeToRefs(store)
const { t, lang } = useI18n()
const period = ref('30')

const filteredChart = computed(() => {
  const p = parseInt(period.value)
  return revenueChart.value.slice(-p)
})

const totalRevenue = computed(() => filteredChart.value.reduce((s, p) => s + p.revenue, 0))
const totalTrips = computed(() => filteredChart.value.reduce((s, p) => s + p.trips, 0))
const avgRevenue = computed(() => totalTrips.value ? Math.round(totalRevenue.value / totalTrips.value) : 0)
const completionRate = computed(() => 87)

function formatNumber(n: number): string {
  return new Intl.NumberFormat(lang.value === 'fr' ? 'fr-FR' : 'en-US').format(n)
}

function formatCurrency(n: number): string {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF', maximumFractionDigits: 0 }).format(n)
}

function formatDate(d: string): string {
  return new Date(d).toLocaleDateString(lang.value === 'fr' ? 'fr-FR' : 'en-US', { day: '2-digit', month: 'short' })
}

onMounted(async () => {
  if (revenueChart.value.length === 0) {
    await store.fetchDashboard()
  }
})
</script>
