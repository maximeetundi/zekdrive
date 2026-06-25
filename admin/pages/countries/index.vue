<template>
  <div>
    <!-- Header -->
    <div class="page-header animate-fade-in">
      <div>
        <h1 class="page-title">🌍 {{ lang==='fr' ? 'Pays & Tarification' : 'Countries & Pricing' }}</h1>
        <p class="page-desc">{{ lang==='fr' ? 'Sélectionne un pays et configure tous ses paramètres tarifaires' : 'Select a country and configure all pricing parameters' }}</p>
      </div>
    </div>

    <!-- Stats -->
    <div class="stats-grid animate-fade-in" style="grid-template-columns:repeat(4,1fr);margin-bottom:1.5rem;">
      <AppStatsCard :title="lang==='fr'?'Total pays':'Total Countries'" :value="allCountries.length.toString()" icon="🌍" color="blue"/>
      <AppStatsCard :title="lang==='fr'?'Marchés actifs':'Active Markets'" :value="allCountries.filter(c=>c.is_active).length.toString()" icon="✅" color="green"/>
      <AppStatsCard :title="lang==='fr'?'Devises':'Currencies'" :value="uniqueCurrencies.toString()" icon="💱" color="purple"/>
      <AppStatsCard :title="lang==='fr'?'Résultats filtrés':'Filtered'" :value="filteredCountries.length.toString()" icon="🔍" color="orange"/>
    </div>

    <div class="country-layout">
      <!-- ──────────── LEFT PANEL ──────────── -->
      <div class="card country-list-card animate-slide-up">
        <!-- Search + filters -->
        <div class="card-body" style="padding:1rem;border-bottom:1px solid var(--border-color);">
          <input v-model="search" class="form-input" :placeholder="lang==='fr'?'🔍 Rechercher un pays...':'🔍 Search countries...'" style="margin-bottom:0.625rem;"/>
          <div class="flex gap-2" style="flex-wrap:wrap;">
            <button v-for="cont in continents" :key="cont.key" class="filter-chip" :class="{active: continentFilter===cont.key}" @click="continentFilter=continentFilter===cont.key?'':cont.key">
              {{ cont.label }}
            </button>
            <button class="filter-chip" :class="{active: onlyActive}" @click="onlyActive=!onlyActive">
              ✅ {{ lang==='fr'?'Actifs':'Active' }}
            </button>
          </div>
        </div>
        <!-- List -->
        <div class="country-scroll">
          <div v-for="c in filteredCountries" :key="c.code"
            class="country-item" :class="{selected: selectedCode===c.code, active: c.is_active}"
            @click="selectCountry(c)">
            <span class="country-flag">{{ c.flag_emoji }}</span>
            <div class="country-item-info">
              <div class="country-item-name">{{ lang==='fr' ? c.name_fr : c.name_en }}</div>
              <div class="country-item-meta">{{ c.currency_symbol }} {{ c.currency_code }} · {{ c.phone_code }}</div>
            </div>
            <span v-if="c.is_active" class="badge-active-dot" title="Actif">●</span>
          </div>
          <div v-if="filteredCountries.length===0" style="padding:2rem;text-align:center;color:var(--text-muted);font-size:0.85rem;">
            {{ lang==='fr'?'Aucun pays trouvé':'No countries found' }}
          </div>
        </div>
      </div>

      <!-- ──────────── RIGHT PANEL ──────────── -->
      <div class="country-config-panel animate-slide-up">

        <!-- Placeholder si rien sélectionné -->
        <div v-if="!selected" class="card empty-panel">
          <div style="font-size:3rem;">🌐</div>
          <div>{{ lang==='fr'?'Sélectionne un pays à gauche pour configurer ses tarifs':'Select a country on the left to configure pricing' }}</div>
        </div>

        <!-- Config form — toujours accessible même si pays inactif -->
        <div v-else>
          <!-- Country header -->
          <div class="card animate-fade-in" style="margin-bottom:1rem;">
            <div class="card-body">
              <div class="flex items-center gap-4">
                <div style="font-size:3rem;line-height:1;">{{ selected.flag_emoji }}</div>
                <div style="flex:1;">
                  <h2 style="font-size:1.4rem;font-weight:800;color:var(--text-primary);margin:0;">
                    {{ lang==='fr' ? selected.name_fr : selected.name_en }}
                  </h2>
                  <div class="text-muted text-sm">
                    {{ selected.code }} · {{ selected.phone_code }} · {{ lang==='fr' ? selected.currency_name_fr : selected.currency_name_en }} ({{ selected.currency_symbol }} {{ selected.currency_code }})
                  </div>
                </div>
                <div class="flex gap-3 items-center">
                  <div class="flex items-center gap-2">
                    <span class="text-xs text-muted">{{ lang==='fr'?'Actif':'Active' }}</span>
                    <button class="toggle-btn" :class="{on: selected.is_active}" @click="toggleActive">
                      <span class="toggle-knob"/>
                    </button>
                  </div>
                  <button class="btn btn-primary" @click="saveConfig" :disabled="saving" style="min-width:130px;">
                    <span v-if="saving">⏳ {{ lang==='fr'?'Enregistrement...':'Saving...' }}</span>
                    <span v-else>💾 {{ lang==='fr'?'Sauvegarder':'Save' }}</span>
                  </button>
                </div>
              </div>
            </div>
          </div>

          <!-- Note si pays inactif -->
          <div v-if="!selected.is_active" class="inactive-notice animate-fade-in">
            ⚠️ {{ lang==='fr'?'Ce pays est inactif. Configure-le puis active-le pour le rendre disponible sur la plateforme.':'This country is inactive. Configure it then activate it to make it available on the platform.' }}
          </div>

          <!-- Bandeau devise -->
          <div class="currency-box animate-fade-in">
            <div class="currency-symbol-big">{{ selected.currency_symbol }}</div>
            <div>
              <div style="font-weight:700;font-size:1.05rem;">{{ selected.currency_code }}</div>
              <div class="text-sm" style="opacity:.85;">{{ lang==='fr' ? selected.currency_name_fr : selected.currency_name_en }}</div>
              <div class="text-xs" style="opacity:.7;margin-top:.15rem;">{{ lang==='fr'?'Tous les montants en':'All amounts in' }} <strong>{{ selected.currency_code }}</strong></div>
            </div>
          </div>

          <!-- ── 2 colonnes ── -->
          <div v-if="form" class="config-two-col">

            <!-- Colonne gauche -->
            <div class="col-left">

              <!-- 🚗 VTC -->
              <div class="card animate-fade-in">
                <div class="card-body">
                  <div class="config-section-title">🚗 {{ lang==='fr'?'Courses VTC':'Ride Pricing' }}</div>
                  <div class="config-grid">
                    <div class="config-field">
                      <label>{{ lang==='fr'?'Prix de départ':'Base fare' }} ({{ selected.currency_code }})</label>
                      <input v-model.number="form.base_fare" type="number" class="form-input" min="0"/>
                    </div>
                    <div class="config-field">
                      <label>{{ lang==='fr'?'Par km':'Per km' }} ({{ selected.currency_code }})</label>
                      <input v-model.number="form.per_km_rate" type="number" class="form-input" min="0"/>
                    </div>
                    <div class="config-field">
                      <label>{{ lang==='fr'?'Par minute':'Per min' }} ({{ selected.currency_code }})</label>
                      <input v-model.number="form.per_min_rate" type="number" class="form-input" min="0"/>
                    </div>
                    <div class="config-field">
                      <label>{{ lang==='fr'?'Course minimum':'Min fare' }} ({{ selected.currency_code }})</label>
                      <input v-model.number="form.min_fare" type="number" class="form-input" min="0"/>
                    </div>
                    <div class="config-field">
                      <label>{{ lang==='fr'?'Supplément aéroport':'Airport surcharge' }} ({{ selected.currency_code }})</label>
                      <input v-model.number="form.airport_surcharge" type="number" class="form-input" min="0"/>
                    </div>
                  </div>
                </div>
              </div>

              <!-- 🛵 Livraison -->
              <div class="card animate-fade-in">
                <div class="card-body">
                  <div class="config-section-title">🛵 {{ lang==='fr'?'Livraisons':'Deliveries' }}</div>
                  <div class="config-grid">
                    <div class="config-field">
                      <label>{{ lang==='fr'?'Prix de départ':'Base fare' }} ({{ selected.currency_code }})</label>
                      <input v-model.number="form.delivery_base" type="number" class="form-input" min="0"/>
                    </div>
                    <div class="config-field">
                      <label>{{ lang==='fr'?'Par km':'Per km' }} ({{ selected.currency_code }})</label>
                      <input v-model.number="form.delivery_per_km" type="number" class="form-input" min="0"/>
                    </div>
                    <div class="config-field">
                      <label>{{ lang==='fr'?'Minimum livraison':'Min delivery' }} ({{ selected.currency_code }})</label>
                      <input v-model.number="form.delivery_min" type="number" class="form-input" min="0"/>
                    </div>
                  </div>
                </div>
              </div>

              <!-- 💰 Commissions -->
              <div class="card animate-fade-in">
                <div class="card-body">
                  <div class="config-section-title">💰 {{ lang==='fr'?'Commissions plateforme':'Platform Commissions' }}</div>
                  <div class="config-grid">
                    <div class="config-field">
                      <label>{{ lang==='fr'?'Commission courses':'Ride commission' }} (%)</label>
                      <input v-model.number="form.commission_ride" type="number" step="0.5" class="form-input" min="0" max="100"/>
                    </div>
                    <div class="config-field">
                      <label>{{ lang==='fr'?'Commission livraisons':'Delivery commission' }} (%)</label>
                      <input v-model.number="form.commission_delivery" type="number" step="0.5" class="form-input" min="0" max="100"/>
                    </div>
                    <div class="config-field">
                      <label>{{ lang==='fr'?'Commission commerce':'Store commission' }} (%)</label>
                      <input v-model.number="form.commission_store" type="number" step="0.5" class="form-input" min="0" max="100"/>
                    </div>
                    <div class="config-field">
                      <label>{{ lang==='fr'?'Frais service (fixe)':'Service fee (flat)' }} ({{ selected.currency_code }})</label>
                      <input v-model.number="form.service_fee" type="number" class="form-input" min="0"/>
                    </div>
                    <div class="config-field">
                      <label>{{ lang==='fr'?'TVA locale':'Local VAT' }} (%)</label>
                      <input v-model.number="form.vat_rate" type="number" step="0.5" class="form-input" min="0" max="100"/>
                    </div>
                  </div>
                </div>
              </div>

              <!-- 🏆 Bonus chauffeurs -->
              <div class="card animate-fade-in">
                <div class="card-body">
                  <div class="config-section-title">🏆 {{ lang==='fr'?'Bonus chauffeurs (hebdo)':'Driver Weekly Bonuses' }} — {{ selected.currency_code }}</div>
                  <div class="bonus-grid">
                    <div class="bonus-card bronze">
                      <div class="bonus-medal">🥉</div>
                      <div class="bonus-label">Bronze<br><small>50 courses/sem</small></div>
                      <input v-model.number="form.driver_bonus_bronze" type="number" class="form-input bonus-input" min="0" :placeholder="'ex: '+formatAmt(5000)"/>
                    </div>
                    <div class="bonus-card silver">
                      <div class="bonus-medal">🥈</div>
                      <div class="bonus-label">Argent<br><small>100 courses/sem</small></div>
                      <input v-model.number="form.driver_bonus_silver" type="number" class="form-input bonus-input" min="0" :placeholder="'ex: '+formatAmt(12000)"/>
                    </div>
                    <div class="bonus-card gold">
                      <div class="bonus-medal">🥇</div>
                      <div class="bonus-label">Or<br><small>150 courses/sem</small></div>
                      <input v-model.number="form.driver_bonus_gold" type="number" class="form-input bonus-input" min="0" :placeholder="'ex: '+formatAmt(25000)"/>
                    </div>
                  </div>
                </div>
              </div>

            </div><!-- fin col gauche -->

            <!-- Colonne droite -->
            <div class="col-right">

              <!-- 👁️ Aperçu tarif enrichi -->
              <div class="card animate-fade-in preview-sticky">
                <div class="card-body">
                  <div class="config-section-title" style="margin-bottom:.75rem;">👁️ {{ lang==='fr'?'Aperçu — course 5km / 10min':'Preview — 5km / 10min trip' }}</div>
                  <div class="fare-preview">
                    <div class="fare-row"><span>{{ lang==='fr'?'Prise en charge':'Base fare' }}</span><span>{{ formatAmt(form.base_fare) }}</span></div>
                    <div class="fare-row"><span>5 km × {{ formatAmt(form.per_km_rate) }}/km</span><span>{{ formatAmt(5*form.per_km_rate) }}</span></div>
                    <div class="fare-row"><span>10 min × {{ formatAmt(form.per_min_rate) }}/min</span><span>{{ formatAmt(10*form.per_min_rate) }}</span></div>
                    <div class="fare-row fare-row-sep"><span>{{ lang==='fr'?'Sous-total brut':'Gross subtotal' }}</span><span>{{ formatAmt(rawFare) }}</span></div>
                    <div class="fare-row text-muted" v-if="form.vat_rate>0"><span>TVA {{ form.vat_rate }}%</span><span>+ {{ formatAmt(rawFare*form.vat_rate/100) }}</span></div>
                    <div class="fare-row fare-row-sep"><span><strong>{{ lang==='fr'?'Total payé par client':'Client pays' }}</strong></span><span><strong>{{ formatAmt(totalFare) }}</strong></span></div>
                    <div class="fare-row" style="color:#f87171;"><span>ZekDrive {{ form.commission_ride }}%</span><span>− {{ formatAmt(totalFare*form.commission_ride/100) }}</span></div>
                    <div class="fare-row fare-driver">
                      <span>🚗 {{ lang==='fr'?'Chauffeur reçoit':'Driver earns' }}</span>
                      <span>{{ formatAmt(driverEarns) }}</span>
                    </div>
                  </div>
                </div>
              </div>

              <!-- ⚡ Surge -->
              <div class="card animate-fade-in">
                <div class="card-body">
                  <div class="section-title-row">
                    <span class="config-section-title" style="margin:0;">⚡ {{ lang==='fr'?'Majorations (Surge)':'Surge Rules' }}</span>
                    <button class="btn btn-secondary" style="padding:.3rem .8rem;font-size:.75rem;" @click="addSurge">
                      + {{ lang==='fr'?'Ajouter':'Add' }}
                    </button>
                  </div>
                  <div v-if="surgeRules.length===0" class="text-muted text-sm" style="padding:.75rem 0;text-align:center;">
                    {{ lang==='fr'?'Aucune règle. Cliquez + pour en ajouter.':'No rules yet. Click + to add one.' }}
                  </div>
                  <div v-for="(rule,i) in surgeRules" :key="i" class="surge-rule-item">
                    <div class="surge-left">
                      <span class="surge-badge" :class="'surge-'+rule.rule_type">{{ surgeLabel(rule.rule_type) }}</span>
                      <div>
                        <div class="text-sm font-semibold">{{ lang==='fr'?rule.name_fr:rule.name_en }}</div>
                        <div class="text-xs text-muted">{{ rule.schedule }}</div>
                      </div>
                    </div>
                    <div class="surge-right">
                      <span class="surge-mult">×{{ rule.multiplier }}</span>
                      <button class="toggle-btn toggle-sm" :class="{on:rule.is_active}" @click="rule.is_active=!rule.is_active"><span class="toggle-knob"/></button>
                      <button class="btn-icon" @click="surgeRules.splice(i,1)" title="Supprimer">
                        <svg width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <!-- 💳 Paiements -->
              <div class="card animate-fade-in">
                <div class="card-body">
                  <div class="config-section-title">💳 {{ lang==='fr'?'Modes de paiement':'Payment Methods' }}</div>
                  <div style="display:flex;flex-direction:column;gap:.625rem;margin-bottom:.875rem;">
                    <label class="payment-toggle flex items-center gap-3 cursor-pointer">
                      <input type="checkbox" v-model="form.payment_cash"/>
                      <span>💵 {{ lang==='fr'?'Espèces':'Cash' }}</span>
                    </label>
                    <label class="payment-toggle flex items-center gap-3 cursor-pointer">
                      <input type="checkbox" v-model="form.payment_mobile_money"/>
                      <span>📱 Mobile Money</span>
                    </label>
                    <label class="payment-toggle flex items-center gap-3 cursor-pointer">
                      <input type="checkbox" v-model="form.payment_card"/>
                      <span>💳 {{ lang==='fr'?'Carte bancaire':'Card' }}</span>
                    </label>
                  </div>
                  <div class="config-field" v-if="form.payment_mobile_money">
                    <label>{{ lang==='fr'?'Opérateurs Mobile Money (séparés par virgule)':'Mobile Money Operators (comma-separated)' }}</label>
                    <input v-model="form.mobile_money_providers" type="text" class="form-input" placeholder="orange_money,wave,mtn_money,free_money"/>
                  </div>
                </div>
              </div>

              <!-- ⚖️ Légal & notes -->
              <div class="card animate-fade-in">
                <div class="card-body">
                  <div class="config-section-title">⚖️ {{ lang==='fr'?'Légal & lancement':'Legal & Launch' }}</div>
                  <div class="config-grid">
                    <div class="config-field">
                      <label>{{ lang==='fr'?'Âge minimum chauffeur':'Min driver age' }}</label>
                      <input v-model.number="form.driver_age_min" type="number" class="form-input" min="18"/>
                    </div>
                    <div class="config-field">
                      <label>{{ lang==='fr'?'Date de lancement':'Launch date' }}</label>
                      <input v-model="form.launch_date" type="date" class="form-input"/>
                    </div>
                  </div>
                  <div class="config-field" style="margin-top:.75rem;">
                    <label>{{ lang==='fr'?'Notes internes':'Internal notes' }}</label>
                    <textarea v-model="form.notes" class="form-input" rows="2" :placeholder="lang==='fr'?'Notes internes sur ce marché...':'Internal market notes...'"/>
                  </div>
                </div>
              </div>

            </div><!-- fin col droite -->
          </div><!-- fin 2-col -->
        </div><!-- fin v-else selected -->
      </div><!-- fin right panel -->
    </div><!-- fin country-layout -->

    <!-- ── Modal Surge ── -->
    <AppModal :show="showSurgeModal" :title="lang==='fr'?'Nouvelle règle de majoration':'New Surge Rule'" @close="showSurgeModal=false">
      <div style="display:flex;flex-direction:column;gap:.75rem;text-align:left;">
        <div class="config-field"><label>{{ lang==='fr'?'Nom français':'Name (FR)' }}</label><input v-model="newSurge.name_fr" class="form-input" placeholder="Heure de pointe matin"/></div>
        <div class="config-field"><label>{{ lang==='fr'?'Nom anglais':'Name (EN)' }}</label><input v-model="newSurge.name_en" class="form-input" placeholder="Morning Rush Hour"/></div>
        <div class="config-field">
          <label>{{ lang==='fr'?'Type de règle':'Rule type' }}</label>
          <select v-model="newSurge.rule_type" class="form-input">
            <option value="time_of_day">⏰ {{ lang==='fr'?'Heure / Jour de semaine':'Time of day / Weekday' }}</option>
            <option value="weather">🌧️ {{ lang==='fr'?'Conditions météo':'Weather condition' }}</option>
            <option value="holiday">🎉 {{ lang==='fr'?'Fête / Événement spécial':'Holiday / Special event' }}</option>
            <option value="event">📍 {{ lang==='fr'?'Zone géographique / Aéroport':'Geographic zone / Airport' }}</option>
          </select>
        </div>
        <div class="config-field">
          <label>{{ lang==='fr'?'Multiplicateur':'Multiplier' }} (1.0 = normal, 1.5 = +50%, 2.0 = ×2)</label>
          <input v-model.number="newSurge.multiplier" type="number" step="0.05" min="1" max="5" class="form-input"/>
        </div>
        <div class="config-field">
          <label>{{ lang==='fr'?'Planification / description':'Schedule / description' }}</label>
          <input v-model="newSurge.schedule" class="form-input" placeholder="Lun-Ven 07:30-09:30"/>
        </div>
        <div class="flex gap-3 justify-end" style="margin-top:.5rem;">
          <button class="btn btn-secondary" @click="showSurgeModal=false">{{ lang==='fr'?'Annuler':'Cancel' }}</button>
          <button class="btn btn-primary" @click="confirmSurge">{{ lang==='fr'?'Ajouter la règle':'Add Rule' }}</button>
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

