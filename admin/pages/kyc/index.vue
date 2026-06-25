<template>
  <div>
    <!-- Header -->
    <div class="page-header animate-fade-in">
      <div>
        <h1 class="page-title">🛡️ {{ lang === 'fr' ? 'Vérification KYC' : 'KYC Verification' }}</h1>
        <p class="page-desc">{{ lang === 'fr' ? 'Validation des pièces d\'identité — utilisateurs, chauffeurs et véhicules' : 'Identity document validation — users, drivers and vehicles' }}</p>
      </div>
      <div class="page-actions">
        <select v-model="entityFilter" class="form-input" style="width:auto;padding:0.5rem 1rem;">
          <option value="">{{ lang === 'fr' ? 'Tous les types' : 'All types' }}</option>
          <option value="user">👤 {{ lang === 'fr' ? 'Utilisateurs' : 'Users' }}</option>
          <option value="driver">🚗 {{ lang === 'fr' ? 'Chauffeurs' : 'Drivers' }}</option>
          <option value="vehicle">🚙 {{ lang === 'fr' ? 'Véhicules' : 'Vehicles' }}</option>
        </select>
        <select v-model="statusFilter" class="form-input" style="width:auto;padding:0.5rem 1rem;">
          <option value="">{{ lang === 'fr' ? 'Tous les statuts' : 'All statuses' }}</option>
          <option value="pending">⏳ {{ lang === 'fr' ? 'En attente' : 'Pending' }}</option>
          <option value="approved">✅ {{ lang === 'fr' ? 'Approuvé' : 'Approved' }}</option>
          <option value="rejected">❌ {{ lang === 'fr' ? 'Rejeté' : 'Rejected' }}</option>
          <option value="unsubmitted">📭 {{ lang === 'fr' ? 'Non soumis' : 'Unsubmitted' }}</option>
        </select>
      </div>
    </div>

    <!-- Stats -->
    <div class="stats-grid animate-fade-in" style="grid-template-columns:repeat(5,1fr);margin-bottom:2rem;">
      <AppStatsCard :title="lang==='fr'?'Total dossiers':'Total Dossiers'" :value="items.length.toString()" icon="📋" color="blue"/>
      <AppStatsCard :title="lang==='fr'?'En attente':'Pending'" :value="countByStatus('pending').toString()" icon="⏳" color="orange"/>
      <AppStatsCard :title="lang==='fr'?'Approuvés':'Approved'" :value="countByStatus('approved').toString()" icon="✅" color="green"/>
      <AppStatsCard :title="lang==='fr'?'Rejetés':'Rejected'" :value="countByStatus('rejected').toString()" icon="❌" color="red"/>
      <AppStatsCard :title="lang==='fr'?'Non soumis':'Unsubmitted'" :value="countByStatus('unsubmitted').toString()" icon="📭" color="purple"/>
    </div>

    <!-- KYC Table -->
    <div class="card animate-slide-up">
      <div class="card-body" style="padding:0;">
        <table class="kyc-table">
          <thead>
            <tr>
              <th>{{ lang==='fr'?'Entité':'Entity' }}</th>
              <th>{{ lang==='fr'?'Type':'Type' }}</th>
              <th>{{ lang==='fr'?'Document':'Document' }}</th>
              <th>{{ lang==='fr'?'Pays':'Country' }}</th>
              <th>{{ lang==='fr'?'Soumis le':'Submitted' }}</th>
              <th>{{ lang==='fr'?'Statut KYC':'KYC Status' }}</th>
              <th style="text-align:right;">Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in filteredItems" :key="item.id" class="kyc-row">
              <!-- Entité -->
              <td>
                <div class="flex items-center gap-3">
                  <div class="avatar-sm">{{ item.name?.charAt(0).toUpperCase() }}</div>
                  <div>
                    <div class="font-semibold text-primary">{{ item.name }}</div>
                    <div class="text-xs text-muted">{{ item.email }}</div>
                  </div>
                </div>
              </td>
              <!-- Type -->
              <td>
                <span class="entity-badge" :class="'entity-' + item.entity_type">
                  {{ entityLabel(item.entity_type) }}
                </span>
              </td>
              <!-- Document -->
              <td>
                <div style="font-size:0.825rem;">
                  <div class="font-semibold">{{ lang==='fr' ? item.doc_type_fr : item.doc_type_en }}</div>
                  <div class="text-xs text-muted font-mono">{{ item.doc_number }}</div>
                </div>
              </td>
              <!-- Pays -->
              <td>
                <span class="text-lg">{{ countryFlag(item.country) }}</span>
                <span class="text-xs font-semibold" style="margin-left:4px;">{{ item.country }}</span>
              </td>
              <!-- Date -->
              <td class="text-muted text-sm">{{ formatDate(item.submitted_at) }}</td>
              <!-- Statut -->
              <td><AppStatusBadge :status="item.kyc_status" /></td>
              <!-- Actions -->
              <td style="text-align:right;">
                <div class="flex gap-2 justify-end">
                  <button class="btn btn-secondary btn-sm" @click="openDetail(item)">
                    {{ lang==='fr'?'Voir':'View' }}
                  </button>
                  <button v-if="item.kyc_status==='pending'" class="btn btn-sm btn-approve" @click="approve(item)">
                    ✅ {{ lang==='fr'?'Approuver':'Approve' }}
                  </button>
                  <button v-if="item.kyc_status==='pending'" class="btn btn-sm btn-reject" @click="openReject(item)">
                    ❌ {{ lang==='fr'?'Rejeter':'Reject' }}
                  </button>
                </div>
              </td>
            </tr>
            <tr v-if="filteredItems.length===0">
              <td colspan="7" style="text-align:center;padding:3rem;color:var(--text-muted);">
                {{ lang==='fr'?'Aucun dossier KYC trouvé':'No KYC dossiers found' }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Detail Modal -->
    <AppModal :show="!!selected" :title="lang==='fr'?'Dossier KYC':'KYC Dossier'" @close="selected=null">
      <div v-if="selected" style="text-align:left;">
        <!-- Profile row -->
        <div class="flex items-center gap-4" style="margin-bottom:1.5rem;padding-bottom:1rem;border-bottom:1px solid var(--border-color);">
          <div class="avatar-lg">{{ selected.name?.charAt(0).toUpperCase() }}</div>
          <div>
            <div class="font-semibold text-primary" style="font-size:1.1rem;">{{ selected.name }}</div>
            <div class="text-sm text-muted">{{ selected.email }}</div>
            <div class="text-xs text-muted">{{ selected.phone }}</div>
          </div>
          <div style="margin-left:auto;">
            <AppStatusBadge :status="selected.kyc_status" />
          </div>
        </div>

        <!-- Doc info grid -->
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:1rem;margin-bottom:1.5rem;">
          <div class="info-block">
            <div class="info-label">{{ lang==='fr'?'Type de document':'Document Type' }}</div>
            <div class="info-value">{{ lang==='fr' ? selected.doc_type_fr : selected.doc_type_en }}</div>
          </div>
          <div class="info-block">
            <div class="info-label">{{ lang==='fr'?'Numéro de document':'Document Number' }}</div>
            <div class="info-value font-mono">{{ selected.doc_number }}</div>
          </div>
          <div class="info-block">
            <div class="info-label">{{ lang==='fr'?'Pays émetteur':'Issuing Country' }}</div>
            <div class="info-value">{{ countryFlag(selected.country) }} {{ countryName(selected.country) }}</div>
          </div>
          <div class="info-block">
            <div class="info-label">{{ lang==='fr'?'Date de soumission':'Submission Date' }}</div>
            <div class="info-value">{{ formatDate(selected.submitted_at) }}</div>
          </div>
          <div v-if="selected.expiry_date" class="info-block">
            <div class="info-label">{{ lang==='fr'?'Expiration document':'Document Expiry' }}</div>
            <div class="info-value">{{ selected.expiry_date }}</div>
          </div>
          <div v-if="selected.entity_type==='vehicle'" class="info-block">
            <div class="info-label">{{ lang==='fr'?'Véhicule':'Vehicle' }}</div>
            <div class="info-value">{{ selected.vehicle_info }}</div>
          </div>
        </div>

        <!-- Document preview -->
        <div style="margin-bottom:1.5rem;">
          <div class="info-label" style="margin-bottom:0.5rem;">{{ lang==='fr'?'Document scanné / photo':'Scanned Document' }}</div>
          <div class="doc-preview-placeholder">
            <div style="font-size:3rem;margin-bottom:0.5rem;">📄</div>
            <div class="text-muted text-sm">{{ selected.doc_number }}.jpg</div>
            <button class="btn btn-secondary btn-sm" style="margin-top:0.75rem;">
              {{ lang==='fr'?'Télécharger':'Download' }}
            </button>
          </div>
        </div>

        <!-- Reject reason if rejected -->
        <div v-if="selected.kyc_status==='rejected' && selected.reject_reason" style="margin-bottom:1rem;" class="reject-info">
          <div class="info-label">{{ lang==='fr'?'Raison du rejet':'Rejection Reason' }}</div>
          <div class="text-sm" style="color:#ef4444;margin-top:0.25rem;">{{ selected.reject_reason }}</div>
        </div>

        <!-- Actions -->
        <div v-if="selected.kyc_status==='pending'" class="flex gap-3 justify-end" style="margin-top:1rem;">
          <button class="btn btn-approve" @click="approve(selected); selected=null">✅ {{ lang==='fr'?'Approuver':'Approve' }}</button>
          <button class="btn btn-reject" @click="openReject(selected); selected=null">❌ {{ lang==='fr'?'Rejeter':'Reject' }}</button>
        </div>
      </div>
    </AppModal>

    <!-- Reject Modal -->
    <AppModal :show="showRejectModal" :title="lang==='fr'?'Motif de rejet':'Rejection Reason'" @close="showRejectModal=false">
      <div style="text-align:left;">
        <p class="text-sm text-muted" style="margin-bottom:1rem;">
          {{ lang==='fr'?'Indiquer au demandeur pourquoi son dossier a été rejeté :':'Provide the applicant with the reason for rejection:' }}
        </p>
        <div style="display:flex;flex-direction:column;gap:0.5rem;margin-bottom:1rem;">
          <label v-for="reason in rejectReasons" :key="reason.key" class="reject-option" :class="{'reject-option-selected': rejectReason===reason[lang==='fr'?'fr':'en']}" @click="rejectReason=reason[lang==='fr'?'fr':'en']">
            {{ reason[lang==='fr'?'fr':'en'] }}
          </label>
        </div>
        <textarea v-model="rejectReason" class="form-input" rows="3" :placeholder="lang==='fr'?'Ou saisir un motif personnalisé...':'Or enter a custom reason...'" style="margin-bottom:1rem;"/>
        <div class="flex gap-3 justify-end">
          <button class="btn btn-secondary" @click="showRejectModal=false">{{ lang==='fr'?'Annuler':'Cancel' }}</button>
          <button class="btn btn-reject" :disabled="!rejectReason" @click="confirmReject">{{ lang==='fr'?'Confirmer le rejet':'Confirm Rejection' }}</button>
        </div>
      </div>
    </AppModal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useI18n } from '~/composables/useI18n'
