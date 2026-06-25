<template>
  <div class="auth-layout" :data-theme="theme">
    <!-- Background decoration -->
    <div class="auth-bg-orb auth-bg-orb-1" />
    <div class="auth-bg-orb auth-bg-orb-2" />

    <div class="auth-wrapper">
      <!-- Brand side (visible only on large screens) -->
      <div class="auth-brand">
        <img src="/logo.png" alt="ZekDrive" class="auth-brand-logo" />
        <h1 class="auth-brand-title">ZekDrive</h1>
        <p class="auth-brand-tagline">{{ lang === 'fr' ? "Panneau d'administration" : 'Admin Dashboard' }}</p>
        <div class="auth-brand-features">
          <div class="auth-feature">
            <span class="auth-feature-icon">🗺️</span>
            <span>{{ lang === 'fr' ? 'Suivi de flotte en temps réel' : 'Real-time fleet tracking' }}</span>
          </div>
          <div class="auth-feature">
            <span class="auth-feature-icon">📊</span>
            <span>{{ lang === 'fr' ? 'Statistiques et revenus' : 'Analytics & earnings' }}</span>
          </div>
          <div class="auth-feature">
            <span class="auth-feature-icon">🚗</span>
            <span>{{ lang === 'fr' ? 'Gestion chauffeurs & courses' : 'Manage drivers & trips' }}</span>
          </div>
          <div class="auth-feature">
            <span class="auth-feature-icon">💳</span>
            <span>{{ lang === 'fr' ? 'Suivi des transactions' : 'Track transactions' }}</span>
          </div>
        </div>
      </div>

      <!-- Login card -->
      <div class="auth-card">
        <!-- Theme & Language Toggles on Login -->
        <div style="position: absolute; top: 1.25rem; right: 1.25rem; display: flex; gap: 0.5rem; align-items: center;">
          <button class="control-btn" @click="toggleLang" :title="`Langue: ${lang === 'fr' ? 'Français' : 'English'}`" style="border-radius: 50%; width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; background: var(--bg-card); border: 1px solid var(--border); color: var(--text-secondary); cursor: pointer; transition: all 0.2s;">
            <span class="lang-flag" style="font-size: 0.875rem;">{{ lang === 'fr' ? '🇫🇷' : '🇬🇧' }}</span>
          </button>
          
          <button class="auth-theme-btn" @click="toggleTheme" :aria-label="theme === 'dark' ? t('light_mode') : t('dark_mode')" style="position: static;">
            <svg v-if="theme === 'dark'" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width:18px;height:18px">
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364-6.364l-.707.707M6.343 17.657l-.707.707m12.728 0l-.707-.707M6.343 6.343l-.707-.707M12 7a5 5 0 100 10 5 5 0 000-10z" />
            </svg>
            <svg v-else xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width:18px;height:18px">
              <path stroke-linecap="round" stroke-linejoin="round" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
            </svg>
          </button>
        </div>

        <!-- Logo (mobile only) -->
        <div class="auth-card-logo">
          <img src="/logo.png" alt="ZekDrive" style="width:44px;height:44px;border-radius:12px;object-fit:contain" />
        </div>

        <h2 class="auth-card-title">{{ t('admin_login') }}</h2>
        <p class="auth-card-subtitle">{{ t('login_subtitle') }}</p>

        <!-- Error Alert -->
        <div v-if="error" class="auth-error">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
          </svg>
          <span>{{ error }}</span>
        </div>

        <!-- Login Form -->
        <form @submit.prevent="handleLogin" class="auth-form">
          <div class="auth-form-group">
            <label class="auth-label" for="email">{{ t('email_label') }}</label>
            <div class="auth-input-wrap">
              <svg class="auth-input-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
              </svg>
              <input
                id="email"
                v-model="email"
                type="email"
                required
                class="auth-input"
                placeholder="admin@zekdrive.com"
                :disabled="loading"
                autocomplete="email"
              />
            </div>
          </div>

          <div class="auth-form-group">
            <label class="auth-label" for="password">{{ t('password_label') }}</label>
            <div class="auth-input-wrap">
              <svg class="auth-input-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
              </svg>
              <input
                id="password"
                v-model="password"
                :type="showPassword ? 'text' : 'password'"
                required
                class="auth-input"
                placeholder="••••••••"
                :disabled="loading"
                autocomplete="current-password"
                style="padding-right: 2.75rem;"
              />
              <button
                type="button"
                class="auth-eye-btn"
                @click="showPassword = !showPassword"
                :disabled="loading"
                :aria-label="showPassword ? 'Masquer' : 'Afficher'"
              >
                <svg v-if="showPassword" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width:17px;height:17px">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                  <path stroke-linecap="round" stroke-linejoin="round" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                </svg>
                <svg v-else xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="width:17px;height:17px">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l18 18" />
                </svg>
              </button>
            </div>
          </div>

          <button type="submit" class="auth-submit-btn" :disabled="loading">
            <span v-if="loading" class="auth-spinner" />
            <span>{{ loading ? t('logging_in') : t('login_btn') }}</span>
          </button>
        </form>

        <!-- Credentials hint -->
        <div class="auth-hint">
          <span class="auth-hint-label">{{ t('default_credentials') }}</span>
          <code class="auth-hint-code">admin@zekdrive.com</code>
          <span style="color:var(--text-muted)">/</span>
          <code class="auth-hint-code">admin123</code>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAuth } from '~/composables/useAuth'
