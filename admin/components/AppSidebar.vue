<template>
  <aside class="sidebar" :class="{ collapsed: collapsed, 'mobile-open': mobileOpen }">
    <!-- Logo -->
    <div class="sidebar-logo">
      <img src="/logo.png" alt="ZekDrive" class="sidebar-logo-img" />
      <span class="sidebar-logo-text">ZekDrive</span>
    </div>

    <!-- Navigation -->
    <nav class="sidebar-nav">
      <div class="sidebar-section-label">{{ t('general') }}</div>

      <NuxtLink to="/" class="nav-item" exact-active-class="active">
        <svg class="nav-item-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v4a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v4a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v4a2 2 0 01-2 2H6a2 2 0 01-2-2v-4zM14 16a2 2 0 012-2h2a2 2 0 012 2v4a2 2 0 01-2 2h-2a2 2 0 01-2-2v-4z" />
        </svg>
        <span class="nav-item-label">{{ t('dashboard') }}</span>
      </NuxtLink>

      <NuxtLink to="/fleet-monitor" class="nav-item" active-class="active">
        <svg class="nav-item-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7" />
        </svg>
        <span class="nav-item-label">{{ t('live_fleet') }}</span>
      </NuxtLink>

      <NuxtLink to="/analytics" class="nav-item" active-class="active">
        <svg class="nav-item-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
        </svg>
        <span class="nav-item-label">{{ t('analytics') }}</span>
      </NuxtLink>

      <div class="sidebar-section-label">{{ t('operations') }}</div>

      <NuxtLink to="/users" class="nav-item" active-class="active">
        <svg class="nav-item-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
        </svg>
        <span class="nav-item-label">{{ t('users') }}</span>
      </NuxtLink>

      <NuxtLink to="/drivers" class="nav-item" active-class="active">
        <svg class="nav-item-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z" />
        </svg>
        <span class="nav-item-label">{{ t('drivers') }}</span>
      </NuxtLink>

      <NuxtLink to="/trips" class="nav-item" active-class="active">
        <svg class="nav-item-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <span class="nav-item-label">{{ t('trips') }}</span>
      </NuxtLink>

      <NuxtLink to="/deliveries" class="nav-item" active-class="active">
        <svg class="nav-item-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
        </svg>
        <span class="nav-item-label">{{ t('deliveries') }}</span>
      </NuxtLink>

      <NuxtLink to="/kyc" class="nav-item" active-class="active">
        <svg class="nav-item-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
        </svg>
        <span class="nav-item-label">🛡️ {{ lang === 'fr' ? 'KYC / Vérifications' : 'KYC / Verifications' }}</span>
      </NuxtLink>

      <!-- ─────────── COMMERCE ─────────── -->
      <div class="sidebar-section-label">🛍️ {{ lang === 'fr' ? 'Commerce' : 'Commerce' }}</div>

      <!-- Tous les commerces -->
      <NuxtLink to="/stores" class="nav-item" :class="{ active: route.path === '/stores' && !route.query.type }">
        <span class="nav-item-icon" style="font-size:1rem;">🏪</span>
        <span class="nav-item-label">{{ lang === 'fr' ? 'Tous les commerces' : 'All Stores' }}</span>
      </NuxtLink>

      <!-- 🍽️ Restauration -->
      <div class="nav-sub-group-label">{{ lang === 'fr' ? 'Restauration' : 'Food & Drink' }}</div>
      <NuxtLink to="/stores?type=restaurant" class="nav-item nav-item-sub" :class="{ active: route.query.type === 'restaurant' }">
        <span class="nav-item-icon">🍽️</span><span class="nav-item-label">{{ lang === 'fr' ? 'Restaurants' : 'Restaurants' }}</span>
      </NuxtLink>
      <NuxtLink to="/stores?type=cafe" class="nav-item nav-item-sub" :class="{ active: route.query.type === 'cafe' }">
        <span class="nav-item-icon">☕</span><span class="nav-item-label">{{ lang === 'fr' ? 'Cafés / Salons' : 'Cafés' }}</span>
      </NuxtLink>
      <NuxtLink to="/stores?type=bakery" class="nav-item nav-item-sub" :class="{ active: route.query.type === 'bakery' }">
        <span class="nav-item-icon">🥐</span><span class="nav-item-label">{{ lang === 'fr' ? 'Boulangeries' : 'Bakeries' }}</span>
      </NuxtLink>

      <!-- 🛒 Alimentation -->
      <div class="nav-sub-group-label">{{ lang === 'fr' ? 'Alimentation' : 'Food Shops' }}</div>
      <NuxtLink to="/stores?type=grocery" class="nav-item nav-item-sub" :class="{ active: route.query.type === 'grocery' }">
        <span class="nav-item-icon">🛒</span><span class="nav-item-label">{{ lang === 'fr' ? 'Épiceries' : 'Grocery' }}</span>
      </NuxtLink>
      <NuxtLink to="/stores?type=butcher" class="nav-item nav-item-sub" :class="{ active: route.query.type === 'butcher' }">
        <span class="nav-item-icon">🥩</span><span class="nav-item-label">{{ lang === 'fr' ? 'Boucheries' : 'Butchers' }}</span>
      </NuxtLink>
      <NuxtLink to="/stores?type=fishmonger" class="nav-item nav-item-sub" :class="{ active: route.query.type === 'fishmonger' }">
        <span class="nav-item-icon">🐟</span><span class="nav-item-label">{{ lang === 'fr' ? 'Poissonneries' : 'Fish Shops' }}</span>
      </NuxtLink>

      <!-- 💊 Santé & Beauté -->
      <div class="nav-sub-group-label">{{ lang === 'fr' ? 'Santé & Beauté' : 'Health & Beauty' }}</div>
      <NuxtLink to="/stores?type=pharmacy" class="nav-item nav-item-sub" :class="{ active: route.query.type === 'pharmacy' }">
        <span class="nav-item-icon">💊</span><span class="nav-item-label">{{ lang === 'fr' ? 'Pharmacies' : 'Pharmacies' }}</span>
      </NuxtLink>
      <NuxtLink to="/stores?type=beauty" class="nav-item nav-item-sub" :class="{ active: route.query.type === 'beauty' }">
        <span class="nav-item-icon">💄</span><span class="nav-item-label">{{ lang === 'fr' ? 'Beauté / Coiffure' : 'Beauty' }}</span>
      </NuxtLink>

      <!-- 👔 Mode & Textile -->
      <div class="nav-sub-group-label">{{ lang === 'fr' ? 'Mode & Maison' : 'Fashion & Home' }}</div>
      <NuxtLink to="/stores?type=clothing" class="nav-item nav-item-sub" :class="{ active: route.query.type === 'clothing' }">
        <span class="nav-item-icon">👔</span><span class="nav-item-label">{{ lang === 'fr' ? 'Vêtements / Mode' : 'Clothing' }}</span>
      </NuxtLink>
      <NuxtLink to="/stores?type=boutique" class="nav-item nav-item-sub" :class="{ active: route.query.type === 'boutique' }">
        <span class="nav-item-icon">🛍️</span><span class="nav-item-label">{{ lang === 'fr' ? 'Boutique générale' : 'General Boutique' }}</span>
      </NuxtLink>
      <NuxtLink to="/stores?type=hardware" class="nav-item nav-item-sub" :class="{ active: route.query.type === 'hardware' }">
        <span class="nav-item-icon">🔧</span><span class="nav-item-label">{{ lang === 'fr' ? 'Quincaillerie' : 'Hardware' }}</span>
      </NuxtLink>
      <NuxtLink to="/stores?type=furniture" class="nav-item nav-item-sub" :class="{ active: route.query.type === 'furniture' }">
        <span class="nav-item-icon">🪑</span><span class="nav-item-label">{{ lang === 'fr' ? 'Meubles / Déco' : 'Furniture' }}</span>
      </NuxtLink>
      <NuxtLink to="/stores?type=electronics" class="nav-item nav-item-sub" :class="{ active: route.query.type === 'electronics' }">
        <span class="nav-item-icon">📱</span><span class="nav-item-label">{{ lang === 'fr' ? 'Électronique' : 'Electronics' }}</span>
      </NuxtLink>

      <!-- Commandes -->
      <NuxtLink to="/orders" class="nav-item" active-class="active" style="margin-top:0.25rem;">
        <svg class="nav-item-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01" />
        </svg>
        <span class="nav-item-label">{{ lang === 'fr' ? '📋 Commandes' : '📋 Orders' }}</span>
      </NuxtLink>

      <!-- PRO USERS -->
      <div class="sidebar-section-label">{{ lang === 'fr' ? '🚗 Pro Users' : '🚗 Pro Users' }}</div>

      <NuxtLink to="/fleet" class="nav-item" active-class="active">
        <svg class="nav-item-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
        </svg>
        <span class="nav-item-label">{{ lang === 'fr' ? 'Parcs Automobiles' : 'Fleet Mgmt' }}</span>
      </NuxtLink>

      <!-- CONFIGURATION -->
      <div class="sidebar-section-label">{{ t('fleet_config') }}</div>

      <NuxtLink to="/vehicles" class="nav-item" active-class="active">
        <svg class="nav-item-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
        </svg>
        <span class="nav-item-label">{{ t('vehicles') }}</span>
      </NuxtLink>

      <NuxtLink to="/zones" class="nav-item" active-class="active">
        <svg class="nav-item-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
          <path stroke-linecap="round" stroke-linejoin="round" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
        </svg>
        <span class="nav-item-label">{{ t('zones') }}</span>
      </NuxtLink>



      <NuxtLink to="/countries" class="nav-item" active-class="active">
        <svg class="nav-item-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <span class="nav-item-label">🌍 {{ lang === 'fr' ? 'Pays & Devises' : 'Countries & Currencies' }}</span>
      </NuxtLink>

      <NuxtLink to="/promotions" class="nav-item" active-class="active">
        <svg class="nav-item-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
        </svg>
        <span class="nav-item-label">{{ t('promotions') }}</span>
      </NuxtLink>

      <!-- FINANCE -->
      <div class="sidebar-section-label">{{ t('finance') }}</div>

      <NuxtLink to="/transactions" class="nav-item" active-class="active">
        <svg class="nav-item-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M9 17v-2m3 2v-4m3 4v-6m2 10H3a2 2 0 01-2-2V5a2 2 0 012-2h14a2 2 0 012 2v14a2 2 0 01-2 2z" />
        </svg>
        <span class="nav-item-label">{{ t('transactions') }}</span>
      </NuxtLink>

      <!-- ADMINISTRATION -->
      <div class="sidebar-section-label">🔐 {{ lang === 'fr' ? 'Administration' : 'Administration' }}</div>

      <NuxtLink to="/admins" class="nav-item" active-class="active">
        <svg class="nav-item-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
        </svg>
        <span class="nav-item-label">{{ lang === 'fr' ? 'Gestion Admins' : 'Admin Management' }}</span>
      </NuxtLink>

      <NuxtLink to="/settings" class="nav-item" active-class="active">
        <svg class="nav-item-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
          <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
        </svg>
        <span class="nav-item-label">{{ t('settings') }}</span>
      </NuxtLink>
    </nav>

    <!-- Footer: Theme + Language + User -->
    <div class="sidebar-footer">
      <!-- Theme & Language row -->
      <div class="sidebar-controls">
        <button class="control-btn" :title="theme === 'dark' ? t('light_mode') : t('dark_mode')" @click="toggleTheme">
          <svg v-if="theme === 'dark'" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" class="control-icon">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364-6.364l-.707.707M6.343 17.657l-.707.707m12.728 0l-.707-.707M6.343 6.343l-.707-.707M12 7a5 5 0 100 10 5 5 0 000-10z" />
          </svg>
          <svg v-else xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" class="control-icon">
            <path stroke-linecap="round" stroke-linejoin="round" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
          </svg>
          <span class="nav-item-label">{{ theme === 'dark' ? t('light_mode') : t('dark_mode') }}</span>
        </button>

        <button class="control-btn" @click="toggleLang" :title="`Langue: ${lang === 'fr' ? 'Français' : 'English'}`">
          <span class="lang-flag">{{ lang === 'fr' ? '🇫🇷' : '🇬🇧' }}</span>
          <span class="nav-item-label">{{ lang === 'fr' ? 'Français' : 'English' }}</span>
        </button>
      </div>

      <!-- User info -->
      <div class="sidebar-user">
        <div class="sidebar-user-avatar">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width: 18px; height: 18px;">
            <path stroke-linecap="round" stroke-linejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
          </svg>
        </div>
        <div class="sidebar-user-info">
          <div class="sidebar-user-name">{{ user?.name || 'Admin ZekDrive' }}</div>
          <div class="sidebar-user-role">{{ user?.role || 'superadmin' }}</div>
        </div>
      </div>
    </div>
  </aside>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { storeToRefs } from 'pinia'
import { useAuthStore } from '~/stores/auth'
import { useI18n } from '~/composables/useI18n'

const route = useRoute()

defineProps({
  collapsed: { type: Boolean, default: false },
  mobileOpen: { type: Boolean, default: false },
})

const authStore = useAuthStore()
const { user } = storeToRefs(authStore)

const { theme, lang, init, toggleTheme, toggleLang } = useTheme()
const { t } = useI18n()

onMounted(() => {
  init()
})
</script>
