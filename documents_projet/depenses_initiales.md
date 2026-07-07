# 💰 Estimation des Dépenses de Fonctionnement sur un An — ZekDrive

Ce document présente l'estimation des coûts réels de fonctionnement de la plateforme **ZekDrive** sur une durée de **un an (12 mois)**, en excluant les frais de marketing, d'enregistrement légal, de SMS payant et de service tiers WhatsApp (OpenWA étant hébergé en local par nos soins).

Toutes les conversions sont basées sur le taux de change moyen : **1 EUR = 655,957 FCFA** (arrondi à **656 FCFA**).

---

## 📊 1. Tableau des Factures et Coûts sur un An (12 mois)

| Catégorie | Description | Type de Coût | Tarification Unitaire | Coût Cumulé sur 1 An (FCFA) | Notes / Détails |
| :--- | :--- | :---: | :---: | :---: | :--- |
| **Hébergement** | IONOS VPS L (8 Go RAM, 4 vCores, 240 Go NVMe) | Récurrent (Mensuel) | ~15 € / mois | **118 080 FCFA** | 12 mois d'hébergement pour tous les conteneurs Docker. |
| **Nom de domaine** | Domaine `zekdrive.com` chez IONOS | Récurrent (Annuel) | 1 € (an 1) / 15 € | **656 FCFA** | Tarif promotionnel la première année chez IONOS. |
| **Certificats SSL** | Chiffrement HTTPS via Let's Encrypt | Gratuit | 0 € | **0 FCFA** | Renouvellement automatique gratuit. |
| **Console Google Play** | Compte Développeur Google (Android) | Unique | 25 $ (une fois) | **15 000 FCFA** | Paiement unique à vie pour publier les APKs. |
| **Apple Developer** | Compte Développeur Apple (iOS) | Récurrent (Annuel) | 99 $ / an | **60 000 FCFA** | Licence annuelle obligatoire pour distribuer sur l'App Store. |
| **Serveur SMTP** | Serveur de messagerie (E-mails système) | Gratuit | Inclus IONOS | **0 FCFA** | Fourni gratuitement avec le pack domaine/mail IONOS. |
| **API WhatsApp** | Instance OpenWA (Hébergement Local) | Gratuit | Self-hosted | **0 FCFA** | Instance hébergée gratuitement sur notre VPS de 8 Go RAM. |
| **Cartographie / GPS** | OpenStreetMap (OSM) & Serveur OSRM | Gratuit | Open Source | **0 FCFA** | Cartographie et calcul d'itinéraires gratuits via OpenStreetMap. |

---

## 📈 2. Synthèse Budgétaire (Première Année vs Années Suivantes)

Grâce à l'hébergement en local de l'API WhatsApp (OpenWA) et à l'utilisation du serveur SMTP gratuit d'IONOS, les charges récurrentes de la plateforme sont extrêmement réduites.

### 🔴 Facture Totale - Année 1 (Lancement)
Ce montant comprend les frais uniques d'ouverture de comptes développeurs et le tarif promotionnel du nom de domaine.

*   Hébergement VPS L (12 mois) : **118 080 FCFA**
*   Nom de domaine (An 1) : **656 FCFA**
*   Compte développeur Google Play : **15 000 FCFA**
*   Compte développeur Apple Store : **60 000 FCFA**
*   **TOTAL FACTURE ANNUELLE (AN 1) : 193 736 FCFA**

---

### 🟢 Facture Totale Récurrente - Années Suivantes (Par An)
À partir de la deuxième année, les frais uniques (Google Play) disparaissent, et le nom de domaine repasse au tarif standard.

*   Hébergement VPS L (12 mois) : **118 080 FCFA**
*   Nom de domaine (Renouvellement standard) : **9 840 FCFA**
*   Compte développeur Apple Store : **60 000 FCFA**
*   **TOTAL FACTURE ANNUELLE RÉCURRENTE : 187 920 FCFA / an** *(soit environ 15 660 FCFA / mois)*
