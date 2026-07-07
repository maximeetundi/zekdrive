import 'dart:convert';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/splash/domain/models/config_model.dart';
import 'package:ride_sharing_user_app/data/api_checker.dart';
import 'package:ride_sharing_user_app/features/splash/domain/services/config_service_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigController extends GetxController implements GetxService {
  final ConfigServiceInterface configServiceInterface;
  ConfigController({required this.configServiceInterface});

  ConfigModel? _config;
  ConfigModel? get config => _config;

  bool loading = false;

  // Clés SharedPreferences pour le cache
  static const String _configCacheKey = 'zk_config_cache';
  static const String _configCacheTsKey = 'zk_config_cache_ts';
  static const int _cacheTtlHours = 24; // Rafraîchir toutes les 24h

  /// Charge la config :
  /// 1. Lit d'abord le cache local (SharedPreferences) — zéro appel réseau
  /// 2. Si cache absent ou expiré (>24h) → appelle le serveur une seule fois
  Future<Response> getConfigData({bool reload = false}) async {
    // Essayer le cache local d'abord
    if (!reload) {
      final cached = await _loadFromCache();
      if (cached != null) {
        _config = cached;
        update();
        // Retourne une réponse factice pour compatibilité
        return Response(statusCode: 200, body: {});
      }
    }

    // Cache absent/expiré → appel serveur
    loading = true;
    update();

    Response response = await configServiceInterface.getConfigData();
    if (response.statusCode == 200) {
      loading = false;
      _config = ConfigModel.fromJson(response.body);
      // Sauvegarder en cache local
      await _saveToCache(response.body);
    } else {
      loading = false;
      ApiChecker.checkApi(response);
    }
    update();
    return response;
  }

  /// Charge le cache depuis SharedPreferences
  Future<ConfigModel?> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_configCacheKey);
      final ts = prefs.getInt(_configCacheTsKey) ?? 0;

      if (json == null || json.isEmpty) return null;

      // Vérifier expiration du cache (24h)
      final age = DateTime.now().millisecondsSinceEpoch - ts;
      final maxAge = _cacheTtlHours * 3600 * 1000;
      if (age > maxAge) return null; // Expiré → appel serveur

      return ConfigModel.fromJson(jsonDecode(json));
    } catch (_) {
      return null;
    }
  }

  /// Sauvegarde la config en cache local
  Future<void> _saveToCache(dynamic body) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = body is String ? body : jsonEncode(body);
      await prefs.setString(_configCacheKey, json);
      await prefs.setInt(
        _configCacheTsKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {}
  }

  /// Force un rafraîchissement depuis le serveur (ex: après login)
  Future<Response> refreshConfig() => getConfigData(reload: true);

  /// Efface le cache local (ex: au logout)
  Future<void> clearConfigCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_configCacheKey);
    await prefs.remove(_configCacheTsKey);
    _config = null;
    update();
  }

  Future<bool> initSharedData() {
    return configServiceInterface.initSharedData();
  }

  Future<bool> removeSharedData() {
    return configServiceInterface.removeSharedData();
  }

  bool showIntro() {
    return configServiceInterface.showIntro()!;
  }

  void disableIntro() {
    configServiceInterface.disableIntro();
  }

  String? _pusherConnectionStatus;
  String? get pusherConnectionStatus => _pusherConnectionStatus;

  void setPusherStatus(String? connection) {
    _pusherConnectionStatus = connection;
  }
}