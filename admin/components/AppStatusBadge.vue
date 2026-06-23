<template>
  <span :class="['badge', badgeClass]">
    <span v-if="showDot" class="badge-dot"></span>
    <slot>{{ normalizedLabel }}</slot>
  </span>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps({
  status: {
    type: String,
    required: true,
  },
  showDot: {
    type: Boolean,
    default: false,
  },
})

const badgeClass = computed(() => {
  const s = props.status?.toLowerCase() || ''
  // Return the class name defined in CSS
  if (['pending'].includes(s)) return 'badge-pending'
  if (['accepted', 'active', 'available'].includes(s)) return 'badge-active'
  if (['ongoing', 'busy'].includes(s)) return 'badge-ongoing'
  if (['completed', 'approved'].includes(s)) return 'badge-completed'
  if (['cancelled', 'rejected', 'banned'].includes(s)) return 'badge-cancelled'
  if (['inactive', 'offline'].includes(s)) return 'badge-inactive'
  
  if (s === 'customer') return 'badge-customer'
  if (s === 'driver') return 'badge-driver'
  
  if (s === 'car') return 'badge-car'
  if (s === 'moto') return 'badge-moto'
  if (s === 'bicycle') return 'badge-bicycle'
  if (s === 'truck') return 'badge-truck'
  
  return 'badge-primary'
})

const normalizedLabel = computed(() => {
  const s = props.status || ''
  if (!s) return ''
  return s.charAt(0).toUpperCase() + s.slice(1).replace('_', ' ')
})
</script>
