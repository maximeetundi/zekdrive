<template>
  <div>
    <NuxtLayout>
      <NuxtPage />
    </NuxtLayout>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'

useHead({
  titleTemplate: (title) => title ? `${title} — ZekDrive Admin` : 'ZekDrive Admin',
})

onMounted(() => {
  const saved = localStorage.getItem('zekdrive_admin_theme')
  if (saved === 'light') {
    document.documentElement.setAttribute('data-theme', 'light')
  } else {
    document.documentElement.setAttribute('data-theme', 'dark')
  }
})
</script>
