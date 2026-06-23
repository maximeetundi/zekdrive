export function useScrollAnimation() {
  const observe = (el: HTMLElement, className = 'visible') => {
    if (!el) return

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add(className)
            observer.unobserve(entry.target)
          }
        })
      },
      {
        threshold: 0.15,
        rootMargin: '0px 0px -40px 0px',
      }
    )

    observer.observe(el)
  }

  const observeAll = (els: NodeListOf<Element> | HTMLElement[], className = 'visible', staggerMs = 100) => {
    Array.from(els).forEach((el, i) => {
      setTimeout(() => observe(el as HTMLElement, className), i * staggerMs)
    })
  }

  return { observe, observeAll }
}
