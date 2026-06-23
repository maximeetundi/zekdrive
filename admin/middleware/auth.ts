// middleware/auth.ts
export default defineNuxtRouteMiddleware((to) => {
  // Skip auth check for login page
  if (to.path.startsWith('/auth')) return

  const token = process.client
    ? localStorage.getItem('zekdrive_token')
    : null

  if (!token) {
    return navigateTo('/auth/login')
  }
})
