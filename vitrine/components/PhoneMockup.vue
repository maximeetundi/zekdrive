<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { useLanguage } from '~/composables/useLanguage'

const props = defineProps<{
  forceMode?: 'vtc' | 'delivery'
}>()

const { currentLang, t } = useLanguage()
const localActiveTab = ref<'vtc' | 'delivery'>('vtc')

const activeTab = computed(() => {
  return props.forceMode || localActiveTab.value
})

let intervalId: ReturnType<typeof setInterval>

function switchTab(tab: 'vtc' | 'delivery') {
  if (props.forceMode) return
  localActiveTab.value = tab
  resetAutoplay()
}

function startAutoplay() {
  if (props.forceMode) return
  intervalId = setInterval(() => {
    localActiveTab.value = localActiveTab.value === 'vtc' ? 'delivery' : 'vtc'
  }, 6000)
}

function resetAutoplay() {
  if (intervalId) clearInterval(intervalId)
  startAutoplay()
}

onMounted(() => {
  startAutoplay()
})

onUnmounted(() => {
  if (intervalId) clearInterval(intervalId)
})
</script>

<template>
  <div class="phone-wrapper">
    <!-- App Tabs (HTML overlay inside phone screen, hidden if forceMode is active) -->
    <div v-if="!forceMode" class="phone-tabs">
      <button @click="switchTab('vtc')" :class="{ active: activeTab === 'vtc' }">
        🚗 VTC
      </button>
      <button @click="switchTab('delivery')" :class="{ active: activeTab === 'delivery' }">
        📦 {{ t('mockup.delivery_tab') }}
      </button>
    </div>

    <!-- Phone Shell SVG -->
    <svg
      width="280"
      height="560"
      viewBox="0 0 280 560"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <!-- Phone frame - Premium Light Silver/Titanium Metallic -->
      <rect x="8" y="8" width="264" height="544" rx="40" fill="url(#phoneGrad)" stroke="url(#frameGrad)" stroke-width="1.5"/>
      
      <!-- Screen area (Light Background) -->
      <rect x="16" y="16" width="248" height="528" rx="34" fill="#f8fafc"/>
      
      <!-- Notch/Camera island -->
      <rect x="100" y="24" width="80" height="24" rx="12" fill="#0f172a"/>
      <circle cx="156" cy="36" r="5" fill="#1e293b"/>
      <circle cx="156" cy="36" r="2.5" fill="#0f172a"/>

      <!-- Status bar -->
      <text x="32" y="44" font-family="Inter,sans-serif" font-weight="600" font-size="11" fill="#0f172a">9:41</text>
      <g transform="translate(206, 34)" fill="#0f172a">
        <!-- Signal strength -->
        <rect x="0" y="6" width="3" height="4" rx="0.5"/>
        <rect x="5" y="4" width="3" height="6" rx="0.5"/>
        <rect x="10" y="2" width="3" height="8" rx="0.5"/>
        <rect x="15" y="0" width="3" height="10" rx="0.5"/>
        <!-- Battery -->
        <rect x="22" y="1" width="18" height="9" rx="2" stroke="#0f172a" stroke-width="1" fill="none"/>
        <rect x="24" y="3" width="11" height="5" rx="0.5"/>
      </g>

      <!-- App Header Area -->
      <g transform="translate(16, 58)">
        <rect x="0" y="0" width="248" height="48" fill="#ffffff" />
        <line x1="0" y1="48" x2="248" y2="48" stroke="#e2e8f0" stroke-width="1" />
        
        <!-- Animated Title depending on Tab & Language -->
        <text v-if="activeTab === 'vtc'" x="16" y="30" font-family="Sora,sans-serif" font-weight="700" font-size="14" fill="#0f172a">
          {{ t('mockup.vtc_title') }}
        </text>
        <text v-else x="16" y="30" font-family="Sora,sans-serif" font-weight="700" font-size="14" fill="#0f172a">
          {{ t('mockup.delivery_title') }}
        </text>

        <!-- Service Tag -->
        <rect x="176" y="11" width="56" height="22" rx="11" fill="#14b19e" fill-opacity="0.1" stroke="#14b19e" stroke-width="1"/>
        <text x="204" y="26" font-family="Inter,sans-serif" font-weight="600" font-size="10" fill="#00735f" text-anchor="middle">
          {{ activeTab === 'vtc' ? 'VTC' : 'PRO' }}
        </text>
      </g>

      <!-- Map Area Background (Warm light beige Google Map style) -->
      <rect x="16" y="106" width="248" height="300" fill="#f4f3f0"/>

      <!-- Map Elements: River and Park -->
      <path d="M 16 130 Q 120 110, 180 150 T 264 160" stroke="#aad3df" stroke-width="16" fill="none" opacity="0.8" />
      <rect x="162" y="202" width="38" height="46" rx="6" fill="#d2ecd4" />
      
      <!-- Map Grid Lines (Streets - White with proper spacing) -->
      <!-- Horizontal streets -->
      <line x1="16" y1="190" x2="264" y2="190" stroke="#ffffff" stroke-width="8"/>
      <line x1="16" y1="260" x2="264" y2="260" stroke="#ffffff" stroke-width="8"/>
      <line x1="16" y1="340" x2="264" y2="340" stroke="#ffffff" stroke-width="10"/>
      
      <!-- Vertical streets -->
      <line x1="80" y1="106" x2="80" y2="406" stroke="#ffffff" stroke-width="10"/>
      <line x1="150" y1="106" x2="150" y2="406" stroke="#ffffff" stroke-width="8"/>
      <line x1="210" y1="106" x2="210" y2="406" stroke="#ffffff" stroke-width="10"/>

      <!-- Stylized building blocks -->
      <rect x="24" y="114" width="48" height="60" rx="4" fill="rgba(15, 23, 42, 0.03)" stroke="rgba(15, 23, 42, 0.05)"/>
      <rect x="92" y="114" width="48" height="60" rx="4" fill="rgba(15, 23, 42, 0.03)" stroke="rgba(15, 23, 42, 0.05)"/>
      <rect x="218" y="114" width="38" height="60" rx="4" fill="rgba(15, 23, 42, 0.02)" stroke="rgba(15, 23, 42, 0.04)"/>

      <rect x="24" y="202" width="48" height="46" rx="4" fill="rgba(15, 23, 42, 0.02)" stroke="rgba(15, 23, 42, 0.04)"/>
      <rect x="92" y="202" width="48" height="46" rx="4" fill="rgba(15, 23, 42, 0.03)" stroke="rgba(15, 23, 42, 0.05)"/>

      <rect x="24" y="272" width="48" height="56" rx="4" fill="rgba(15, 23, 42, 0.03)" stroke="rgba(15, 23, 42, 0.05)"/>
      <rect x="92" y="272" width="48" height="56" rx="4" fill="rgba(15, 23, 42, 0.02)" stroke="rgba(15, 23, 42, 0.04)"/>
      <rect x="162" y="272" width="38" height="56" rx="4" fill="rgba(15, 23, 42, 0.03)" stroke="rgba(15, 23, 42, 0.05)"/>

      <!-- ============================================================
           ANIMATION 1: VTC RIDE HAILING (🚗)
           ============================================================ -->
      <g v-if="activeTab === 'vtc'">
        <!-- Route path -->
        <path
          d="M 80 340 L 80 260 L 150 260 L 150 190 L 210 190"
          stroke="url(#vtcRouteGrad)"
          stroke-width="5"
          stroke-linecap="round"
          stroke-linejoin="round"
          fill="none"
          stroke-dasharray="6 3"
        />
        <path
          d="M 80 340 L 80 260 L 150 260 L 150 190 L 210 190"
          stroke="url(#vtcRouteGrad)"
          stroke-width="8"
          stroke-linecap="round"
          stroke-linejoin="round"
          fill="none"
          opacity="0.2"
        />

        <!-- Pickup pin -->
        <circle cx="80" cy="340" r="10" fill="#14b19e" opacity="0.2"/>
        <circle cx="80" cy="340" r="6" fill="#14b19e"/>
        <circle cx="80" cy="340" r="2.5" fill="white"/>

        <!-- Dropoff pin -->
        <g transform="translate(202, 170)">
          <path d="M8 0C3.58 0 0 3.58 0 8c0 5.25 8 16 8 16s8-10.75 8-16c0-4.42-3.58-8-8-8zm0 11c-1.66 0-3-1.34-3-3s1.34-3 3-3 3 1.34 3 3-1.34 3-3 3z" fill="#00735f"/>
          <circle cx="8" cy="8" r="3" fill="white"/>
        </g>

        <!-- User location pulse -->
        <circle cx="80" cy="340" r="18" fill="rgba(20,177,158,0.1)">
          <animate attributeName="r" values="10;20;10" dur="2.5s" repeatCount="indefinite"/>
          <animate attributeName="opacity" values="0.4;0;0.4" dur="2.5s" repeatCount="indefinite"/>
        </circle>

        <!-- Animating VTC Car -->
        <g>
          <animateTransform
            attributeName="transform"
            type="translate"
            values="72,332; 72,252; 142,252; 142,182; 202,182"
            keyTimes="0; 0.35; 0.55; 0.75; 1"
            dur="5s"
            repeatCount="indefinite"
            calcMode="linear"
          />
          <!-- Stylized car body -->
          <rect x="-10" y="-6" width="20" height="12" rx="3" fill="url(#carBodyGrad)" stroke="#00735f" stroke-width="0.75"/>
          <rect x="-6" y="-10" width="12" height="8" rx="2" fill="url(#carBodyGrad)" opacity="0.9"/>
          <!-- Windows -->
          <rect x="-4" y="-8" width="8" height="4" rx="1" fill="#e2e8f0"/>
          <!-- Wheels -->
          <circle cx="-6" cy="6" r="3" fill="#0f172a"/>
          <circle cx="6" cy="6" r="3" fill="#0f172a"/>
          <!-- Headlights -->
          <rect x="7" y="-9" width="3" height="2" rx="0.5" fill="#fef08a"/>
        </g>

        <!-- Card content (VTC values) -->
        <g transform="translate(20, 412)">
          <!-- Left Col: ETA -->
          <text x="16" y="20" font-family="Inter,sans-serif" font-weight="600" font-size="10" fill="#64748b" letter-spacing="0.05em">
            {{ t('mockup.arrival') }}
          </text>
          <text x="16" y="42" font-family="Sora,sans-serif" font-weight="800" font-size="20" fill="#00735f">3 min</text>
          <text x="16" y="58" font-family="Inter,sans-serif" font-size="9" fill="#64748b">
            {{ t('mockup.distance_vtc') }}
          </text>

          <!-- Divider -->
          <line x1="116" y1="12" x2="116" y2="60" stroke="#e2e8f0" stroke-width="1" />

          <!-- Right Col: Price -->
          <text x="132" y="20" font-family="Inter,sans-serif" font-weight="600" font-size="10" fill="#64748b" letter-spacing="0.05em">
            {{ t('mockup.fare') }}
          </text>
          <text x="132" y="42" font-family="Sora,sans-serif" font-weight="800" font-size="18" fill="#0f172a">1 200 F</text>
          <text x="132" y="58" font-family="Inter,sans-serif" font-size="9" fill="#64748b">
            {{ t('mockup.fare_cfa') }}
          </text>
        </g>

        <!-- Button VTC -->
        <g transform="translate(24, 496)">
          <rect x="0" y="0" width="232" height="34" rx="17" fill="url(#btnGrad)"/>
          <text x="116" y="22" font-family="Sora,sans-serif" font-weight="700" font-size="12" fill="white" text-anchor="middle">
            {{ t('mockup.confirm_vtc') }}
          </text>
        </g>
      </g>

      <!-- ============================================================
           ANIMATION 2: PRO PARCEL DELIVERY (📦)
           ============================================================ -->
      <g v-else>
        <!-- Route path -->
        <path
          d="M 80 190 L 150 190 L 150 260 L 210 260"
          stroke="url(#delRouteGrad)"
          stroke-width="5"
          stroke-linecap="round"
          stroke-linejoin="round"
          fill="none"
          stroke-dasharray="6 3"
        />
        <path
          d="M 80 190 L 150 190 L 150 260 L 210 260"
          stroke="url(#delRouteGrad)"
          stroke-width="8"
          stroke-linecap="round"
          stroke-linejoin="round"
          fill="none"
          opacity="0.2"
        />

        <!-- Pickup pin (orange) -->
        <circle cx="80" cy="190" r="10" fill="#ea580c" opacity="0.2"/>
        <circle cx="80" cy="190" r="6" fill="#ea580c"/>
        <circle cx="80" cy="190" r="2.5" fill="white"/>

        <!-- Dropoff pin (dark red) -->
        <g transform="translate(202, 240)">
          <path d="M8 0C3.58 0 0 3.58 0 8c0 5.25 8 16 8 16s8-10.75 8-16c0-4.42-3.58-8-8-8zm0 11c-1.66 0-3-1.34-3-3s1.34-3 3-3 3 1.34 3 3-1.34 3-3 3z" fill="#ea580c"/>
          <circle cx="8" cy="8" r="3" fill="white"/>
        </g>

        <!-- User location pulse -->
        <circle cx="80" cy="190" r="18" fill="rgba(234,88,12,0.1)">
          <animate attributeName="r" values="10;20;10" dur="2.5s" repeatCount="indefinite"/>
          <animate attributeName="opacity" values="0.4;0;0.4" dur="2.5s" repeatCount="indefinite"/>
        </circle>

        <!-- Animating Delivery Box -->
        <g>
          <animateTransform
            attributeName="transform"
            type="translate"
            values="72,182; 142,182; 142,252; 202,252"
            keyTimes="0; 0.45; 0.8; 1"
            dur="5s"
            repeatCount="indefinite"
            calcMode="linear"
          />
          <!-- 3D style Box -->
          <rect x="-8" y="-8" width="16" height="16" rx="2" fill="url(#boxBodyGrad)" stroke="#d97706" stroke-width="0.75"/>
          <!-- Ribbons -->
          <line x1="0" y1="-8" x2="0" y2="8" stroke="#b45309" stroke-width="1.5"/>
          <line x1="-8" y1="0" x2="8" y2="0" stroke="#b45309" stroke-width="1.5"/>
        </g>

        <!-- Card content (Delivery values) -->
        <g transform="translate(20, 412)">
          <!-- Left Col: ETA -->
          <text x="16" y="20" font-family="Inter,sans-serif" font-weight="600" font-size="10" fill="#64748b" letter-spacing="0.05em">
            {{ t('mockup.delivery') }}
          </text>
          <text x="16" y="42" font-family="Sora,sans-serif" font-weight="800" font-size="20" fill="#d97706">12 min</text>
          <text x="16" y="58" font-family="Inter,sans-serif" font-size="9" fill="#64748b">
            {{ t('mockup.distance_del') }}
          </text>

          <!-- Divider -->
          <line x1="116" y1="12" x2="116" y2="60" stroke="#e2e8f0" stroke-width="1" />

          <!-- Right Col: Price -->
          <text x="132" y="20" font-family="Inter,sans-serif" font-weight="600" font-size="10" fill="#64748b" letter-spacing="0.05em">
            {{ t('mockup.fare') }}
          </text>
          <text x="132" y="42" font-family="Sora,sans-serif" font-weight="800" font-size="18" fill="#0f172a">1 800 F</text>
          <text x="132" y="58" font-family="Inter,sans-serif" font-size="9" fill="#64748b">
            {{ t('mockup.fare_cfa') }}
          </text>
        </g>

        <!-- Button Delivery -->
        <g transform="translate(24, 496)">
          <rect x="0" y="0" width="232" height="34" rx="17" fill="url(#btnDelGrad)"/>
          <text x="116" y="22" font-family="Sora,sans-serif" font-weight="700" font-size="12" fill="white" text-anchor="middle">
            {{ t('mockup.confirm_del') }}
          </text>
        </g>
      </g>

      <!-- ETA Bottom Card Shape (Common border/gradient) -->
      <rect x="20" y="412" width="240" height="72" rx="14" stroke="#e2e8f0" stroke-width="1" fill="none" pointer-events="none" />

      <!-- Gradient definitions -->
      <defs>
        <!-- Phone shell - Premium Light Titanium -->
        <linearGradient id="phoneGrad" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stop-color="#f1f5f9"/>
          <stop offset="50%" stop-color="#cbd5e1"/>
          <stop offset="100%" stop-color="#94a3b8"/>
        </linearGradient>
        <linearGradient id="frameGrad" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stop-color="#ffffff"/>
          <stop offset="100%" stop-color="#94a3b8"/>
        </linearGradient>

        <!-- Route VTC -->
        <linearGradient id="vtcRouteGrad" x1="0" y1="1" x2="1" y2="0">
          <stop offset="0%" stop-color="#14b19e"/>
          <stop offset="100%" stop-color="#00735f"/>
        </linearGradient>

        <!-- Route Delivery -->
        <linearGradient id="delRouteGrad" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stop-color="#f97316"/>
          <stop offset="100%" stop-color="#ea580c"/>
        </linearGradient>

        <!-- Vehicles -->
        <linearGradient id="carBodyGrad" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#14b19e"/>
          <stop offset="100%" stop-color="#00735f"/>
        </linearGradient>
        <linearGradient id="boxBodyGrad" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#fcd34d"/>
          <stop offset="100%" stop-color="#f59e0b"/>
        </linearGradient>

        <!-- Buttons -->
        <linearGradient id="btnGrad" x1="0" y1="0" x2="1" y2="0">
          <stop offset="0%" stop-color="#00735f"/>
          <stop offset="100%" stop-color="#14b19e"/>
        </linearGradient>
        <linearGradient id="btnDelGrad" x1="0" y1="0" x2="1" y2="0">
          <stop offset="0%" stop-color="#ea580c"/>
          <stop offset="100%" stop-color="#f97316"/>
        </linearGradient>
      </defs>
    </svg>
  </div>
</template>

<style scoped>
.phone-wrapper {
  position: relative;
  width: 280px;
  height: 560px;
  margin: 0 auto;
}

.phone-tabs {
  position: absolute;
  top: 112px;
  left: 28px;
  width: 224px;
  display: flex;
  background: #e2e8f0;
  padding: 3px;
  border-radius: 20px;
  z-index: 10;
  box-shadow: inset 0 1px 3px rgba(0,0,0,0.08);
}

.phone-tabs button {
  flex: 1;
  border: none;
  background: none;
  font-family: 'Sora', sans-serif;
  font-size: 0.72rem;
  font-weight: 700;
  padding: 6px 12px;
  border-radius: 16px;
  cursor: pointer;
  transition: all 0.3s ease;
  color: #475569;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4px;
}

.phone-tabs button.active {
  background: #ffffff;
  color: #00735f;
  box-shadow: 0 2px 8px rgba(15, 23, 42, 0.08);
}
</style>
