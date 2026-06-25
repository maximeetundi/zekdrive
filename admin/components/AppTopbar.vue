<template>
  <header class="topbar">
    <!-- Sidebar Toggle -->
    <button class="topbar-hamburger" @click="emitToggle" aria-label="Toggle sidebar">
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width: 20px; height: 20px;">
        <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16" />
      </svg>
    </button>

    <!-- Breadcrumbs -->
    <div class="topbar-breadcrumb">
      <NuxtLink to="/" class="topbar-breadcrumb-item">ZekDrive</NuxtLink>
      <span class="topbar-breadcrumb-sep">/</span>
      <span class="topbar-breadcrumb-item active">{{ currentBreadcrumb }}</span>
    </div>

    <!-- Actions -->
    <div class="topbar-actions">
      <!-- Language Toggle (Visible everywhere) -->
      <button 
        class="btn-icon" 
        @click="toggleLang" 
        :title="`Langue: ${lang === 'fr' ? 'Français' : 'English'}`"
        style="background: transparent; border: none; color: var(--text-secondary); cursor: pointer; display: flex; align-items: center; justify-content: center; width: 2.25rem; height: 2.25rem; border-radius: var(--radius-sm); transition: var(--transition); font-size: 1.15rem;"
      >
        <span class="lang-flag">{{ lang === 'fr' ? '🇫🇷' : '🇬🇧' }}</span>
      </button>

      <!-- Theme Toggle (Visible everywhere) -->
      <button 
        class="btn-icon" 
        @click="toggleTheme" 
        :aria-label="theme === 'dark' ? t('light_mode') : t('dark_mode')" 
        style="background: transparent; border: none; color: var(--text-secondary); cursor: pointer; display: flex; align-items: center; justify-content: center; width: 2.25rem; height: 2.25rem; border-radius: var(--radius-sm); transition: var(--transition);"
      >
        <svg v-if="theme === 'dark'" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width: 20px; height: 20px;">
          <path stroke-linecap="round" stroke-linejoin="round" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364-6.364l-.707.707M6.343 17.657l-.707.707m12.728 0l-.707-.707M6.343 6.343l-.707-.707M12 7a5 5 0 100 10 5 5 0 000-10z" />
        </svg>
        <svg v-else xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width: 20px; height: 20px;">
          <path stroke-linecap="round" stroke-linejoin="round" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
        </svg>
      </button>

      <!-- Notification Badge -->
      <div class="topbar-notif relative" @click="toggleNotifs">
        <button class="btn-icon" aria-label="Notifications" style="background: transparent; border: none; color: var(--text-secondary); cursor: pointer; display: flex; align-items: center; justify-content: center; width: 2.25rem; height: 2.25rem; border-radius: var(--radius-sm); transition: var(--transition);">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width: 20px; height: 20px;">
            <path stroke-linecap="round" stroke-linejoin="round" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
          </svg>
        </button>
        <span v-if="unreadCount > 0" class="topbar-notif-badge" style="position: absolute; top: 2px; right: 2px; background: var(--accent-warning); color: #fff; font-size: 0.65rem; font-weight: 700; width: 14px; height: 14px; border-radius: 50%; display: flex; align-items: center; justify-content: center; box-shadow: 0 0 8px var(--accent-warning);">
          {{ unreadCount }}
        </span>
      </div>

      <!-- Profile Avatar & Dropdown -->
      <div class="relative">
        <button class="profile-btn" @click="toggleProfileDropdown" aria-label="Profile menu">
          <div class="profile-avatar">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width: 18px; height: 18px;">
              <path stroke-linecap="round" stroke-linejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
            </svg>
          </div>
        </button>
        
        <!-- Profile Dropdown Card -->
        <div v-if="showProfileDropdown" class="profile-dropdown">
          <div class="profile-dropdown-header">
            <div class="profile-dropdown-name">{{ user?.name || 'Admin ZekDrive' }}</div>
            <div class="profile-dropdown-email">{{ user?.email || 'admin@zekdrive.com' }}</div>
            <div class="profile-dropdown-role">{{ user?.role || 'superadmin' }}</div>
          </div>
          
          <div class="profile-dropdown-divider" />
          
          <!-- Theme Toggle Inside Dropdown (shown on mobile, useful on all devices) -->
          <button class="profile-dropdown-item" @click="toggleThemeDropdown">
            <svg v-if="theme === 'dark'" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" class="item-icon">
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364-6.364l-.707.707M6.343 17.657l-.707.707m12.728 0l-.707-.707M6.343 6.343l-.707-.707M12 7a5 5 0 100 10 5 5 0 000-10z" />
            </svg>
            <svg v-else xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" class="item-icon">
              <path stroke-linecap="round" stroke-linejoin="round" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
            </svg>
            <span>{{ theme === 'light' ? t('dark_mode') : t('light_mode') }}</span>
          </button>

          <!-- Language Toggle Inside Dropdown -->
          <button class="profile-dropdown-item" @click="toggleLangDropdown">
            <span style="font-size: 1.15rem; display: flex; align-items: center; justify-content: center; width: 1.25rem; margin-right: 0.75rem;">
              {{ lang === 'fr' ? '🇬🇧' : '🇫🇷' }}
            </span>
            <span>{{ lang === 'fr' ? 'Switch to English' : 'Passer au Français' }}</span>
          </button>
          
          <div class="profile-dropdown-divider" />
          
          <button class="profile-dropdown-item text-danger" @click="handleLogout">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" class="item-icon">
              <path stroke-linecap="round" stroke-linejoin="round" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
            </svg>
            <span>{{ t('logout') }}</span>
          </button>
        </div>
      </div>
    </div>
  </header>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'
