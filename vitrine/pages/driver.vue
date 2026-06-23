<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useScrollAnimation } from '~/composables/useScrollAnimation'

const { observe } = useScrollAnimation()

useHead({
  title: 'Devenir Chauffeur ZekDrive — Gagnez plus, conduisez librement',
  meta: [
    { name: 'description', content: 'Rejoignez les +500 chauffeurs ZekDrive. Horaires flexibles, paiement hebdomadaire, assurance incluse. Postulez dès aujourd\'hui.' },
  ],
})

// Earnings calculator
const hoursPerDay = ref(6)
const daysPerWeek = ref(5)

const weeklyEarnings = computed(() => {
  const ratePerHour = 2800 // FCFA per hour average
  return (hoursPerDay.value * daysPerWeek.value * ratePerHour).toLocaleString('fr-FR')
})

const monthlyEarnings = computed(() => {
  const ratePerHour = 2800
  return (hoursPerDay.value * daysPerWeek.value * 4 * ratePerHour).toLocaleString('fr-FR')
})

const benefits = [
  { icon: '⏰', title: 'Horaires flexibles', desc: 'Travaillez quand vous voulez, où vous voulez. Vous êtes votre propre patron.' },
  { icon: '💰', title: 'Paiement hebdomadaire', desc: 'Recevez vos gains chaque semaine directement sur votre mobile money.' },
  { icon: '🛡️', title: 'Assurance incluse', desc: 'Couverture assurance complète pendant vos courses. Conduisez en toute sérénité.' },
  { icon: '📈', title: 'Bonus de performance', desc: 'Obtenez des bonus pour les courses supplémentaires et les bonnes notes.' },
  { icon: '🎓', title: 'Formation gratuite', desc: 'Accès à notre programme de formation et d\'accompagnement sans frais.' },
  { icon: '🌍', title: 'Communauté solide', desc: 'Rejoignez une communauté de chauffeurs partenaires à travers toute l\'Afrique.' },
]

