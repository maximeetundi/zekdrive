<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useScrollAnimation } from '~/composables/useScrollAnimation'

const { observe } = useScrollAnimation()

useHead({
  title: 'Contactez ZekDrive — Notre équipe est à votre écoute',
  meta: [
    { name: 'description', content: 'Une question, un partenariat ou besoin d\'assistance ? Contactez le support ZekDrive à Dakar, Abidjan et Bamako. Nous vous répondons sous 24h.' },
  ],
})

// Offices details
const offices = [
  {
    city: 'Dakar',
    country: 'Sénégal',
    address: 'Rue des Écrivains, Point E, Dakar',
    phone: '+221 33 824 55 55',
    email: 'dakar@zekdrive.com',
    hours: 'Lun - Ven : 8h00 - 18h00',
    coords: { x: 120, y: 110 }
  },
  {
    city: 'Abidjan',
    country: 'Côte d\'Ivoire',
    address: 'Boulevard de Marseille, Marcory, Abidjan',
    phone: '+225 27 22 44 88',
    email: 'abidjan@zekdrive.com',
    hours: 'Lun - Ven : 8h00 - 18h00 / Sam : 9h00 - 13h00',
    coords: { x: 480, y: 290 }
  },
  {
    city: 'Bamako',
    country: 'Mali',
    address: 'Avenue du Mali, ACI 2000, Bamako',
    phone: '+223 20 29 11 11',
    email: 'bamako@zekdrive.com',
    hours: 'Lun - Ven : 8h00 - 17h30',
    coords: { x: 310, y: 170 }
  }
]

const selectedCityIndex = ref(0)
const selectedCity = computed(() => offices[selectedCityIndex.value])

// Contact Form State
const form = ref({
  firstName: '',
  lastName: '',
  email: '',
  phone: '',
  subject: '',
  message: '',
  type: 'passenger' // passenger, driver, business, other
})

const isSubmitting = ref(false)
const showSuccess = ref(false)
const errors = ref<Record<string, string>>({})

function selectCity(index: number) {
  selectedCityIndex.value = index
}

function validateForm() {
  const tempErrors: Record<string, string> = {}
  if (!form.value.firstName.trim()) tempErrors.firstName = 'Le prénom est requis'
  if (!form.value.lastName.trim()) tempErrors.lastName = 'Le nom est requis'
  
  if (!form.value.email.trim()) {
    tempErrors.email = 'L\'adresse e-mail est requise'
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.value.email)) {
    tempErrors.email = 'Format d\'adresse e-mail invalide'
  }
  
  if (!form.value.phone.trim()) {
    tempErrors.phone = 'Le numéro de téléphone est requis'
  }
  
  if (!form.value.subject) {
    tempErrors.subject = 'Veuillez sélectionner un sujet'
  }
  
  if (!form.value.message.trim()) {
    tempErrors.message = 'Le message ne peut pas être vide'
  } else if (form.value.message.length < 10) {
    tempErrors.message = 'Le message doit contenir au moins 10 caractères'
  }
  
  errors.value = tempErrors
  return Object.keys(tempErrors).length === 0
}

function handleSubmit() {
  if (!validateForm()) return
  
  isSubmitting.value = true
  
  // Simulate API call
  setTimeout(() => {
    isSubmitting.value = false
    showSuccess.value = true
    
    // Reset form
    form.value = {
      firstName: '',
      lastName: '',
      email: '',
      phone: '',
      subject: '',
      message: '',
      type: 'passenger'
    }
    
    // Clear success message after 5 seconds
    setTimeout(() => {
      showSuccess.value = false
    }, 5000)
  }, 1500)
}

onMounted(() => {
  document.querySelectorAll('.fade-up, .fade-in').forEach((el) => {
    observe(el as HTMLElement)
  })
})
</script>

