import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ride_sharing_user_app/features/settings/domain/models/country_model.dart';
import 'package:ride_sharing_user_app/features/settings/domain/repositories/country_repository.dart';

class CountryController extends GetxController implements GetxService {
  final CountryRepository countryRepository;
  final SharedPreferences sharedPreferences;

  CountryController({
    required this.countryRepository,
    required this.sharedPreferences,
  });

  static const String _selectedCountryKey = 'selected_country';

  List<CountryModel> _countries = [];
  List<CountryModel> get countries => _countries;

  CountryModel? _selectedCountry;
  CountryModel? get selectedCountry => _selectedCountry;

  CountryConfigModel? _countryConfig;
  CountryConfigModel? get countryConfig => _countryConfig;

  bool isLoading = false;

  // ─── Accesseurs devise ───────────────────────────────────────────
  String get currencySymbol => _selectedCountry?.currencySymbol ?? 'FCFA';
  String get currencyCode => _selectedCountry?.currencyCode ?? 'XOF';

  // ─── Formatage montant ───────────────────────────────────────────
  String formatAmount(double value) {
    // Formater avec séparateurs de milliers
    String formatted = value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted $currencySymbol';
  }

  // ─── Chargement initial ──────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadSavedCountry();
    fetchCountries();
  }

  void _loadSavedCountry() {
    final saved = sharedPreferences.getString(_selectedCountryKey);
    if (saved != null) {
      try {
        _selectedCountry = CountryModel.fromJson(jsonDecode(saved));
        update();
      } catch (_) {}
    }
  }

  Future<void> fetchCountries() async {
    isLoading = true;
    update();
    _countries = await countryRepository.getActiveCountries();
    // Si pas encore de pays sélectionné, prendre le premier de la liste
    if (_selectedCountry == null && _countries.isNotEmpty) {
      await selectCountry(_countries.first);
    }
    isLoading = false;
    update();
  }

  Future<void> selectCountry(CountryModel country) async {
    _selectedCountry = country;
    await sharedPreferences.setString(
      _selectedCountryKey,
      jsonEncode(country.toJson()),
    );
    // Charger la config tarifaire du pays
    _countryConfig = await countryRepository.getCountryConfig(country.code);
    update();
  }

  /// Nom affiché selon la locale courante
  String countryDisplayName(CountryModel country) {
    final locale = Get.locale?.languageCode ?? 'fr';
    return locale == 'fr' ? country.nameFr : country.nameEn;
  }
}
