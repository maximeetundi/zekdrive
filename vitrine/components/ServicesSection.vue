<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useScrollAnimation } from '~/composables/useScrollAnimation'
import { useLanguage } from '~/composables/useLanguage'

const { t } = useLanguage()
const { observe } = useScrollAnimation()
const sectionRef = ref<HTMLElement | null>(null)

const services = computed(() => [
  {
    icon: '🚗',
    title: t('services.vtc_title'),
    desc: t('services.vtc_desc'),
    tag: t('services.vtc_tag'),
    color: '#CC5500',
  },
  {
    icon: '🏍️',
    title: t('services.moto_title'),
    desc: t('services.moto_desc'),
    tag: t('services.moto_tag'),
    color: '#FF7A00',
  },
  {
    icon: '🚲',
    title: t('services.bike_title'),
    desc: t('services.bike_desc'),
    tag: t('services.bike_tag'),
    color: '#4ade80',
  },
  {
    icon: '📦',
    title: t('services.delivery_title'),
    desc: t('services.delivery_desc'),
    tag: t('services.delivery_tag'),
    color: '#f59e0b',
  },
  {
    icon: '🍔',
    title: t('services.food_title'),
    desc: t('services.food_desc'),
    tag: t('services.food_tag'),
    color: '#ef4444',
  },
  {
    icon: '🛍️',
    title: t('services.shop_title'),
    desc: t('services.shop_desc'),
    tag: t('services.shop_tag'),
    color: '#ec4899',
  },
])

onMounted(() => {
  const cards = sectionRef.value?.querySelectorAll('.service-card')
  cards?.forEach((card, i) => {
    setTimeout(() => observe(card as HTMLElement), i * 100)
  })
})
</script>

<template>
  <section id="services" class="section" ref="sectionRef" style="position:relative;overflow:hidden;">
    <!-- Background orbs -->
    <div class="orb orb-violet" style="width:400px;height:400px;right:-100px;top:0;opacity:0.5;" />
    <div class="orb orb-teal" style="width:300px;height:300px;left:-80px;bottom:0;opacity:0.4;" />

    <div class="container" style="position:relative;z-index:1;">
      <div class="section-header fade-up">
        <div class="section-tag">{{ t('services.tag') }}</div>
        <h2 class="section-title">{{ t('services.title_1') }}<br><span class="gradient-text">{{ t('services.title_highlight') }}</span></h2>
        <p class="section-subtitle">
          {{ t('services.subtitle') }}
        </p>
      </div>

      <div class="services-grid">
        <div
          v-for="(service, i) in services"
          :key="i"
          class="service-card fade-up"
          :style="{ '--accent': service.color }"
        >
          <div class="card-glow" :style="{ background: service.color, top: '20px', right: '20px' }" />
          <div class="service-icon-wrap" :style="{ background: service.color + '18', borderColor: service.color + '30' }">
            <span>{{ service.icon }}</span>
          </div>
          <h3 class="service-card-title">{{ service.title }}</h3>
          <p class="service-card-desc">{{ service.desc }}</p>
          <div class="service-card-tag" :style="{ color: service.color, background: service.color + '15' }">
            <svg width="8" height="8" viewBox="0 0 8 8" fill="currentColor">
              <circle cx="4" cy="4" r="4"/>
            </svg>
            {{ service.tag }}
          </div>
        </div>
      </div>
    </div>
  </section>
</template>