<template>
  <div>
    <TheHeader />
    <main>
      <!-- Hero Section -->
      <section class="contact-hero" style="position:relative;overflow:hidden;padding:140px 0 80px;">
        <div class="orb orb-violet" style="width:500px;height:500px;right:-100px;top:-100px;opacity:0.4;" />
        <div class="orb orb-teal" style="width:300px;height:300px;left:-50px;bottom:0;opacity:0.3;" />
        
        <div class="container" style="position:relative;z-index:1;">
          <div style="max-width:720px;margin:0 auto;text-align:center;">
            <div class="section-tag fade-up">Contact & Support</div>
            <h1 class="section-title fade-up" style="font-size:clamp(2.2rem,5vw,3.6rem);">
              Une question ?<br><span class="gradient-text">Notre équipe est là</span>
            </h1>
            <p class="section-subtitle fade-up" style="margin:0 auto;">
              Que vous soyez passager, chauffeur ou entreprise, nous répondons à vos besoins de mobilité partout en Afrique de l'Ouest.
            </p>
          </div>
        </div>
      </section>

      <!-- Contact Info Cards -->
      <section class="section" style="padding-top:20px;padding-bottom:60px;">
        <div class="container">
          <div class="contact-info-grid">
            <div class="contact-info-card fade-up">
              <div class="contact-icon">📞</div>
              <h3 class="contact-info-title">Téléphone</h3>
              <p class="contact-info-value" style="margin-bottom:8px;">+221 33 824 55 55</p>
              <p style="font-size:0.85rem;color:var(--text-muted);">Assistance 7j/7, 24h/24</p>
            </div>
            
            <div class="contact-info-card fade-up" style="transition-delay:0.1s;">
              <div class="contact-icon">✉️</div>
              <h3 class="contact-info-title">E-mail</h3>
              <p class="contact-info-value" style="margin-bottom:8px;">support@zekdrive.com</p>
              <p style="font-size:0.85rem;color:var(--text-muted);">Réponse sous 24 heures ouvrées</p>
            </div>
            
            <div class="contact-info-card fade-up" style="transition-delay:0.2s;">
              <div class="contact-icon">📍</div>
              <h3 class="contact-info-title">Siège social</h3>
              <p class="contact-info-value" style="margin-bottom:8px;">Dakar, Sénégal</p>
              <p style="font-size:0.85rem;color:var(--text-muted);">Point E, Rue des Écrivains</p>
            </div>
          </div>
        </div>
      </section>

      <!-- Map & Details Grid -->
      <section class="section" style="padding-top:20px;padding-bottom:80px;background:var(--bg-2);position:relative;">
        <div class="orb orb-purple" style="width:400px;height:400px;left:30%;top:20%;opacity:0.25;" />
        
        <div class="container" style="position:relative;z-index:1;">
          <div class="section-header centered fade-up">
            <div class="section-tag">Présence locale</div>
            <h2 class="section-title">Nos <span class="gradient-text">bureaux régionaux</span></h2>
            <p class="section-subtitle">Découvrez nos hubs de support et centres d'accueil pour chauffeurs partenaires.</p>
          </div>

          <div class="map-section-grid">
            <!-- Interactive Map Wrapper -->
            <div class="map-card fade-up">
              <div class="map-header">
                <span class="pulse-indicator"></span>
                <span style="font-family:'Sora',sans-serif;font-size:0.85rem;font-weight:700;letter-spacing:0.05em;text-transform:uppercase;">
                  Carte interactive des hubs
                </span>
              </div>
              <div class="map-svg-container">
                <svg width="100%" height="100%" viewBox="0 0 640 400" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <!-- Tech Grid Pattern Background -->
                  <defs>
                    <pattern id="dotGrid" width="20" height="20" patternUnits="userSpaceOnUse">
                      <circle cx="2" cy="2" r="1.5" fill="rgba(255, 255, 255, 0.04)" />
                    </pattern>
                  </defs>
                  <rect width="100%" height="100%" fill="url(#dotGrid)" />

                  <!-- Stylized connection paths between hubs -->
                  <path d="M120 110 Q220 120 310 170" stroke="rgba(124, 58, 237, 0.3)" stroke-width="2" stroke-dasharray="6 4" />
                  <path d="M310 170 Q410 220 480 290" stroke="rgba(0, 229, 204, 0.3)" stroke-width="2" stroke-dasharray="6 4" />
                  <path d="M120 110 Q320 230 480 290" stroke="rgba(255, 255, 255, 0.15)" stroke-width="1.5" stroke-dasharray="4 4" />

                  <!-- Coastline abstract representation -->
                  <path d="M50 80 C 80 100, 100 130, 90 180 C 80 230, 110 270, 150 290 C 200 310, 250 330, 310 320 C 370 310, 420 340, 480 340 C 540 340, 590 310, 620 280" 
                        stroke="rgba(255, 255, 255, 0.05)" stroke-width="3" fill="none" />

                  <!-- Glowing animated connections (gradient overlays) -->
                  <circle cx="120" cy="110" r="15" fill="rgba(124, 58, 237, 0.25)" class="glowing-circle" />
                  <circle cx="310" cy="170" r="15" fill="rgba(0, 229, 204, 0.2)" class="glowing-circle" />
                  <circle cx="480" cy="290" r="15" fill="rgba(168, 85, 247, 0.2)" class="glowing-circle" />

                  <!-- Dakar Hub Interactive Node -->
                  <g class="map-node" :class="{ active: selectedCityIndex === 0 }" @click="selectCity(0)">
                    <circle cx="120" cy="110" r="8" fill="var(--violet)" stroke="#fff" stroke-width="2" />
                    <circle cx="120" cy="110" r="20" fill="transparent" class="hover-area" />
                    <text x="120" y="90" text-anchor="middle" fill="#fff" font-family="Sora" font-size="12" font-weight="700">Dakar</text>
                  </g>

                  <!-- Bamako Hub Interactive Node -->
                  <g class="map-node" :class="{ active: selectedCityIndex === 2 }" @click="selectCity(2)">
                    <circle cx="310" cy="170" r="8" fill="var(--teal)" stroke="#fff" stroke-width="2" />
                    <circle cx="310" cy="170" r="20" fill="transparent" class="hover-area" />
                    <text x="310" y="150" text-anchor="middle" fill="#fff" font-family="Sora" font-size="12" font-weight="700">Bamako</text>
                  </g>

                  <!-- Abidjan Hub Interactive Node -->
                  <g class="map-node" :class="{ active: selectedCityIndex === 1 }" @click="selectCity(1)">
                    <circle cx="480" cy="290" r="8" fill="var(--violet-light)" stroke="#fff" stroke-width="2" />
                    <circle cx="480" cy="290" r="20" fill="transparent" class="hover-area" />
                    <text x="480" y="270" text-anchor="middle" fill="#fff" font-family="Sora" font-size="12" font-weight="700">Abidjan</text>
                  </g>
                </svg>
              </div>
            </div>

            <!-- Operating Office Detail Card -->
            <div class="office-details-card fade-up">
              <div style="margin-bottom:24px;">
                <span class="office-country-tag">{{ selectedCity.country }}</span>
                <h3 class="office-city-title">{{ selectedCity.city }}</h3>
              </div>
              
              <div class="office-info-list">
                <div class="office-info-item">
                  <div class="office-info-icon">📍</div>
                  <div>
                    <h4 class="office-info-label">Adresse</h4>
                    <p class="office-info-text">{{ selectedCity.address }}</p>
                  </div>
                </div>

                <div class="office-info-item">
                  <div class="office-info-icon">📞</div>
                  <div>
                    <h4 class="office-info-label">Téléphone</h4>
                    <a :href="'tel:' + selectedCity.phone.replace(/\s+/g, '')" class="office-info-text-link">
                      {{ selectedCity.phone }}
                    </a>
                  </div>
                </div>

                <div class="office-info-item">
                  <div class="office-info-icon">✉️</div>
                  <div>
                    <h4 class="office-info-label">E-mail Hub</h4>
                    <a :href="'mailto:' + selectedCity.email" class="office-info-text-link">
                      {{ selectedCity.email }}
                    </a>
                  </div>
                </div>

                <div class="office-info-item">
                  <div class="office-info-icon">⏰</div>
                  <div>
                    <h4 class="office-info-label">Horaires d'ouverture</h4>
                    <p class="office-info-text">{{ selectedCity.hours }}</p>
                  </div>
                </div>
              </div>

              <!-- Quick City Selectors -->
              <div class="city-selector-tabs">
                <button 
                  v-for="(office, index) in offices" 
                  :key="office.city"
                  @click="selectCity(index)"
                  class="city-tab"
                  :class="{ active: selectedCityIndex === index }"
                  type="button"
                >
                  {{ office.city }}
                </button>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Contact Form & FAQ intro -->
      <section class="section" style="position:relative;overflow:hidden;">
        <div class="orb orb-violet" style="width:450px;height:450px;right:-100px;bottom:-100px;opacity:0.3;" />
        
        <div class="container" style="position:relative;z-index:1;max-width:960px;">
          <div class="section-header centered fade-up">
            <div class="section-tag">Formulaire</div>
            <h2 class="section-title">Envoyez-nous un <span class="gradient-text">message</span></h2>
            <p class="section-subtitle">Notre support client est disponible pour vous assister rapidement.</p>
          </div>

          <div class="form-section fade-up">
            <!-- Form Success Notification -->
            <transition name="slide-fade">
              <div v-if="showSuccess" class="form-success-banner" style="margin-bottom:32px;">
                <div class="success-icon">✓</div>
                <div>
                  <h4 style="font-family:'Sora',sans-serif;font-weight:700;margin-bottom:4px;">Message envoyé avec succès !</h4>
                  <p style="font-size:0.9rem;opacity:0.9;">Merci de nous avoir contactés. Nos agents prendront contact avec vous sous 24 heures.</p>
                </div>
              </div>
            </transition>

            <form @submit.prevent="handleSubmit">
              <div class="form-grid">
                <!-- Profile Type Select -->
                <div class="form-group full-width">
                  <label class="form-label">Vous êtes *</label>
                  <div class="profile-type-grid">
                    <label class="profile-type-option" :class="{ active: form.type === 'passenger' }">
                      <input type="radio" v-model="form.type" value="passenger" style="display:none;" />
                      <span class="profile-icon">🚗</span>
                      <span class="profile-label">Passager</span>
                    </label>
                    <label class="profile-type-option" :class="{ active: form.type === 'driver' }">
                      <input type="radio" v-model="form.type" value="driver" style="display:none;" />
                      <span class="profile-icon">🔑</span>
                      <span class="profile-label">Chauffeur</span>
                    </label>
                    <label class="profile-type-option" :class="{ active: form.type === 'business' }">
                      <input type="radio" v-model="form.type" value="business" style="display:none;" />
                      <span class="profile-icon">🏢</span>
                      <span class="profile-label">Entreprise</span>
                    </label>
                    <label class="profile-type-option" :class="{ active: form.type === 'other' }">
                      <input type="radio" v-model="form.type" value="other" style="display:none;" />
                      <span class="profile-icon">🤝</span>
                      <span class="profile-label">Partenaire</span>
                    </label>
                  </div>
                </div>

                <!-- Fields -->
                <div class="form-group">
                  <label class="form-label">Prénom *</label>
                  <input 
                    v-model="form.firstName" 
                    type="text" 
                    class="form-input" 
                    :class="{ 'has-error': errors.firstName }"
                    placeholder="Votre prénom" 
                  />
                  <span v-if="errors.firstName" class="form-error-msg">{{ errors.firstName }}</span>
                </div>

                <div class="form-group">
                  <label class="form-label">Nom *</label>
                  <input 
                    v-model="form.lastName" 
                    type="text" 
                    class="form-input" 
                    :class="{ 'has-error': errors.lastName }"
                    placeholder="Votre nom" 
                  />
                  <span v-if="errors.lastName" class="form-error-msg">{{ errors.lastName }}</span>
                </div>

                <div class="form-group">
                  <label class="form-label">Adresse e-mail *</label>
                  <input 
                    v-model="form.email" 
                    type="email" 
                    class="form-input" 
                    :class="{ 'has-error': errors.email }"
                    placeholder="nom@exemple.com" 
                  />
                  <span v-if="errors.email" class="form-error-msg">{{ errors.email }}</span>
                </div>

                <div class="form-group">
                  <label class="form-label">Téléphone *</label>
                  <input 
                    v-model="form.phone" 
                    type="tel" 
                    class="form-input" 
                    :class="{ 'has-error': errors.phone }"
                    placeholder="+221 77 000 00 00" 
                  />
                  <span v-if="errors.phone" class="form-error-msg">{{ errors.phone }}</span>
                </div>

                <div class="form-group full-width">
                  <label class="form-label">Sujet de votre demande *</label>
                  <select 
                    v-model="form.subject" 
                    class="form-select"
                    :class="{ 'has-error': errors.subject }"
                  >
                    <option value="">Choisissez une option</option>
                    <option value="support">Assistance avec un trajet / problème de l'application</option>
                    <option value="recruitment">Recrutement / Devenir chauffeur partenaire</option>
                    <option value="b2b">ZekDrive Pro & Facturation entreprise</option>
                    <option value="partnership">Opportunité de partenariat commercial</option>
                    <option value="legal">Demandes juridiques ou presse</option>
                    <option value="other">Autre demande générale</option>
                  </select>
                  <span v-if="errors.subject" class="form-error-msg">{{ errors.subject }}</span>
                </div>

                <div class="form-group full-width">
                  <label class="form-label">Message *</label>
                  <textarea 
                    v-model="form.message" 
                    class="form-textarea" 
                    :class="{ 'has-error': errors.message }"
                    placeholder="Écrivez votre message de manière détaillée afin de nous aider à mieux vous répondre..."
                  />
                  <span v-if="errors.message" class="form-error-msg">{{ errors.message }}</span>
                </div>
              </div>

              <!-- Action button -->
              <div style="margin-top:40px; display:flex; flex-direction:column; align-items:center; gap:16px;">
                <button 
                  type="submit" 
                  class="btn btn-primary btn-lg w-full" 
                  style="width:100%; justify-content:center;"
                  :disabled="isSubmitting"
                >
                  <span v-if="isSubmitting">Envoi en cours...</span>
                  <span v-else style="display:flex; align-items:center; gap:10px;">
                    Envoyer mon message
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                      <path d="M22 2L11 13M22 2l-7 20-4-9-9-4 20-7z"/>
                    </svg>
                  </span>
                </button>
                <p style="font-size:0.8rem;color:var(--text-subtle);text-align:center;">
                  * En envoyant ce formulaire, vous consentez à ce que ZekDrive traite vos données pour répondre à votre demande.
                </p>
              </div>
            </form>
          </div>
        </div>
      </section>

      <!-- Global Social Connection Banner -->
      <section class="section" style="padding:60px 0;background:var(--bg-2);border-top:1px solid var(--card-border);">
        <div class="container">
          <div style="display:flex;flex-wrap:wrap;justify-content:space-between;align-items:center;gap:32px;">
            <div>
              <h3 style="font-family:'Sora',sans-serif;font-size:1.4rem;font-weight:700;margin-bottom:8px;">Suivez-nous sur les réseaux</h3>
              <p style="color:var(--text-muted);font-size:0.95rem;">Soyez informé de nos nouveautés, promotions et lancements de villes.</p>
            </div>
            
            <div style="display:flex;gap:16px;">
              <a href="https://twitter.com" target="_blank" rel="noopener" class="social-circle-link" aria-label="X (Twitter)">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-4.714-6.231-5.401 6.231H2.744l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
                </svg>
              </a>
              <a href="https://instagram.com" target="_blank" rel="noopener" class="social-circle-link" aria-label="Instagram">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/>
                </svg>
              </a>
              <a href="https://facebook.com" target="_blank" rel="noopener" class="social-circle-link" aria-label="Facebook">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
                </svg>
              </a>
              <a href="https://linkedin.com" target="_blank" rel="noopener" class="social-circle-link" aria-label="LinkedIn">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/>
                </svg>
              </a>
            </div>
          </div>
        </div>
      </section>
    </main>
    <TheFooter />
  </div>
