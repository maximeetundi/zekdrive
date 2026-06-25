<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useScrollAnimation } from '~/composables/useScrollAnimation'
import { useLanguage } from '~/composables/useLanguage'

const { t, currentLang } = useLanguage()
const { observe } = useScrollAnimation()

useHead({
  title: computed(() => t('driver.meta_title')),
  meta: [
    { name: 'description', content: computed(() => t('driver.meta_desc')) },
  ],
})

// Earnings calculator
const hoursPerDay = ref(6)
const daysPerWeek = ref(5)

const weeklyEarnings = computed(() => {
  const ratePerHour = 2800 // FCFA per hour average
  return (hoursPerDay.value * daysPerWeek.value * ratePerHour).toLocaleString(currentLang.value === 'fr' ? 'fr-FR' : 'en-US')
})

const monthlyEarnings = computed(() => {
  const ratePerHour = 2800
  return (hoursPerDay.value * daysPerWeek.value * 4 * ratePerHour).toLocaleString(currentLang.value === 'fr' ? 'fr-FR' : 'en-US')
})

const benefits = computed(() => [
  { icon: '⏰', title: t('driver.b1_title'), desc: t('driver.b1_desc') },
  { icon: '💰', title: t('driver.b2_title'), desc: t('driver.b2_desc') },
  { icon: '🛡️', title: t('driver.b3_title'), desc: t('driver.b3_desc') },
  { icon: '📈', title: t('driver.b4_title'), desc: t('driver.b4_desc') },
  { icon: '🎓', title: t('driver.b5_title'), desc: t('driver.b5_desc') },
  { icon: '🌍', title: t('driver.b6_title'), desc: t('driver.b6_desc') },
])

const requirements = computed(() => [
  { step: '01', title: t('driver.req1_title'), desc: t('driver.req1_desc') },
  { step: '02', title: t('driver.req2_title'), desc: t('driver.req2_desc') },
  { step: '03', title: t('driver.req3_title'), desc: t('driver.req3_desc') },
  { step: '04', title: t('driver.req4_title'), desc: t('driver.req4_desc') },
])

// Form
const form = ref({
  prenom: '',
  nom: '',
  telephone: '',
  email: '',
  ville: '',
  vehicule: '',
  experience: '',
  message: '',
})

onMounted(() => {
  document.querySelectorAll('.fade-up').forEach((el) => {
    observe(el as HTMLElement)
  })
})
</script>

