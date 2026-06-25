// stores/auth.ts
import { defineStore } from 'pinia'
import { computed } from 'vue'

export interface AdminUser {
  id: string
  name: string
  email: string
  role: 'superadmin' | 'admin' | 'support'
  avatar?: string
}

export const useAuthStore = defineStore('auth', () => {
  const token = useCookie<string | null>('zekdrive_token', { default: () => null })
  const refreshToken = useCookie<string | null>('zekdrive_refresh_token', { default: () => null })
  const user = useCookie<AdminUser | null>('zekdrive_user', { default: () => null })

  const isAuthenticated = computed(() => !!token.value)

  function init() {
    // Session state is automatically initialized and synced via useCookie
  }

  async function login(
    email: string,
    password: string
  ): Promise<{ success: boolean; error?: string }> {
    const config = useRuntimeConfig()
    const baseUrl = config.public.apiUrl

    try {
      const res = await fetch(`${baseUrl}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      })

      if (!res.ok) {
        let msg = 'Invalid credentials'
        try {
          const body = await res.json()
          msg = body.message || body.error || msg
        } catch {}
        return { success: false, error: msg }
      }

      const body = await res.json()

      token.value = body.access_token || body.token || null
      refreshToken.value = body.refresh_token || null
      user.value = body.user || body.admin || null

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
      window.location.href = '/auth/login'
    }
  }

  async function tryRefreshToken(): Promise<boolean> {
    if (!refreshToken.value) return false

    const config = useRuntimeConfig()
    const baseUrl = config.public.apiUrl

    try {
      const res = await fetch(`${baseUrl}/auth/refresh`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refresh_token: refreshToken.value }),
      })
      if (!res.ok) return false

      const body = await res.json()
      token.value = body.access_token
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