interface Country { code:string; code3:string; name_fr:string; name_en:string; currency_code:string; currency_name_fr:string; currency_name_en:string; currency_symbol:string; phone_code:string; flag_emoji:string; continent:string; is_active:boolean }
interface Config { country_code:string; base_fare:number; per_km_rate:number; per_min_rate:number; min_fare:number; airport_surcharge:number; delivery_base:number; delivery_per_km:number; delivery_min:number; commission_ride:number; commission_delivery:number; commission_store:number; service_fee:number; driver_bonus_bronze:number; driver_bonus_silver:number; driver_bonus_gold:number; payment_cash:boolean; payment_mobile_money:boolean; payment_card:boolean; mobile_money_providers:string; vat_rate:number; driver_age_min:number; launch_date:string; notes:string }
interface SurgeRule { name_fr:string; name_en:string; rule_type:string; multiplier:number; schedule:string; is_active:boolean }

const allCountries = ref<Country[]>([])
const selected = ref<Country|null>(null)
const selectedCode = ref('')
const form = ref<Config|null>(null)
const saving = ref(false)
const search = ref('')
const continentFilter = ref('')
const onlyActive = ref(false)
const surgeRules = ref<SurgeRule[]>([])
const showSurgeModal = ref(false)
const newSurge = ref<SurgeRule>({ name_fr:'', name_en:'', rule_type:'time_of_day', multiplier:1.5, schedule:'', is_active:true })