const requirements = [
  { step: '01', title: 'Inscrivez-vous en ligne', desc: 'Remplissez le formulaire d\'inscription en moins de 5 minutes.' },
  { step: '02', title: 'Soumettez vos documents', desc: 'Permis de conduire, pièce d\'identité et documents du véhicule.' },
  { step: '03', title: 'Entretien en ligne', desc: 'Un court entretien vidéo pour vous présenter à notre équipe.' },
  { step: '04', title: 'Activation du compte', desc: 'Votre compte est validé sous 48h. Commencez à gagner !' },
]

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
            <div class="section-tag">Chauffeurs Partenaires</div>
            <h1 class="section-title" style="font-size:clamp(2.5rem,5vw,4rem);margin-bottom:24px;">
              Conduisez avec ZekDrive,<br><span class="gradient-text">Gagnez plus</span>
            </h1>
            <p style="font-size:1.15rem;color:var(--text-muted);line-height:1.7;margin-bottom:40px;">
              Rejoignez +500 chauffeurs partenaires et gagnez jusqu'à <strong style="color:var(--teal);">350 000 FCFA par mois</strong>. Horaires flexibles, assurance incluse, paiement rapide.
            </p>
            <div style="display:flex;gap:16px;flex-wrap:wrap;">
              <a href="#postuler" class="btn btn-primary btn-lg">
                Commencer maintenant
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M5 12h14M12 5l7 7-7 7"/>
                </svg>
              </a>
              <a href="#calcul" class="btn btn-secondary btn-lg">Calculer mes gains</a>
            </div>
          </div>
        </div>
      </section>

      <!-- Benefits -->
      <section class="section">
        <div class="container">
          <div class="section-header fade-up">
            <div class="section-tag">Avantages</div>
            <h2 class="section-title">Pourquoi conduire avec <span class="gradient-text">ZekDrive ?</span></h2>
            <p class="section-subtitle">Nous prenons soin de nos chauffeurs partenaires avec des avantages concrets.</p>
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
            <div class="section-tag">Calculateur</div>
            <h2 class="section-title">Estimez vos <span class="gradient-text">revenus</span></h2>
            <p class="section-subtitle">Ajustez vos paramètres pour estimer vos gains avec ZekDrive.</p>
          </div>

          <div class="calculator-section fade-up" style="max-width:700px;margin:0 auto;">
            <div style="margin-bottom:32px;">
              <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;">
                <label style="font-family:'Sora',sans-serif;font-weight:600;font-size:0.95rem;">
                  Heures par jour
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
                  Jours par semaine
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
                  <div style="font-size:0.8rem;color:var(--text-subtle);text-transform:uppercase;letter-spacing:0.1em;margin-bottom:8px;">Par semaine</div>
                  <div class="calc-amount">{{ weeklyEarnings }}</div>
                  <div style="font-size:0.85rem;color:var(--text-muted);margin-top:4px;">FCFA estimés</div>
                </div>
                <div style="border-left:1px solid var(--card-border);padding-left:32px;">
                  <div style="font-size:0.8rem;color:var(--text-subtle);text-transform:uppercase;letter-spacing:0.1em;margin-bottom:8px;">Par mois</div>
                  <div class="calc-amount">{{ monthlyEarnings }}</div>
                  <div style="font-size:0.85rem;color:var(--text-muted);margin-top:4px;">FCFA estimés</div>
                </div>
              </div>
              <p style="font-size:0.8rem;color:var(--text-subtle);margin-top:20px;padding-top:16px;border-top:1px solid var(--card-border);">
                * Estimation basée sur le tarif horaire moyen de 2 800 FCFA. Les revenus réels peuvent varier selon la zone, la demande et le type de véhicule.
              </p>
            </div>
          </div>
        </div>
      </section>

      <!-- Requirements -->
      <section class="section" style="position:relative;overflow:hidden;">
        <div class="container" style="position:relative;z-index:1;">
          <div class="section-header centered fade-up">
            <div class="section-tag">Comment postuler</div>
            <h2 class="section-title">4 étapes pour <span class="gradient-text">commencer</span></h2>
          </div>

          <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:24px;">
            <div v-for="(req, i) in requirements" :key="i" class="fade-up" style="text-align:center;">
              <div style="width:72px;height:72px;background:var(--gradient);border-radius:50%;display:flex;align-items:center;justify-content:center;font-family:'Sora',sans-serif;font-size:1.4rem;font-weight:800;color:#fff;margin:0 auto 20px;box-shadow:0 8px 24px rgba(124,58,237,0.35);">
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
            <div class="section-tag">Candidature</div>
            <h2 class="section-title">Postulez <span class="gradient-text">maintenant</span></h2>
            <p class="section-subtitle">Remplissez le formulaire et notre équipe vous contactera sous 24h.</p>
          </div>

          <div class="form-section fade-up">
            <div class="form-grid">
              <div class="form-group">
                <label class="form-label">Prénom *</label>
                <input v-model="form.prenom" type="text" class="form-input" placeholder="Votre prénom" />
              </div>
              <div class="form-group">
                <label class="form-label">Nom *</label>
                <input v-model="form.nom" type="text" class="form-input" placeholder="Votre nom" />
              </div>
              <div class="form-group">
                <label class="form-label">Téléphone *</label>
                <input v-model="form.telephone" type="tel" class="form-input" placeholder="+221 77 000 00 00" />
              </div>
              <div class="form-group">
                <label class="form-label">Email</label>
                <input v-model="form.email" type="email" class="form-input" placeholder="votre@email.com" />
              </div>
              <div class="form-group">
                <label class="form-label">Ville *</label>
                <select v-model="form.ville" class="form-select">
                  <option value="">Sélectionnez votre ville</option>
                  <option>Dakar</option>
                  <option>Abidjan</option>
                  <option>Bamako</option>
                  <option>Kinshasa</option>
                  <option>Douala</option>
                  <option>Autre</option>
                </select>
              </div>
              <div class="form-group">
                <label class="form-label">Type de véhicule *</label>
                <select v-model="form.vehicule" class="form-select">
                  <option value="">Sélectionnez un type</option>
                  <option>Voiture (VTC)</option>
                  <option>Moto-taxi</option>
                  <option>Vélo</option>
                </select>
              </div>
              <div class="form-group full-width">
                <label class="form-label">Expérience de conduite</label>
                <select v-model="form.experience" class="form-select">
                  <option value="">Années d'expérience</option>
                  <option>Moins d'1 an</option>
                  <option>1 à 3 ans</option>
                  <option>3 à 5 ans</option>
                  <option>Plus de 5 ans</option>
                </select>
              </div>
              <div class="form-group full-width">
                <label class="form-label">Message (optionnel)</label>
                <textarea v-model="form.message" class="form-textarea" placeholder="Parlez-nous de vous, de votre motivation..." />
              </div>
            </div>

            <div style="margin-top:32px;">
              <button type="button" class="btn btn-primary btn-lg w-full" style="width:100%;justify-content:center;">
                Envoyer ma candidature
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M22 2L11 13M22 2l-7 20-4-9-9-4 20-7z"/>
                </svg>
              </button>
              <p style="font-size:0.82rem;color:var(--text-subtle);text-align:center;margin-top:16px;">
                En soumettant ce formulaire, vous acceptez nos conditions d'utilisation et notre politique de confidentialité.
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
