import 'package:geolocator/geolocator.dart';

/// Location Service — Real GPS using Geolocator package.
///
/// Requests location permission on first use and returns
/// the user's real-time coordinates.
class LocationService {
  LocationService._();

  /// Fallback defaults (Makassar city center)
  static const double defaultLat = -5.1350;
  static const double defaultLng = 119.4124;
  static const String defaultCity = 'Makassar';
  static const String defaultProvince = 'Sulawesi Selatan';

  /// Cached position so we don't re-request every rebuild.
  static Position? _cachedPosition;

  /// Whether we already attempted to get location.
  static bool _hasAttempted = false;

  /// Whether real GPS succeeded (for UI to know).
  static bool get isUsingRealLocation => _cachedPosition != null;

  /// Current latitude — real or fallback.
  static double get currentLat => _cachedPosition?.latitude ?? defaultLat;

  /// Current longitude — real or fallback.
  static double get currentLng => _cachedPosition?.longitude ?? defaultLng;

  /// Determine current position with proper permission handling.
  ///
  /// This will:
  /// 1. Check if location services are enabled
  /// 2. Request permission if not yet granted
  /// 3. Get the current GPS position
  /// 4. Fall back to defaults on any failure
  static Future<({double lat, double lng, bool isReal})> getCurrentPosition() async {
    // Return cached if available
    if (_cachedPosition != null) {
      return (
        lat: _cachedPosition!.latitude,
        lng: _cachedPosition!.longitude,
        isReal: true,
      );
    }

    // Only attempt once per app session to avoid repeated dialogs
    if (_hasAttempted) {
      return (lat: defaultLat, lng: defaultLng, isReal: false);
    }
    _hasAttempted = true;

    try {
      // Step 1: Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return (lat: defaultLat, lng: defaultLng, isReal: false);
      }

      // Step 2: Check and request permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return (lat: defaultLat, lng: defaultLng, isReal: false);
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return (lat: defaultLat, lng: defaultLng, isReal: false);
      }

      // Step 3: Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      _cachedPosition = position;
      return (lat: position.latitude, lng: position.longitude, isReal: true);
    } catch (_) {
      return (lat: defaultLat, lng: defaultLng, isReal: false);
    }
  }

  /// Check location permission status without getting position.
  /// Returns a clear status for the UI to act on.
  static Future<LocationStatus> ensurePermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return LocationStatus.serviceDisabled;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationStatus.denied;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return LocationStatus.deniedForever;
      }
      return LocationStatus.granted;
    } catch (_) {
      return LocationStatus.serviceDisabled;
    }
  }

  /// Open system location settings (for deniedForever case).
  static Future<bool> openSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings (for deniedForever permission case).
  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Get address from coordinates.
  static Future<String> getAddressFromCoordinates(double lat, double lng) async {
    // TODO: Replace with Geocoding package
    return 'Jl. Penghibur, Makassar, Sulawesi Selatan';
  }
}

/// Status of location permission check.
enum LocationStatus { granted, denied, deniedForever, serviceDisabled }