</template>

<style scoped>
/* Page Specific Hero Style */
.contact-hero {
  background: radial-gradient(ellipse at 50% 10%, rgba(124, 58, 237, 0.12) 0%, transparent 60%);
}

/* Map Grid Styles */
.map-section-grid {
  display: grid;
  grid-template-columns: 1.2fr 0.8fr;
  gap: 32px;
  margin-top: 40px;
}

.map-card {
  background: var(--bg);
  border: 1px solid var(--card-border);
  border-radius: var(--radius-lg);
  padding: 24px;
  position: relative;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  height: 480px;
}

.map-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 20px;
  position: relative;
  z-index: 2;
}

.pulse-indicator {
  width: 8px;
  height: 8px;
  background-color: var(--teal);
  border-radius: 50%;
  box-shadow: 0 0 0 0 rgba(0, 229, 204, 0.7);
  animation: pulse-dot 1.8s infinite;
}

@keyframes pulse-dot {
  0% {
    transform: scale(0.95);
    box-shadow: 0 0 0 0 rgba(0, 229, 204, 0.7);
  }
  70% {
    transform: scale(1);
    box-shadow: 0 0 0 8px rgba(0, 229, 204, 0);
  }
  100% {
    transform: scale(0.95);
    box-shadow: 0 0 0 0 rgba(0, 229, 204, 0);
  }
}

