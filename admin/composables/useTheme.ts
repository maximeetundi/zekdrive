// composables/useTheme.ts
// Shared reactive theme & language state across all components

const _theme = ref<'dark' | 'light'>('dark')
const _lang = ref<'fr' | 'en'>('fr')
let _initialized = false

export function useTheme() {
  function init() {
    if (!process.client || _initialized) return
    _initialized = true
    const savedTheme = localStorage.getItem('zekdrive_admin_theme')
    if (savedTheme === 'light' || savedTheme === 'dark') {
      _theme.value = savedTheme
    }
    const savedLang = localStorage.getItem('zekdrive_admin_lang')
    if (savedLang === 'en' || savedLang === 'fr') {
      _lang.value = savedLang
    }
    document.documentElement.setAttribute('data-theme', _theme.value)
  }

  function setTheme(t: 'dark' | 'light') {
    _theme.value = t
    if (process.client) {
      localStorage.setItem('zekdrive_admin_theme', t)
      document.documentElement.setAttribute('data-theme', t)
    }
  }

  function toggleTheme() {
    setTheme(_theme.value === 'dark' ? 'light' : 'dark')
  }

  function toggleLang() {
    _lang.value = _lang.value === 'fr' ? 'en' : 'fr'
    if (process.client) {
      localStorage.setItem('zekdrive_admin_lang', _lang.value)
    }
  }

  return { theme: _theme, lang: _lang, init, toggleTheme, toggleLang }
}
