<template>
  <aside class="sidebar" :class="{ collapsed: collapsed }">
    <!-- Logo Section -->
    <div class="sidebar-logo">
      <svg class="sidebar-logo-icon" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg">
        <rect width="40" height="40" rx="10" fill="url(#logo-grad)"/>
        <path d="M12 28L20 12L28 28H12Z" fill="white" fill-opacity="0.9"/>
        <circle cx="20" cy="22" r="4" fill="var(--accent-secondary)"/>
        <defs>
          <linearGradient id="logo-grad" x1="0" y1="0" x2="40" y2="40" gradientUnits="userSpaceOnUse">
            <stop stop-color="#6c63ff"/>
            <stop offset="1" stop-color="#00d4aa"/>
          </linearGradient>
        </defs>
      </svg>
      <span class="sidebar-logo-text">ZekDrive</span>
    </div>

    <!-- Navigation List -->
    <nav class="sidebar-nav">
      <div class="sidebar-section-label">General</div>
      
      <NuxtLink to="/" class="nav-item" exact-active-class="active">
        <svg class="nav-item-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v4a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v4a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v4a2 2 0 01-2 2H6a2 2 0 01-2-2v-4zM14 16a2 2 0 012-2h2a2 2 0 012 2v4a2 2 0 01-2 2h-2a2 2 0 01-2-2v-4z" />
        </svg>
        <span class="nav-item-label">Dashboard</span>
      </NuxtLink>

      <div class="sidebar-section-label">Operations</div>
      
      <NuxtLink to="/users" class="nav-item" active-class="active">
        <svg class="nav-item-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
        </svg>
        <span class="nav-item-label">Users</span>
      </NuxtLink>

      <NuxtLink to="/drivers" class="nav-item" active-class="active">
        <svg class="nav-item-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M9 12a5 5 0 1110 0 5 5 0 01-10 0z" />
          <path stroke-linecap="round" stroke-linejoin="round" d="M12 14v7m-9-4h18" />
        </svg>
        <span class="nav-item-label">Drivers</span>
      </NuxtLink>

      <NuxtLink to="/trips" class="nav-item" active-class="active">
        <svg class="nav-item-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7" />
        </svg>
        <span class="nav-item-label">Trips</span>
      </NuxtLink>

      <NuxtLink to="/deliveries" class="nav-item" active-class="active">
        <svg class="nav-item-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
        </svg>
        <span class="nav-item-label">Deliveries</span>
      </NuxtLink>

      <div class="sidebar-section-label">Fleet & Config</div>

      <NuxtLink to="/vehicles" class="nav-item" active-class="active">
        <svg class="nav-item-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
        </svg>
        <span class="nav-item-label">Vehicles</span>
      </NuxtLink>

      <NuxtLink to="/zones" class="nav-item" active-class="active">
        <svg class="nav-item-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
          <path stroke-linecap="round" stroke-linejoin="round" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
        </svg>
        <span class="nav-item-label">Zones</span>
      </NuxtLink>

      <NuxtLink to="/pricing" class="nav-item" active-class="active">
        <svg class="nav-item-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <span class="nav-item-label">Pricing Rules</span>
      </NuxtLink>

      <NuxtLink to="/promotions" class="nav-item" active-class="active">
        <svg class="nav-item-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M12 8v13m0-13V6a2 2 0 112 2h-2zm0 0V5.5A2.5 2.5 0 109.5 8H12zm-7 4h14M5 12a2 2 0 110-4h14a2 2 0 110 4M5 12v7a2 2 0 002 2h10a2 2 0 002-2v-7" />
        </svg>
        <span class="nav-item-label">Promotions</span>
      </NuxtLink>

      <div class="sidebar-section-label">Finance & Adm</div>

      <NuxtLink to="/transactions" class="nav-item" active-class="active">
        <svg class="nav-item-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M9 17v-2m3 2v-4m3 4v-6m2 10H3a2 2 0 01-2-2V5a2 2 0 012-2h14a2 2 0 012 2v14a2 2 0 01-2 2z" />
        </svg>
        <span class="nav-item-label">Transactions</span>
      </NuxtLink>

      <NuxtLink to="/settings" class="nav-item" active-class="active">
        <svg class="nav-item-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
          <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
        </svg>
        <span class="nav-item-label">Settings</span>
      </NuxtLink>
    </nav>

    <!-- Sidebar User Footer -->
    <div class="sidebar-footer">
      <div class="sidebar-user">
        <div class="sidebar-user-avatar">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width: 20px; height: 20px; color: var(--text-primary);">
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
import { storeToRefs } from 'pinia'
import { useAuthStore } from '~/stores/auth'

defineProps({
  collapsed: {
    type: Boolean,
    default: false,
  },
})

const authStore = useAuthStore()
const { user } = storeToRefs(authStore)
</script>