import { useApi } from '~/composables/useApi'

definePageMeta({ middleware: 'auth' })

const { lang } = useI18n()
const { get, put } = useApi()

const entityFilter = ref('')
const statusFilter = ref('')
const selected = ref<any>(null)
const showRejectModal = ref(false)
const rejectingItem = ref<any>(null)
const rejectReason = ref('')

interface KycItem {
  id: string; name: string; email: string; phone: string;
  entity_type: 'user' | 'driver' | 'vehicle';
  doc_type_fr: string; doc_type_en: string; doc_number: string;
  country: string; submitted_at: string; kyc_status: string;
  expiry_date?: string; vehicle_info?: string; reject_reason?: string;
}

const items = ref<KycItem[]>([
  { id:'k1', name:'Ibrahima Diallo', email:'ibra@mail.sn', phone:'+221771234567', entity_type:'user', doc_type_fr:"Carte Nationale d'Identité", doc_type_en:'National ID Card', doc_number:'SN-7821-4432', country:'SN', submitted_at: new Date(Date.now()-86400000).toISOString(), kyc_status:'pending' },
  { id:'k2', name:'Cheikh Fall', email:'cheikh.fall@mail.sn', phone:'+221785556677', entity_type:'driver', doc_type_fr:'Permis de conduire', doc_type_en:"Driver's License", doc_number:'DL-221-9983', country:'SN', submitted_at: new Date(Date.now()-172800000).toISOString(), kyc_status:'approved' },
  { id:'k3', name:'Véhicule DK-4521-A (Cheikh Fall)', email:'cheikh.fall@mail.sn', phone:'+221785556677', entity_type:'vehicle', doc_type_fr:'Carte Grise', doc_type_en:'Vehicle Registration', doc_number:'DK-4521-A', country:'SN', submitted_at: new Date(Date.now()-172800000).toISOString(), kyc_status:'approved', vehicle_info:'Toyota Corolla 2020 Blanc', expiry_date:'2027-06-30' },
  { id:'k4', name:'Moussa Kouyaté', email:'moussa.k@mail.ci', phone:'+2250787654321', entity_type:'driver', doc_type_fr:'Permis de conduire', doc_type_en:"Driver's License", doc_number:'CI-DRV-44521', country:'CI', submitted_at: new Date(Date.now()-3600000).toISOString(), kyc_status:'pending' },
  { id:'k5', name:'Fatou Camara', email:'fatou.c@mail.ml', phone:'+22376111222', entity_type:'user', doc_type_fr:'Passeport', doc_type_en:'Passport', doc_number:'ML-8899-12', country:'ML', submitted_at: new Date(Date.now()-604800000).toISOString(), kyc_status:'rejected', reject_reason:'Document expiré — la date de validité est dépassée.' },
  { id:'k6', name:'Abdoulaye Seck', email:'a.seck@mail.sn', phone:'+221706543210', entity_type:'driver', doc_type_fr:'Permis de conduire', doc_type_en:"Driver's License", doc_number:'DL-221-7721', country:'SN', submitted_at: new Date(Date.now()-43200000).toISOString(), kyc_status:'pending' },
  { id:'k7', name:'Véhicule DK-9877-B (Abdoulaye Seck)', email:'a.seck@mail.sn', phone:'+221706543210', entity_type:'vehicle', doc_type_fr:"Certificat d'assurance", doc_type_en:'Insurance Certificate', doc_number:'INS-DK-2026-B', country:'SN', submitted_at: new Date(Date.now()-43200000).toISOString(), kyc_status:'pending', vehicle_info:'Renault Logan 2019 Gris', expiry_date:'2026-12-31' },
  { id:'k8', name:'Mariama Ba', email:'mari.ba@mail.sn', phone:'+221779988776', entity_type:'user', doc_type_fr:"Carte Nationale d'Identité", doc_type_en:'National ID Card', doc_number:'SN-5534-8812', country:'SN', submitted_at: new Date(Date.now()-1209600000).toISOString(), kyc_status:'unsubmitted' },
])

