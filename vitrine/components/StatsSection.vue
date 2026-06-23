<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useScrollAnimation } from '~/composables/useScrollAnimation'
import { useCounter } from '~/composables/useCounter'

const { observe } = useScrollAnimation()
const sectionRef = ref<HTMLElement | null>(null)

const stats = [
  { target: 50000, suffix: 'K+', label: 'Utilisateurs actifs', prefix: '' },
  { target: 500, suffix: '+', label: 'Chauffeurs vérifiés', prefix: '' },
  { target: 100000, suffix: 'K+', label: 'Trajets effectués', prefix: '' },
  { target: 49, suffix: '', label: 'Note moyenne', prefix: '4.' },
]

const counters = stats.map(s => {
  const display = s.target >= 1000 ? Math.round(s.target / 1000) : s.target
  return useCounter(display, 2000)
})

onMounted(() => {
  if (sectionRef.value) {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            counters.forEach(c => c.start())
            observer.disconnect()
          }
        })
      },
      { threshold: 0.3 }
    )
    observer.observe(sectionRef.value)
  }
})
</script>

<template>
  <section class="stats-section" ref="sectionRef">
    <div class="container" style="position:relative;z-index:1;">
      <div class="stats-grid">
        <div
          v-for="(stat, i) in stats"
          :key="i"
          class="stat-item fade-up"
        >
          <div class="stat-number">
            {{ stat.prefix }}{{ counters[i].count.value }}{{ stat.suffix }}
          </div>
          <div class="stat-label">{{ stat.label }}</div>
        </div>
      </div>
    </div>
  </section>
</template>
