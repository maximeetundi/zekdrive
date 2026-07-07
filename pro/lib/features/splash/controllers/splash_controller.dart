import 'dart:convert';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/splash/domain/models/config_model.dart';
import 'package:ride_sharing_user_app/data/api_checker.dart';
import 'package:ride_sharing_user_app/features/splash/domain/services/splash_service_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashController extends GetxController implements GetxService {
  final SplashServiceInterface splashServiceInterface;
  SplashController({required this.splashServiceInterface});

  ConfigModel? _config;
  ConfigModel? get config => _config;

  bool loading = false;

  // Cache persistant — clés SharedPreferences
  static const String _configCacheKey = 'zk_pro_config_cache';
  static const String _configCacheTsKey = 'zk_pro_config_cache_ts';
  static const int _cacheTtlHours = 24; // Rafraîchir toutes les 24h

  /// Charge la config du driver Pro :
  /// 1. Lit le cache SharedPreferences (zéro réseau si cache valide < 24h)
  /// 2. Si cache absent/expiré → appelle /api/driver/configuration une seule fois
  Future<bool> getConfigData({bool reload = false}) async {
    // Essayer le cache local d'abord
    if (!reload) {
      final cached = await _loadFromCache();
      if (cached != null) {
        _config = cached;
        update();
        return true;
      }
    }

    // Cache absent/expiré → appel serveur
    loading = true;
    update();

    Response response = await splashServiceInterface.getConfigData();
    bool isSuccess = false;
    if (response.statusCode == 200) {
      isSuccess = true;
      loading = false;
      _config = ConfigModel.fromJson(response.body);
      // Sauvegarder en cache local
      await _saveToCache(response.body);
    } else {
      loading = false;
      ApiChecker.checkApi(response);
    }
    update();
    return isSuccess;
  }

  /// Charge le cache depuis SharedPreferences
  Future<ConfigModel?> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_configCacheKey);
      final ts = prefs.getInt(_configCacheTsKey) ?? 0;

      if (json == null || json.isEmpty) return null;

      // Vérifier expiration (24h)
      final age = DateTime.now().millisecondsSinceEpoch - ts;
      final maxAge = _cacheTtlHours * 3600 * 1000;
      if (age > maxAge) return null;

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

  /// Force un rafraîchissement (ex: après mise à jour du pays utilisateur)
  Future<bool> refreshConfig() => getConfigData(reload: true);

  /// Efface le cache (ex: au logout)
  Future<void> clearConfigCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_configCacheKey);
    await prefs.remove(_configCacheTsKey);
    _config = null;
    update();
  }

  Future<bool> initSharedData() {
    return splashServiceInterface.initSharedData();
  }

  Future<bool> removeSharedData() {
    return splashServiceInterface.removeSharedData();
  }

  final Uri params = Uri(
    scheme: 'mailto',
    path: '',
    query: 'subject=support Feedback&body=',
  );

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  Future<void> sendMailOrCall(String url, bool isMail) async {
    if (!await launchUrl(Uri.parse(isMail ? params.toString() : url))) {
      throw 'Could not launch $url';
    }
  }

  String? _pusherConnectionStatus;
  String? get pusherConnectionStatus => _pusherConnectionStatus;

  void setPusherStatus(String? connection) {
    _pusherConnectionStatus = connection;
  }
}