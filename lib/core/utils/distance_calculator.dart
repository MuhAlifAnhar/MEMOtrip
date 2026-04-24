import 'dart:math';

/// MEMOtrip — Distance & Geo Utilities
class DistanceCalculator {
  DistanceCalculator._();

  static const double _earthRadiusKm = 6371.0;

  /// Calculate distance between two GPS coordinates using Haversine formula.
  /// Returns distance in kilometers.
  static double haversine(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return _earthRadiusKm * c;
  }

  /// Format distance as user-friendly string.
  /// Under 1km: "850 m", over 1km: "2.3 km"
  static String formatDistance(double km) {
    if (km < 1.0) {
      return '${(km * 1000).round()} m';
    }
    return '${km.toStringAsFixed(1)} km';
  }

  /// Estimate travel time by car (avg 30 km/h in city).
  static String estimateDriveTime(double km) {
    final minutes = (km / 30 * 60).round();
    if (minutes < 60) return '$minutes menit';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '$h jam ${m > 0 ? '$m menit' : ''}';
  }

  /// Estimate walking time (avg 5 km/h).
  static String estimateWalkTime(double km) {
    final minutes = (km / 5 * 60).round();
    if (minutes < 60) return '$minutes menit jalan kaki';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '$h jam ${m > 0 ? '$m menit' : ''} jalan kaki';
  }

  static double _toRadians(double degrees) => degrees * pi / 180;
}