.map-svg-container {
  flex-grow: 1;
  width: 100%;
  position: relative;
}

/* Map Nodes Styling */
.map-node {
  cursor: pointer;
  transition: transform var(--transition);
}

.map-node circle {
  transition: r var(--transition), fill var(--transition), stroke var(--transition);
}

.map-node text {
  font-family: 'Sora', sans-serif;
  font-size: 11px;
  font-weight: 700;
  fill: var(--text-muted);
  transition: fill var(--transition), font-size var(--transition);
  text-shadow: 0 2px 4px rgba(0,0,0,0.8);
  pointer-events: none;
}

.map-node:hover text,
.map-node.active text {
  fill: #fff;
  font-size: 13px;
}

.map-node:hover circle:first-child,
.map-node.active circle:first-child {
  r: 10px;
  stroke-width: 3px;
}

.map-node.active circle:first-child {
  fill: var(--teal);
}

/* Glowing Circles behind Nodes */
.glowing-circle {
  transform-origin: center;
  animation: ripple 4s ease-out infinite;
}

@keyframes ripple {
  0% {
    r: 8px;
    opacity: 0.8;
  }
  100% {
    r: 35px;
    opacity: 0;
  }
}

.hover-area {
  cursor: pointer;
}

/* Office Details Card */
.office-details-card {
  background: var(--card-bg);
  border: 1px solid var(--card-border);
  border-radius: var(--radius-lg);
  padding: 40px 32px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  backdrop-filter: blur(10px);
}

