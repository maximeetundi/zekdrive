<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useLanguage } from '~/composables/useLanguage'

const { t } = useLanguage()

const testimonials = computed(() => [
  {
    text: t('testimonials.t1_text'),
    name: 'Fatou D.',
    city: 'Dakar, Sénégal',
    initials: 'FD',
    color: '#CC5500',
    stars: 5,
  },
  {
    text: t('testimonials.t2_text'),
    name: 'Kofi A.',
    city: 'Abidjan, Côte d\'Ivoire',
    initials: 'KA',
    color: '#FF7A00',
    stars: 5,
  },
  {
    text: t('testimonials.t3_text'),
    name: 'Aminata S.',
    city: 'Bamako, Mali',
    initials: 'AS',
    color: '#f59e0b',
    stars: 5,
  },
  {
    text: t('testimonials.t4_text'),
    name: 'Jean-Pierre M.',
    city: 'Kinshasa, RDC',
    initials: 'JP',
    color: '#4ade80',
    stars: 5,
  },
  {
    text: t('testimonials.t5_text'),
    name: 'Sandrine B.',
    city: 'Douala, Cameroun',
    initials: 'SB',
    color: '#f472b6',
    stars: 5,
  },
  {
    text: t('testimonials.t6_text'),
    name: 'Oumar T.',
    city: 'Dakar, Sénégal',
    initials: 'OT',
    color: '#60a5fa',
    stars: 5,
  },
])

const current = ref(0)
const maxIndex = computed(() => Math.max(0, testimonials.value.length - 3))
let autoplayInterval: ReturnType<typeof setInterval>

function prev() {
  current.value = current.value <= 0 ? maxIndex.value : current.value - 1
}

function next() {
  current.value = current.value >= maxIndex.value ? 0 : current.value + 1
}

function goTo(i: number) {
  current.value = i
}

function startAutoplay() {
  autoplayInterval = setInterval(next, 4500)
}

onMounted(() => {
  startAutoplay()
})

onUnmounted(() => {
  clearInterval(autoplayInterval)
})

function stars(n: number) {
  return '★'.repeat(n)
}
</script>

<template>
  <section class="testimonials-section" style="background:var(--bg-2);position:relative;overflow:hidden;">
    <div class="orb orb-violet" style="width:400px;height:400px;left:-150px;top:50%;transform:translateY(-50%);opacity:0.3;" />

    <div class="container" style="position:relative;z-index:1;">
      <div class="section-header centered fade-up">
        <div class="section-tag">{{ t('testimonials.tag') }}</div>
        <h2 class="section-title">{{ t('testimonials.title_1') }}<span class="gradient-text">{{ t('testimonials.title_highlight') }}</span></h2>
        <p class="section-subtitle">
          {{ t('testimonials.subtitle') }}
        </p>
      </div>

      <!-- Carousel -->
      <div style="overflow:hidden;">
        <div
          class="testimonials-track"
          :style="{ transform: `translateX(calc(-${current * (100/3 + 2.7)}%))` }"
        >
          <div
            v-for="(t, i) in testimonials"
            :key="i"
            class="testimonial-card"
          >
            <div class="testimonial-stars">{{ stars(t.stars) }}</div>
            <p class="testimonial-text">"{{ t.text }}"</p>
            <div class="testimonial-author">
              <div class="author-avatar" :style="{ background: t.color }">
                {{ t.initials }}
              </div>
              <div>
                <div class="author-name">{{ t.name }}</div>
                <div class="author-city">{{ t.city }}</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Arrows -->
      <div class="testimonials-arrows">
        <button class="arrow-btn" @click="prev" aria-label="Précédent">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M15 18l-6-6 6-6"/>
          </svg>
        </button>
        <button class="arrow-btn" @click="next" aria-label="Suivant">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M9 18l6-6-6-6"/>
          </svg>
        </button>
      </div>

      <!-- Dots -->
      <div class="testimonials-nav">
        <button
          v-for="i in maxIndex + 1"
          :key="i"
          class="testimonials-dot"
          :class="{ active: current === i - 1 }"
          @click="goTo(i - 1)"
          :aria-label="`Slide ${i}`"
        />
      </div>
    </div>
  </section>
</template>
