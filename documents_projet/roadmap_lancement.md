# 🚀 Feuille de Route de Lancement (Roadmap) — ZekDrive

Ce document décrit étape par étape les actions techniques et opérationnelles requises pour lancer officiellement la startup **ZekDrive** sur le marché.

---

## 📅 Chronologie du Lancement (6 Étapes)

```
┌────────────────────────┐      ┌────────────────────────┐      ┌────────────────────────┐
│ Phase 1: Préparation   │ ───> │ Phase 2: Setup VPS     │ ───> │ Phase 3: Setup OSM/WA  │
│ Achat Domaine & VPS    │      │ Docker & Certificats   │      │ OSRM & OpenWA local    │
└────────────────────────┘      └────────────────────────┘      └────────────────────────┘
                                                                            │
┌────────────────────────┐      ┌────────────────────────┐      ┌────────────────────────┐
│ Phase 6: Lancement     │ <─── │ Phase 5: Recrutement   │ <─── │ Phase 4: Compil & Pub  │
│ Public & Marketing     │      │ Onboarding Chauffeurs  │      │ Google Play & App Store│
└────────────────────────┘      └────────────────────────┘      └────────────────────────┘
```

---

## 🛠️ Phase 1 : Préparatifs Techniques & Réservations (Semaine 1)
*   [ ] **Nom de domaine :** Acheter le domaine `zekdrive.com` (ou extension locale comme `.net`, `.org` ou extension pays) chez IONOS.
*   [ ] **Serveur :** Commander le serveur IONOS VPS L (8 Go RAM, 4 vCores, OS Ubuntu 24.04 LTS).
*   [ ] **Comptes Stores :** 
    *   Créer le compte développeur Google Play Console (25 $ unique).
    *   Créer le compte développeur Apple Developer Program (99 $ / an).
*   [ ] **Services Cloud :**
    *   Créer un compte Firebase Console pour le projet de notifications push (FCM).

---

## 💻 Phase 2 : Configuration du VPS & Base de données (Semaine 2)
*   [ ] **Outils système :** Se connecter au VPS en SSH, installer Docker, Docker Compose, Git et Make.
*   [ ] **Clonage :** Cloner le code de ZekDrive dans `/root/zekdrive`.
*   [ ] **Sécurité (SSL) :** Installer `certbot` et générer les certificats SSL gratuits pour `zekdrive.com`, `api.zekdrive.com` et `admin.zekdrive.com`. Copier les fichiers dans `nginx/ssl/`.
*   [ ] **Variables d'environnement :** Créer le fichier `/root/zekdrive/.env` de production avec des mots de passe robustes (PostgreSQL, Redis, clés JWT). Renseigner le fichier de configuration Firebase.
*   [ ] **Premier Lancement :** Exécuter `make prod` pour builder et lancer l'ensemble de la pile Docker (Base de données, API, Admin, Vitrine, Nginx).

---

## 🗺️ Phase 3 : Configuration d'OpenStreetMap, OSRM et WhatsApp (Semaine 2-3)
*   [ ] **Routing local (OSRM) :** Télécharger les données de cartes gratuites d'OpenStreetMap (format `.osm.pbf`) de votre région de lancement. Configurer et lancer le conteneur OSRM pour calculer les temps de trajet et les itinéraires de manière 100% gratuite sur votre VPS de 8 Go.
*   [ ] **WhatsApp (OpenWA) :** Lancer le conteneur OpenWA en local sur le VPS, scanner le QR code avec le téléphone dédié au service client pour coupler l'API WhatsApp et activer les notifications automatiques.
*   [ ] **Test SMTP :** Vérifier que les mails d'invitation d'administration partent correctement via le serveur SMTP IONOS gratuit.

---

## 📱 Phase 4 : Compilation et Publication des Applications (Semaine 3)
*   [ ] **Keystores :** Générer les clés de signature de production pour les applications Android (Pro et User).
*   [ ] **Configuration API :** Renseigner l'adresse HTTPS de production de l'API (`https://api.zekdrive.com`) dans les configurations Flutter des deux applications.
*   [ ] **Compilation :** Exécuter les commandes de compilation release pour générer les APKs signés (`zekdrive-user.apk` et `zekdrive-chauffeur.apk`).
*   [ ] **Publication Google Play :** Soumettre les APKs sur la console Google Play pour examen (prévoir 3 à 7 jours de validation par Google).
*   [ ] **Publication App Store (Si applicable) :** Soumettre la version iOS sur App Store Connect.

---

## 🚗 Phase 5 : Onboarding et Validation des Chauffeurs (Semaine 4)
*   [ ] **Site Vitrine :** Ouvrir le site vitrine avec le formulaire d'inscription pour les futurs chauffeurs partenaires.
*   [ ] **Vérification Légale (Onboarding) :** Pour chaque inscription de chauffeur sur le panel d'administration, exiger et valider les documents suivants :
    *   Permis de conduire en cours de validité.
    *   Carte grise du véhicule.
    *   Attestation d'assurance professionnelle de transport de personnes.
    *   Extrait de casier judiciaire (N° 3) pour garantir la sécurité des passagers.
*   [ ] **Formation :** Expliquer le fonctionnement de l'application ZekDrive Pro (accepter une course, lancer le guidage GPS OSM, valider la fin de course, gestion des paiements).

---

## 📣 Phase 6 : Lancement Officiel & Communication (Semaine 5)
*   [ ] **Mise en service :** Passer la plateforme en mode actif (tous les feux sont au vert).
*   [ ] **Marketing local :** Distribuer des flyers dans les zones stratégiques (hôtels, centres commerciaux, gares, centres d'affaires).
*   [ ] **Parrainage :** Activer la campagne de parrainage client/chauffeur pour déclencher le bouche-à-oreille.
*   [ ] **Monitoring :** Surveiller les logs du serveur (avec `make logs`) et la consommation de RAM du VPS pour s'assurer qu'aucun service ne sature.