.office-country-tag {
  font-family: 'Sora', sans-serif;
  font-size: 0.72rem;
  font-weight: 700;
  color: var(--teal);
  letter-spacing: 0.1em;
  text-transform: uppercase;
  background: var(--teal-dim);
  border: 1px solid rgba(0, 229, 204, 0.15);
  border-radius: 100px;
  padding: 4px 12px;
}

.office-city-title {
  font-family: 'Sora', sans-serif;
  font-size: 2.2rem;
  font-weight: 800;
  margin-top: 12px;
  color: var(--text);
  letter-spacing: -0.02em;
}

.office-info-list {
  display: flex;
  flex-direction: column;
  gap: 24px;
  margin-bottom: 32px;
}

.office-info-item {
  display: flex;
  gap: 16px;
  align-items: flex-start;
}

.office-info-icon {
  width: 42px;
  height: 42px;
  border-radius: 10px;
  background: rgba(255,255,255,0.03);
  border: 1px solid var(--card-border);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.1rem;
  flex-shrink: 0;
}

.office-info-label {
  font-size: 0.75rem;
  font-weight: 600;
  color: var(--text-subtle);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: 2px;
}

.office-info-text {
  font-size: 0.95rem;
  color: var(--text);
  font-weight: 500;
  line-height: 1.5;
}

