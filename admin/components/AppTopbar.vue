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

      <!-- Quick Profile logout trigger -->
      <button class="btn btn-secondary btn-sm flex items-center gap-2" @click="handleLogout" style="border: 1px solid var(--border); padding: 0.375rem 0.75rem;">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width: 14px; height: 14px;">
          <path stroke-linecap="round" stroke-linejoin="round" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
        </svg>
        <span>Logout</span>
      </button>
    </div>
  </header>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import { useAuthStore } from '~/stores/auth'

const emit = defineEmits(['toggle-sidebar'])

const route = useRoute()
const authStore = useAuthStore()

const unreadCount = ref(3)

const currentBreadcrumb = computed(() => {
  const path = route.path
  if (path === '/') return 'Dashboard'
  const segment = path.split('/')[1]
  if (!segment) return 'Dashboard'
  return segment.charAt(0).toUpperCase() + segment.slice(1).replace('-', ' ')
})

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
