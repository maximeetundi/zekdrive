<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { useLanguage } from '~/composables/useLanguage'

const { t } = useLanguage()

const isMobile = ref(false)
function checkMobile() {
  isMobile.value = window.innerWidth <= 768
}

// Generate particles
const particles = Array.from({ length: 25 }, (_, i) => ({
  id: i,
  left: Math.random() * 100,
  delay: Math.random() * 20,
  duration: 15 + Math.random() * 20,
  size: 2 + Math.random() * 3,
}))

onMounted(() => {
  checkMobile()
  window.addEventListener('resize', checkMobile, { passive: true })
})

onUnmounted(() => {
  window.removeEventListener('resize', checkMobile)
})
</script>

<template>
  <section class="hero">
    <!-- Background -->
    <div class="hero-bg" />
    <div class="orb orb-violet" style="width:600px;height:600px;top:-100px;left:-200px;animation-duration:25s;" />
    <div class="orb orb-teal" style="width:400px;height:400px;top:30%;right:-100px;animation-duration:20s;animation-delay:-8s;" />
    <div class="orb orb-purple" style="width:300px;height:300px;bottom:10%;left:30%;animation-duration:18s;animation-delay:-4s;" />

    <!-- Floating particles -->
    <div class="particles">
      <div
        v-for="p in particles"
        :key="p.id"
        class="particle"
        :style="{
          left: p.left + '%',
          animationDelay: p.delay + 's',
          animationDuration: p.duration + 's',
          width: p.size + 'px',
          height: p.size + 'px',
        }"
      />
    </div>

    <div class="container">
      <div class="hero-grid">
        <!-- Left: Content -->
        <div class="hero-content">
          <div class="hero-badge">
            <span class="badge-stars">★★★★★</span>
            <span>{{ t('hero.stars') }}</span>
          </div>

          <h1 class="hero-title">
            {{ t('hero.title_1') }}
            <span class="highlight">{{ t('hero.title_highlight') }}</span>
            {{ t('hero.title_2') }}
          </h1>

          <p class="hero-sub">
            {{ t('hero.sub') }}
          </p>

          <div class="hero-actions">
            <a href="#download" class="btn btn-primary btn-lg">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
              </svg>
              App Store
            </a>
            <a href="#download" class="btn btn-outline btn-lg">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                <path d="M3.18 23.76c.38.21.82.22 1.22.03l12.62-7.28-2.68-2.68-11.16 9.93zM.54 2.23C.2 2.63 0 3.19 0 3.9v16.2c0 .71.2 1.27.54 1.67l.09.09 9.08-9.08v-.21L.63 2.14l-.09.09zM20.4 10.43l-2.6-1.5-2.98 2.98 2.98 2.98 2.62-1.51c.75-.43.75-1.12 0-1.95zM4.4.21L17.02 7.49l-2.68 2.68L3.18.24A1.14 1.14 0 0 1 4.4.21z"/>
              </svg>
              Google Play
            </a>
          </div>

          <!-- Mini stats -->
          <div class="hero-stats">
            <div>
              <div class="hero-stat-num">50K+</div>
              <div class="hero-stat-label">{{ t('hero.users') }}</div>
            </div>
            <div>
              <div class="hero-stat-num">500+</div>
              <div class="hero-stat-label">{{ t('hero.drivers') }}</div>
            </div>
            <div>
              <div class="hero-stat-num">4.9★</div>
              <div class="hero-stat-label">{{ t('hero.rating') }}</div>
            </div>
          </div>
        </div>

        <!-- Right: Dual Phone Mockups -->
        <div class="hero-visual">
          <div class="dual-phones">
            <div class="phone-container phone-vtc">
              <PhoneMockup :force-mode="isMobile ? undefined : 'vtc'" />
            </div>
            <div class="phone-container phone-delivery">
              <PhoneMockup force-mode="delivery" />
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Scroll indicator -->
    <div class="scroll-indicator">
      <span>{{ t('hero.discover') }}</span>
      <div class="scroll-arrow">
        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
          <path d="M6 9l6 6 6-6" />
        </svg>
      </div>
    </div>
  </section>
</template>

<style scoped>
.dual-phones {
  display: flex;
  gap: 32px;
  align-items: center;
  position: relative;
  width: 100%;
  justify-content: center;
}

.phone-container {
  position: relative;
  transition: all 0.5s cubic-bezier(0.4, 0, 0.2, 1);
}

.phone-vtc {
  transform: translateY(-20px) rotate(-3deg);
  z-index: 2;
}

.phone-delivery {
  transform: translateY(20px) rotate(3deg);
  z-index: 1;
}

.phone-container:hover {
  transform: scale(1.05) translateY(0) rotate(0deg);
  z-index: 10;
}

@media (max-width: 768px) {
  .dual-phones {
    gap: 0;
  }
  .phone-delivery {
    display: none;
  }
  .phone-vtc {
    transform: none;
    z-index: 1;
  }
  .phone-vtc:hover {
    transform: none;
  }
}
</style>
