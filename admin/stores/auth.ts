// stores/auth.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export interface AdminUser {
  id: string
  name: string
  email: string
  role: 'superadmin' | 'admin' | 'support'
  avatar?: string
}

export const useAuthStore = defineStore('auth', () => {
  const token = ref<string | null>(null)
  const refreshToken = ref<string | null>(null)
  const user = ref<AdminUser | null>(null)

  const isAuthenticated = computed(() => !!token.value)

  // Initialize from localStorage on client
  function init() {
    if (process.client) {
      token.value = localStorage.getItem('zekdrive_token')
      refreshToken.value = localStorage.getItem('zekdrive_refresh_token')
      const stored = localStorage.getItem('zekdrive_user')
      if (stored) {
        try {
          user.value = JSON.parse(stored)
        } catch {}
      }
    }
  }

  async function login(
    email: string,
    password: string
  ): Promise<{ success: boolean; error?: string }> {
    const config = useRuntimeConfig()
    const baseUrl = config.public.apiUrl

    try {
      const res = await fetch(`${baseUrl}/admin/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      })

      if (!res.ok) {
        // Try to parse error
        let msg = 'Invalid credentials'
        try {
          const body = await res.json()
          msg = body.message || body.error || msg
        } catch {}
        return { success: false, error: msg }
      }

      const body = await res.json()

      token.value = body.access_token || body.token
      refreshToken.value = body.refresh_token || null
      user.value = body.user || body.admin || null

      if (process.client) {
        if (token.value) localStorage.setItem('zekdrive_token', token.value)
        if (refreshToken.value) localStorage.setItem('zekdrive_refresh_token', refreshToken.value)
        if (user.value) localStorage.setItem('zekdrive_user', JSON.stringify(user.value))
      }

      return { success: true }
    } catch (err) {
      // API unavailable — use mock login for development
      if (email === 'admin@zekdrive.com' && password === 'admin123') {
        const mockToken = 'mock_token_' + Date.now()
        const mockUser: AdminUser = {
          id: '1',
          name: 'Admin ZekDrive',
          email: 'admin@zekdrive.com',
          role: 'superadmin',
        }
        token.value = mockToken
        user.value = mockUser

        if (process.client) {
          localStorage.setItem('zekdrive_token', mockToken)
          localStorage.setItem('zekdrive_user', JSON.stringify(mockUser))
        }
        return { success: true }
      }
      return { success: false, error: 'Connection failed. Use admin@zekdrive.com / admin123 for demo.' }
    }
  }

  function logout() {
    token.value = null
    refreshToken.value = null
    user.value = null

    if (process.client) {
      localStorage.removeItem('zekdrive_token')
      localStorage.removeItem('zekdrive_refresh_token')
      localStorage.removeItem('zekdrive_user')
      window.location.href = '/auth/login'
    }
  }

  async function tryRefreshToken(): Promise<boolean> {
    if (!refreshToken.value) return false

    const config = useRuntimeConfig()
    const baseUrl = config.public.apiUrl

    try {
      const res = await fetch(`${baseUrl}/admin/auth/refresh`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refresh_token: refreshToken.value }),
      })
      if (!res.ok) return false

      const body = await res.json()
      token.value = body.access_token
      if (process.client) {
        localStorage.setItem('zekdrive_token', body.access_token)
      }
      return true
    } catch {
      return false
    }
  }

  // Initialize immediately
  init()

  return {
    token,
    refreshToken,
    user,
    isAuthenticated,
    login,
    logout,
    tryRefreshToken,
    init,
  }
})
