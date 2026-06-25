<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useScrollAnimation } from '~/composables/useScrollAnimation'
import { useLanguage } from '~/composables/useLanguage'

const { t, currentLang } = useLanguage()
const { observe } = useScrollAnimation()

useHead({
  title: computed(() => t('pro.meta_title')),
  meta: [
    { name: 'description', content: computed(() => t('pro.meta_desc')) },
  ],
})

const plans = computed(() => [
  {
    tier: 'Starter',
    price: '0',
    period: t('pro.plan_period'),
    desc: t('pro.plan1_desc'),
    features: [
      t('pro.plan1_f1'),
      t('pro.plan1_f2'),
      t('pro.plan1_f3'),
      t('pro.plan1_f4'),
      t('pro.plan1_f5'),
    ],
    cta: t('pro.plan_cta_starter'),
    featured: false,
  },
  {
    tier: 'Business',
    price: currentLang.value === 'fr' ? '49 000' : '49,000',
    period: t('pro.plan_period'),
    desc: t('pro.plan2_desc'),
    features: [
      t('pro.plan2_f1'),
      t('pro.plan2_f2'),
      t('pro.plan2_f3'),
      t('pro.plan2_f4'),
      t('pro.plan2_f5'),
      t('pro.plan2_f6'),
      t('pro.plan2_f7'),
    ],
    cta: t('pro.plan_cta_business'),
    featured: true,
  },
  {
    tier: 'Enterprise',
    price: currentLang.value === 'fr' ? 'Sur devis' : 'On quote',
    period: '',
    desc: t('pro.plan3_desc'),
    features: [
      t('pro.plan3_f1'),
      t('pro.plan3_f2'),
      t('pro.plan3_f3'),
      t('pro.plan3_f4'),
      t('pro.plan3_f5'),
      t('pro.plan3_f6'),
      t('pro.plan3_f7'),
    ],
    cta: t('pro.plan_cta_enterprise'),
    featured: false,
  },
])

const useCases = computed(() => [
  {
    icon: '🏢',
    title: t('pro.sol1_title'),
    desc: t('pro.sol1_desc'),
  },
  {
    icon: '📦',
    title: t('pro.sol2_title'),
    desc: t('pro.sol2_desc'),
  },
  {
    icon: '🔗',
    title: t('pro.sol3_title'),
    desc: t('pro.sol3_desc'),
  },
  {
    icon: '📊',
    title: t('pro.sol4_title'),
    desc: t('pro.sol4_desc'),
  },
])

