<template>
  <div>
    <!-- Page Header -->
    <div class="page-header animate-fade-in">
      <div>
        <h1 class="page-title">{{ lang === 'fr' ? 'Configuration Système' : 'System Settings' }}</h1>
        <p class="page-desc">{{ lang === 'fr' ? 'Modifier les configurations du répartiteur, les commissions de versement, les passerelles de paiement et les clés API' : 'Modify dispatcher configurations, payout commissions, payment gates, and API keys' }}</p>
      </div>
      <div class="page-actions">
        <button class="btn btn-primary" :disabled="saving" @click="saveAllSettings">
          <span v-if="saving" class="loader" style="width: 16px; height: 16px; margin-right: 8px;"></span>
          <span>{{ saving ? (lang === 'fr' ? 'Enregistrement...' : 'Saving Changes...') : (lang === 'fr' ? 'Enregistrer' : 'Save Settings') }}</span>
        </button>
      </div>
    </div>

    <!-- Alert Success Banner -->
    <div v-if="saveSuccess" class="badge-active" style="padding: 0.75rem 1rem; border-radius: var(--radius-sm); margin-bottom: 1.5rem; font-size: 0.8125rem; border: 1px solid rgba(0, 212, 170, 0.2); display: flex; align-items: center; gap: 0.5rem; color: var(--accent-secondary); text-align: left;">
      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
      <span>{{ lang === 'fr' ? 'Paramètres enregistrés avec succès ! Transmission des mises à jour aux processus applicatifs.' : 'Settings saved successfully! Re-routing configuration updates to node processes.' }}</span>
    </div>

    <!-- Tabs Wrapper -->
    <div class="tabs animate-fade-in" style="margin-bottom: 1.5rem;">
      <button class="tab-item" :class="{ active: activeTab === 'app' }" @click="activeTab = 'app'">
        {{ lang === 'fr' ? 'Configuration Générale' : 'App Configuration' }}
      </button>
      <button class="tab-item" :class="{ active: activeTab === 'gateways' }" @click="activeTab = 'gateways'">
        {{ lang === 'fr' ? 'Passerelles de paiement' : 'Payment Gateways' }}
      </button>
      <button class="tab-item" :class="{ active: activeTab === 'audit' }" @click="activeTab = 'audit'">
        {{ lang === 'fr' ? 'Sécurité & Audit' : 'Security & System Audit' }}
      </button>
    </div>

    <!-- 1. App Configuration Tab Content -->
    <div v-if="activeTab === 'app'" class="page-grid-2 animate-slide-up" style="margin-bottom: 2rem;">
      <!-- Dispatch Settings Card -->
      <div class="card">
        <div class="card-header" style="padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border); text-align: left;">
          <h3 class="text-base font-semibold">{{ lang === 'fr' ? 'Paramètres de répartition (Dispatch)' : 'Dispatch Parameters' }}</h3>
        </div>
        <div class="card-body" style="padding: 1.5rem; text-align: left;">
          <div class="form-group text-left" style="margin-bottom: 1rem;">
            <label class="form-label">{{ lang === 'fr' ? 'Délai d\'auto-répartition (Secondes)' : 'Auto-Dispatch Timeout (Seconds)' }}</label>
            <input v-model.number="appConfig.dispatchTimeout" type="number" class="form-input" />
            <span class="text-xs text-muted" style="margin-top: 4px; display: block;">{{ lang === 'fr' ? 'Temps alloué à un chauffeur pour accepter une demande avant qu\'elle ne soit transmise à un autre.' : 'Time allotted for a driver to accept a request before it cascades.' }}</span>
          </div>

          <div class="form-group text-left" style="margin-bottom: 1rem;">
            <label class="form-label">{{ lang === 'fr' ? 'Rayon de recherche maximal (KM)' : 'Maximum Driver Search Radius (KM)' }}</label>
            <input v-model.number="appConfig.searchRadius" type="number" class="form-input" />
            <span class="text-xs text-muted" style="margin-top: 4px; display: block;">{{ lang === 'fr' ? 'Limite la distance de mise en relation spatiale pour éviter les longs déplacements à vide.' : 'Limits spatial matching distance to avoid driver fatigue.' }}</span>
          </div>

          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Commission de la plateforme (%)' : 'Platform Commission Percentage (%)' }}</label>
            <input v-model.number="appConfig.commissionRate" type="number" class="form-input" />
            <span class="text-xs text-muted" style="margin-top: 4px; display: block;">{{ lang === 'fr' ? 'Frais de commission de base déduits de chaque course terminée.' : 'Base commission fee deducted from completed fare payout.' }}</span>
          </div>
        </div>
      </div>

      <!-- Support Info Card -->
      <div class="card">
        <div class="card-header" style="padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border); text-align: left;">
          <h3 class="text-base font-semibold">{{ lang === 'fr' ? 'Assistance de la plateforme' : 'Platform Support Info' }}</h3>
        </div>
        <div class="card-body" style="padding: 1.5rem; text-align: left;">
          <div class="form-group text-left" style="margin-bottom: 1rem;">
            <label class="form-label">{{ lang === 'fr' ? 'E-mail de support' : 'Support Helpdesk Contact Email' }}</label>
            <input v-model="appConfig.supportEmail" type="email" class="form-input" />
          </div>

          <div class="form-group text-left" style="margin-bottom: 1rem;">
            <label class="form-label">{{ lang === 'fr' ? 'Téléphone d\'assistance' : 'Support Helpline Phone Number' }}</label>
            <input v-model="appConfig.supportPhone" type="text" class="form-input" />
          </div>

          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Langue par défaut' : 'Supported Default Language' }}</label>
            <select v-model="appConfig.defaultLang" class="form-select">
              <option value="fr">{{ lang === 'fr' ? 'Français (Sénégal)' : 'French (Senegal)' }}</option>
              <option value="wo">Wolof</option>
              <option value="en">{{ lang === 'fr' ? 'Anglais' : 'English' }}</option>
            </select>
          </div>
        </div>
      </div>
    </div>

    <!-- 2. Gateway Settings Tab Content -->
    <div v-else-if="activeTab === 'gateways'" class="flex flex-col gap-6 animate-slide-up" style="margin-bottom: 2rem;">
      <div v-for="gw in gateways" :key="gw.id" class="card">
        <div class="card-header flex justify-between items-center flex-wrap gap-4" style="padding: 1rem 1.5rem; border-bottom: 1px solid var(--border); text-align: left;">
          <div>
            <h3 class="text-base font-semibold">{{ gw.name }}</h3>
            <p class="text-xs text-muted">{{ lang === 'fr' ? (gw.id === 'gw_wave' ? 'Prend en charge les paiements locaux par QR-code Wave directement via redirection applicative.' : gw.id === 'gw_orange_money' ? 'Prend en charge les paiements push Orange Money USSD avec invite d\'authentification mobile.' : 'Prend en charge les paiements internationaux par cartes de crédit/débit visa et mastercard.') : gw.desc }}</p>
          </div>
          <!-- Custom Design System Class Switch -->
          <div class="toggle-switch" :class="{ on: gw.enabled }" @click="gw.enabled = !gw.enabled">
            <div class="toggle-knob"></div>
          </div>
        </div>
        
        <div v-if="gw.enabled" class="card-body" style="padding: 1.5rem; text-align: left;">
          <div class="grid grid-cols-2 gap-4 modal-form-grid" style="grid-template-columns: 1fr 1fr;">
            <div class="form-group text-left">
              <label class="form-label">{{ lang === 'fr' ? 'Clé publique de l\'API' : 'Gateway API Public Key' }}</label>
              <input v-model="gw.publicKey" type="text" class="form-input" style="font-family: monospace;" />
            </div>
            <div class="form-group text-left">
              <label class="form-label">{{ lang === 'fr' ? 'Jeton secret de la passerelle' : 'Gateway Secret Token' }}</label>
              <input v-model="gw.secretToken" type="password" class="form-input" placeholder="••••••••••••••••••••••••" />
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 3. Security & System Audit Tab Content -->
    <div v-else class="animate-slide-up" style="margin-bottom: 2rem;">
      <div class="card">
        <div class="card-header" style="padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border); text-align: left;">
          <h3 class="text-base font-semibold">{{ lang === 'fr' ? 'Journaux de sécurité système' : 'Security System Logs' }}</h3>
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
                {{ lang === 'fr' ? (item.severity === 'high' ? 'élevée' : item.severity === 'medium' ? 'moyenne' : 'faible') : item.severity }}
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
import { ref, computed, onMounted } from 'vue'
import { useApi } from '~/composables/useApi'
import { useI18n } from '~/composables/useI18n'

