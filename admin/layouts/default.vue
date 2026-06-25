<template>
  <div class="admin-layout">
    <!-- Sidebar -->
    <AppSidebar :collapsed="sidebarCollapsed && !mobileOpen" :mobile-open="mobileOpen" />
    
    <!-- Sidebar Backdrop for Mobile -->
    <div v-if="mobileOpen" class="sidebar-backdrop" @click="closeSidebar" />
    
    <!-- Main Content Area -->
    <div class="admin-main" :class="{ 'sidebar-collapsed': sidebarCollapsed && !isMobile }">
      <!-- Topbar -->
      <AppTopbar @toggle-sidebar="toggleSidebar" />
      
      <!-- Page Content -->
      <main class="page-content">
        <slot />
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, watch } from 'vue'
import { useRoute } from 'vue-router'

const sidebarCollapsed = ref(false)
const mobileOpen = ref(false)
const isMobile = ref(false)
const route = useRoute()

function checkMobile() {
  if (process.client) {
    isMobile.value = window.innerWidth < 900
  }
}

function toggleSidebar() {
  if (isMobile.value) {
    // On mobile: slide in/out overlay — never change collapsed
    mobileOpen.value = !mobileOpen.value
  } else {
    // On desktop: collapse/expand the sidebar width
    sidebarCollapsed.value = !sidebarCollapsed.value
  }
}

function closeSidebar() {
  mobileOpen.value = false
}

// Close mobile menu on navigation
watch(() => route.path, () => {
  mobileOpen.value = false
})

onMounted(() => {
  checkMobile()
  // Collapse by default on medium screens (not mobile — handled by CSS transform)
  if (process.client && window.innerWidth < 1024 && window.innerWidth >= 900) {
    sidebarCollapsed.value = true
  }
  if (process.client) {
    window.addEventListener('resize', checkMobile)
  }
})

onUnmounted(() => {
  if (process.client) {
    window.removeEventListener('resize', checkMobile)
  }
})
</script>