const continents = [
  { key:'Africa',  label:'🌍 Afrique'  },
  { key:'Europe',  label:'🌍 Europe'   },
  { key:'America', label:'🌎 Amérique' },
  { key:'Asia',    label:'🌏 Asie'     },
]

onMounted(async () => {
  const res = await get<Country[]>('/api/admin/countries')
  allCountries.value = (res.data?.length) ? res.data : seedCountries()
})

const uniqueCurrencies = computed(() => new Set(allCountries.value.map(c => c.currency_code)).size)
const filteredCountries = computed(() => allCountries.value.filter(c => {
  if (onlyActive.value && !c.is_active) return false
  if (continentFilter.value && c.continent !== continentFilter.value) return false
  const q = search.value.toLowerCase()
  if (q) return c.name_fr.toLowerCase().includes(q) || c.name_en.toLowerCase().includes(q) || c.code.toLowerCase().includes(q) || c.currency_code.toLowerCase().includes(q)
  return true
}))

// Calculs aperçu
const rawFare = computed(() => {
  if (!form.value) return 0
  return Math.max(form.value.min_fare, form.value.base_fare + 5*form.value.per_km_rate + 10*form.value.per_min_rate)
})
const totalFare = computed(() => {
  if (!form.value) return 0
  return rawFare.value * (1 + form.value.vat_rate/100)
})
const driverEarns = computed(() => {
  if (!form.value) return 0
  return totalFare.value * (1 - form.value.commission_ride/100)
})