.office-info-text-link {
  font-size: 0.95rem;
  color: var(--text);
  font-weight: 600;
  line-height: 1.5;
  transition: color 0.3s;
}

.office-info-text-link:hover {
  color: var(--teal);
}

/* Tabs inside details card */
.city-selector-tabs {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 8px;
  background: rgba(8, 11, 20, 0.4);
  padding: 6px;
  border-radius: var(--radius-sm);
  border: 1px solid var(--card-border);
}

.city-tab {
  font-family: 'Sora', sans-serif;
  font-size: 0.85rem;
  font-weight: 600;
  padding: 10px;
  text-align: center;
  border-radius: 6px;
  color: var(--text-muted);
  transition: all var(--transition);
}

.city-tab:hover {
  color: var(--text);
  background: rgba(255,255,255,0.02);
}

.city-tab.active {
  color: #fff;
  background: var(--violet);
  box-shadow: 0 4px 12px rgba(124, 58, 237, 0.3);
}

/* Profile Type Options Styles */
.profile-type-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
  margin-bottom: 8px;
}

.profile-type-option {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 16px 8px;
  background: var(--bg);
  border: 1px solid var(--card-border);
  border-radius: var(--radius-sm);
  cursor: pointer;
  transition: all var(--transition);
  text-align: center;
}

