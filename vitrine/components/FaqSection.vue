<script setup lang="ts">
import { ref } from 'vue'

const faqs = [
  {
    q: 'Comment puis-je télécharger l\'application ZekDrive ?',
    a: 'Vous pouvez télécharger ZekDrive gratuitement sur l\'App Store (iOS) et sur Google Play (Android). Recherchez "ZekDrive" et installez l\'application. L\'inscription prend moins de 2 minutes.',
  },
  {
    q: 'Quels modes de paiement sont acceptés ?',
    a: 'ZekDrive accepte les paiements via Orange Money, MTN Mobile Money, Wave, les cartes bancaires Visa/Mastercard, ainsi que les espèces pour certains services. Vous pouvez sauvegarder votre méthode préférée dans l\'app.',
  },
  {
    q: 'Dans quelles villes ZekDrive est-il disponible ?',
    a: 'ZekDrive est actuellement disponible à Dakar, Abidjan, Bamako, Kinshasa, Douala et en cours de déploiement dans d\'autres grandes villes africaines. Activez les notifications pour être informé du lancement dans votre ville.',
  },
  {
    q: 'Comment sont sélectionnés et vérifiés les chauffeurs ?',
    a: 'Chaque chauffeur ZekDrive passe par un processus rigoureux de vérification : contrôle du permis de conduire, vérification de l\'identité, inspection du véhicule et formation sur les standards de service. Ils sont ensuite régulièrement évalués par les utilisateurs.',
  },
  {
    q: 'Puis-je annuler une course ? Y a-t-il des frais ?',
    a: 'Vous pouvez annuler gratuitement dans les 2 premières minutes suivant votre réservation. Au-delà, des frais d\'annulation minimes peuvent s\'appliquer pour respecter le temps du chauffeur. Les détails sont affichés dans l\'application avant confirmation.',
  },
  {
    q: 'Le service de livraison ZekDrive est-il assuré ?',
    a: 'Oui, tous les colis transportés via ZekDrive Livraison sont couverts par notre assurance jusqu\'à une valeur déclarée. En cas de problème, notre support 24/7 est disponible pour traiter votre réclamation rapidement.',
  },
  {
    q: 'Comment puis-je devenir chauffeur partenaire ?',
    a: 'Rendez-vous sur la page "Devenir Chauffeur" de notre site ou dans la section Chauffeur de l\'application. Remplissez le formulaire, fournissez vos documents (permis, pièce d\'identité, carte grise) et passez l\'entretien en ligne. Vous pouvez commencer en quelques jours.',
  },
  {
    q: 'ZekDrive propose-t-il des tarifs entreprise ?',
    a: 'Oui ! ZekDrive Pro offre des solutions dédiées aux entreprises : tableau de bord centralisé, facturation mensuelle, rapports de dépenses, et tarifs négociés pour les grands volumes. Visitez notre page Pro ou contactez-nous pour un devis.',
  },
]

const openIndex = ref<number | null>(null)

function toggle(i: number) {
  openIndex.value = openIndex.value === i ? null : i
}

function getMaxHeight(i: number) {
  return openIndex.value === i ? '400px' : '0'
}
</script>

<template>
  <section class="section" style="position:relative;overflow:hidden;">
    <div class="orb orb-violet" style="width:400px;height:400px;right:-100px;top:0;opacity:0.3;" />

    <div class="container" style="position:relative;z-index:1;">
      <div class="section-header centered fade-up">
        <div class="section-tag">FAQ</div>
        <h2 class="section-title">Questions <span class="gradient-text">fréquentes</span></h2>
        <p class="section-subtitle">Tout ce que vous devez savoir sur ZekDrive.</p>
      </div>

      <div class="faq-list fade-up">
        <div
          v-for="(faq, i) in faqs"
          :key="i"
          class="faq-item"
          :class="{ open: openIndex === i }"
        >
          <button class="faq-question" @click="toggle(i)">
            {{ faq.q }}
            <div class="faq-icon">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                <path d="M12 5v14M5 12h14"/>
              </svg>
            </div>
          </button>
          <div
            class="faq-answer"
            :style="{ maxHeight: getMaxHeight(i) }"
          >
            <div class="faq-answer-inner">{{ faq.a }}</div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>