async function selectCountry(c: Country) {
  selected.value = c; selectedCode.value = c.code
  surgeRules.value = []
  const res = await get<Config>(`/api/admin/countries/${c.code}/config`)
  form.value = res.data ?? defaultConfig(c.code)
}

async function toggleActive() {
  if (!selected.value) return
  selected.value.is_active = !selected.value.is_active
  await put(`/api/admin/countries/${selected.value.code}/active`, { active: selected.value.is_active })
  const idx = allCountries.value.findIndex(c => c.code === selected.value!.code)
  if (idx !== -1) allCountries.value[idx].is_active = selected.value.is_active
}

async function saveConfig() {
  if (!form.value) return
  saving.value = true
  await put(`/api/admin/countries/${selectedCode.value}/config`, form.value)
  setTimeout(() => saving.value = false, 800)
}

function formatAmt(v: number) {
  if (!selected.value) return v.toFixed(0)
  return new Intl.NumberFormat('fr-FR').format(Math.round(v||0)) + ' ' + selected.value.currency_code
}

function addSurge() {
  newSurge.value = { name_fr:'', name_en:'', rule_type:'time_of_day', multiplier:1.5, schedule:'', is_active:true }
  showSurgeModal.value = true
}
function confirmSurge() {
  if (!newSurge.value.name_fr) return
  surgeRules.value.push({ ...newSurge.value })
  showSurgeModal.value = false
}
function surgeLabel(type: string) {
  const labels: Record<string,string> = { time_of_day:'⏰ Heure', weather:'🌧️ Météo', holiday:'🎉 Fête', event:'📍 Zone' }
  return labels[type] ?? type
}

function defaultConfig(code: string): Config {
  return { country_code:code, base_fare:500, per_km_rate:300, per_min_rate:50, min_fare:500, airport_surcharge:2000, delivery_base:300, delivery_per_km:150, delivery_min:300, commission_ride:20, commission_delivery:18, commission_store:15, service_fee:100, driver_bonus_bronze:5000, driver_bonus_silver:12000, driver_bonus_gold:25000, payment_cash:true, payment_mobile_money:true, payment_card:false, mobile_money_providers:'', vat_rate:18, driver_age_min:21, launch_date:'', notes:'' }
}

