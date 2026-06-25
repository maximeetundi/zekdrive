import 'package:get/get_connect/http/src/response/response.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/features/settings/domain/models/country_model.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';

class CountryRepository {
  final ApiClient apiClient;

  CountryRepository({required this.apiClient});

  /// GET /api/countries → liste des pays actifs
  Future<List<CountryModel>> getActiveCountries() async {
    try {
      Response response = await apiClient.getData(AppConstants.countriesUri);
      if (response.statusCode == 200) {
        final dynamic body = response.body;
        List<dynamic> data;
        if (body is List) {
          data = body;
        } else if (body is Map) {
          data = (body['data'] ?? body['countries'] ?? []) as List<dynamic>;
        } else {
          data = [];
        }
        return data
            .map((json) => CountryModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// GET /api/countries/:code/config → config tarifaire d'un pays
  Future<CountryConfigModel?> getCountryConfig(String code) async {
    try {
      Response response =
          await apiClient.getData('${AppConstants.countryConfigUri}/$code/config');
      if (response.statusCode == 200) {
        final dynamic body = response.body;
        Map<String, dynamic> data;
        if (body is Map) {
          data = (body['data'] ?? body) as Map<String, dynamic>;
        } else {
          return null;
        }
        return CountryConfigModel.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
