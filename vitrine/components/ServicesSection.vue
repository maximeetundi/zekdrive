<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useScrollAnimation } from '~/composables/useScrollAnimation'

const { observe } = useScrollAnimation()
const sectionRef = ref<HTMLElement | null>(null)

const services = [
  {
    icon: '🚗',
    title: 'VTC Premium',
    desc: 'Confortez-vous à bord d\'un véhicule climatisé avec des chauffeurs professionnels. Idéal pour vos déplacements d\'affaires et sorties en toute élégance.',
    tag: 'Le plus populaire',
    color: '#7c3aed',
  },
  {
    icon: '🏍️',
    title: 'Moto-Taxi',
    desc: 'Traversez la ville en un éclair grâce à nos moto-taxis agiles. Évitez les embouteillages et arrivez à l\'heure, à chaque fois.',
    tag: 'Express',
    color: '#00e5cc',
  },
  {
    icon: '🚲',
    title: 'Vélo',
    desc: 'Déplacez-vous de manière écologique et économique avec notre service de vélo. Parfait pour les courtes distances en zone urbaine.',
    tag: 'Éco-responsable',
    color: '#4ade80',
  },
  {
    icon: '📦',
    title: 'Livraison',
    desc: 'Envoyez vos colis en toute sécurité partout dans la ville. Suivi en temps réel, livraison garantie et assurance incluse.',
    tag: 'Fiable & Rapide',
    color: '#f59e0b',
  },
]

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
        <div class="section-tag">Nos Services</div>
        <h2 class="section-title">Tout ce dont vous avez besoin,<br><span class="gradient-text">en un seul clic</span></h2>
        <p class="section-subtitle">
          Que vous ayez besoin d'un VTC, d'une moto-taxi ou d'une livraison, ZekDrive vous couvre 24h/24, 7j/7.
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
