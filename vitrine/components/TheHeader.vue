<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'
import { useLanguage } from '~/composables/useLanguage'

const scrolled = ref(false)
const menuOpen = ref(false)
const route = useRoute()
const { currentLang, t, setLanguage, toggleLanguage } = useLanguage()

function handleScroll() {
  scrolled.value = window.scrollY > 50
}

function toggleMenu() {
  menuOpen.value = !menuOpen.value
  document.body.style.overflow = menuOpen.value ? 'hidden' : ''
}

function closeMenu() {
  menuOpen.value = false
  document.body.style.overflow = ''
}

function isActive(path: string) {
  return route.path === path
}

onMounted(() => {
  window.addEventListener('scroll', handleScroll, { passive: true })
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
  document.body.style.overflow = ''
})
</script>

<template>
  <header>
    <nav class="nav" :class="{ scrolled }">
      <div class="container">
        <div class="nav-inner">
          <!-- Logo -->
          <NuxtLink to="/" class="nav-logo" @click="closeMenu">
            <img src="/logo.png" alt="ZekDrive Logo" class="logo-img" style="width: 38px; height: 38px; object-fit: contain; border-radius: 10px; box-shadow: 0 4px 16px rgba(255, 122, 0, 0.35);" />
            <span>ZekDrive</span>
          </NuxtLink>

          <!-- Desktop Links -->
          <ul class="nav-links">
            <li>
              <NuxtLink to="/" :class="{ active: isActive('/') }">{{ t('nav.home') }}</NuxtLink>
            </li>
            <li>
              <NuxtLink to="/#services" :class="{ active: false }">{{ t('nav.services') }}</NuxtLink>
            </li>
            <li>
              <NuxtLink to="/driver" :class="{ active: isActive('/driver') }">{{ t('nav.becomeDriver') }}</NuxtLink>
            </li>
            <li>
              <NuxtLink to="/pro" :class="{ active: isActive('/pro') }">{{ t('nav.pro') }}</NuxtLink>
            </li>
            <li>
              <NuxtLink to="/contact" :class="{ active: isActive('/contact') }">{{ t('nav.contact') }}</NuxtLink>
            </li>
          </ul>

          <!-- CTA -->
          <div class="nav-cta">
            <button @click="toggleLanguage" class="btn btn-secondary btn-sm lang-btn" style="padding: 8px 12px; display: flex; align-items: center; gap: 6px;">
              <span>🌐</span>
              <span style="font-weight: 600; font-size: 0.85rem;">{{ currentLang.toUpperCase() }}</span>
            </button>
            <a href="#download" class="btn btn-primary btn-sm">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
                <polyline points="7 10 12 15 17 10" />
                <line x1="12" y1="15" x2="12" y2="3" />
              </svg>
              {{ t('nav.download') }}
            </a>
          </div>

          <!-- Hamburger -->
          <div class="hamburger" :class="{ open: menuOpen }" @click="toggleMenu" aria-label="Menu">
            <span />
            <span />
            <span />
          </div>
        </div>
      </div>
    </nav>

    <!-- Mobile Menu -->
    <div class="mobile-menu" :class="{ open: menuOpen }">
      <NuxtLink to="/" @click="closeMenu">{{ t('nav.home') }}</NuxtLink>
      <NuxtLink to="/#services" @click="closeMenu">{{ t('nav.services') }}</NuxtLink>
      <NuxtLink to="/driver" @click="closeMenu">{{ t('nav.becomeDriver') }}</NuxtLink>
      <NuxtLink to="/pro" @click="closeMenu">{{ t('nav.pro') }}</NuxtLink>
      <NuxtLink to="/contact" @click="closeMenu">{{ t('nav.contact') }}</NuxtLink>
      
      <div style="display: flex; gap: 12px; margin-top: 24px; justify-content: center; width: 100%;">
        <button @click="setLanguage('fr')" class="btn btn-sm" :class="currentLang === 'fr' ? 'btn-primary' : 'btn-secondary'" style="flex: 1; justify-content: center;">Français</button>
        <button @click="setLanguage('en')" class="btn btn-sm" :class="currentLang === 'en' ? 'btn-primary' : 'btn-secondary'" style="flex: 1; justify-content: center;">English</button>
      </div>

      <a href="#download" class="btn btn-primary" @click="closeMenu" style="margin-top: 16px; width: 100%; justify-content: center;">
        {{ t('nav.download') }}
      </a>
    </div>
  </header>
</template>
