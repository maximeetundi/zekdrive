// composables/useApi.ts
import { ref } from 'vue'

export interface ApiResponse<T> {
  data: T | null
  error: string | null
  loading: boolean
}

export function useApi() {
  const config = useRuntimeConfig()
  const baseUrl = config.public.apiUrl

  function getToken(): string | null {
    const token = useCookie('zekdrive_token')
    return token.value || null
  }

  function getHeaders(): Record<string, string> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    }
    const token = getToken()
    if (token) {
      headers['Authorization'] = `Bearer ${token}`
    }
    return headers
  }

  async function request<T>(
    path: string,
    options: RequestInit = {}
  ): Promise<{ data: T | null; error: string | null }> {
    try {
      const res = await fetch(`${baseUrl}${path}`, {
        ...options,
        headers: {
          ...getHeaders(),
          ...(options.headers || {}),
        },
      })

      if (res.status === 401) {
        // Token expired — clear and redirect
        const token = useCookie('zekdrive_token')
        const refreshToken = useCookie('zekdrive_refresh_token')
        const userCookie = useCookie('zekdrive_user')
        token.value = null
        refreshToken.value = null
        userCookie.value = null
        if (process.client) {
          window.location.href = '/auth/login'
        }
        return { data: null, error: 'Unauthorized' }
      }

      if (!res.ok) {
        let errMsg = `HTTP ${res.status}`
        try {
          const errBody = await res.json()
          errMsg = errBody.message || errBody.error || errMsg
        } catch {}
        return { data: null, error: errMsg }
      }

      // No-content responses
      if (res.status === 204) {
        return { data: null, error: null }
      }

      const json = await res.json()
      return { data: json as T, error: null }
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Network error'
      return { data: null, error: msg }
    }
  }

  async function get<T>(path: string): Promise<{ data: T | null; error: string | null }> {
    return request<T>(path, { method: 'GET' })
  }

  async function post<T>(path: string, body: unknown): Promise<{ data: T | null; error: string | null }> {
    return request<T>(path, {
      method: 'POST',
      body: JSON.stringify(body),
    })
  }

  async function put<T>(path: string, body: unknown): Promise<{ data: T | null; error: string | null }> {
    return request<T>(path, {
      method: 'PUT',
      body: JSON.stringify(body),
    })
  }

  async function patch<T>(path: string, body: unknown): Promise<{ data: T | null; error: string | null }> {
    return request<T>(path, {
      method: 'PATCH',
      body: JSON.stringify(body),
    })
  }

  async function del<T>(path: string): Promise<{ data: T | null; error: string | null }> {
    return request<T>(path, { method: 'DELETE' })
  }

  return { get, post, put, patch, del, request }
}
