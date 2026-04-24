/// Weather entity — From BMKG API for Condition A dashboard.
class Weather {
  final String condition;
  final double temperature;
  final double humidity;
  final double windSpeed;
  final String iconCode;
  final String locationName;
  final DateTime timestamp;

  const Weather({
    required this.condition,
    required this.temperature,
    required this.humidity,
    this.windSpeed = 0.0,
    this.iconCode = 'sunny',
    required this.locationName,
    required this.timestamp,
  });

  String get conditionIcon {
    switch (condition.toLowerCase()) {
      case 'cerah': return 'wb_sunny';
      case 'berawan': case 'berawan tebal': return 'cloud';
      case 'hujan ringan': case 'hujan': return 'grain';
      case 'hujan lebat': return 'thunderstorm';
      default: return 'wb_sunny';
    }
  }
}

/// Traffic info entity.
class TrafficInfo {
  final String status;
  final String description;
  final int estimatedMinutes;
  final DateTime lastUpdate;

  const TrafficInfo({
    required this.status,
    required this.description,
    this.estimatedMinutes = 0,
    required this.lastUpdate,
  });

  bool get isSmooth => status == 'Lancar';
}
