import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';

class ApiChecker {
  static void checkApi(Response response) {
    if (response.statusCode == 401) {
      debugPrint('[ApiChecker] 401 received — ignoring auto-logout');
      return;
    }

    String? rawMessage;
    if (response.body != null && response.body is Map) {
      rawMessage = response.body['message'] ?? response.body['error'];
    }
    rawMessage ??= response.statusText;

    final userMessage = _toFriendlyMessage(rawMessage, response.statusCode);
    showCustomSnackBar(userMessage);
  }

  /// Langue courante de l'app
  static bool get _isFrench => Get.locale?.languageCode == 'fr';

  /// Traduit un message d'erreur technique en message lisible selon la langue de l'app
  static String _toFriendlyMessage(String? raw, int? statusCode) {
    if (raw == null || raw.isEmpty) return _messageByCode(statusCode);

    final lower = raw.toLowerCase();

    // Erreurs de validation technique (validator Go)
    if (lower.contains('field validation') || lower.contains('key:') || lower.contains('error:field')) {
      return _parseValidationError(raw);
    }

    // Auth
    if (lower.contains('invalid email') || lower.contains('invalid email/phone') ||
        lower.contains('invalid email or password') || lower.contains('mot de passe ou identifiant')) {
      return _isFrench ? 'Identifiant ou mot de passe incorrect' : 'Incorrect email or password';
    }
    if (lower.contains('already in use') || lower.contains('already exists') || lower.contains('duplicate') ||
        lower.contains('déjà utilisé')) {
      if (lower.contains('phone') || lower.contains('téléphone')) {
        return _isFrench ? 'Ce numéro de téléphone est déjà utilisé' : 'This phone number is already in use';
      }
      if (lower.contains('email')) {
        return _isFrench ? 'Cette adresse email est déjà utilisée' : 'This email address is already in use';
      }
      return _isFrench ? 'Ce compte existe déjà' : 'This account already exists';
    }

    // Not found
    if (lower.contains('no active trip')) return _isFrench ? 'Aucune course en cours' : 'No active trip';
    if (lower.contains('trip not found') || lower.contains('course introuvable')) {
      return _isFrench ? 'Course introuvable' : 'Trip not found';
    }
    if (lower.contains('store not found') || lower.contains('boutique introuvable')) {
      return _isFrench ? 'Boutique introuvable' : 'Store not found';
    }
    if (lower.contains('not found') || lower.contains('no rows') || lower.contains('introuvable')) {
      return _isFrench ? 'Élément introuvable' : 'Item not found';
    }

    // Auth/Session
    if (lower.contains('session expir') || lower.contains('invalid or expired') ||
        lower.contains('missing authorization') || lower.contains('missing token')) {
      return _isFrench ? 'Session expirée, veuillez vous reconnecter' : 'Session expired, please sign in again';
    }
    if (lower.contains('unauthorized') || lower.contains('forbidden') || lower.contains('access forbidden')) {
      return _isFrench ? 'Accès non autorisé' : 'Access denied';
    }

    // Rate limit / network
    if (lower.contains('too many requests')) {
      return _isFrench ? 'Trop de tentatives, veuillez patienter' : 'Too many requests, please wait';
    }
    if (lower.contains('cannot parse') || lower.contains('unmarshal') || lower.contains('invalid json')) {
      return _isFrench ? 'Erreur de format, veuillez réessayer' : 'Format error, please try again';
    }
    if (lower.contains('connection') || lower.contains('timeout') || lower.contains('unavailable')) {
      return _isFrench ? 'Service indisponible, réessayez' : 'Service unavailable, please try again';
    }

    // Wallet
    if (lower.contains('wallet locked') || lower.contains('portefeuille verrouillé')) {
      return _isFrench
          ? 'Votre portefeuille est verrouillé. Rechargez votre solde pour continuer'
          : 'Your wallet is locked. Recharge your balance to continue';
    }
    if (lower.contains('insufficient balance') || lower.contains('solde insuffisant')) {
      return _isFrench ? 'Solde insuffisant' : 'Insufficient balance';
    }

    // Specific
    if (lower.contains('store is closed')) {
      return _isFrench ? 'Cette boutique est fermée aujourd\'hui' : 'This store is closed today';
    }
    if (lower.contains('phone number is required')) {
      return _isFrench ? 'Le numéro de téléphone est requis' : 'Phone number is required';
    }

    // Si déjà un message court lisible
    if (raw.length < 80 && !raw.contains('Key:') && !raw.contains('Error:')) return raw;

    return _messageByCode(statusCode);
  }

