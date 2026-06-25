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
      <button class="tab-item" :class="{ active: activeTab === 'auth' }" @click="activeTab = 'auth'">
        {{ lang === 'fr' ? 'Authentification & OTP' : 'Auth & OTP Settings' }}
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

    <!-- Auth & OTP Settings Tab Content -->
    <div v-else-if="activeTab === 'auth'" class="flex flex-col gap-6 animate-slide-up" style="margin-bottom: 2rem;">
      <!-- Providers Enable Card -->
      <div class="card">
        <div class="card-header" style="padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border); text-align: left;">
          <h3 class="text-base font-semibold">{{ lang === 'fr' ? 'Méthodes de connexion autorisées' : 'Allowed Authentication Methods' }}</h3>
        </div>
        <div class="card-body" style="padding: 1.5rem; text-align: left;">
          <div style="display: flex; flex-direction: column; gap: 1rem;">
            <!-- Email & Password -->
            <div style="display: flex; justify-content: space-between; align-items: center;">
              <div>
                <h4 class="text-sm font-medium">{{ lang === 'fr' ? 'Email & Mot de passe' : 'Email & Password Authentication' }}</h4>
                <p class="text-xs text-muted">{{ lang === 'fr' ? 'Permet aux utilisateurs de se connecter via Email/Password standard.' : 'Allows users to sign in using standard email and password credentials.' }}</p>
              </div>
              <div class="toggle-switch" :class="{ on: authConfig.email_password_enabled }" @click="authConfig.email_password_enabled = !authConfig.email_password_enabled">
                <div class="toggle-knob"></div>
              </div>
            </div>
            <!-- WhatsApp OTP -->
            <div style="display: flex; justify-content: space-between; align-items: center; border-top: 1px solid var(--border); padding-top: 1rem;">
              <div>
                <h4 class="text-sm font-medium">{{ lang === 'fr' ? 'WhatsApp OTP (Sans mot de passe)' : 'WhatsApp OTP (Passwordless)' }}</h4>
                <p class="text-xs text-muted">{{ lang === 'fr' ? 'Envoie un code OTP à 6 chiffres via WhatsApp (OpenWA).' : 'Sends a 6-digit OTP code to the user\'s WhatsApp phone number.' }}</p>
              </div>
              <div class="toggle-switch" :class="{ on: authConfig.whatsapp_enabled }" @click="authConfig.whatsapp_enabled = !authConfig.whatsapp_enabled">
                <div class="toggle-knob"></div>
              </div>
            </div>
            <!-- SMS OTP -->
            <div style="display: flex; justify-content: space-between; align-items: center; border-top: 1px solid var(--border); padding-top: 1rem;">
              <div>
                <h4 class="text-sm font-medium">{{ lang === 'fr' ? 'SMS OTP (Téléphone classique)' : 'SMS OTP (Classic Mobile)' }}</h4>
                <p class="text-xs text-muted">{{ lang === 'fr' ? 'Envoie un code OTP par SMS via Twilio ou Nexmo.' : 'Sends a classic SMS OTP code using Twilio or Nexmo API gateways.' }}</p>
              </div>
              <div class="toggle-switch" :class="{ on: authConfig.sms_enabled }" @click="authConfig.sms_enabled = !authConfig.sms_enabled">
                <div class="toggle-knob"></div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- WhatsApp Gateway Details -->
      <div v-if="authConfig.whatsapp_enabled" class="card animate-slide-up">
        <div class="card-header" style="padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border); text-align: left;">
          <h3 class="text-base font-semibold">{{ lang === 'fr' ? 'Configuration OpenWA WhatsApp Gateway' : 'OpenWA WhatsApp Gateway Configuration' }}</h3>
        </div>
        <div class="card-body" style="padding: 1.5rem; text-align: left;">
          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1rem;" class="modal-form-grid">
            <div class="form-group text-left">
              <label class="form-label">{{ lang === 'fr' ? 'URL du serveur OpenWA' : 'OpenWA Server URL' }}</label>
              <input v-model="authConfig.whatsapp_url" type="text" class="form-input" placeholder="http://openwa-api:2785" />
            </div>
            <div class="form-group text-left">
              <label class="form-label">{{ lang === 'fr' ? 'ID de Session OpenWA' : 'OpenWA Session ID' }}</label>
              <input v-model="authConfig.whatsapp_session_id" type="text" class="form-input" placeholder="Session-UUID-Here" />
            </div>
          </div>
          <div class="form-group text-left">
            <label class="form-label">{{ lang === 'fr' ? 'Clé API OpenWA (x-api-key)' : 'OpenWA API Key (x-api-key)' }}</label>
            <input v-model="authConfig.whatsapp_api_key" type="password" class="form-input" placeholder="••••••••••••••••••••••••" />
          </div>
        </div>
      </div>

      <!-- SMTP Gateway Details -->
      <div v-if="authConfig.email_password_enabled" class="card animate-slide-up">
        <div class="card-header" style="padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border); text-align: left;">
          <h3 class="text-base font-semibold">{{ lang === 'fr' ? 'Configuration Serveur SMTP (E-mail)' : 'SMTP Mail Server Configuration' }}</h3>
        </div>
        <div class="card-body" style="padding: 1.5rem; text-align: left;">
          <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 1rem; margin-bottom: 1rem;" class="modal-form-grid">
            <div class="form-group text-left">
              <label class="form-label">{{ lang === 'fr' ? 'Hôte SMTP' : 'SMTP Server Hostname' }}</label>
              <input v-model="authConfig.smtp_host" type="text" class="form-input" placeholder="smtp.mailtrap.io" />
            </div>
            <div class="form-group text-left">
              <label class="form-label">{{ lang === 'fr' ? 'Port SMTP' : 'SMTP Port' }}</label>
              <input v-model.number="authConfig.smtp_port" type="number" class="form-input" placeholder="2525" />
            </div>
          </div>
          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1rem;" class="modal-form-grid">
            <div class="form-group text-left">
              <label class="form-label">{{ lang === 'fr' ? 'Nom d\'utilisateur' : 'SMTP Auth Username' }}</label>
              <input v-model="authConfig.smtp_user" type="text" class="form-input" />
            </div>
            <div class="form-group text-left">
              <label class="form-label">{{ lang === 'fr' ? 'Mot de passe SMTP' : 'SMTP Auth Password' }}</label>
              <input v-model="authConfig.smtp_password" type="password" class="form-input" placeholder="••••••••••••" />
            </div>
          </div>
          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1rem;" class="modal-form-grid">
            <div class="form-group text-left">
              <label class="form-label">{{ lang === 'fr' ? 'E-mail d\'expédition (From Email)' : 'From Email Address' }}</label>
              <input v-model="authConfig.smtp_from_email" type="email" class="form-input" placeholder="support@zekdrive.com" />
            </div>
            <div class="form-group text-left">
              <label class="form-label">{{ lang === 'fr' ? 'Nom d\'expédition (From Name)' : 'From Name' }}</label>
              <input v-model="authConfig.smtp_from_name" type="text" class="form-input" placeholder="ZekDrive Support" />
            </div>
          </div>
          <div class="form-group text-left" style="display: flex; align-items: center; gap: 0.5rem; margin-top: 0.5rem;">
            <input v-model="authConfig.smtp_use_tls" type="checkbox" id="smtp_use_tls" style="width: 18px; height: 18px; accent-color: var(--primary);" />
            <label for="smtp_use_tls" class="form-label" style="margin: 0; cursor: pointer;">{{ lang === 'fr' ? 'Utiliser SSL/TLS (Sécurité requise)' : 'Use SSL/TLS Security' }}</label>
          </div>
        </div>
      </div>

      <!-- SMS Gateway Details -->
      <div v-if="authConfig.sms_enabled" class="card animate-slide-up">
        <div class="card-header" style="padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border); text-align: left;">
          <h3 class="text-base font-semibold">{{ lang === 'fr' ? 'Configuration Passerelle SMS' : 'SMS API Gateway Configuration' }}</h3>
        </div>
        <div class="card-body" style="padding: 1.5rem; text-align: left;">
          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1rem;" class="modal-form-grid">
            <div class="form-group text-left">
              <label class="form-label">{{ lang === 'fr' ? 'Fournisseur SMS' : 'SMS Provider Gateway' }}</label>
              <select v-model="authConfig.sms_provider" class="form-select">
                <option value="twilio">Twilio SMS API</option>
                <option value="nexmo">Vonage / Nexmo API</option>
              </select>
            </div>
            <div class="form-group text-left">
              <label class="form-label">{{ lang === 'fr' ? 'Numéro d\'expéditeur / ID' : 'SMS Sender Phone / ID' }}</label>
              <input v-model="authConfig.sms_sender" type="text" class="form-input" placeholder="+1234567890" />
            </div>
          </div>
          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;" class="modal-form-grid">
            <div class="form-group text-left">
              <label class="form-label">{{ lang === 'fr' ? 'Clé API / SID Compte' : 'SMS API Key / Account SID' }}</label>
              <input v-model="authConfig.sms_api_key" type="text" class="form-input" />
            </div>
            <div class="form-group text-left">
              <label class="form-label">{{ lang === 'fr' ? 'Secret API / Jeton d\'authentification' : 'SMS API Secret / Auth Token' }}</label>
              <input v-model="authConfig.sms_api_secret" type="password" class="form-input" placeholder="••••••••••••••••••••••••" />
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

