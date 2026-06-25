<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useLanguage } from '~/composables/useLanguage'

const { t } = useLanguage()
const connectorRef = ref<HTMLElement | null>(null)
const sectionRef = ref<HTMLElement | null>(null)

const steps = computed(() => [
  {
    number: '01',
    icon: '📱',
    title: t('howItWorks.step1_title'),
    desc: t('howItWorks.step1_desc'),
  },
  {
    number: '02',
    icon: '🗺️',
    title: t('howItWorks.step2_title'),
    desc: t('howItWorks.step2_desc'),
  },
  {
    number: '03',
    icon: '✅',
    title: t('howItWorks.step3_title'),
    desc: t('howItWorks.step3_desc'),
  },
])

onMounted(() => {
  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          connectorRef.value?.classList.add('visible')
          sectionRef.value?.querySelectorAll('.hiw-step').forEach((el, i) => {
            setTimeout(() => el.classList.add('visible'), i * 200)
          })
        }
      })
    },
    { threshold: 0.3 }
  )
  if (sectionRef.value) observer.observe(sectionRef.value)
})
</script>

<template>
  <section class="section" ref="sectionRef" style="background: var(--bg-2); position:relative; overflow:hidden;">
    <div class="orb orb-violet" style="width:500px;height:500px;left:50%;top:50%;transform:translate(-50%,-50%);opacity:0.3;" />
    <div class="container" style="position:relative;z-index:1;">
      <div class="section-header centered fade-up">
        <div class="section-tag">{{ t('howItWorks.tag') }}</div>
        <h2 class="section-title">{{ t('howItWorks.title_1') }}<span class="gradient-text">{{ t('howItWorks.title_highlight') }}</span></h2>
        <p class="section-subtitle">
          {{ t('howItWorks.subtitle') }}
        </p>
      </div>

      <div class="hiw-grid">
        <!-- Connector line -->
        <div class="hiw-connector" ref="connectorRef" />

        <div
          v-for="(step, i) in steps"
          :key="i"
          class="hiw-step fade-up"
        >
          <div class="hiw-number">{{ step.number }}</div>
          <span class="hiw-step-icon">{{ step.icon }}</span>
          <h3 class="hiw-title">{{ step.title }}</h3>
          <p class="hiw-desc">{{ step.desc }}</p>
        </div>
      </div>
    </div>
  </section>
</template>
