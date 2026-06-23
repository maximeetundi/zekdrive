<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useScrollAnimation } from '~/composables/useScrollAnimation'

const { observe } = useScrollAnimation()
const sectionRef = ref<HTMLElement | null>(null)

onMounted(() => {
  if (sectionRef.value) observe(sectionRef.value)
})
</script>

<template>
  <section id="download" class="app-section" ref="sectionRef">
    <div class="orb orb-violet" style="width:500px;height:500px;left:-150px;top:-100px;opacity:0.4;" />
    <div class="orb orb-teal" style="width:400px;height:400px;right:-100px;bottom:-100px;opacity:0.3;" />

    <div class="container" style="position:relative;z-index:1;">
      <div class="app-section-inner fade-up">
        <!-- Left content -->
        <div>
          <div class="section-tag" style="margin-bottom:20px;">Application Mobile</div>
          <h2 class="section-title" style="margin-bottom:16px;">
            Téléchargez <span class="gradient-text">ZekDrive</span>
          </h2>
          <p style="font-size:1rem;color:var(--text-muted);line-height:1.7;margin-bottom:32px;">
            Disponible gratuitement sur iOS et Android. Rejoignez des milliers d'utilisateurs qui font confiance à ZekDrive pour leurs déplacements quotidiens.
          </p>

          <div class="app-buttons">
            <!-- App Store -->
            <a href="#" class="app-btn app-btn-white">
              <svg width="28" height="28" viewBox="0 0 24 24" fill="currentColor">
                <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
              </svg>
              <div class="app-btn-label">
                <span>Télécharger sur</span>
                <span>App Store</span>
              </div>
            </a>

            <!-- Google Play -->
            <a href="#" class="app-btn app-btn-gradient">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
                <path d="M3.18 23.76c.38.21.82.22 1.22.03l12.62-7.28-2.68-2.68-11.16 9.93zM.54 2.23C.2 2.63 0 3.19 0 3.9v16.2c0 .71.2 1.27.54 1.67l.09.09 9.08-9.08v-.21L.63 2.14l-.09.09zM20.4 10.43l-2.6-1.5-2.98 2.98 2.98 2.98 2.62-1.51c.75-.43.75-1.12 0-1.95zM4.4.21L17.02 7.49l-2.68 2.68L3.18.24A1.14 1.14 0 0 1 4.4.21z"/>
              </svg>
              <div class="app-btn-label">
                <span>Disponible sur</span>
                <span>Google Play</span>
              </div>
            </a>
          </div>

          <ul class="app-features-list">
            <li class="app-feature-item">
              <div class="app-feature-check">✓</div>
              <span>Disponible sur iOS & Android — 100% gratuit</span>
            </li>
            <li class="app-feature-item">
              <div class="app-feature-check">✓</div>
              <span>Mises à jour régulières avec de nouvelles fonctionnalités</span>
            </li>
            <li class="app-feature-item">
              <div class="app-feature-check">✓</div>
              <span>Interface disponible en français et en langues locales</span>
            </li>
            <li class="app-feature-item">
              <div class="app-feature-check">✓</div>
              <span>Fonctionne même avec une connexion internet lente</span>
            </li>
          </ul>
        </div>

        <!-- Right: QR + visual -->
        <div class="app-qr-wrap">
          <!-- QR Code SVG -->
          <div style="background:white;padding:20px;border-radius:16px;box-shadow:0 20px 60px rgba(124,58,237,0.3);">
            <svg width="160" height="160" viewBox="0 0 160 160" xmlns="http://www.w3.org/2000/svg">
              <!-- QR Code pattern -->
              <rect width="160" height="160" fill="white"/>
              <!-- Top-left finder -->
              <rect x="10" y="10" width="50" height="50" rx="6" fill="#0d1120"/>
              <rect x="18" y="18" width="34" height="34" rx="4" fill="white"/>
              <rect x="24" y="24" width="22" height="22" rx="2" fill="#7c3aed"/>
              <!-- Top-right finder -->
              <rect x="100" y="10" width="50" height="50" rx="6" fill="#0d1120"/>
              <rect x="108" y="18" width="34" height="34" rx="4" fill="white"/>
              <rect x="114" y="24" width="22" height="22" rx="2" fill="#7c3aed"/>
              <!-- Bottom-left finder -->
              <rect x="10" y="100" width="50" height="50" rx="6" fill="#0d1120"/>
              <rect x="18" y="108" width="34" height="34" rx="4" fill="white"/>
              <rect x="24" y="114" width="22" height="22" rx="2" fill="#7c3aed"/>
              <!-- Data modules (simulated) -->
              <rect x="72" y="10" width="8" height="8" rx="2" fill="#00e5cc"/>
              <rect x="84" y="10" width="8" height="8" rx="2" fill="#0d1120"/>
              <rect x="72" y="20" width="8" height="8" rx="2" fill="#0d1120"/>
              <rect x="84" y="20" width="8" height="8" rx="2" fill="#00e5cc"/>
              <rect x="72" y="30" width="8" height="8" rx="2" fill="#7c3aed"/>
              <rect x="84" y="30" width="8" height="8" rx="2" fill="#0d1120"/>
              <rect x="10" y="72" width="8" height="8" rx="2" fill="#0d1120"/>
              <rect x="20" y="72" width="8" height="8" rx="2" fill="#00e5cc"/>
              <rect x="30" y="72" width="8" height="8" rx="2" fill="#7c3aed"/>
              <rect x="40" y="72" width="8" height="8" rx="2" fill="#0d1120"/>
              <rect x="50" y="72" width="8" height="8" rx="2" fill="#00e5cc"/>
              <rect x="62" y="62" width="38" height="38" rx="6" fill="#0d1120"/>
              <rect x="68" y="68" width="26" height="26" rx="4" fill="white"/>
              <!-- Logo in center -->
              <text x="80" y="84" font-family="Sora,sans-serif" font-weight="800" font-size="12" fill="#7c3aed" text-anchor="middle">Z</text>
              <rect x="100" y="72" width="8" height="8" rx="2" fill="#0d1120"/>
              <rect x="110" y="72" width="8" height="8" rx="2" fill="#7c3aed"/>
              <rect x="120" y="72" width="8" height="8" rx="2" fill="#0d1120"/>
              <rect x="130" y="72" width="8" height="8" rx="2" fill="#00e5cc"/>
              <rect x="140" y="72" width="8" height="8" rx="2" fill="#0d1120"/>
              <rect x="100" y="82" width="8" height="8" rx="2" fill="#7c3aed"/>
              <rect x="110" y="82" width="8" height="8" rx="2" fill="#0d1120"/>
              <rect x="120" y="82" width="8" height="8" rx="2" fill="#00e5cc"/>
              <rect x="130" y="82" width="8" height="8" rx="2" fill="#0d1120"/>
              <rect x="140" y="82" width="8" height="8" rx="2" fill="#7c3aed"/>
              <rect x="100" y="100" width="8" height="8" rx="2" fill="#0d1120"/>
              <rect x="110" y="100" width="8" height="8" rx="2" fill="#7c3aed"/>
              <rect x="120" y="100" width="8" height="8" rx="2" fill="#0d1120"/>
              <rect x="130" y="100" width="8" height="8" rx="2" fill="#00e5cc"/>
              <rect x="140" y="100" width="8" height="8" rx="2" fill="#0d1120"/>
              <rect x="100" y="110" width="8" height="8" rx="2" fill="#00e5cc"/>
              <rect x="110" y="110" width="8" height="8" rx="2" fill="#0d1120"/>
              <rect x="120" y="110" width="8" height="8" rx="2" fill="#7c3aed"/>
              <rect x="130" y="110" width="8" height="8" rx="2" fill="#0d1120"/>
              <rect x="140" y="110" width="8" height="8" rx="2" fill="#0d1120"/>
              <rect x="10" y="82" width="8" height="8" rx="2" fill="#00e5cc"/>
              <rect x="20" y="82" width="8" height="8" rx="2" fill="#0d1120"/>
              <rect x="30" y="82" width="8" height="8" rx="2" fill="#7c3aed"/>
              <rect x="40" y="82" width="8" height="8" rx="2" fill="#0d1120"/>
              <rect x="50" y="82" width="8" height="8" rx="2" fill="#00e5cc"/>
              <rect x="100" y="120" width="8" height="8" rx="2" fill="#0d1120"/>
              <rect x="110" y="120" width="8" height="8" rx="2" fill="#7c3aed"/>
              <rect x="120" y="120" width="8" height="8" rx="2" fill="#0d1120"/>
              <rect x="130" y="120" width="8" height="8" rx="2" fill="#0d1120"/>
              <rect x="140" y="120" width="8" height="8" rx="2" fill="#00e5cc"/>
              <rect x="100" y="130" width="8" height="8" rx="2" fill="#7c3aed"/>
              <rect x="110" y="130" width="8" height="8" rx="2" fill="#0d1120"/>
              <rect x="120" y="130" width="8" height="8" rx="2" fill="#00e5cc"/>
              <rect x="130" y="130" width="8" height="8" rx="2" fill="#7c3aed"/>
              <rect x="140" y="130" width="8" height="8" rx="2" fill="#0d1120"/>
              <rect x="100" y="140" width="8" height="8" rx="2" fill="#0d1120"/>
              <rect x="110" y="140" width="8" height="8" rx="2" fill="#00e5cc"/>
              <rect x="120" y="140" width="8" height="8" rx="2" fill="#0d1120"/>
              <rect x="130" y="140" width="8" height="8" rx="2" fill="#0d1120"/>
              <rect x="140" y="140" width="8" height="8" rx="2" fill="#7c3aed"/>
            </svg>
          </div>
          <p style="font-size:0.85rem;color:var(--text-subtle);text-align:center;">
            Scannez pour télécharger l'application
          </p>

          <!-- Rating badge -->
          <div class="glass" style="border-radius:16px;padding:20px 28px;text-align:center;">
            <div style="font-family:'Sora',sans-serif;font-size:2.5rem;font-weight:800;background:var(--gradient-text);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;">4.9</div>
            <div style="color:#fbbf24;font-size:1.1rem;margin:4px 0;">★★★★★</div>
            <div style="font-size:0.8rem;color:var(--text-muted);">+12 400 avis</div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>