<template>
  <div>
    <TheHeader />
    <main>
      <!-- Hero -->
      <section class="driver-hero" style="position:relative;overflow:hidden;">
        <div class="orb orb-violet" style="width:600px;height:600px;right:-200px;top:-100px;" />
        <div class="orb orb-teal" style="width:400px;height:400px;left:-100px;bottom:0;" />

        <div class="container" style="position:relative;z-index:1;">
          <div style="max-width:680px;">
            <div class="section-tag">{{ t('driver.tag') }}</div>
            <h1 class="section-title" style="font-size:clamp(2.5rem,5vw,4rem);margin-bottom:24px;">
              {{ t('driver.hero_title_1') }}<br><span class="gradient-text">{{ t('driver.hero_title_highlight') }}</span>
            </h1>
            <p style="font-size:1.15rem;color:var(--text-muted);line-height:1.7;margin-bottom:40px;">
              {{ t('driver.hero_desc') }}
            </p>
            <div style="display:flex;gap:16px;flex-wrap:wrap;">
              <a href="#postuler" class="btn btn-primary btn-lg">
                {{ t('driver.btn_start') }}
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M5 12h14M12 5l7 7-7 7"/>
                </svg>
              </a>
              <a href="#calcul" class="btn btn-secondary btn-lg">{{ t('driver.btn_calc') }}</a>
            </div>
          </div>
        </div>
      </section>

      <!-- Benefits -->
      <section class="section">
        <div class="container">
          <div class="section-header fade-up">
            <div class="section-tag">{{ t('driver.benefits_tag') }}</div>
            <h2 class="section-title">{{ t('driver.benefits_title_1') }}<span class="gradient-text">{{ t('driver.benefits_title_highlight') }}</span></h2>
            <p class="section-subtitle">{{ t('driver.benefits_sub') }}</p>
          </div>

          <div class="benefits-grid">
            <div v-for="(b, i) in benefits" :key="i" class="benefit-card fade-up">
              <span class="benefit-icon">{{ b.icon }}</span>
              <h3 class="benefit-title">{{ b.title }}</h3>
              <p class="benefit-desc">{{ b.desc }}</p>
            </div>
          </div>
        </div>
      </section>

      <!-- Earnings Calculator -->
      <section id="calcul" class="section" style="background:var(--bg-2);position:relative;overflow:hidden;">
        <div class="orb orb-teal" style="width:400px;height:400px;right:-100px;bottom:-100px;opacity:0.3;" />

        <div class="container" style="position:relative;z-index:1;">
          <div class="section-header centered fade-up">
            <div class="section-tag">{{ t('driver.calc_tag') }}</div>
            <h2 class="section-title">{{ t('driver.calc_title_1') }}<span class="gradient-text">{{ t('driver.calc_title_highlight') }}</span></h2>
            <p class="section-subtitle">{{ t('driver.calc_sub') }}</p>
          </div>

          <div class="calculator-section fade-up" style="max-width:700px;margin:0 auto;">
            <div style="margin-bottom:32px;">
              <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;">
                <label style="font-family:'Sora',sans-serif;font-weight:600;font-size:0.95rem;">
                  {{ t('driver.hours_label') }}
                </label>
                <span style="font-family:'Sora',sans-serif;font-weight:700;font-size:1.2rem;color:var(--teal);">{{ hoursPerDay }}h</span>
              </div>
              <input
                v-model="hoursPerDay"
                type="range"
                class="calc-slider"
                min="2"
                max="14"
                step="1"
              />
              <div style="display:flex;justify-content:space-between;font-size:0.8rem;color:var(--text-subtle);">
                <span>2h min</span>
                <span>14h max</span>
              </div>
            </div>

            <div style="margin-bottom:32px;">
              <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;">
                <label style="font-family:'Sora',sans-serif;font-weight:600;font-size:0.95rem;">
                  {{ t('driver.days_label') }}
                </label>
                <span style="font-family:'Sora',sans-serif;font-weight:700;font-size:1.2rem;color:var(--teal);">{{ daysPerWeek }}j</span>
              </div>
              <input
                v-model="daysPerWeek"
                type="range"
                class="calc-slider"
                min="1"
                max="7"
                step="1"
              />
              <div style="display:flex;justify-content:space-between;font-size:0.8rem;color:var(--text-subtle);">
                <span>1 jour</span>
                <span>7 jours</span>
              </div>
            </div>

            <div class="calc-result">
              <div style="display:grid;grid-template-columns:1fr 1fr;gap:32px;">
                <div>
                  <div style="font-size:0.8rem;color:var(--text-subtle);text-transform:uppercase;letter-spacing:0.1em;margin-bottom:8px;">{{ t('driver.calc_week') }}</div>
                  <div class="calc-amount">{{ weeklyEarnings }}</div>
                  <div style="font-size:0.85rem;color:var(--text-muted);margin-top:4px;">{{ t('driver.calc_est') }}</div>
                </div>
                <div style="border-left:1px solid var(--card-border);padding-left:32px;">
                  <div style="font-size:0.8rem;color:var(--text-subtle);text-transform:uppercase;letter-spacing:0.1em;margin-bottom:8px;">{{ t('driver.calc_month') }}</div>
                  <div class="calc-amount">{{ monthlyEarnings }}</div>
                  <div style="font-size:0.85rem;color:var(--text-muted);margin-top:4px;">{{ t('driver.calc_est') }}</div>
                </div>
              </div>
              <p style="font-size:0.8rem;color:var(--text-subtle);margin-top:20px;padding-top:16px;border-top:1px solid var(--card-border);">
                {{ t('driver.calc_note') }}
              </p>
            </div>
          </div>
        </div>
      </section>

      <!-- Requirements -->
      <section class="section" style="position:relative;overflow:hidden;">
        <div class="container" style="position:relative;z-index:1;">
          <div class="section-header centered fade-up">
            <div class="section-tag">{{ t('driver.steps_tag') }}</div>
            <h2 class="section-title">{{ t('driver.steps_title_1') }}<span class="gradient-text">{{ t('driver.steps_title_highlight') }}</span></h2>
          </div>

          <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:24px;">
            <div v-for="(req, i) in requirements" :key="i" class="fade-up" style="text-align:center;">
              <div style="width:72px;height:72px;background:var(--gradient);border-radius:50%;display:flex;align-items:center;justify-content:center;font-family:'Sora',sans-serif;font-size:1.4rem;font-weight:800;color:#fff;margin:0 auto 20px;box-shadow:0 8px 24px rgba(0,115,95,0.35);">
                {{ req.step }}
              </div>
              <h3 style="font-family:'Sora',sans-serif;font-size:1rem;font-weight:700;margin-bottom:10px;">{{ req.title }}</h3>
              <p style="font-size:0.9rem;color:var(--text-muted);line-height:1.5;">{{ req.desc }}</p>
            </div>
          </div>
        </div>
      </section>

      <!-- Application Form -->
      <section id="postuler" class="section" style="background:var(--bg-2);position:relative;overflow:hidden;">
        <div class="orb orb-violet" style="width:400px;height:400px;right:-100px;top:0;opacity:0.3;" />

        <div class="container" style="position:relative;z-index:1;max-width:800px;margin:0 auto;">
          <div class="section-header centered fade-up">
            <div class="section-tag">{{ t('driver.form_tag') }}</div>
            <h2 class="section-title">{{ t('driver.form_title_1') }}<span class="gradient-text">{{ t('driver.form_title_highlight') }}</span></h2>
            <p class="section-subtitle">{{ t('driver.form_sub') }}</p>
          </div>

          <div class="form-section fade-up">
            <div class="form-grid">
              <div class="form-group">
                <label class="form-label">{{ t('driver.first_name') }}</label>
                <input v-model="form.prenom" type="text" class="form-input" placeholder="" />
              </div>
              <div class="form-group">
                <label class="form-label">{{ t('driver.last_name') }}</label>
                <input v-model="form.nom" type="text" class="form-input" placeholder="" />
              </div>
              <div class="form-group">
                <label class="form-label">{{ t('driver.phone') }}</label>
                <input v-model="form.telephone" type="tel" class="form-input" placeholder="+221 77 000 00 00" />
              </div>
              <div class="form-group">
                <label class="form-label">{{ t('driver.email') }}</label>
                <input v-model="form.email" type="email" class="form-input" placeholder="name@email.com" />
              </div>
              <div class="form-group">
                <label class="form-label">{{ t('driver.city') }}</label>
                <select v-model="form.ville" class="form-select">
                  <option value="">{{ t('driver.city_placeholder') }}</option>
                  <option>Dakar</option>
                  <option>Abidjan</option>
                  <option>Bamako</option>
                  <option>Kinshasa</option>
                  <option>Douala</option>
                  <option>Autre</option>
                </select>
              </div>
              <div class="form-group">
                <label class="form-label">{{ t('driver.vehicle_type') }}</label>
                <select v-model="form.vehicule" class="form-select">
                  <option value="">{{ t('driver.vehicle_placeholder') }}</option>
                  <option>{{ t('driver.vehicle_vtc') }}</option>
                  <option>{{ t('driver.vehicle_moto') }}</option>
                  <option>{{ t('driver.vehicle_bike') }}</option>
                </select>
              </div>
              <div class="form-group full-width">
                <label class="form-label">{{ t('driver.experience') }}</label>
                <select v-model="form.experience" class="form-select">
                  <option value="">{{ t('driver.exp_placeholder') }}</option>
                  <option>{{ t('driver.exp_1') }}</option>
                  <option>{{ t('driver.exp_2') }}</option>
                  <option>{{ t('driver.exp_3') }}</option>
                  <option>{{ t('driver.exp_4') }}</option>
                </select>
              </div>
              <div class="form-group full-width">
                <label class="form-label">{{ t('driver.message') }}</label>
                <textarea v-model="form.message" class="form-textarea" :placeholder="t('driver.message_placeholder')" />
              </div>
            </div>

            <div style="margin-top:32px;">
              <button type="button" class="btn btn-primary btn-lg w-full" style="width:100%;justify-content:center;">
                {{ t('driver.btn_submit') }}
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M22 2L11 13M22 2l-7 20-4-9-9-4 20-7z"/>
                </svg>
              </button>
              <p style="font-size:0.82rem;color:var(--text-subtle);text-align:center;margin-top:16px;">
                {{ t('driver.form_note') }}
              </p>
            </div>
          </div>
        </div>
      </section>
    </main>
    <TheFooter />
  </div>
</template>

<style scoped>
@media (max-width: 768px) {
  .hiw-grid-4 {
    grid-template-columns: repeat(2, 1fr) !important;
  }
}
</style>
