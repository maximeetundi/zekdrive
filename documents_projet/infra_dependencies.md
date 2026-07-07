# 🚗 ZekDrive - Guide des Dépendances & Prérequis d'Infrastructure

Ce document récapitule l'ensemble des besoins matériels, logiciels, noms de domaine et dépendances tierces (APIs) nécessaires pour lancer l'infrastructure **ZekDrive** en production.

---

## 📊 1. Choix du Serveur VPS (IONOS)

L'architecture de ZekDrive fonctionne entièrement sous Docker avec plusieurs conteneurs en production :
*   **Base de données :** PostgreSQL 16 + Extension PostGIS (limite : 512 Mo RAM)
*   **Cache & Key-Value :** Redis 7 (limite : 256 Mo RAM)
*   **Backend API :** Go Fiber REST API (limite : 512 Mo RAM par réplicat × 2 = 1 Go RAM)
*   **Admin Panel :** Nuxt 3 SSR (limite : 256 Mo RAM)
*   **Site Vitrine :** Nuxt 3 SSG (limite : 128 Mo RAM)
*   **Reverse Proxy :** Nginx (limite : 128 Mo RAM)

Le total des limites de mémoire définies dans le fichier `docker-compose.prod.yml` est d'environ **2,3 Go de RAM**. En y ajoutant la consommation du système d'exploitation (environ 500 Mo à 1 Go), voici les options chez **IONOS.fr** :

