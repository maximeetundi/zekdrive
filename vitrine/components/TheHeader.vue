<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'

const scrolled = ref(false)
const menuOpen = ref(false)
const route = useRoute()

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
            <div class="logo-mark">Z</div>
            <span>ZekDrive</span>
          </NuxtLink>

          <!-- Desktop Links -->
          <ul class="nav-links">
            <li>
              <NuxtLink to="/" :class="{ active: isActive('/') }">Accueil</NuxtLink>
            </li>
            <li>
              <NuxtLink to="/#services" :class="{ active: false }">Services</NuxtLink>
            </li>
            <li>
              <NuxtLink to="/driver" :class="{ active: isActive('/driver') }">Devenir Chauffeur</NuxtLink>
            </li>
            <li>
              <NuxtLink to="/pro" :class="{ active: isActive('/pro') }">Pro</NuxtLink>
            </li>
            <li>
              <NuxtLink to="/contact" :class="{ active: isActive('/contact') }">Contact</NuxtLink>
            </li>
          </ul>

          <!-- CTA -->
          <div class="nav-cta">
            <a href="#download" class="btn btn-primary btn-sm">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
              </svg>
              Télécharger l'App
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
      <NuxtLink to="/" @click="closeMenu">Accueil</NuxtLink>
      <NuxtLink to="/#services" @click="closeMenu">Services</NuxtLink>
      <NuxtLink to="/driver" @click="closeMenu">Devenir Chauffeur</NuxtLink>
      <NuxtLink to="/pro" @click="closeMenu">Pro</NuxtLink>
      <NuxtLink to="/contact" @click="closeMenu">Contact</NuxtLink>
      <a href="#download" class="btn btn-primary" @click="closeMenu" style="margin-top: 16px;">
        Télécharger l'App
      </a>
    </div>
  </header>
</template>