import { useI18n } from '~/composables/useI18n'

definePageMeta({ layout: false })

const email = ref('')
const password = ref('')
const showPassword = ref(false)
const loading = ref(false)
const error = ref<string | null>(null)

const { theme, lang, init, toggleTheme, toggleLang } = useTheme()
const { t } = useI18n()
const { login } = useAuth()

onMounted(() => {
  init()
})

async function handleLogin() {
  loading.value = true
  error.value = null
  try {
    const res = await login(email.value, password.value)
    if (res.success) {
      navigateTo('/')
    } else {
      error.value = res.error || t('login_error_invalid')
    }
  } catch {
    error.value = t('login_error_unexpected')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
/* ── Layout ── */
.auth-layout {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--bg-primary);
  position: relative;
  overflow: hidden;
  padding: 1.5rem;
}

.auth-bg-orb {
  position: absolute;
  border-radius: 50%;
  pointer-events: none;
}
.auth-bg-orb-1 {
  width: 600px; height: 600px;
  background: radial-gradient(circle, rgba(20,177,158,0.12) 0%, transparent 70%);
  top: -220px; right: -180px;
}
.auth-bg-orb-2 {
  width: 400px; height: 400px;
  background: radial-gradient(circle, rgba(0,212,170,0.08) 0%, transparent 70%);
  bottom: -120px; left: -120px;
}

/* ── Two-column wrapper ── */
.auth-wrapper {
  display: flex;
  gap: 3rem;
  align-items: center;
  justify-content: center;
  width: 100%;
  max-width: 960px;
  position: relative;
  z-index: 1;
}

/* ── Brand side ── */
.auth-brand {
  flex: 1;
  max-width: 380px;
  color: var(--text-primary);
}

.auth-brand-logo {
  width: 60px; height: 60px;
  border-radius: 16px;
  object-fit: contain;
  margin-bottom: 1.25rem;
  box-shadow: 0 8px 24px rgba(20,177,158,0.3);
}

.auth-brand-title {
  font-size: 2.25rem;
  font-weight: 900;
  background: linear-gradient(135deg, var(--accent-primary), var(--accent-secondary));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  line-height: 1.1;
  margin-bottom: 0.375rem;
}

.auth-brand-tagline {
  font-size: 1rem;
  color: var(--text-secondary);
  margin-bottom: 2rem;
}

.auth-brand-features {
  display: flex;
  flex-direction: column;
  gap: 0.875rem;
}

.auth-feature {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-size: 0.9375rem;
  color: var(--text-secondary);
}

.auth-feature-icon {
  font-size: 1.125rem;
  width: 36px;
  height: 36px;
  background: var(--bg-card);
  border: 1px solid var(--border);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

/* ── Card ── */
.auth-card {
  width: 100%;
  max-width: 420px;
  background: var(--bg-secondary);
  border: 1px solid var(--border);
  border-radius: 24px;
  padding: 2.5rem;
  box-shadow: 0 24px 80px rgba(0,0,0,0.3), 0 0 0 1px rgba(20,177,158,0.06);
  position: relative;
  animation: slideUp 0.35s cubic-bezier(0.4,0,0.2,1);
}

[data-theme="light"] .auth-card {
  background: #ffffff;
  box-shadow: 0 24px 80px rgba(15,23,42,0.08), 0 0 0 1px rgba(20,177,158,0.08);
  border-color: #e2e8f0;
}

[data-theme="light"] .auth-layout {
  background: linear-gradient(135deg, #f0f4f8 0%, #e8f4f2 100%);
}

[data-theme="light"] .auth-brand {
  color: #0f172a;
}

[data-theme="light"] .auth-brand-tagline {
  color: #475569;
}

[data-theme="light"] .auth-feature {
  color: #334155;
}

[data-theme="light"] .auth-card-subtitle {
  color: #64748b;
}

[data-theme="light"] .auth-bg-orb-1 {
  background: radial-gradient(circle, rgba(20,177,158,0.18) 0%, transparent 70%);
}

[data-theme="light"] .auth-bg-orb-2 {
  background: radial-gradient(circle, rgba(0,212,170,0.12) 0%, transparent 70%);
}

/* ── Theme button ── */
.auth-theme-btn {
  position: absolute;
  top: 1.25rem;
  right: 1.25rem;
  width: 36px; height: 36px;
  border-radius: 50%;
  background: var(--bg-card);
  border: 1px solid var(--border);
  color: var(--text-secondary);
  display: flex; align-items: center; justify-content: center;
  cursor: pointer;
  transition: all 0.2s;
}
.auth-theme-btn:hover {
  color: var(--accent-primary);
  border-color: var(--accent-primary);
}

/* ── Card logo (mobile only) ── */
.auth-card-logo {
  display: none;
  justify-content: center;
  margin-bottom: 1.5rem;
}

/* ── Headings ── */
.auth-card-title {
  font-size: 1.375rem;
  font-weight: 800;
  color: var(--text-primary);
  margin-bottom: 0.375rem;
  text-align: center;
}
.auth-card-subtitle {
  font-size: 0.8125rem;
  color: var(--text-muted);
  text-align: center;
  margin-bottom: 1.75rem;
  line-height: 1.5;
}

/* ── Error ── */
.auth-error {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1rem;
  border-radius: 10px;
  background: rgba(239,68,68,0.08);
  border: 1px solid rgba(239,68,68,0.2);
  color: #ef4444;
  font-size: 0.8125rem;
  margin-bottom: 1.25rem;
}

/* ── Form ── */
.auth-form { display: flex; flex-direction: column; gap: 1.25rem; }

.auth-form-group { display: flex; flex-direction: column; gap: 0.5rem; }

.auth-label {
  font-size: 0.8125rem;
  font-weight: 600;
  color: var(--text-secondary);
}

.auth-input-wrap {
  position: relative;
  display: flex;
  align-items: center;
}

.auth-input-icon {
  position: absolute;
  left: 0.875rem;
  width: 16px; height: 16px;
  color: var(--text-muted);
  pointer-events: none;
  flex-shrink: 0;
}

.auth-input {
  width: 100%;
  padding: 0.75rem 0.875rem 0.75rem 2.625rem;
  background: var(--bg-card);
  border: 1px solid var(--border);
  border-radius: 10px;
  color: var(--text-primary);
  font-size: 0.9375rem;
  font-family: inherit;
  transition: all 0.2s;
  outline: none;
}

.auth-input:focus {
  border-color: var(--accent-primary);
  box-shadow: 0 0 0 3px rgba(20,177,158,0.12);
  background: var(--bg-card-hover);
}

.auth-input::placeholder { color: var(--text-muted); }
.auth-input:disabled { opacity: 0.5; cursor: not-allowed; }

[data-theme="light"] .auth-input {
  background: #f8fafc;
  border-color: #e2e8f0;
  color: #0f172a;
}
[data-theme="light"] .auth-input:focus {
  background: #ffffff;
  border-color: var(--accent-primary);
}

/* ── Eye button ── */
.auth-eye-btn {
  position: absolute;
  right: 0.75rem;
  background: transparent;
  border: none;
  color: var(--text-muted);
  cursor: pointer;
  display: flex; align-items: center; justify-content: center;
  padding: 4px;
  border-radius: 6px;
  transition: color 0.2s;
}
.auth-eye-btn:hover { color: var(--text-primary); }
.auth-eye-btn:disabled { cursor: not-allowed; opacity: 0.4; }

/* ── Submit ── */
.auth-submit-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  width: 100%;
  height: 2.875rem;
  background: linear-gradient(135deg, var(--accent-primary), var(--accent-secondary));
  border: none;
  border-radius: 10px;
  color: #fff;
  font-size: 0.9375rem;
  font-weight: 700;
  font-family: inherit;
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 4px 16px rgba(20,177,158,0.35);
  margin-top: 0.25rem;
}
.auth-submit-btn:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 8px 24px rgba(20,177,158,0.5);
}
.auth-submit-btn:disabled { opacity: 0.6; cursor: not-allowed; }

/* ── Spinner ── */
.auth-spinner {
  width: 16px; height: 16px;
  border: 2px solid rgba(255,255,255,0.3);
  border-top-color: #fff;
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }

/* ── Hint ── */
.auth-hint {
  display: flex;
  align-items: center;
  justify-content: center;
  flex-wrap: wrap;
  gap: 0.375rem;
  margin-top: 1.75rem;
  padding-top: 1.25rem;
  border-top: 1px solid var(--border);
  font-size: 0.75rem;
}
.auth-hint-label { color: var(--text-muted); }
.auth-hint-code {
  background: var(--bg-card);
  border: 1px solid var(--border);
  border-radius: 5px;
  padding: 0.125rem 0.5rem;
  font-size: 0.75rem;
  color: var(--accent-primary);
  font-family: 'Courier New', monospace;
}
[data-theme="light"] .auth-hint-code {
  background: #f1f5f9;
  border-color: #e2e8f0;
}

/* ── Responsive ── */
@media (max-width: 780px) {
  .auth-brand { display: none; }
  .auth-card-logo { display: flex; }
  .auth-wrapper { max-width: 420px; }
  .auth-card { padding: 2rem 1.5rem; }
}

@media (max-width: 480px) {
  .auth-card { padding: 1.75rem 1.25rem; border-radius: 18px; }
}
</style>