.profile-type-option:hover {
  border-color: rgba(255,255,255,0.15);
  background: rgba(255, 255, 255, 0.01);
}

.profile-type-option.active {
  border-color: var(--teal);
  background: var(--teal-dim);
  box-shadow: 0 0 12px rgba(0, 229, 204, 0.1);
}

.profile-icon {
  font-size: 1.4rem;
}

.profile-label {
  font-family: 'Sora', sans-serif;
  font-size: 0.82rem;
  font-weight: 700;
  color: var(--text-muted);
}

.profile-type-option.active .profile-label {
  color: #fff;
}

/* Form Errors */
.form-input.has-error,
.form-select.has-error,
.form-textarea.has-error {
  border-color: #ef4444 !important;
  box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1) !important;
}

.form-error-msg {
  font-size: 0.75rem;
  color: #ef4444;
  margin-top: 4px;
  font-weight: 500;
}

/* Success Banner style */
.form-success-banner {
  background: rgba(16, 185, 129, 0.1);
  border: 1px solid rgba(16, 185, 129, 0.25);
  border-radius: var(--radius-md);
  padding: 20px 24px;
  display: flex;
  gap: 16px;
  align-items: center;
  color: #fff;
}

.success-icon {
  width: 38px;
  height: 38px;
  background: #10b981;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
  font-weight: 800;
  flex-shrink: 0;
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
}

/* Social link circles */
.social-circle-link {
  width: 48px;
  height: 48px;
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid var(--card-border);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--text-muted);
  transition: all var(--transition);
}

.social-circle-link:hover {
  background: var(--gradient);
  border-color: transparent;
  color: #fff;
  transform: translateY(-3px);
  box-shadow: 0 4px 16px rgba(124, 58, 237, 0.4);
}

/* Vue Transitions */
.slide-fade-enter-active {
  transition: all 0.3s ease-out;
}
.slide-fade-leave-active {
  transition: all 0.3s cubic-bezier(1, 0.5, 0.8, 1);
}
.slide-fade-enter-from,
.slide-fade-leave-to {
  transform: translateY(-20px);
  opacity: 0;
}

/* Media Queries */
@media (max-width: 992px) {
  .map-section-grid {
    grid-template-columns: 1fr;
  }
  .map-card {
    height: 380px;
  }
}

@media (max-width: 600px) {
  .profile-type-grid {
    grid-template-columns: 1fr 1fr;
  }
  .map-card {
    height: 280px;
    padding: 16px;
  }
  .map-header {
    margin-bottom: 10px;
  }
  .map-svg-container svg text {
    font-size: 10px;
  }
}
</style>
