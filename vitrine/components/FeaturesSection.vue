<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useScrollAnimation } from '~/composables/useScrollAnimation'

const { observe } = useScrollAnimation()
const sectionRef = ref<HTMLElement | null>(null)

const features = [
  {
    icon: '🗺️',
    title: 'Suivi en temps réel',
    desc: 'Suivez votre chauffeur sur la carte en direct avec une précision GPS optimale.',
  },
  {
    icon: '💳',
    title: 'Paiements sécurisés',
    desc: 'Mobile money (Orange, MTN, Wave), carte bancaire ou espèces — vous choisissez.',
  },
  {
    icon: '⭐',
    title: 'Chauffeurs notés',
    desc: 'Chaque chauffeur est vérifié, noté et évalué par notre communauté.',
  },
  {
    icon: '📞',
    title: 'Support 24/7',
    desc: 'Notre équipe est disponible à toute heure pour vous aider.',
  },
  {
    icon: '🚗',
    title: 'Multi-véhicules',
    desc: 'VTC, moto-taxi, vélo — choisissez selon votre budget et vos besoins.',
  },
  {
    icon: '⚡',
    title: 'Réservation rapide',
    desc: 'Trouvez un chauffeur disponible en moins de 2 minutes, garanti.',
  },
]

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
        <div class="section-tag">Fonctionnalités</div>
        <h2 class="section-title">Conçu pour vous faire<br><span class="gradient-text">gagner du temps</span></h2>
        <p class="section-subtitle">
          ZekDrive intègre tout ce dont vous avez besoin pour des déplacements sans stress.
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
