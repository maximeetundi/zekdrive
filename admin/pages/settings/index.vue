<template>
  <div>
    <!-- Page Header -->
    <div class="page-header animate-fade-in">
      <div>
        <h1 class="page-title">System Settings</h1>
        <p class="page-desc">Modify dispatcher configurations, payout commissions, payment gates, and API keys</p>
      </div>
      <div class="page-actions">
        <button class="btn btn-primary" :disabled="saving" @click="saveAllSettings">
          <span v-if="saving" class="loader" style="width: 16px; height: 16px; margin-right: 8px;"></span>
          <span>{{ saving ? 'Saving Changes...' : 'Save Settings' }}</span>
        </button>
      </div>
    </div>

    <!-- Alert Success Banner -->
    <div v-if="saveSuccess" class="badge-active" style="padding: 0.75rem 1rem; border-radius: var(--radius-sm); margin-bottom: 1.5rem; font-size: 0.8125rem; border: 1px solid rgba(0, 212, 170, 0.2); display: flex; align-items: center; gap: 0.5rem; color: var(--accent-secondary);">
      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
      <span>Settings saved successfully! Re-routing configuration updates to node processes.</span>
    </div>

    <!-- Tabs Wrapper -->
    <div class="tabs animate-fade-in" style="margin-bottom: 1.5rem;">
      <button class="tab-item" :class="{ active: activeTab === 'app' }" @click="activeTab = 'app'">
        App Configuration
      </button>
      <button class="tab-item" :class="{ active: activeTab === 'gateways' }" @click="activeTab = 'gateways'">
        Payment Gateways
      </button>
      <button class="tab-item" :class="{ active: activeTab === 'audit' }" @click="activeTab = 'audit'">
        Security & System Audit
      </button>
    </div>

    <!-- 1. App Configuration Tab Content -->
    <div v-if="activeTab === 'app'" class="grid grid-cols-2 gap-6 animate-slide-up" style="grid-template-columns: 1fr 1fr; margin-bottom: 2rem;">
      <!-- Dispatch Settings Card -->
      <div class="card">
        <div class="card-header" style="padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border);">
          <h3 class="text-base font-semibold">Dispatch Parameters</h3>
        </div>
        <div class="card-body" style="padding: 1.5rem;">
          <div class="form-group" style="margin-bottom: 1rem;">
            <label class="form-label">Auto-Dispatch Timeout (Seconds)</label>
            <input v-model.number="appConfig.dispatchTimeout" type="number" class="form-control" />
            <span class="text-xs text-muted" style="margin-top: 4px; display: block;">Time allotted for a driver to accept a request before it cascades.</span>
          </div>

          <div class="form-group" style="margin-bottom: 1rem;">
            <label class="form-label">Maximum Driver Search Radius (KM)</label>
            <input v-model.number="appConfig.searchRadius" type="number" class="form-control" />
            <span class="text-xs text-muted" style="margin-top: 4px; display: block;">Limits spatial matching distance to avoid driver fatigue.</span>
          </div>

          <div class="form-group">
            <label class="form-label">Platform Commission Percentage (%)</label>
            <input v-model.number="appConfig.commissionRate" type="number" class="form-control" />
            <span class="text-xs text-muted" style="margin-top: 4px; display: block;">Base commission fee deducted from completed fare payout.</span>
          </div>
        </div>
      </div>

      <!-- Support Info Card -->
      <div class="card">
        <div class="card-header" style="padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border);">
          <h3 class="text-base font-semibold">Platform Support Info</h3>
        </div>
        <div class="card-body" style="padding: 1.5rem;">
          <div class="form-group" style="margin-bottom: 1rem;">
            <label class="form-label">Support Helpdesk Contact Email</label>
            <input v-model="appConfig.supportEmail" type="email" class="form-control" />
          </div>

          <div class="form-group" style="margin-bottom: 1rem;">
            <label class="form-label">Support Helpline Phone Number</label>
            <input v-model="appConfig.supportPhone" type="text" class="form-control" />
          </div>

          <div class="form-group">
            <label class="form-label">Supported Default Language</label>
            <select v-model="appConfig.defaultLang" class="form-select">
              <option value="fr">French (Senegal)</option>
              <option value="wo">Wolof</option>
              <option value="en">English</option>
            </select>
          </div>
        </div>
      </div>
    </div>

    <!-- 2. Gateway Settings Tab Content -->
    <div v-else-if="activeTab === 'gateways'" class="flex flex-col gap-6 animate-slide-up" style="margin-bottom: 2rem;">
      <div v-for="gw in gateways" :key="gw.id" class="card">
        <div class="card-header flex justify-between items-center" style="padding: 1rem 1.5rem; border-bottom: 1px solid var(--border);">
          <div>
            <h3 class="text-base font-semibold">{{ gw.name }}</h3>
            <p class="text-xs text-muted">{{ gw.desc }}</p>
          </div>
          <!-- Custom Design System Class Switch -->
          <div class="toggle-switch" :class="{ on: gw.enabled }" @click="gw.enabled = !gw.enabled">
            <div class="toggle-knob"></div>
          </div>
        </div>
        
        <div v-if="gw.enabled" class="card-body" style="padding: 1.5rem;">
          <div class="grid grid-cols-2 gap-4" style="grid-template-columns: 1fr 1fr;">
            <div class="form-group">
              <label class="form-label">Gateway API Public Key</label>
              <input v-model="gw.publicKey" type="text" class="form-control" style="font-family: monospace;" />
            </div>
            <div class="form-group">
              <label class="form-label">Gateway Secret Token</label>
              <input v-model="gw.secretToken" type="password" class="form-control" placeholder="••••••••••••••••••••••••" />
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 3. Security & System Audit Tab Content -->
    <div v-else class="animate-slide-up" style="margin-bottom: 2rem;">
      <div class="card">
        <div class="card-header" style="padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border);">
          <h3 class="text-base font-semibold">Security System Logs</h3>
        </div>
        <div class="card-body" style="padding: 0;">
          <AppDataTable
            :headers="auditHeaders"
            :items="auditLogs"
            :loading="loading"
            :currentPage="1"
            :perPage="20"
            :totalItems="auditLogs.length"
            :totalPages="1"
          >
            <!-- Severity badges -->
            <template #cell-severity="{ item }">
              <span class="badge" :class="item.severity === 'high' ? 'badge-danger' : item.severity === 'medium' ? 'badge-warning' : 'badge-info'">
                {{ item.severity }}
              </span>
            </template>
            <template #cell-timestamp="{ item }">
              <span>{{ formatDateTime(item.timestamp) }}</span>
            </template>
          </AppDataTable>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

