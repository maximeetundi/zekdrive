<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useScrollAnimation } from '~/composables/useScrollAnimation'
import { useLanguage } from '~/composables/useLanguage'

const { t } = useLanguage()
const { observe } = useScrollAnimation()
const sectionRef = ref<HTMLElement | null>(null)

const features = computed(() => [
  {
    icon: '🗺️',
    title: t('features.feat1_title'),
    desc: t('features.feat1_desc'),
  },
  {
    icon: '💳',
    title: t('features.feat2_title'),
    desc: t('features.feat2_desc'),
  },
  {
    icon: '⭐',
    title: t('features.feat3_title'),
    desc: t('features.feat3_desc'),
  },
  {
    icon: '📞',
    title: t('features.feat4_title'),
    desc: t('features.feat4_desc'),
  },
  {
    icon: '🚗',
    title: t('features.feat5_title'),
    desc: t('features.feat5_desc'),
  },
  {
    icon: '⚡',
    title: t('features.feat6_title'),
    desc: t('features.feat6_desc'),
  },
])

onMounted(() => {
  const cards = sectionRef.value?.querySelectorAll('.feature-card')
  cards?.forEach((card, i) => {
    setTimeout(() => observe(card as HTMLElement), i * 80)
  })
})
</script>

<template>
  <section class="section" ref="sectionRef" style="position:relative;overflow:hidden;">
    <div class="orb orb-teal" style="width:350px;height:350px;top:-50px;right:-100px;opacity:0.4;" />
    <div class="container" style="position:relative;z-index:1;">
      <div class="section-header fade-up">
        <div class="section-tag">{{ t('features.tag') }}</div>
        <h2 class="section-title">{{ t('features.title_1') }}<br><span class="gradient-text">{{ t('features.title_highlight') }}</span></h2>
        <p class="section-subtitle">
          {{ t('features.subtitle') }}
        </p>
      </div>

      <div class="features-grid">
        <div
          v-for="(feature, i) in features"
          :key="i"
          class="feature-card fade-up"
        >
          <div class="feature-icon">{{ feature.icon }}</div>
          <div>
            <h3 class="feature-title">{{ feature.title }}</h3>
            <p class="feature-desc">{{ feature.desc }}</p>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>
