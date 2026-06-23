<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useScrollAnimation } from '~/composables/useScrollAnimation'

const { observe } = useScrollAnimation()

useHead({
  title: 'ZekDrive Pro — Solutions de mobilité pour entreprises',
  meta: [
    { name: 'description', content: 'ZekDrive Pro offre des solutions de mobilité clé en main pour les entreprises : courses professionnelles, livraisons, API et tarifs négociés.' },
  ],
})

const plans = [
  {
    tier: 'Starter',
    price: '0',
    period: '/ mois',
    desc: 'Parfait pour les petites équipes et startups.',
    features: [
      'Jusqu\'à 10 utilisateurs',
      '50 courses/mois incluses',
      'Tableau de bord basique',
      'Facturation mensuelle',
      'Support email',
    ],
    cta: 'Commencer gratuitement',
    featured: false,
  },
  {
    tier: 'Business',
    price: '49 000',
    period: '/ mois',
    desc: 'La solution complète pour les PME en croissance.',
    features: [
      'Jusqu\'à 50 utilisateurs',
      'Courses illimitées',
      'Tableau de bord avancé',
      'Facturation & exports CSV',
      'API basique',
      'Support prioritaire 24/7',
      'Chauffeur dédié optionnel',
    ],
    cta: 'Essai gratuit 30 jours',
    featured: true,
  },
  {
    tier: 'Enterprise',
    price: 'Sur devis',
    period: '',
    desc: 'Solutions sur mesure pour les grandes entreprises.',
    features: [
      'Utilisateurs illimités',
      'SLA garanti 99.9%',
      'API complète & webhooks',
      'Intégration ERP/SAP',
      'Manager dédié',
      'Formation équipe',
      'Contrat personnalisé',
    ],
    cta: 'Contacter l\'équipe',
    featured: false,
  },
]

const useCases = [
  {
    icon: '🏢',
    title: 'Courses professionnelles',
    desc: 'Gérez tous vos déplacements professionnels depuis un tableau de bord centralisé. Suivi en temps réel, rapports de dépenses automatiques.',
  },
  {
    icon: '📦',
    title: 'Livraison pour entreprises',
    desc: 'Expédiez vos documents, échantillons et colis grâce à notre flotte dédiée. Livraison express ou planifiée selon vos besoins.',
  },
  {
    icon: '🔗',
    title: 'Intégration API',
    desc: 'Intégrez ZekDrive directement dans vos outils métier via notre API REST. Documentée, sécurisée et supportée.',
  },
  {
    icon: '📊',
    title: 'Reporting & Analytics',
    desc: 'Visualisez vos dépenses de mobilité, optimisez vos coûts avec des rapports détaillés et des exports personnalisés.',
  },
]

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
            <div class="section-tag">Pour les entreprises</div>
            <h1 class="section-title" style="font-size:clamp(2.5rem,5vw,4rem);">
              La mobilité pro<br><span class="gradient-text">sans compromis</span>
            </h1>
            <p style="font-size:1.15rem;color:var(--text-muted);line-height:1.7;margin-bottom:40px;max-width:540px;">
              Gérez tous vos déplacements professionnels avec une solution tout-en-un. Facturation centralisée, API, tableau de bord et support dédié.
            </p>
            <div style="display:flex;gap:16px;flex-wrap:wrap;">
              <a href="#contact-pro" class="btn btn-primary btn-lg">Demander une démo</a>
              <a href="#pricing" class="btn btn-secondary btn-lg">Voir les tarifs</a>
            </div>

            <!-- Trust logos -->
            <div style="margin-top:56px;padding-top:40px;border-top:1px solid var(--card-border);">
              <p style="font-size:0.8rem;color:var(--text-subtle);text-transform:uppercase;letter-spacing:0.1em;margin-bottom:20px;">Ils nous font confiance</p>
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
            <div class="section-tag">Solutions</div>
            <h2 class="section-title">Tout ce dont votre<br><span class="gradient-text">entreprise a besoin</span></h2>
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
            <div class="section-tag">Tarifs</div>
            <h2 class="section-title">Des plans adaptés à<br><span class="gradient-text">chaque besoin</span></h2>
            <p class="section-subtitle">Commencez gratuitement, évoluez à votre rythme. Tous les plans incluent un essai de 30 jours.</p>
          </div>

          <div class="pricing-grid fade-up">
            <div
              v-for="(plan, i) in plans"
              :key="i"
              class="pricing-card"
              :class="{ featured: plan.featured }"
            >
              <div v-if="plan.featured" class="pricing-badge">Le plus choisi</div>
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
            <div class="section-tag">Contact Pro</div>
            <h2 class="section-title">Parlons de votre <span class="gradient-text">projet</span></h2>
            <p class="section-subtitle">Décrivez vos besoins et notre équipe vous contactera sous 24h.</p>
          </div>

          <div class="form-section fade-up">
            <div class="form-grid">
              <div class="form-group">
                <label class="form-label">Entreprise *</label>
                <input v-model="proForm.entreprise" type="text" class="form-input" placeholder="Nom de votre entreprise" />
              </div>
              <div class="form-group">
                <label class="form-label">Votre nom *</label>
                <input v-model="proForm.nom" type="text" class="form-input" placeholder="Prénom Nom" />
              </div>
              <div class="form-group">
                <label class="form-label">Email professionnel *</label>
                <input v-model="proForm.email" type="email" class="form-input" placeholder="vous@entreprise.com" />
              </div>
              <div class="form-group">
                <label class="form-label">Téléphone</label>
                <input v-model="proForm.telephone" type="tel" class="form-input" placeholder="+221 77 000 00 00" />
              </div>
              <div class="form-group">
                <label class="form-label">Effectif de l'entreprise</label>
                <select v-model="proForm.effectif" class="form-select">
                  <option value="">Sélectionnez</option>
                  <option>1 à 10 employés</option>
                  <option>11 à 50 employés</option>
                  <option>51 à 200 employés</option>
                  <option>200+ employés</option>
                </select>
              </div>
              <div class="form-group">
                <label class="form-label">Plan souhaité</label>
                <select v-model="proForm.besoins" class="form-select">
                  <option value="">Sélectionnez un plan</option>
                  <option>Starter (Gratuit)</option>
                  <option>Business (49 000 FCFA/mois)</option>
                  <option>Enterprise (Sur devis)</option>
                </select>
              </div>
              <div class="form-group full-width">
                <label class="form-label">Décrivez vos besoins</label>
                <textarea v-model="proForm.message" class="form-textarea" placeholder="Parlez-nous de votre activité, vos besoins en mobilité, le volume mensuel estimé..." />
              </div>
            </div>

            <button type="button" class="btn btn-primary btn-lg" style="width:100%;justify-content:center;margin-top:24px;">
              Envoyer ma demande
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