onMounted(async () => {
  const res = await get<KycItem[]>('/api/admin/kyc')
  if (res.data && res.data.length) items.value = res.data
})

const filteredItems = computed(() => items.value.filter(i => {
  if (entityFilter.value && i.entity_type !== entityFilter.value) return false
  if (statusFilter.value && i.kyc_status !== statusFilter.value) return false
  return true
}))

const countByStatus = (s: string) => items.value.filter(i => i.kyc_status === s).length

function entityLabel(type: string) {
  const m: Record<string, string[]> = {
    user: ['👤 Utilisateur', '👤 User'],
    driver: ['🚗 Chauffeur', '🚗 Driver'],
    vehicle: ['🚙 Véhicule', '🚙 Vehicle'],
  }
  return (m[type] ?? ['🔹 Autre', '🔹 Other'])[lang.value === 'fr' ? 0 : 1]
}

function countryFlag(code: string) {
  const flags: Record<string,string> = { SN:'🇸🇳', CI:'🇨🇮', ML:'🇲🇱', GN:'🇬🇳', BF:'🇧🇫', TG:'🇹🇬', BJ:'🇧🇯', NE:'🇳🇪', MR:'🇲🇷', GW:'🇬🇼' }
  return flags[code] ?? '🌍'
}

function countryName(code: string) {
  const names: Record<string,string[]> = {
    SN:['Sénégal','Senegal'], CI:["Côte d'Ivoire","Ivory Coast"], ML:['Mali','Mali'],
    GN:['Guinée','Guinea'], BF:['Burkina Faso','Burkina Faso'], TG:['Togo','Togo'],
    BJ:['Bénin','Benin'], NE:['Niger','Niger'], MR:['Mauritanie','Mauritania']
  }
  return (names[code] ?? ['Inconnu','Unknown'])[lang.value === 'fr' ? 0 : 1]
}

