import { ref } from 'vue'

export function useCounter(target: number, duration = 2000) {
  const count = ref(0)
  let animationFrame: number
  let startTime: number | null = null

  const start = () => {
    count.value = 0
    startTime = null

    const animate = (timestamp: number) => {
      if (!startTime) startTime = timestamp
      const elapsed = timestamp - startTime
      const progress = Math.min(elapsed / duration, 1)

      // Ease-out cubic easing
      const eased = 1 - Math.pow(1 - progress, 3)
      count.value = Math.round(eased * target)

      if (progress < 1) {
        animationFrame = requestAnimationFrame(animate)
      } else {
        count.value = target
      }
    }

    animationFrame = requestAnimationFrame(animate)
  }

  const stop = () => {
    if (animationFrame) cancelAnimationFrame(animationFrame)
  }

  return { count, start, stop }
}