const activeTab = ref<'app' | 'gateways' | 'auth' | 'audit'>('app')
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

// Auth Configuration state
const authConfig = ref({
  sms_enabled: false,
  whatsapp_enabled: true,
  email_password_enabled: true,
  smtp_host: 'smtp.ionos.fr',
  smtp_port: 465,
  smtp_user: 'send-email@rodriguendeffo.com',
  smtp_password: 'MdpDev55647913@#',
  smtp_from_email: 'send-email@rodriguendeffo.com',
  smtp_from_name: 'ZekDrive Support',
  smtp_use_tls: true,
  whatsapp_url: 'http://openwa-api:2785',
  whatsapp_session_id: 'bdcc38d6-840f-4fce-b0b6-8365063d7fc4',
  whatsapp_api_key: 'owa_k1_eee56788a1354467c70629006b57db1e97c8f4988d4f8bab1cb415faf2067d5e',
  sms_provider: 'twilio',
  sms_api_key: '',
  sms_api_secret: '',
  sms_sender: '+1234567890'
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
  const { data, error } = await get<{ app_config: any; gateways: any[]; auth_config: any }>('/admin/settings')
  if (data) {
    if (data.app_config) {
      appConfig.value = { ...appConfig.value, ...data.app_config }
    }
    if (data.auth_config) {
      authConfig.value = { ...authConfig.value, ...data.auth_config }
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
    gateways: gateways.value,
    auth_config: authConfig.value
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
