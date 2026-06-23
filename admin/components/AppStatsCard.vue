<template>
  <div class="stat-card" :style="{ '--stat-color': color }">
    <div class="stat-card-header">
      <span class="stat-card-label">{{ label }}</span>
      <div class="stat-card-icon" :style="iconStyle">
        <slot name="icon">
          <!-- Default SVG fallback -->
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <line x1="12" y1="1" x2="12" y2="23"></line>
            <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path>
          </svg>
        </slot>
      </div>
    </div>
    <div class="stat-card-value">{{ value }}</div>
    <div v-if="trend !== undefined" class="stat-card-change" :class="trend >= 0 ? 'up' : 'down'">
      <span>{{ trend >= 0 ? '▲' : '▼' }}</span>
      <span>{{ Math.abs(trend) }}%</span>
      <span style="color: var(--text-muted); font-weight: normal; margin-left: 2px;">vs last month</span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps({
  label: {
    type: String,
    required: true,
  },
  value: {
    type: [String, Number],
    required: true,
  },
  trend: {
    type: Number,
    default: undefined,
  },
  color: {
    type: String,
    default: 'var(--accent-primary)',
  },
})

const iconStyle = computed(() => {
  // Extract hex or css variable to create a 12% opacity background
  const c = props.color
  const bg = c.startsWith('var') ? `rgba(108, 99, 255, 0.12)` : `${c}1f`
  return {
    color: c,
    background: bg,
  }
})
</script>
