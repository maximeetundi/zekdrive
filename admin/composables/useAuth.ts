// composables/useAuth.ts
import { useAuthStore } from '~/stores/auth'

export function useAuth() {
  const authStore = useAuthStore()

  function isAuthenticated(): boolean {
    const token = useCookie('zekdrive_token')
    return !!token.value
  }

  async function login(email: string, password: string): Promise<{ success: boolean; error?: string }> {
    return authStore.login(email, password)
  }

  function logout(): void {
    authStore.logout()
  }

  function getCurrentUser() {
    return authStore.user
  }

  return {
    isAuthenticated,
    login,
    logout,
    getCurrentUser,
    user: authStore.user,
    token: authStore.token,
  }
}