import { storeToRefs } from 'pinia'
import { useAuthStore } from '~/stores/auth'
import { useI18n } from '~/composables/useI18n'

const emit = defineEmits(['toggle-sidebar'])

const route = useRoute()
const authStore = useAuthStore()
const { user } = storeToRefs(authStore)

// Shared theme state — stays in sync with sidebar
const { theme, lang, init, toggleTheme, toggleLang } = useTheme()
const { t } = useI18n()

const unreadCount = ref(3)
const showProfileDropdown = ref(false)

const currentBreadcrumb = computed(() => {
  const path = route.path
  const labels: Record<string, string> = {
    '/': t('dashboard'),
    '/fleet': t('live_fleet'),
    '/analytics': t('analytics'),
    '/users': t('users'),
    '/drivers': t('drivers'),
    '/trips': t('trips'),
    '/deliveries': t('deliveries'),
    '/stores': t('stores'),
    '/vehicles': t('vehicles'),
    '/zones': t('zones'),
    '/pricing': t('pricing'),
    '/promotions': t('promotions'),
    '/transactions': t('transactions'),
    '/settings': t('settings'),
  }
  return labels[path] || (path.split('/')[1] || t('dashboard'))
})

// Corrected window event listeners signature
function toggleThemeDropdown(event: Event) {
  event.stopPropagation()
  toggleTheme()
}

function toggleLangDropdown(event: Event) {
  event.stopPropagation()
  toggleLang()
}

function toggleProfileDropdown(event: Event) {
  event.stopPropagation()
  showProfileDropdown.value = !showProfileDropdown.value
}

function closeDropdowns() {
  showProfileDropdown.value = false
}

onMounted(() => {
  init()
  if (process.client) {
    window.addEventListener('click', closeDropdowns)
  }
})

onUnmounted(() => {
  if (process.client) {
    window.removeEventListener('click', closeDropdowns)
  }
})

// Header buttons emit
function emitToggle() {
  emit('toggle-sidebar')
}

function toggleNotifs() {
  unreadCount.value = 0
}

function handleLogout() {
  authStore.logout()
}
</script>
