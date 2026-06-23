// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },

  css: ['~/assets/css/main.css'],

  app: {
    head: {
      charset: 'utf-8',
      viewport: 'width=device-width, initial-scale=1',
      title: 'ZekDrive — La mobilité urbaine réinventée en Afrique',
      meta: [
        { name: 'description', content: 'ZekDrive est la plateforme de mobilité urbaine premium en Afrique. VTC, moto-taxi, vélo et livraison de colis — rapide, fiable et abordable.' },
        { name: 'keywords', content: 'ZekDrive, VTC Afrique, moto-taxi, livraison, mobilité urbaine, Dakar, Abidjan, Bamako' },
        { property: 'og:title', content: 'ZekDrive — La mobilité urbaine réinventée en Afrique' },
        { property: 'og:description', content: 'Commandez un VTC, une moto-taxi ou faites livrer vos colis avec ZekDrive.' },
        { property: 'og:type', content: 'website' },
        { property: 'og:image', content: '/og-image.png' },
        { name: 'twitter:card', content: 'summary_large_image' },
        { name: 'theme-color', content: '#080b14' },
      ],
      link: [
        { rel: 'preconnect', href: 'https://fonts.googleapis.com' },
        { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' },
        {
          rel: 'stylesheet',
          href: 'https://fonts.googleapis.com/css2?family=Sora:wght@300;400;600;700;800&family=Inter:wght@300;400;500;600&display=swap',
        },
        { rel: 'icon', type: 'image/svg+xml', href: '/favicon.svg' },
      ],
    },
  },

  nitro: {
    prerender: {
      routes: ['/', '/driver', '/pro', '/contact'],
    },
  },

  typescript: {
    strict: false,
  },

  compatibilityDate: '2024-11-01',
})
