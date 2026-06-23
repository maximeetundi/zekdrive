<script setup lang="ts">
import { onMounted } from 'vue'
import { useScrollAnimation } from '~/composables/useScrollAnimation'

const { observe } = useScrollAnimation()

useHead({
  title: 'ZekDrive — La mobilité urbaine réinventée en Afrique',
  meta: [
    { name: 'description', content: 'VTC, moto-taxi, vélo et livraison — rapide, fiable et abordable. Téléchargez ZekDrive et rejoignez +50 000 utilisateurs en Afrique.' },
  ],
})

onMounted(() => {
  document.querySelectorAll('.fade-up, .fade-in').forEach((el) => {
    observe(el as HTMLElement)
  })
})
</script>

<template>
  <div>
    <TheHeader />
    <main>
      <HeroSection />
      <StatsSection />
      <ServicesSection />
      <HowItWorksSection />
      <FeaturesSection />
      <AppDownloadSection />
      <TestimonialsSection />
      <FaqSection />

      <!-- CTA Banner -->
      <section class="section" style="padding:80px 0;background:var(--bg-2);position:relative;overflow:hidden;">
        <div class="orb orb-violet" style="width:500px;height:500px;left:50%;top:50%;transform:translate(-50%,-50%);opacity:0.4;" />
        <div class="container" style="position:relative;z-index:1;text-align:center;">
          <div class="section-tag" style="margin:0 auto 20px;">Rejoignez-nous</div>
          <h2 class="section-title fade-up">
            Prêt à transformer vos<br><span class="gradient-text">déplacements ?</span>
          </h2>
          <p style="font-size:1.1rem;color:var(--text-muted);max-width:500px;margin:16px auto 40px;" class="fade-up">
            Téléchargez ZekDrive et bénéficiez de votre premier trajet avec 20% de réduction.
          </p>
          <div style="display:flex;gap:16px;justify-content:center;flex-wrap:wrap;" class="fade-up">
            <a href="#download" class="btn btn-primary btn-lg">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
              </svg>
              Télécharger l'App
            </a>
            <NuxtLink to="/driver" class="btn btn-secondary btn-lg">
              Devenir chauffeur
            </NuxtLink>
          </div>
        </div>
      </section>
    </main>
    <TheFooter />
  </div>
</template>