function formatDate(d: string) {
  if (!d) return '—'
  return new Date(d).toLocaleString(lang.value === 'fr' ? 'fr-FR' : 'en-GB', { dateStyle: 'medium', timeStyle: 'short' })
}

function openDetail(item: any) { selected.value = item }

async function approve(item: any) {
  await put(`/api/admin/kyc/${item.id}/approve`, {})
  const idx = items.value.findIndex(i => i.id === item.id)
  if (idx !== -1) items.value[idx].kyc_status = 'approved'
}

function openReject(item: any) { rejectingItem.value = item; rejectReason.value = ''; showRejectModal.value = true }

async function confirmReject() {
  if (!rejectingItem.value) return
  await put(`/api/admin/kyc/${rejectingItem.value.id}/reject`, { reason: rejectReason.value })
  const idx = items.value.findIndex(i => i.id === rejectingItem.value!.id)
  if (idx !== -1) { items.value[idx].kyc_status = 'rejected'; items.value[idx].reject_reason = rejectReason.value }
  showRejectModal.value = false
  rejectingItem.value = null
}

const rejectReasons = [
  { key:'expired',    fr:'Document expiré — la date de validité est dépassée.',         en:'Document expired — validity date has passed.' },
  { key:'blurry',     fr:'Document illisible — photo floue ou mal cadrée.',               en:'Unreadable document — blurry or poorly framed photo.' },
  { key:'mismatch',   fr:'Données non concordantes — le nom ne correspond pas au profil.', en:'Data mismatch — name does not match the profile.' },
  { key:'fake',       fr:'Document suspicieux ou falsifié.',                               en:'Suspicious or potentially forged document.' },
  { key:'incomplete', fr:'Dossier incomplet — documents manquants.',                       en:'Incomplete dossier — missing documents.' },
]
</script>