definePageMeta({
  middleware: 'auth',
})

const activeTab = ref<'app' | 'gateways' | 'audit'>('app')
const saving = ref(false)
const saveSuccess = ref(false)

// Config form data
const appConfig = ref({
  dispatchTimeout: 30,
  searchRadius: 8,
  commissionRate: 15,
  supportEmail: 'support@zekdrive.com',
  supportPhone: '+221 33 800 0000',
  defaultLang: 'fr'
})

// Gateways state
const gateways = ref([
  {
    id: 'gw_wave',
    name: 'Wave Senegal Gateway',
    desc: 'Support local Wave QR-code payments directly from mobile app redirects.',
    enabled: true,
    publicKey: 'pk_live_wave_51m92Fkd208mD2l',
    secretToken: 'sk_live_wave_secret_token_100x'
  },
  {
    id: 'gw_om',
    name: 'Orange Money WebPay API',
    desc: 'Support Orange Money USSD push payments with mobile auth prompts.',
    enabled: true,
    publicKey: 'pk_live_orange_448kd901msda',
    secretToken: 'sk_live_orange_secret_token_99y'
  },
  {
    id: 'gw_stripe',
    name: 'Stripe International Gateway',
    desc: 'Support credit/debit visa and mastercard payouts and client fares.',
    enabled: false,
    publicKey: 'pk_live_stripe_823190salkdm',
    secretToken: 'sk_live_stripe_secret_token_33z'
  }
])

// Audit System Logs
const auditLogs = ref([
  { id: '1', action: 'Admin Login Successful', user: 'admin@zekdrive.com', ip: '197.34.82.11', severity: 'low', timestamp: new Date(Date.now() - 3600000).toISOString() },
  { id: '2', action: 'Zone Boundary Almadies Updated', user: 'admin@zekdrive.com', ip: '197.34.82.11', severity: 'medium', timestamp: new Date(Date.now() - 7200000).toISOString() },
  { id: '3', action: 'Pricing Rule Commission Altered', user: 'admin@zekdrive.com', ip: '197.34.82.11', severity: 'high', timestamp: new Date(Date.now() - 14400000).toISOString() },
  { id: '4', action: 'Driver Seymour Approved', user: 'support@zekdrive.com', ip: '196.223.10.4', severity: 'low', timestamp: new Date(Date.now() - 86400000).toISOString() }
])

const auditHeaders = [
  { key: 'action', label: 'Action Event' },
  { key: 'user', label: 'Authorized Operator' },
  { key: 'ip', label: 'IP Address' },
  { key: 'severity', label: 'Severity' },
  { key: 'timestamp', label: 'Log Timestamp' }
]

function saveAllSettings() {
  saving.value = true
  saveSuccess.value = false
  
  setTimeout(() => {
    saving.value = false
    saveSuccess.value = true
    
    // Auto clear success banner
    setTimeout(() => {
      saveSuccess.value = false
    }, 5000)
  }, 1000)
}

function formatDateTime(dateStr: string): string {
  try {
    const d = new Date(dateStr)
    return d.toLocaleString('fr-FR', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit' })
  } catch {
    return dateStr
  }
}
</script>