// Contact form
const proForm = ref({
  entreprise: '',
  nom: '',
  email: '',
  telephone: '',
  effectif: '',
  besoins: '',
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
      <section class="page-hero" style="text-align:left;padding-top:140px;padding-bottom:80px;">
        <div class="orb orb-teal" style="width:500px;height:500px;right:-150px;top:-100px;opacity:0.5;" />
        <div class="orb orb-violet" style="width:400px;height:400px;left:-100px;bottom:-100px;opacity:0.4;" />

        <div class="container" style="position:relative;z-index:1;">
          <div style="max-width:680px;">
            <div class="section-tag">{{ t('pro.tag') }}</div>
            <h1 class="section-title" style="font-size:clamp(2.5rem,5vw,4rem);">
              {{ t('pro.hero_title_1') }}<br><span class="gradient-text">{{ t('pro.hero_title_highlight') }}</span>
            </h1>
            <p style="font-size:1.15rem;color:var(--text-muted);line-height:1.7;margin-bottom:40px;max-width:540px;">
              {{ t('pro.hero_desc') }}
            </p>
            <div style="display:flex;gap:16px;flex-wrap:wrap;">
              <a href="#contact-pro" class="btn btn-primary btn-lg">{{ t('pro.btn_demo') }}</a>
              <a href="#pricing" class="btn btn-secondary btn-lg">{{ t('pro.btn_prices') }}</a>
            </div>

            <!-- Trust logos -->
            <div style="margin-top:56px;padding-top:40px;border-top:1px solid var(--card-border);">
              <p style="font-size:0.8rem;color:var(--text-subtle);text-transform:uppercase;letter-spacing:0.1em;margin-bottom:20px;">{{ t('pro.trust_label') }}</p>
              <div style="display:flex;gap:32px;align-items:center;flex-wrap:wrap;">
                <div v-for="brand in ['Ecobank', 'MTN Business', 'Orange Pro', 'Société Générale', 'Jumia']" :key="brand"
                  style="font-family:'Sora',sans-serif;font-size:0.9rem;font-weight:700;color:var(--text-subtle);letter-spacing:0.05em;">
                  {{ brand }}
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Use Cases -->
      <section class="section" style="background:var(--bg-2);position:relative;overflow:hidden;">
        <div class="orb orb-violet" style="width:400px;height:400px;left:-100px;center:0;opacity:0.3;" />
        <div class="container" style="position:relative;z-index:1;">
          <div class="section-header centered fade-up">
            <div class="section-tag">{{ t('pro.sol_tag') }}</div>
            <h2 class="section-title">{{ t('pro.sol_title_1') }}<br><span class="gradient-text">{{ t('pro.sol_title_highlight') }}</span></h2>
          </div>

          <div style="display:grid;grid-template-columns:repeat(2,1fr);gap:24px;">
            <div v-for="(uc, i) in useCases" :key="i" class="card fade-up" style="display:flex;gap:20px;align-items:flex-start;">
              <div style="width:56px;height:56px;background:var(--violet-dim);border-radius:14px;display:flex;align-items:center;justify-content:center;font-size:1.6rem;flex-shrink:0;">
                {{ uc.icon }}
              </div>
              <div>
                <h3 style="font-family:'Sora',sans-serif;font-size:1.05rem;font-weight:700;margin-bottom:10px;">{{ uc.title }}</h3>
                <p style="font-size:0.9rem;color:var(--text-muted);line-height:1.6;">{{ uc.desc }}</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Pricing -->
      <section id="pricing" class="section" style="position:relative;overflow:hidden;">
        <div class="orb orb-teal" style="width:400px;height:400px;right:-100px;top:50%;transform:translateY(-50%);opacity:0.3;" />

        <div class="container" style="position:relative;z-index:1;">
          <div class="section-header centered fade-up">
            <div class="section-tag">{{ t('pro.pricing_tag') }}</div>
            <h2 class="section-title">{{ t('pro.pricing_title_1') }}<br><span class="gradient-text">{{ t('pro.pricing_title_highlight') }}</span></h2>
            <p class="section-subtitle">{{ t('pro.pricing_sub') }}</p>
          </div>

          <div class="pricing-grid fade-up">
            <div
              v-for="(plan, i) in plans"
              :key="i"
              class="pricing-card"
              :class="{ featured: plan.featured }"
            >
              <div v-if="plan.featured" class="pricing-badge">{{ t('pro.plan_featured') }}</div>
              <div class="pricing-tier">{{ plan.tier }}</div>
              <div class="pricing-price">
                {{ plan.price }}
                <span v-if="plan.period">{{ plan.period }}</span>
              </div>
              <p class="pricing-period">{{ plan.desc }}</p>

              <ul class="pricing-features">
                <li v-for="(feat, j) in plan.features" :key="j" class="pricing-feature">
                  <div class="check">✓</div>
                  {{ feat }}
                </li>
              </ul>

              <button
                class="btn w-full"
                :class="plan.featured ? 'btn-primary' : 'btn-secondary'"
                style="justify-content:center;"
              >
                {{ plan.cta }}
              </button>
            </div>
          </div>
        </div>
      </section>

      <!-- Contact Pro Form -->
      <section id="contact-pro" class="section" style="background:var(--bg-2);position:relative;overflow:hidden;">
        <div class="orb orb-violet" style="width:400px;height:400px;left:-100px;bottom:-100px;opacity:0.3;" />

        <div class="container" style="position:relative;z-index:1;max-width:800px;margin:0 auto;">
          <div class="section-header centered fade-up">
            <div class="section-tag">{{ t('pro.form_tag') }}</div>
            <h2 class="section-title">{{ t('pro.form_title_1') }}<span class="gradient-text">{{ t('pro.form_title_highlight') }}</span></h2>
            <p class="section-subtitle">{{ t('pro.form_sub') }}</p>
          </div>

          <div class="form-section fade-up">
            <div class="form-grid">
              <div class="form-group">
                <label class="form-label">{{ t('pro.company') }}</label>
                <input v-model="proForm.entreprise" type="text" class="form-input" :placeholder="t('pro.company_placeholder')" />
              </div>
              <div class="form-group">
                <label class="form-label">{{ t('pro.name') }}</label>
                <input v-model="proForm.nom" type="text" class="form-input" :placeholder="t('pro.name_placeholder')" />
              </div>
              <div class="form-group">
                <label class="form-label">{{ t('pro.email_pro') }}</label>
                <input v-model="proForm.email" type="email" class="form-input" :placeholder="t('pro.email_pro_placeholder')" />
              </div>
              <div class="form-group">
                <label class="form-label">{{ t('driver.phone') }}</label>
                <input v-model="proForm.telephone" type="tel" class="form-input" placeholder="+221 77 000 00 00" />
              </div>
              <div class="form-group">
                <label class="form-label">{{ t('pro.employees') }}</label>
                <select v-model="proForm.effectif" class="form-select">
                  <option value="">{{ t('pro.emp_placeholder') }}</option>
                  <option v-if="currentLang === 'fr'">1 à 10 employés</option>
                  <option v-else>1 to 10 employees</option>
                  <option v-if="currentLang === 'fr'">11 à 50 employés</option>
                  <option v-else>11 to 50 employees</option>
                  <option v-if="currentLang === 'fr'">51 à 200 employés</option>
                  <option v-else>51 to 200 employees</option>
                  <option v-if="currentLang === 'fr'">200+ employés</option>
                  <option v-else>200+ employees</option>
                </select>
              </div>
              <div class="form-group">
                <label class="form-label">{{ t('pro.plan_desired') }}</label>
                <select v-model="proForm.besoins" class="form-select">
                  <option value="">{{ t('pro.plan_placeholder') }}</option>
                  <option>Starter ({{ currentLang === 'fr' ? 'Gratuit' : 'Free' }})</option>
                  <option>Business (49 000 FCFA/{{ currentLang === 'fr' ? 'mois' : 'month' }})</option>
                  <option>Enterprise ({{ currentLang === 'fr' ? 'Sur devis' : 'On quote' }})</option>
                </select>
              </div>
              <div class="form-group full-width">
                <label class="form-label">{{ t('pro.desc_needs') }}</label>
                <textarea v-model="proForm.message" class="form-textarea" :placeholder="t('pro.desc_needs_placeholder')" />
              </div>
            </div>

            <button type="button" class="btn btn-primary btn-lg" style="width:100%;justify-content:center;margin-top:24px;">
              {{ t('pro.btn_submit') }}
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M22 2L11 13M22 2l-7 20-4-9-9-4 20-7z"/>
              </svg>
            </button>
          </div>
        </div>
      </section>
    </main>
    <TheFooter />
  </div>
</template>