| Offre IONOS VPS | CPU (vCores) | Mémoire RAM | Disque NVMe | Prix Standard (Indicatif) | Verdict pour ZekDrive |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **VPS XS** | 1 vCore | 1 Go | 10 Go | ~1 à 2 € / mois | ❌ **Inadapté** (La base de données et les builds Nuxt crasheront immédiatement par manque de RAM). |
| **VPS S** | 2 vCores | 2 Go | 80 Go | ~4 à 5 € / mois | ❌ **Insuffisant** (Trop de risques de crashs OOM pour une mise en production, même avec du swap). |
| **VPS M** | 2 vCores | 4 Go | 160 Go | ~8 à 9 € / mois | ⚠️ **Limité à terme** (Permet de démarrer mais reste trop juste pour gérer simultanément la compilation Nuxt, l'API Go et les calculs géographiques PostGIS). |
| **VPS L** | 4 vCores | **8 Go** | 240 Go | ~14 à 16 € / mois | **Recommandé (Idéal pour la production)**. Assure une excellente stabilité, élimine les crashs OOM, fluidifie les compilations Docker et absorbe les pics de trafic initiaux. |

> [!IMPORTANT]
> **Choix validé pour le lancement :**
> Choisissez le **VPS L (8 Go RAM / 4 vCores)** à environ 14-16 €/mois. 
> 4 Go de RAM reste un peu juste pour faire tourner sereinement PostgreSQL/PostGIS, Redis, 2 réplicas de l'API Go, le panel Admin Nuxt et la Vitrine de manière stable en production, surtout lors des phases de build des conteneurs qui sollicitent fortement la mémoire. Les 8 Go de RAM offrent la marge nécessaire pour garantir la réactivité de l'application et éviter toute indisponibilité.

*   **Système d'exploitation recommandé sur le serveur :** Ubuntu 24.04 LTS (ou Debian 12).

---

## 🛠️ 2. Logiciels requis sur le Serveur

Une fois le serveur VPS IONOS provisionné avec Ubuntu/Debian, les dépendances système suivantes doivent être installées :

1.  **Docker Engine** (version >= 24.0) : Pour exécuter l'ensemble des composants de manière isolée.
2.  **Docker Compose** (version >= 2.0) : Pour orchestrer le démarrage des conteneurs.
3.  **Git** : Pour cloner et mettre à jour le code source sur le serveur.
4.  **GNU Make** : Pour utiliser les raccourcis configurés dans le `Makefile` (ex: `make prod`, `make logs`).

---

## 🌐 3. Nom de Domaine & Configuration DNS

Pour l'accès des utilisateurs et des applications mobiles, un nom de domaine est obligatoire. Vous pouvez l'acheter chez IONOS (ex: `zekdrive.com`).

### Configuration des Zones DNS (Pointages A)
Dans l'interface de gestion de votre domaine IONOS, vous devez créer les enregistrements suivants pointant vers **l'adresse IP publique de votre VPS** :

| Type | Sous-domaine | Cible / Valeur | Rôle |
| :---: | :--- | :--- | :--- |
| **A** | `@` (ou vide) | `IP_DU_VPS_IONOS` | Redirige les clients vers le site vitrine. |
| **A** | `www` | `IP_DU_VPS_IONOS` | Alias classique pour le site vitrine. |
| **A** | `api` | `IP_DU_VPS_IONOS` | Point d'entrée pour le backend Go (REST & WebSockets). |
| **A** | `admin` | `IP_DU_VPS_IONOS` | Point d'accès pour le dashboard administratif Nuxt. |

### 🔒 Certificats SSL (HTTPS obligatoire)
Pour sécuriser les échanges (surtout pour les applications mobiles et le dashboard d'administration), le trafic doit être chiffré.
1.  Nous utiliserons **Let's Encrypt** (via `certbot` en mode standalone ou webroot) pour générer des certificats SSL gratuits pour `zekdrive.com`, `api.zekdrive.com` et `admin.zekdrive.com`.
2.  Ces certificats doivent être copiés/liés dans le dossier du projet :
    *   `nginx/ssl/fullchain.pem`
    *   `nginx/ssl/privkey.pem`

---

## 🔌 4. Dépendances Externes & APIs Tierces (Clés requises)

Le fonctionnement de l'application dépend de services cloud tiers. Voici la liste des comptes et clés à configurer :

### A. OpenStreetMap & Services Libres (Cartographie & Itinéraires)
ZekDrive utilise OpenStreetMap (OSM) pour l'affichage des cartes et des outils libres pour le traitement géographique, éliminant ainsi les frais récurrents liés à Google Maps :
*   **Affichage des cartes :** Utilisation de tuiles OpenStreetMap gratuites ou d'un serveur de tuiles personnalisé (ex: Mapbox / MapLibre avec style personnalisé).
*   **Calcul d'itinéraires (Routing) :** Utilisation d'un serveur OSRM (Open Source Routing Machine) ou GraphHopper, qui peut être installé directement en conteneur Docker sur le VPS L de 8 Go RAM.
*   **Recherche d'adresses (Géocodage) :** Utilisation de Nominatim (service de géocodage OpenStreetMap) ou Photon pour la saisie semi-automatique des adresses de départ et d'arrivée.

### B. Firebase (Notifications Push)
Les chauffeurs doivent recevoir les demandes de course instantanément, même si l'application est en arrière-plan.
*   **Firebase Cloud Messaging (FCM) :** Un projet Firebase gratuit doit être créé.
*   **Fichier de configuration :** Télécharger le fichier JSON de compte de service Firebase Admin SDK et renseigner son chemin dans la variable `FIREBASE_CREDENTIALS_FILE` dans le fichier `.env`.

### C. Passerelle SMS / OTP (Authentification)
La création de compte sur les applications se fait via la validation d'un numéro de téléphone par SMS (code OTP à usage unique).
*   **Fournisseur requis :** Un compte chez un expéditeur de SMS (Twilio, Brevo, Orange SMS, etc.).
*   **Variables à renseigner :** `SMS_PROVIDER` et `SMS_API_KEY` dans le fichier `.env`.

### D. Passerelle WhatsApp (Notifications alternatives)
Le projet intègre une communication WhatsApp via OpenWA pour notifier les utilisateurs ou chauffeurs.
*   **Instance OpenWA :** Une instance WhatsApp API fonctionnelle.
*   **Variables à renseigner :** `WHATSAPP_URL` et `WHATSAPP_API_KEY` dans le fichier `.env`.

### E. Serveur SMTP (E-mails)
Pour l'envoi d'e-mails système (ex. invitation d'un administrateur au panel, réinitialisation de mot de passe).
*   Un service de relais SMTP comme Brevo, Mailgun, Resend, ou le service e-mail inclus dans votre domaine IONOS.

---

## 📱 5. Comptes Développeurs Stores Mobiles

Pour distribuer les applications à vos clients et chauffeurs :

1.  **Google Play Console (Android) :**
    *   Frais : 25 USD (paiement unique).
    *   Nécessaire pour publier les fichiers APK compilés (`zekdrive-user.apk` et `zekdrive-chauffeur.apk`).
2.  **Apple Developer Program (iOS) - Optionnel mais recommandé :**
    *   Frais : 99 USD / an.
    *   Nécessaire si vous souhaitez publier une version iOS sur l'App Store.
3.  **Clés de signature (Keystores) :**
    *   Les clés de production `zekdrive-pro.jks` et `zekdrive-user.jks` doivent être conservées en lieu sûr pour signer les mises à jour des applications mobiles.