definePageMeta({
  middleware: 'auth',
})

const { t, lang } = useI18n()
const { get, post } = useApi()

const activeTab = ref<'app' | 'gateways' | 'audit'>('app')
const saving = ref(false)
const loading = ref(false)
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
    id: 'gw_orange_money',
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

const auditHeaders = computed(() => [
  { key: 'action', label: lang.value === 'fr' ? 'Action / Événement' : 'Action Event' },
  { key: 'user', label: lang.value === 'fr' ? 'Opérateur Autorisé' : 'Authorized Operator' },
  { key: 'ip', label: 'IP Address' },
  { key: 'severity', label: lang.value === 'fr' ? 'Gravité' : 'Severity' },
  { key: 'timestamp', label: lang.value === 'fr' ? 'Horodatage' : 'Log Timestamp' }
])

async function loadSettings() {
  loading.value = true
  const { data, error } = await get<{ app_config: any; gateways: any[] }>('/admin/settings')
  if (data) {
    if (data.app_config) {
      appConfig.value = { ...appConfig.value, ...data.app_config }
    }
    if (data.gateways && Array.isArray(data.gateways)) {
      data.gateways.forEach((bgw: any) => {
        const localG = gateways.value.find(lg => lg.id === bgw.id)
        if (localG) {
          localG.enabled = bgw.enabled !== undefined ? bgw.enabled : (bgw.is_active !== undefined ? bgw.is_active : localG.enabled)
          localG.publicKey = bgw.publicKey || bgw.public_key || localG.publicKey
          localG.secretToken = bgw.secretToken || bgw.secret_token || localG.secretToken
        }
      })
    }
  }
  loading.value = false
}

async function saveAllSettings() {
  saving.value = true
  saveSuccess.value = false
  
  const payload = {
    app_config: appConfig.value,
    gateways: gateways.value
  }

  const { error } = await post('/admin/settings', payload)
  if (!error) {
    saveSuccess.value = true
    setTimeout(() => {
      saveSuccess.value = false
    }, 5000)
  } else {
    alert(lang.value === 'fr' ? 'Échec de l\'enregistrement : ' + error : 'Failed to save settings: ' + error)
  }
  saving.value = false
}

onMounted(() => {
  loadSettings()
})

function formatDateTime(dateStr: string): string {
  try {
    const d = new Date(dateStr)
    return d.toLocaleString(lang.value === 'fr' ? 'fr-FR' : 'en-US', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit' })
  } catch {
    return dateStr
  }
}
</script>

<style scoped>
.text-left {
  text-align: left;
}

@media (max-width: 640px) {
  .modal-form-grid {
    grid-template-columns: 1fr !important;
    gap: 1rem !important;
  }
  .modal-footer-actions {
    flex-direction: column;
    align-items: stretch;
    gap: 0.5rem !important;
  }
  .modal-footer-actions .btn {
    width: 100%;
  }
}
</style>
