<script setup lang="ts">
import { computed } from 'vue'
import { useLanguage } from '~/composables/useLanguage'

const { t } = useLanguage()

const footerLinks = computed(() => ({
  services: [
    { label: t('services.vtc_title'), href: '/#services' },
    { label: t('services.moto_title'), href: '/#services' },
    { label: t('services.bike_title'), href: '/#services' },
    { label: t('services.delivery_title'), href: '/#services' },
  ],
  entreprise: [
    { label: t('footer.about'), href: '/' },
    { label: t('nav.becomeDriver'), href: '/driver' },
    { label: t('nav.pro'), href: '/pro' },
    { label: t('footer.careers'), href: '/' },
    { label: t('footer.press'), href: '/' },
  ],
  legal: [
    { label: t('footer.terms'), href: '/' },
    { label: t('footer.privacy'), href: '/' },
    { label: t('footer.cookies'), href: '/' },
    { label: t('footer.accessibility'), href: '/' },
  ],
}))

const socials = [
  {
    name: 'Twitter/X',
    href: 'https://twitter.com',
    icon: `<svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-4.714-6.231-5.401 6.231H2.744l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/></svg>`,
  },
  {
    name: 'Instagram',
    href: 'https://instagram.com',
    icon: `<svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/></svg>`,
  },
  {
    name: 'Facebook',
    href: 'https://facebook.com',
    icon: `<svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/></svg>`,
  },
  {
    name: 'LinkedIn',
    href: 'https://linkedin.com',
    icon: `<svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/></svg>`,
  },
]
</script>

<template>
  <footer class="footer">
    <div class="container">
      <div class="footer-grid">
        <!-- Brand column -->
        <div class="footer-brand">
          <NuxtLink to="/" class="nav-logo" style="margin-bottom: 16px; display: inline-flex;">
            <img src="/logo.png" alt="ZekDrive Logo" class="logo-img" style="width: 38px; height: 38px; object-fit: contain; border-radius: 10px; box-shadow: 0 4px 16px rgba(0, 115, 95, 0.25); margin-right: 10px;" />
            <span>ZekDrive</span>
          </NuxtLink>
          <p class="footer-tagline">
            {{ t('footer.tagline') }}
          </p>
          <div class="footer-socials">
            <a
               v-for="social in socials"
               :key="social.name"
               :href="social.href"
               class="social-btn"
               :aria-label="social.name"
               target="_blank"
               rel="noopener"
               v-html="social.icon"
               />
          </div>
        </div>

        <!-- Services -->
        <div class="footer-col">
          <h4>{{ t('footer.services') }}</h4>
          <ul class="footer-links">
            <li v-for="link in footerLinks.services" :key="link.label">
              <a :href="link.href">{{ link.label }}</a>
            </li>
          </ul>
        </div>

        <!-- Entreprise -->
        <div class="footer-col">
          <h4>{{ t('footer.entreprise') }}</h4>
          <ul class="footer-links">
            <li v-for="link in footerLinks.entreprise" :key="link.label">
              <NuxtLink :to="link.href">{{ link.label }}</NuxtLink>
            </li>
          </ul>
        </div>

        <!-- Légal -->
        <div class="footer-col">
          <h4>{{ t('footer.legal') }}</h4>
          <ul class="footer-links">
            <li v-for="link in footerLinks.legal" :key="link.label">
              <a :href="link.href">{{ link.label }}</a>
            </li>
          </ul>

          <div style="margin-top: 28px;">
            <h4>{{ t('footer.download') }}</h4>
            <div class="footer-app-badges" style="flex-direction: column; gap: 10px; margin-top: 0;">
              <a href="#" class="store-badge">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
                </svg>
                <div class="store-badge-text">
                  <span>{{ t('download.store_ios_lbl') }}</span>
                  <span>App Store</span>
                </div>
              </a>
              <a href="#" class="store-badge">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M3.18 23.76c.38.21.82.22 1.22.03l12.62-7.28-2.68-2.68-11.16 9.93zM.54 2.23C.2 2.63 0 3.19 0 3.9v16.2c0 .71.2 1.27.54 1.67l.09.09 9.08-9.08v-.21L.63 2.14l-.09.09zM20.4 10.43l-2.6-1.5-2.98 2.98 2.98 2.98 2.62-1.51c.75-.43.75-1.12 0-1.95zM4.4.21L17.02 7.49l-2.68 2.68L3.18.24A1.14 1.14 0 0 1 4.4.21z"/>
                </svg>
                <div class="store-badge-text">
                  <span>{{ t('download.store_android_lbl') }}</span>
                  <span>Google Play</span>
                </div>
              </a>
            </div>
          </div>
        </div>
      </div>

      <div class="footer-bottom">
        <p class="footer-copyright">
          {{ t('footer.copyright') }}
        </p>
        <div style="display: flex; gap: 20px;">
          <a href="/" style="font-size: 0.85rem; color: var(--text-subtle); transition: color 0.3s;" 
             onmouseover="this.style.color='var(--teal)'" 
             onmouseout="this.style.color='var(--text-subtle)'">
            {{ t('footer.privacy') }}
          </a>
          <a href="/" style="font-size: 0.85rem; color: var(--text-subtle); transition: color 0.3s;"
             onmouseover="this.style.color='var(--teal)'" 
             onmouseout="this.style.color='var(--text-subtle)'">
            {{ t('footer.terms') }}
          </a>
          <a href="/" style="font-size: 0.85rem; color: var(--text-subtle); transition: color 0.3s;"
             onmouseover="this.style.color='var(--teal)'" 
             onmouseout="this.style.color='var(--text-subtle)'">
            {{ t('footer.cookies') }}
          </a>
        </div>
      </div>
    </div>
  </footer>
</template>
