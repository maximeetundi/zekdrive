<template>
  <div class="auth-card">
    <div style="display: flex; justify-content: center; margin-bottom: 1.5rem;">
      <svg width="48" height="48" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg">
        <rect width="40" height="40" rx="10" fill="url(#login-logo-grad)"/>
        <path d="M12 28L20 12L28 28H12Z" fill="white" fill-opacity="0.9"/>
        <circle cx="20" cy="22" r="4" fill="#00d4aa"/>
        <defs>
          <linearGradient id="login-logo-grad" x1="0" y1="0" x2="40" y2="40" gradientUnits="userSpaceOnUse">
            <stop stop-color="#6c63ff"/>
            <stop offset="1" stop-color="#00d4aa"/>
          </linearGradient>
        </defs>
      </svg>
    </div>
    
    <h2 style="font-size: 1.5rem; font-weight: 800; text-align: center; margin-bottom: 0.25rem;">ZekDrive Admin</h2>
    <p style="text-align: center; font-size: 0.875rem; color: var(--text-muted); margin-bottom: 2rem;">
      Sign in to manage the ride-hailing & delivery fleet
    </p>

    <!-- Error Alert -->
    <div v-if="error" class="badge-danger" style="padding: 0.75rem 1rem; border-radius: var(--radius-sm); margin-bottom: 1.5rem; font-size: 0.8125rem; border: 1px solid rgba(239, 68, 68, 0.2); display: flex; align-items: center; gap: 0.5rem; color: #ff6b6b;">
      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
      </svg>
      <span>{{ error }}</span>
    </div>

    <!-- Login Form -->
    <form @submit.prevent="handleLogin">
      <div class="form-group" style="margin-bottom: 1.25rem;">
        <label class="form-label" for="email">Email Address</label>
        <input
          id="email"
          v-model="email"
          type="email"
          required
          class="form-control"
          placeholder="admin@zekdrive.com"
          :disabled="loading"
        />
      </div>

      <div class="form-group" style="margin-bottom: 1.5rem;">
        <label class="form-label" for="password">Password</label>
        <input
          id="password"
          v-model="password"
          type="password"
          required
          class="form-control"
          placeholder="••••••••"
          :disabled="loading"
        />
      </div>

      <button type="submit" class="btn btn-primary w-full justify-center" :disabled="loading" style="height: 2.75rem; font-weight: 600;">
        <span v-if="loading" class="loader" style="width: 16px; height: 16px; margin-right: 8px;"></span>
        <span>{{ loading ? 'Signing in...' : 'Sign In' }}</span>
      </button>
    </form>

    <div style="margin-top: 2rem; border-top: 1px solid var(--border); padding-top: 1rem; font-size: 0.75rem; text-align: center; color: var(--text-muted);">
      <div style="margin-bottom: 0.25rem;">Demo Credentials:</div>
      <div><strong>admin@zekdrive.com</strong> / <strong>admin123</strong></div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useAuth } from '~/composables/useAuth'

definePageMeta({
  layout: 'auth',
})

const email = ref('')
const password = ref('')
const loading = ref(false)
const error = ref<string | null>(null)

const { login } = useAuth()

async function handleLogin() {
  loading.value = true
  error.value = null
  
  try {
    const res = await login(email.value, password.value)
    if (res.success) {
      // Redirect to main panel dashboard
      navigateTo('/')
    } else {
      error.value = res.error || 'Authentication failed'
    }
  } catch (err) {
    error.value = 'An unexpected error occurred'
  } finally {
    loading.value = false
  }
}
</script>