<style scoped>
.kyc-table { width:100%; border-collapse:collapse; }
.kyc-table th { padding:0.875rem 1.25rem; text-align:left; font-size:0.72rem; font-weight:700; text-transform:uppercase; letter-spacing:.05em; color:var(--text-muted); border-bottom:1px solid var(--border-color); }
.kyc-row td { padding:0.875rem 1.25rem; border-bottom:1px solid var(--border-color); font-size:0.875rem; vertical-align:middle; }
.kyc-row:last-child td { border-bottom:none; }
.kyc-row:hover { background:var(--bg-card-hover); }

.entity-badge { padding:0.25rem 0.625rem; border-radius:999px; font-size:0.72rem; font-weight:600; white-space:nowrap; }
.entity-user    { background:rgba(59,130,246,0.12); color:#3b82f6; border:1px solid rgba(59,130,246,0.25); }
.entity-driver  { background:rgba(20,177,158,0.12); color:var(--accent-primary); border:1px solid rgba(20,177,158,0.25); }
.entity-vehicle { background:rgba(245,158,11,0.12); color:#f59e0b; border:1px solid rgba(245,158,11,0.25); }

.avatar-sm { width:34px; height:34px; border-radius:50%; background:var(--accent-gradient); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:700; font-size:0.875rem; flex-shrink:0; }
.avatar-lg { width:52px; height:52px; border-radius:50%; background:var(--accent-gradient); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:700; font-size:1.25rem; flex-shrink:0; }

.info-block { background:var(--bg-card-hover); border-radius:var(--radius-sm); padding:0.75rem 1rem; }
.info-label { font-size:0.7rem; font-weight:700; text-transform:uppercase; letter-spacing:.06em; color:var(--text-muted); margin-bottom:0.25rem; }
.info-value { font-size:0.875rem; font-weight:600; color:var(--text-primary); }

.doc-preview-placeholder { border:2px dashed var(--border-color); border-radius:var(--radius-sm); padding:2rem; text-align:center; background:var(--bg-card-hover); }
.reject-info { background:rgba(239,68,68,0.07); border:1px solid rgba(239,68,68,0.2); border-radius:var(--radius-sm); padding:0.75rem 1rem; }

.btn-approve { background:rgba(16,185,129,0.12); color:#10b981; border:1px solid rgba(16,185,129,0.3); }
.btn-approve:hover { background:rgba(16,185,129,0.22); }
.btn-reject  { background:rgba(239,68,68,0.10); color:#ef4444; border:1px solid rgba(239,68,68,0.25); }
.btn-reject:hover { background:rgba(239,68,68,0.20); }

.reject-option { display:block; padding:0.6rem 0.875rem; border-radius:var(--radius-sm); border:1px solid var(--border-color); cursor:pointer; font-size:0.8rem; color:var(--text-secondary); transition:all .15s; margin-bottom:0.25rem; }
.reject-option:hover { background:var(--bg-card-hover); border-color:var(--accent-primary); }
.reject-option-selected { background:rgba(239,68,68,0.08); border-color:rgba(239,68,68,0.4); color:#ef4444; }
</style>
