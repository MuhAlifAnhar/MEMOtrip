/// Location Service — GPS & Geocoding placeholder.
///
/// Will use geolocator + geocoding packages when added to pubspec.
class LocationService {
  LocationService._();

  /// Mock current user position (Makassar city center)
  static const double defaultLat = -5.1350;
  static const double defaultLng = 119.4124;
  static const String defaultCity = 'Makassar';
  static const String defaultProvince = 'Sulawesi Selatan';

  /// Get current user position.
  /// Returns mock data for now.
  static Future<({double lat, double lng})> getCurrentPosition() async {
    // TODO: Replace with Geolocator when package is added
    return (lat: defaultLat, lng: defaultLng);
  }

  /// Get address from coordinates.
  static Future<String> getAddressFromCoordinates(double lat, double lng) async {
    // TODO: Replace with Geocoding package
    return 'Jl. Penghibur, Makassar, Sulawesi Selatan';
  }
}