  /// Extrait un message lisible depuis une erreur de validation Go selon la locale
  static String _parseValidationError(String raw) {
    final lower = raw.toLowerCase();
    final fr = _isFrench;

    if (lower.contains('password') && lower.contains('required')) {
      return fr ? 'Le mot de passe est requis' : 'Password is required';
    }
    if (lower.contains('password') && lower.contains('min')) {
      return fr ? 'Le mot de passe doit contenir au moins 6 caractères' : 'Password must be at least 6 characters';
    }
    if (lower.contains('email') && lower.contains('required')) {
      return fr ? 'L\'adresse email est requise' : 'Email address is required';
    }
    if (lower.contains('email')) {
      return fr ? 'L\'adresse email n\'est pas valide' : 'Invalid email address';
    }
    if (lower.contains('phone') && lower.contains('required')) {
      return fr ? 'Le numéro de téléphone est requis' : 'Phone number is required';
    }
    if (lower.contains('phone') && lower.contains('min')) {
      return fr ? 'Numéro de téléphone trop court' : 'Phone number too short';
    }
    if (lower.contains('name') && lower.contains('required')) {
      return fr ? 'Le nom est requis' : 'Name is required';
    }
    if (lower.contains('name') && lower.contains('min')) {
      return fr ? 'Le nom doit contenir au moins 2 caractères' : 'Name must be at least 2 characters';
    }
    if (lower.contains('pickup') && (lower.contains('lat') || lower.contains('lng'))) {
      return fr ? 'Position de départ invalide' : 'Invalid pickup location';
    }
    if (lower.contains('dropoff') && (lower.contains('lat') || lower.contains('lng'))) {
      return fr ? 'Destination invalide' : 'Invalid destination';
    }
    if (lower.contains('pickup_address') || lower.contains('pickupaddress')) {
      return fr ? 'L\'adresse de départ est requise' : 'Pickup address is required';
    }
    if (lower.contains('dropoff_address') || lower.contains('dropoffaddress')) {
      return fr ? 'L\'adresse de destination est requise' : 'Destination address is required';
    }
    if (lower.contains('vehicletype') || lower.contains('vehicle_type')) {
      return fr ? 'Type de véhicule non reconnu' : 'Invalid vehicle type';
    }
    if (lower.contains('recipientname') || lower.contains('recipient_name')) {
      return fr ? 'Le nom du destinataire est requis' : 'Recipient name is required';
    }
    if (lower.contains('recipientphone') || lower.contains('recipient_phone')) {
      return fr ? 'Le téléphone du destinataire est requis' : 'Recipient phone is required';
    }
    if (lower.contains('packagedetails') || lower.contains('package_details')) {
      return fr ? 'La description du colis est requise' : 'Package description is required';
    }
    if (lower.contains('amount') && lower.contains('required')) {
      return fr ? 'Le montant est requis' : 'Amount is required';
    }
    if (lower.contains('amount') && (lower.contains('min') || lower.contains('gt'))) {
      return fr ? 'Le montant doit être supérieur à 0' : 'Amount must be greater than 0';
    }

    return fr ? 'Veuillez vérifier les informations saisies' : 'Please check the information entered';
  }

  /// Message générique selon le code HTTP et la langue
  static String _messageByCode(int? code) {
    final fr = _isFrench;
    switch (code) {
      case 400: return fr ? 'Veuillez vérifier les informations saisies' : 'Please check the information entered';
      case 401: return fr ? 'Session expirée, veuillez vous reconnecter' : 'Session expired, please sign in again';
      case 403: return fr ? 'Accès non autorisé' : 'Access denied';
      case 404: return fr ? 'Élément introuvable' : 'Item not found';
      case 409: return fr ? 'Ce compte existe déjà' : 'This account already exists';
      case 422: return fr ? 'Données invalides' : 'Invalid data';
      case 429: return fr ? 'Trop de tentatives, patientez quelques instants' : 'Too many attempts, please wait';
      case 500:
      case 502:
      case 503: return fr ? 'Service temporairement indisponible, réessayez' : 'Service temporarily unavailable';
      default:  return fr ? 'Une erreur est survenue, veuillez réessayer' : 'An error occurred, please try again';
    }
  }
}
