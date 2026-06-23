// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },

  ssr: true,

  modules: ['@pinia/nuxt'],

  css: ['~/assets/css/main.css'],

  app: {
    head: {
      title: 'ZekDrive Admin',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'description', content: 'ZekDrive Admin Panel - Manage your ride-hailing and delivery platform' },
      ],
      link: [
        { rel: 'preconnect', href: 'https://fonts.googleapis.com' },
        { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' },
        {
          rel: 'stylesheet',
          href: 'https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap',
        },
        { rel: 'icon', type: 'image/svg+xml', href: '/favicon.svg' },
      ],
    },
  },

  runtimeConfig: {
    public: {
      apiUrl: process.env.NUXT_PUBLIC_API_URL || 'http://localhost:8080/api/v1',
      wsUrl: process.env.NUXT_PUBLIC_WS_URL || 'ws://localhost:8080/ws',
    },
  },

  build: {
    transpile: ['vue-chartjs', 'chart.js'],
  },

  vite: {
    optimizeDeps: {
      include: ['chart.js', 'vue-chartjs'],
    },
  },

  typescript: {
    strict: true,
    shim: false,
  },

  compatibilityDate: '2024-04-03',
})
