<template>
  <div>
    <div class="page-header animate-fade-in">
      <div>
        <h1 class="page-title">{{ lang === 'fr' ? 'Flotte en direct' : 'Live Fleet Monitor' }}</h1>
        <p class="page-desc">{{ lang === 'fr' ? 'Localisation GPS en temps réel des chauffeurs actifs' : 'Real-time GPS tracking of active drivers' }}</p>
      </div>
      <div class="page-actions flex items-center gap-3">
        <div class="live-badge">
          <span class="badge-dot" style="background: #22c55e; width: 8px; height: 8px; border-radius: 50%; display: inline-block; animation: pulse-dot 1.5s infinite;"></span>
          <span style="font-size: 0.8rem; font-weight: 600; color: #22c55e; margin-left: 0.375rem;">{{ lang === 'fr' ? 'EN DIRECT' : 'LIVE' }}</span>
        </div>
        <button class="btn btn-secondary flex items-center gap-2" @click="refreshDrivers">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width: 16px; height: 16px;">
            <path stroke-linecap="round" stroke-linejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 1121.21 15.89M21 21v-5h-5.181" />
          </svg>
          <span>{{ lang === 'fr' ? 'Actualiser' : 'Refresh' }}</span>
        </button>
      </div>
    </div>

    <!-- Status summary -->
    <div class="fleet-stats animate-slide-up" style="margin-bottom: 1.5rem;">
      <div class="fleet-stat-item">
        <span class="fleet-stat-dot available"></span>
        <span class="fleet-stat-label">{{ lang === 'fr' ? 'Disponibles' : 'Available' }}</span>
        <span class="fleet-stat-count">{{ availableCount }}</span>
      </div>
      <div class="fleet-stat-item">
        <span class="fleet-stat-dot busy"></span>
        <span class="fleet-stat-label">{{ lang === 'fr' ? 'En course' : 'On Trip' }}</span>
        <span class="fleet-stat-count">{{ busyCount }}</span>
      </div>
      <div class="fleet-stat-item">
        <span class="fleet-stat-dot offline"></span>
        <span class="fleet-stat-label">{{ lang === 'fr' ? 'Hors ligne' : 'Offline' }}</span>
        <span class="fleet-stat-count">{{ offlineCount }}</span>
      </div>
      <div class="fleet-stat-item total">
        <span class="fleet-stat-label" style="font-weight:600">Total</span>
        <span class="fleet-stat-count" style="color: var(--accent-primary); font-weight: 700;">{{ activeDrivers.length }}</span>
      </div>
    </div>

    <!-- Map -->
    <div class="card animate-slide-up" style="margin-bottom: 1.5rem;">
      <div class="card-body" style="padding: 0; border-radius: var(--radius-md); overflow: hidden;">
        <ClientOnly>
          <AppMapView height="520px" :drivers="activeDrivers" />
          <template #fallback>
            <div class="skeleton" style="height: 520px; width: 100%; border-radius: var(--radius-md);"></div>
          </template>
        </ClientOnly>
      </div>
    </div>

    <!-- Driver list -->
    <div class="card animate-slide-up">
      <div class="card-header flex justify-between items-center" style="padding: 1rem 1.5rem; border-bottom: 1px solid var(--border); text-align: left;">
        <h3 class="text-base font-semibold">{{ lang === 'fr' ? 'Liste des chauffeurs' : 'Drivers List' }}</h3>
        <NuxtLink to="/drivers" class="btn btn-secondary btn-sm">{{ lang === 'fr' ? 'Gérer les chauffeurs' : 'Manage Drivers' }}</NuxtLink>
      </div>
      <div class="card-body" style="padding: 0;">
        <div class="driver-list">
          <div v-for="driver in activeDrivers" :key="driver.id" class="driver-list-item">
            <div class="driver-avatar">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width: 18px; height: 18px;">
                <path stroke-linecap="round" stroke-linejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
              </svg>
            </div>
            <div class="driver-info" style="text-align: left;">
              <div class="driver-name">{{ driver.name }}</div>
              <div class="driver-vehicle">{{ driver.vehicle_type }}</div>
            </div>
            <div class="driver-coords">
              <div style="font-size:0.7rem; color: var(--text-muted);">{{ driver.lat.toFixed(4) }}, {{ driver.lng.toFixed(4) }}</div>
            </div>
            <span class="badge" :class="`status-${driver.status}`">{{ statusLabel(driver.status) }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { storeToRefs } from 'pinia'
import { useDashboardStore } from '~/stores/dashboard'
import { useI18n } from '~/composables/useI18n'

definePageMeta({ middleware: 'auth' })

const store = useDashboardStore()
const { activeDrivers } = storeToRefs(store)
const { t, lang } = useI18n()

const availableCount = computed(() => activeDrivers.value.filter(d => d.status === 'available').length)
const busyCount = computed(() => activeDrivers.value.filter(d => d.status === 'busy').length)
const offlineCount = computed(() => activeDrivers.value.filter(d => d.status === 'offline').length)

function statusLabel(s: string) {
  if (s === 'available') return lang.value === 'fr' ? 'Disponible' : 'Available'
  if (s === 'busy') return lang.value === 'fr' ? 'En course' : 'On Trip'
  return lang.value === 'fr' ? 'Hors ligne' : 'Offline'
}

async function refreshDrivers() {
  await store.fetchDashboard()
}

onMounted(async () => {
  if (activeDrivers.value.length === 0) {
    await store.fetchDashboard()
  }
})
</script>

<style scoped>
.live-badge {
  display: flex;
  align-items: center;
  background: rgba(34, 197, 94, 0.1);
  border: 1px solid rgba(34, 197, 94, 0.25);
  border-radius: 100px;
  padding: 0.25rem 0.75rem;
}

@keyframes pulse-dot {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.4; }
}

.fleet-stats {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
}

.fleet-stat-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background: var(--bg-card);
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  padding: 0.625rem 1rem;
}

.fleet-stat-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
}
.fleet-stat-dot.available { background: #22c55e; }
.fleet-stat-dot.busy { background: var(--accent-gold); }
.fleet-stat-dot.offline { background: var(--text-muted); }

.fleet-stat-label { font-size: 0.8125rem; color: var(--text-secondary); }
.fleet-stat-count { font-size: 0.9375rem; font-weight: 700; color: var(--text-primary); }

.driver-list { padding: 0.5rem 0; }
.driver-list-item {
  display: flex;
  align-items: center;
  gap: 0.875rem;
  padding: 0.75rem 1.5rem;
  border-bottom: 1px solid var(--border);
  transition: var(--transition);
}
.driver-list-item:last-child { border-bottom: none; }
.driver-list-item:hover { background: var(--bg-card-hover); }

.driver-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: var(--bg-card);
  border: 1px solid var(--border);
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--text-muted);
  flex-shrink: 0;
}

.driver-info { flex: 1; min-width: 0; }
.driver-name { font-size: 0.875rem; font-weight: 600; color: var(--text-primary); }
.driver-vehicle { font-size: 0.75rem; color: var(--text-muted); text-transform: capitalize; }
.driver-coords { margin-left: auto; margin-right: 0.75rem; }

.status-available { background: rgba(34,197,94,0.12); color: #22c55e; border: 1px solid rgba(34,197,94,0.25); }
.status-busy { background: rgba(255,215,0,0.12); color: var(--accent-gold); border: 1px solid rgba(255,215,0,0.25); }
.status-offline { background: rgba(148,163,184,0.1); color: var(--text-muted); border: 1px solid var(--border); }
</style>