function seedCountries(): Country[] {
  return [
    {code:'SN',code3:'SEN',name_fr:'Sénégal',name_en:'Senegal',currency_code:'XOF',currency_name_fr:'Franc CFA UEMOA',currency_name_en:'West African CFA',currency_symbol:'XOF',phone_code:'+221',flag_emoji:'🇸🇳',continent:'Africa',is_active:true},
    {code:'CI',code3:'CIV',name_fr:"Côte d'Ivoire",name_en:'Ivory Coast',currency_code:'XOF',currency_name_fr:'Franc CFA UEMOA',currency_name_en:'West African CFA',currency_symbol:'XOF',phone_code:'+225',flag_emoji:'🇨🇮',continent:'Africa',is_active:true},
    {code:'ML',code3:'MLI',name_fr:'Mali',name_en:'Mali',currency_code:'XOF',currency_name_fr:'Franc CFA UEMOA',currency_name_en:'West African CFA',currency_symbol:'XOF',phone_code:'+223',flag_emoji:'🇲🇱',continent:'Africa',is_active:false},
    {code:'BF',code3:'BFA',name_fr:'Burkina Faso',name_en:'Burkina Faso',currency_code:'XOF',currency_name_fr:'Franc CFA UEMOA',currency_name_en:'West African CFA',currency_symbol:'XOF',phone_code:'+226',flag_emoji:'🇧🇫',continent:'Africa',is_active:false},
    {code:'GN',code3:'GIN',name_fr:'Guinée',name_en:'Guinea',currency_code:'GNF',currency_name_fr:'Franc guinéen',currency_name_en:'Guinean Franc',currency_symbol:'GNF',phone_code:'+224',flag_emoji:'🇬🇳',continent:'Africa',is_active:false},
    {code:'GW',code3:'GNB',name_fr:'Guinée-Bissau',name_en:'Guinea-Bissau',currency_code:'XOF',currency_name_fr:'Franc CFA UEMOA',currency_name_en:'West African CFA',currency_symbol:'XOF',phone_code:'+245',flag_emoji:'🇬🇼',continent:'Africa',is_active:false},
    {code:'TG',code3:'TGO',name_fr:'Togo',name_en:'Togo',currency_code:'XOF',currency_name_fr:'Franc CFA UEMOA',currency_name_en:'West African CFA',currency_symbol:'XOF',phone_code:'+228',flag_emoji:'🇹🇬',continent:'Africa',is_active:false},
    {code:'BJ',code3:'BEN',name_fr:'Bénin',name_en:'Benin',currency_code:'XOF',currency_name_fr:'Franc CFA UEMOA',currency_name_en:'West African CFA',currency_symbol:'XOF',phone_code:'+229',flag_emoji:'🇧🇯',continent:'Africa',is_active:false},
    {code:'NE',code3:'NER',name_fr:'Niger',name_en:'Niger',currency_code:'XOF',currency_name_fr:'Franc CFA UEMOA',currency_name_en:'West African CFA',currency_symbol:'XOF',phone_code:'+227',flag_emoji:'🇳🇪',continent:'Africa',is_active:false},
    {code:'MR',code3:'MRT',name_fr:'Mauritanie',name_en:'Mauritania',currency_code:'MRU',currency_name_fr:'Ouguiya',currency_name_en:'Mauritanian Ouguiya',currency_symbol:'MRU',phone_code:'+222',flag_emoji:'🇲🇷',continent:'Africa',is_active:false},
    {code:'CM',code3:'CMR',name_fr:'Cameroun',name_en:'Cameroon',currency_code:'XAF',currency_name_fr:'Franc CFA CEMAC',currency_name_en:'CFA Franc BEAC',currency_symbol:'XAF',phone_code:'+237',flag_emoji:'🇨🇲',continent:'Africa',is_active:true},
    {code:'CG',code3:'COG',name_fr:'Congo (Rép.)',name_en:'Congo Republic',currency_code:'XAF',currency_name_fr:'Franc CFA CEMAC',currency_name_en:'CFA Franc BEAC',currency_symbol:'XAF',phone_code:'+242',flag_emoji:'🇨🇬',continent:'Africa',is_active:false},
    {code:'GA',code3:'GAB',name_fr:'Gabon',name_en:'Gabon',currency_code:'XAF',currency_name_fr:'Franc CFA CEMAC',currency_name_en:'CFA Franc BEAC',currency_symbol:'XAF',phone_code:'+241',flag_emoji:'🇬🇦',continent:'Africa',is_active:false},
    {code:'TD',code3:'TCD',name_fr:'Tchad',name_en:'Chad',currency_code:'XAF',currency_name_fr:'Franc CFA CEMAC',currency_name_en:'CFA Franc BEAC',currency_symbol:'XAF',phone_code:'+235',flag_emoji:'🇹🇩',continent:'Africa',is_active:false},
    {code:'CF',code3:'CAF',name_fr:'Centrafrique',name_en:'C.A.R.',currency_code:'XAF',currency_name_fr:'Franc CFA CEMAC',currency_name_en:'CFA Franc BEAC',currency_symbol:'XAF',phone_code:'+236',flag_emoji:'🇨🇫',continent:'Africa',is_active:false},
    {code:'GQ',code3:'GNQ',name_fr:'Guinée Équatoriale',name_en:'Equatorial Guinea',currency_code:'XAF',currency_name_fr:'Franc CFA CEMAC',currency_name_en:'CFA Franc BEAC',currency_symbol:'XAF',phone_code:'+240',flag_emoji:'🇬🇶',continent:'Africa',is_active:false},
    {code:'NG',code3:'NGA',name_fr:'Nigéria',name_en:'Nigeria',currency_code:'NGN',currency_name_fr:'Naira',currency_name_en:'Nigerian Naira',currency_symbol:'₦',phone_code:'+234',flag_emoji:'🇳🇬',continent:'Africa',is_active:false},
    {code:'GH',code3:'GHA',name_fr:'Ghana',name_en:'Ghana',currency_code:'GHS',currency_name_fr:'Cedi',currency_name_en:'Ghanaian Cedi',currency_symbol:'₵',phone_code:'+233',flag_emoji:'🇬🇭',continent:'Africa',is_active:false},
    {code:'SL',code3:'SLE',name_fr:'Sierra Leone',name_en:'Sierra Leone',currency_code:'SLE',currency_name_fr:'Leone',currency_name_en:'Leone',currency_symbol:'Le',phone_code:'+232',flag_emoji:'🇸🇱',continent:'Africa',is_active:false},
    {code:'LR',code3:'LBR',name_fr:'Libéria',name_en:'Liberia',currency_code:'LRD',currency_name_fr:'Dollar libérien',currency_name_en:'Liberian Dollar',currency_symbol:'L$',phone_code:'+231',flag_emoji:'🇱🇷',continent:'Africa',is_active:false},
    {code:'GM',code3:'GMB',name_fr:'Gambie',name_en:'Gambia',currency_code:'GMD',currency_name_fr:'Dalasi',currency_name_en:'Gambian Dalasi',currency_symbol:'D',phone_code:'+220',flag_emoji:'🇬🇲',continent:'Africa',is_active:false},
    {code:'CV',code3:'CPV',name_fr:'Cap-Vert',name_en:'Cape Verde',currency_code:'CVE',currency_name_fr:'Escudo',currency_name_en:'Cape Verdean Escudo',currency_symbol:'Esc',phone_code:'+238',flag_emoji:'🇨🇻',continent:'Africa',is_active:false},
    {code:'MA',code3:'MAR',name_fr:'Maroc',name_en:'Morocco',currency_code:'MAD',currency_name_fr:'Dirham marocain',currency_name_en:'Moroccan Dirham',currency_symbol:'MAD',phone_code:'+212',flag_emoji:'🇲🇦',continent:'Africa',is_active:false},
    {code:'DZ',code3:'DZA',name_fr:'Algérie',name_en:'Algeria',currency_code:'DZD',currency_name_fr:'Dinar algérien',currency_name_en:'Algerian Dinar',currency_symbol:'DA',phone_code:'+213',flag_emoji:'🇩🇿',continent:'Africa',is_active:false},
    {code:'TN',code3:'TUN',name_fr:'Tunisie',name_en:'Tunisia',currency_code:'TND',currency_name_fr:'Dinar tunisien',currency_name_en:'Tunisian Dinar',currency_symbol:'DT',phone_code:'+216',flag_emoji:'🇹🇳',continent:'Africa',is_active:false},
    {code:'EG',code3:'EGY',name_fr:'Égypte',name_en:'Egypt',currency_code:'EGP',currency_name_fr:'Livre égyptienne',currency_name_en:'Egyptian Pound',currency_symbol:'E£',phone_code:'+20',flag_emoji:'🇪🇬',continent:'Africa',is_active:false},
    {code:'LY',code3:'LBY',name_fr:'Libye',name_en:'Libya',currency_code:'LYD',currency_name_fr:'Dinar libyen',currency_name_en:'Libyan Dinar',currency_symbol:'LD',phone_code:'+218',flag_emoji:'🇱🇾',continent:'Africa',is_active:false},
    {code:'KE',code3:'KEN',name_fr:'Kenya',name_en:'Kenya',currency_code:'KES',currency_name_fr:'Shilling kényan',currency_name_en:'Kenyan Shilling',currency_symbol:'KSh',phone_code:'+254',flag_emoji:'🇰🇪',continent:'Africa',is_active:false},
    {code:'TZ',code3:'TZA',name_fr:'Tanzanie',name_en:'Tanzania',currency_code:'TZS',currency_name_fr:'Shilling tanzanien',currency_name_en:'Tanzanian Shilling',currency_symbol:'TSh',phone_code:'+255',flag_emoji:'🇹🇿',continent:'Africa',is_active:false},
    {code:'UG',code3:'UGA',name_fr:'Ouganda',name_en:'Uganda',currency_code:'UGX',currency_name_fr:'Shilling ougandais',currency_name_en:'Ugandan Shilling',currency_symbol:'USh',phone_code:'+256',flag_emoji:'🇺🇬',continent:'Africa',is_active:false},
    {code:'RW',code3:'RWA',name_fr:'Rwanda',name_en:'Rwanda',currency_code:'RWF',currency_name_fr:'Franc rwandais',currency_name_en:'Rwandan Franc',currency_symbol:'RF',phone_code:'+250',flag_emoji:'🇷🇼',continent:'Africa',is_active:false},
    {code:'ET',code3:'ETH',name_fr:'Éthiopie',name_en:'Ethiopia',currency_code:'ETB',currency_name_fr:'Birr éthiopien',currency_name_en:'Ethiopian Birr',currency_symbol:'Br',phone_code:'+251',flag_emoji:'🇪🇹',continent:'Africa',is_active:false},
    {code:'SO',code3:'SOM',name_fr:'Somalie',name_en:'Somalia',currency_code:'SOS',currency_name_fr:'Shilling somalien',currency_name_en:'Somali Shilling',currency_symbol:'Sh',phone_code:'+252',flag_emoji:'🇸🇴',continent:'Africa',is_active:false},
    {code:'DJ',code3:'DJI',name_fr:'Djibouti',name_en:'Djibouti',currency_code:'DJF',currency_name_fr:'Franc djiboutien',currency_name_en:'Djiboutian Franc',currency_symbol:'Fdj',phone_code:'+253',flag_emoji:'🇩🇯',continent:'Africa',is_active:false},
    {code:'SD',code3:'SDN',name_fr:'Soudan',name_en:'Sudan',currency_code:'SDG',currency_name_fr:'Livre soudanaise',currency_name_en:'Sudanese Pound',currency_symbol:'SDG',phone_code:'+249',flag_emoji:'🇸🇩',continent:'Africa',is_active:false},
    {code:'SS',code3:'SSD',name_fr:'Soudan du Sud',name_en:'South Sudan',currency_code:'SSP',currency_name_fr:'Livre sud-soud.',currency_name_en:'S. Sudanese Pound',currency_symbol:'SSP',phone_code:'+211',flag_emoji:'🇸🇸',continent:'Africa',is_active:false},
    {code:'BI',code3:'BDI',name_fr:'Burundi',name_en:'Burundi',currency_code:'BIF',currency_name_fr:'Franc burundais',currency_name_en:'Burundian Franc',currency_symbol:'Fr',phone_code:'+257',flag_emoji:'🇧🇮',continent:'Africa',is_active:false},
    {code:'ER',code3:'ERI',name_fr:'Érythrée',name_en:'Eritrea',currency_code:'ERN',currency_name_fr:'Nakfa',currency_name_en:'Eritrean Nakfa',currency_symbol:'Nfk',phone_code:'+291',flag_emoji:'🇪🇷',continent:'Africa',is_active:false},
    {code:'ZA',code3:'ZAF',name_fr:'Afrique du Sud',name_en:'South Africa',currency_code:'ZAR',currency_name_fr:'Rand',currency_name_en:'South African Rand',currency_symbol:'R',phone_code:'+27',flag_emoji:'🇿🇦',continent:'Africa',is_active:false},
    {code:'AO',code3:'AGO',name_fr:'Angola',name_en:'Angola',currency_code:'AOA',currency_name_fr:'Kwanza',currency_name_en:'Angolan Kwanza',currency_symbol:'Kz',phone_code:'+244',flag_emoji:'🇦🇴',continent:'Africa',is_active:false},
    {code:'MZ',code3:'MOZ',name_fr:'Mozambique',name_en:'Mozambique',currency_code:'MZN',currency_name_fr:'Metical',currency_name_en:'Mozambican Metical',currency_symbol:'MT',phone_code:'+258',flag_emoji:'🇲🇿',continent:'Africa',is_active:false},
    {code:'CD',code3:'COD',name_fr:'Congo (RDC)',name_en:'Congo DRC',currency_code:'CDF',currency_name_fr:'Franc congolais',currency_name_en:'Congolese Franc',currency_symbol:'FC',phone_code:'+243',flag_emoji:'🇨🇩',continent:'Africa',is_active:false},
    {code:'ZM',code3:'ZMB',name_fr:'Zambie',name_en:'Zambia',currency_code:'ZMW',currency_name_fr:'Kwacha zambien',currency_name_en:'Zambian Kwacha',currency_symbol:'ZK',phone_code:'+260',flag_emoji:'🇿🇲',continent:'Africa',is_active:false},
    {code:'ZW',code3:'ZWE',name_fr:'Zimbabwe',name_en:'Zimbabwe',currency_code:'USD',currency_name_fr:'Dollar US',currency_name_en:'US Dollar',currency_symbol:'$',phone_code:'+263',flag_emoji:'🇿🇼',continent:'Africa',is_active:false},
    {code:'MW',code3:'MWI',name_fr:'Malawi',name_en:'Malawi',currency_code:'MWK',currency_name_fr:'Kwacha malawien',currency_name_en:'Malawian Kwacha',currency_symbol:'MK',phone_code:'+265',flag_emoji:'🇲🇼',continent:'Africa',is_active:false},
    {code:'BW',code3:'BWA',name_fr:'Botswana',name_en:'Botswana',currency_code:'BWP',currency_name_fr:'Pula',currency_name_en:'Botswana Pula',currency_symbol:'P',phone_code:'+267',flag_emoji:'🇧🇼',continent:'Africa',is_active:false},
    {code:'NA',code3:'NAM',name_fr:'Namibie',name_en:'Namibia',currency_code:'NAD',currency_name_fr:'Dollar namibien',currency_name_en:'Namibian Dollar',currency_symbol:'N$',phone_code:'+264',flag_emoji:'🇳🇦',continent:'Africa',is_active:false},
    {code:'MG',code3:'MDG',name_fr:'Madagascar',name_en:'Madagascar',currency_code:'MGA',currency_name_fr:'Ariary',currency_name_en:'Malagasy Ariary',currency_symbol:'Ar',phone_code:'+261',flag_emoji:'🇲🇬',continent:'Africa',is_active:false},
    {code:'MU',code3:'MUS',name_fr:'Maurice (Île)',name_en:'Mauritius',currency_code:'MUR',currency_name_fr:'Roupie mauricienne',currency_name_en:'Mauritian Rupee',currency_symbol:'₨',phone_code:'+230',flag_emoji:'🇲🇺',continent:'Africa',is_active:false},
    {code:'FR',code3:'FRA',name_fr:'France',name_en:'France',currency_code:'EUR',currency_name_fr:'Euro',currency_name_en:'Euro',currency_symbol:'€',phone_code:'+33',flag_emoji:'🇫🇷',continent:'Europe',is_active:false},
    {code:'BE',code3:'BEL',name_fr:'Belgique',name_en:'Belgium',currency_code:'EUR',currency_name_fr:'Euro',currency_name_en:'Euro',currency_symbol:'€',phone_code:'+32',flag_emoji:'🇧🇪',continent:'Europe',is_active:false},
    {code:'CH',code3:'CHE',name_fr:'Suisse',name_en:'Switzerland',currency_code:'CHF',currency_name_fr:'Franc suisse',currency_name_en:'Swiss Franc',currency_symbol:'CHF',phone_code:'+41',flag_emoji:'🇨🇭',continent:'Europe',is_active:false},
    {code:'DE',code3:'DEU',name_fr:'Allemagne',name_en:'Germany',currency_code:'EUR',currency_name_fr:'Euro',currency_name_en:'Euro',currency_symbol:'€',phone_code:'+49',flag_emoji:'🇩🇪',continent:'Europe',is_active:false},
    {code:'GB',code3:'GBR',name_fr:'Royaume-Uni',name_en:'United Kingdom',currency_code:'GBP',currency_name_fr:'Livre sterling',currency_name_en:'British Pound',currency_symbol:'£',phone_code:'+44',flag_emoji:'🇬🇧',continent:'Europe',is_active:false},
    {code:'ES',code3:'ESP',name_fr:'Espagne',name_en:'Spain',currency_code:'EUR',currency_name_fr:'Euro',currency_name_en:'Euro',currency_symbol:'€',phone_code:'+34',flag_emoji:'🇪🇸',continent:'Europe',is_active:false},
    {code:'IT',code3:'ITA',name_fr:'Italie',name_en:'Italy',currency_code:'EUR',currency_name_fr:'Euro',currency_name_en:'Euro',currency_symbol:'€',phone_code:'+39',flag_emoji:'🇮🇹',continent:'Europe',is_active:false},
    {code:'PT',code3:'PRT',name_fr:'Portugal',name_en:'Portugal',currency_code:'EUR',currency_name_fr:'Euro',currency_name_en:'Euro',currency_symbol:'€',phone_code:'+351',flag_emoji:'🇵🇹',continent:'Europe',is_active:false},
    {code:'NL',code3:'NLD',name_fr:'Pays-Bas',name_en:'Netherlands',currency_code:'EUR',currency_name_fr:'Euro',currency_name_en:'Euro',currency_symbol:'€',phone_code:'+31',flag_emoji:'🇳🇱',continent:'Europe',is_active:false},
    {code:'US',code3:'USA',name_fr:'États-Unis',name_en:'United States',currency_code:'USD',currency_name_fr:'Dollar américain',currency_name_en:'US Dollar',currency_symbol:'$',phone_code:'+1',flag_emoji:'🇺🇸',continent:'America',is_active:false},
    {code:'CA',code3:'CAN',name_fr:'Canada',name_en:'Canada',currency_code:'CAD',currency_name_fr:'Dollar canadien',currency_name_en:'Canadian Dollar',currency_symbol:'C$',phone_code:'+1',flag_emoji:'🇨🇦',continent:'America',is_active:false},
    {code:'BR',code3:'BRA',name_fr:'Brésil',name_en:'Brazil',currency_code:'BRL',currency_name_fr:'Réal brésilien',currency_name_en:'Brazilian Real',currency_symbol:'R$',phone_code:'+55',flag_emoji:'🇧🇷',continent:'America',is_active:false},
    {code:'MX',code3:'MEX',name_fr:'Mexique',name_en:'Mexico',currency_code:'MXN',currency_name_fr:'Peso mexicain',currency_name_en:'Mexican Peso',currency_symbol:'$',phone_code:'+52',flag_emoji:'🇲🇽',continent:'America',is_active:false},
    {code:'HT',code3:'HTI',name_fr:'Haïti',name_en:'Haiti',currency_code:'HTG',currency_name_fr:'Gourde',currency_name_en:'Haitian Gourde',currency_symbol:'G',phone_code:'+509',flag_emoji:'🇭🇹',continent:'America',is_active:false},
    {code:'AE',code3:'ARE',name_fr:'Émirats Arabes Unis',name_en:'UAE',currency_code:'AED',currency_name_fr:'Dirham des EAU',currency_name_en:'UAE Dirham',currency_symbol:'AED',phone_code:'+971',flag_emoji:'🇦🇪',continent:'Asia',is_active:false},
    {code:'SA',code3:'SAU',name_fr:'Arabie Saoudite',name_en:'Saudi Arabia',currency_code:'SAR',currency_name_fr:'Riyal saoudien',currency_name_en:'Saudi Riyal',currency_symbol:'SAR',phone_code:'+966',flag_emoji:'🇸🇦',continent:'Asia',is_active:false},
    {code:'CN',code3:'CHN',name_fr:'Chine',name_en:'China',currency_code:'CNY',currency_name_fr:'Yuan',currency_name_en:'Chinese Yuan',currency_symbol:'¥',phone_code:'+86',flag_emoji:'🇨🇳',continent:'Asia',is_active:false},
    {code:'IN',code3:'IND',name_fr:'Inde',name_en:'India',currency_code:'INR',currency_name_fr:'Roupie indienne',currency_name_en:'Indian Rupee',currency_symbol:'₹',phone_code:'+91',flag_emoji:'🇮🇳',continent:'Asia',is_active:false},
    {code:'JP',code3:'JPN',name_fr:'Japon',name_en:'Japan',currency_code:'JPY',currency_name_fr:'Yen',currency_name_en:'Japanese Yen',currency_symbol:'¥',phone_code:'+81',flag_emoji:'🇯🇵',continent:'Asia',is_active:false},
  ]
}
</script>

