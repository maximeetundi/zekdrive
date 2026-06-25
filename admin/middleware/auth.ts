// middleware/auth.ts
export default defineNuxtRouteMiddleware((to) => {
  // Skip auth check for login page
  if (to.path.startsWith('/auth')) return

  const token = useCookie('zekdrive_token')

  if (!token.value) {
    return navigateTo('/auth/login')
  }
})
