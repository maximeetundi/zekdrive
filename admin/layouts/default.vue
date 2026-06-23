<template>
  <div class="admin-layout">
    <!-- Sidebar -->
    <AppSidebar :collapsed="sidebarCollapsed" />
    
    <!-- Main Content Area -->
    <div class="admin-main" :class="{ 'sidebar-collapsed': sidebarCollapsed }">
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
import { ref, onMounted } from 'vue'

const sidebarCollapsed = ref(false)

function toggleSidebar() {
  sidebarCollapsed.value = !sidebarCollapsed.value
}

onMounted(() => {
  // Collapse sidebar by default on smaller screens
  if (window.innerWidth < 1024) {
    sidebarCollapsed.value = true
  }
})
</script>