<style scoped>
.country-layout { display:grid; grid-template-columns:300px 1fr; gap:1.5rem; align-items:start; }

/* Left */
.country-list-card { position:sticky; top:1rem; }
.country-scroll { max-height:calc(100vh - 360px); overflow-y:auto; scrollbar-width:thin; }
.country-item { display:flex; align-items:center; gap:.75rem; padding:.7rem 1rem; cursor:pointer; transition:var(--transition); border-bottom:1px solid var(--border-color); }
.country-item:hover { background:var(--bg-card-hover); }
.country-item.selected { background:rgba(20,177,158,0.1); border-left:3px solid var(--accent-primary); }
.country-flag { font-size:1.4rem; flex-shrink:0; }
.country-item-info { flex:1; min-width:0; }
.country-item-name { font-size:.85rem; font-weight:600; color:var(--text-primary); white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.country-item-meta { font-size:.72rem; color:var(--text-muted); }
.badge-active-dot { color:#10b981; font-size:.9rem; }
.filter-chip { padding:.25rem .625rem; border-radius:999px; font-size:.72rem; font-weight:600; background:var(--bg-card-hover); border:1px solid var(--border-color); color:var(--text-muted); cursor:pointer; transition:all .15s; }
.filter-chip.active { background:rgba(20,177,158,.15); border-color:rgba(20,177,158,.4); color:var(--accent-primary); }

/* Right */
.empty-panel { height:300px; display:flex; align-items:center; justify-content:center; flex-direction:column; gap:1rem; color:var(--text-muted); font-size:.9rem; }
.inactive-notice { background:rgba(251,191,36,.1); border:1px solid rgba(251,191,36,.3); color:#d97706; border-radius:var(--radius-sm); padding:.75rem 1rem; font-size:.82rem; margin-bottom:1rem; }
.currency-box { display:flex; align-items:center; gap:1rem; background:var(--accent-gradient); border-radius:var(--radius-sm); padding:1rem 1.25rem; margin-bottom:1rem; color:#fff; }
.currency-symbol-big { font-size:2.5rem; font-weight:900; opacity:.9; }

/* 2 colonnes config */
.config-two-col { display:grid; grid-template-columns:1fr 1fr; gap:1rem; align-items:start; }
.col-left, .col-right { display:flex; flex-direction:column; gap:1rem; }

.config-section-title { font-size:.78rem; font-weight:700; text-transform:uppercase; letter-spacing:.06em; color:var(--text-muted); margin-bottom:.875rem; }
.config-grid { display:grid; grid-template-columns:repeat(auto-fill, minmax(180px,1fr)); gap:.75rem; }
.config-field label { display:block; font-size:.75rem; font-weight:600; color:var(--text-muted); margin-bottom:.325rem; }

/* Toggle */
.toggle-btn { width:46px; height:24px; border-radius:999px; border:none; cursor:pointer; background:var(--border-color); position:relative; transition:background .2s; flex-shrink:0; }
.toggle-btn.on { background:var(--accent-primary); }
.toggle-knob { position:absolute; top:2px; left:2px; width:20px; height:20px; border-radius:50%; background:#fff; transition:transform .2s; display:block; }
.toggle-btn.on .toggle-knob { transform:translateX(22px); }
.toggle-sm { width:36px; height:18px; }
.toggle-sm .toggle-knob { width:14px; height:14px; top:2px; left:2px; }
.toggle-sm.on .toggle-knob { transform:translateX(18px); }

/* Bonus */
.bonus-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:.75rem; }
.bonus-card { display:flex; flex-direction:column; align-items:center; gap:.4rem; padding:.875rem .5rem; border-radius:var(--radius-sm); border:1px solid var(--border-color); background:var(--bg-card-hover); }
.bonus-card.bronze { border-color:rgba(205,127,50,.4); }
.bonus-card.silver { border-color:rgba(192,192,192,.4); }
.bonus-card.gold { border-color:rgba(255,215,0,.4); }
.bonus-medal { font-size:1.6rem; }
.bonus-label { font-size:.72rem; font-weight:600; color:var(--text-muted); text-align:center; line-height:1.4; }
.bonus-input { text-align:center; font-size:.82rem; padding:.35rem .5rem !important; }

/* Fare preview */
.preview-sticky { position:sticky; top:1rem; }
.fare-preview { background:var(--bg-card-hover); border-radius:var(--radius-sm); padding:.875rem; }
.fare-row { display:flex; justify-content:space-between; padding:.3rem 0; font-size:.83rem; border-bottom:1px solid var(--border-color); color:var(--text-secondary); }
.fare-row:last-child { border-bottom:none; }
.fare-row-sep { font-weight:700; color:var(--text-primary); border-top:2px solid var(--border-color); padding-top:.5rem; margin-top:.2rem; }
.fare-driver { color:var(--accent-primary); font-weight:800; font-size:.95rem; margin-top:.2rem; }

/* Surge */
.section-title-row { display:flex; justify-content:space-between; align-items:center; margin-bottom:.875rem; }
.surge-rule-item { display:flex; justify-content:space-between; align-items:center; padding:.6rem 0; border-bottom:1px solid var(--border-color); }
.surge-rule-item:last-child { border-bottom:none; }
.surge-left { display:flex; align-items:center; gap:.625rem; }
.surge-right { display:flex; align-items:center; gap:.5rem; }
.surge-badge { font-size:.68rem; font-weight:700; padding:.15rem .45rem; border-radius:999px; white-space:nowrap; }
.surge-time_of_day { background:rgba(99,102,241,.15); color:#818cf8; }
.surge-weather { background:rgba(59,130,246,.15); color:#60a5fa; }
.surge-holiday { background:rgba(245,158,11,.15); color:#fbbf24; }
.surge-event { background:rgba(20,177,158,.15); color:var(--accent-primary); }
.surge-mult { font-size:.8rem; font-weight:800; color:var(--accent-primary); }
.btn-icon { background:none; border:none; color:var(--text-muted); cursor:pointer; padding:.25rem; transition:color .15s; }
.btn-icon:hover { color:#ef4444; }

/* Paiements */
.payment-toggle { font-size:.85rem; color:var(--text-secondary); }
.payment-toggle input[type=checkbox] { accent-color:var(--accent-primary); width:15px; height:15px; }

/* Fix mode clair */
.form-input, input[type=number], input[type=text], input[type=date], select, textarea {
  background-color: var(--bg-input, var(--bg-card-hover)) !important;
  color: var(--text-primary) !important;
  border-color: var(--border-color) !important;
}
select option, select optgroup {
  background-color: var(--bg-input, #fff) !important;
  color: var(--text-primary, #111) !important;
}

@media (max-width: 1200px) { .config-two-col { grid-template-columns:1fr; } }
@media (max-width: 768px) { .country-layout { grid-template-columns:1fr; } }
</style>
