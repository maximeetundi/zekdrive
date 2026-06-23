<script setup lang="ts">
import { ref, onMounted } from 'vue'

const connectorRef = ref<HTMLElement | null>(null)
const sectionRef = ref<HTMLElement | null>(null)

const steps = [
  {
    number: '01',
    icon: '📱',
    title: 'Téléchargez l\'app',
    desc: 'Disponible gratuitement sur App Store et Google Play. Créez votre compte en moins de 2 minutes.',
  },
  {
    number: '02',
    icon: '🗺️',
    title: 'Réservez votre trajet',
    desc: 'Entrez votre destination, choisissez votre type de véhicule et trouvez un chauffeur en moins de 3 min.',
  },
  {
    number: '03',
    icon: '✅',
    title: 'Arrivez à destination',
    desc: 'Suivez votre chauffeur en temps réel et arrivez à destination en toute sécurité et confort.',
  },
]

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
        <div class="section-tag">Comment ça marche</div>
        <h2 class="section-title">Simple comme <span class="gradient-text">bonjour</span></h2>
        <p class="section-subtitle">
          Trois étapes simples pour commencer à profiter de ZekDrive.
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
