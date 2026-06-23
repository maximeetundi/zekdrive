<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'

const testimonials = [
  {
    text: 'Incroyable ! J\'arrive au bureau en 10 minutes maintenant. Les chauffeurs sont toujours ponctuels et les voitures sont impeccables. Je recommande vivement !',
    name: 'Fatou D.',
    city: 'Dakar, Sénégal',
    initials: 'FD',
    color: '#7c3aed',
    stars: 5,
  },
  {
    text: 'Les chauffeurs sont très professionnels et courtois. L\'application est super simple à utiliser. C\'est la meilleure plateforme de VTC que j\'ai utilisée en Afrique.',
    name: 'Kofi A.',
    city: 'Abidjan, Côte d\'Ivoire',
    initials: 'KA',
    color: '#00e5cc',
    stars: 5,
  },
  {
    text: 'La livraison est super rapide et fiable. J\'utilise ZekDrive pour envoyer mes colis chaque semaine. Le suivi en temps réel est fantastique !',
    name: 'Aminata S.',
    city: 'Bamako, Mali',
    initials: 'AS',
    color: '#f59e0b',
    stars: 5,
  },
  {
    text: 'J\'utilise le service moto-taxi tous les jours pour éviter les embouteillages. C\'est rapide, abordable et les tarifs sont transparents. Bravo ZekDrive !',
    name: 'Jean-Pierre M.',
    city: 'Kinshasa, RDC',
    initials: 'JP',
    color: '#4ade80',
    stars: 5,
  },
  {
    text: 'Excellent service ! Le paiement via Orange Money est super pratique. Je n\'ai plus besoin d\'avoir du liquide sur moi. L\'application est parfaite.',
    name: 'Sandrine B.',
    city: 'Douala, Cameroun',
    initials: 'SB',
    color: '#f472b6',
    stars: 5,
  },
  {
    text: 'ZekDrive Pro est parfait pour notre entreprise. On gère toutes nos courses professionnelles depuis un seul compte. Service client très réactif aussi !',
    name: 'Oumar T.',
    city: 'Dakar, Sénégal',
    initials: 'OT',
    color: '#60a5fa',
    stars: 5,
  },
]

const current = ref(0)
const maxIndex = computed(() => Math.max(0, testimonials.length - 3))
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
        <div class="section-tag">Témoignages</div>
        <h2 class="section-title">Ce que disent nos <span class="gradient-text">utilisateurs</span></h2>
        <p class="section-subtitle">
          Des milliers de personnes font confiance à ZekDrive pour leurs déplacements quotidiens.
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
