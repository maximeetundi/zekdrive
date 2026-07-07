import 'package:ride_sharing_user_app/features/map/widgets/google_map_replacement.dart';

abstract class LocationServiceInterface {
  Future<dynamic> getZone(String lat, String lng);
  Future<bool?> saveUserZoneId(String zoneId);
  Future<dynamic> getAddressFromGeocode(LatLng? latLng);
  Future<dynamic> searchLocation(String text);
  Future<dynamic> getPlaceDetails(String placeID);
  Future<dynamic> storeLastLocationApi(String lat, String lng, String zoneID);
}