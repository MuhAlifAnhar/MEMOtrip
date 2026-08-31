/// Sensor reading entity — DHT22 data from Firebase Realtime DB.
class SensorReading {
  final String locationId;
  final String locationName;
  final double suhu;
  final double kelembapan;
  final double tekanan;
  final DateTime timestamp;
  final bool isOnline;

  const SensorReading({
    required this.locationId,
    required this.locationName,
    required this.suhu,
    required this.kelembapan,
    required this.tekanan,
    required this.timestamp,
    this.isOnline = true,
  });

  SensorReading copyWith({
    String? locationId, String? locationName,
    double? suhu, double? kelembapan, double? tekanan,
    DateTime? timestamp, bool? isOnline,
  }) {
    return SensorReading(
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      suhu: suhu ?? this.suhu,
      kelembapan: kelembapan ?? this.kelembapan,
      tekanan: tekanan ?? this.tekanan,
      timestamp: timestamp ?? this.timestamp,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

/// ESP32-CAM snapshot data.
class CameraSnapshot {
  final String locationId;
  final String locationName;
  final String imageUrl;
  final String crowdLevel;
  final DateTime timestamp;

  const CameraSnapshot({
    required this.locationId,
    required this.locationName,
    required this.imageUrl,
    required this.crowdLevel,
    required this.timestamp,
  });
}

/// Device connectivity status.
class DeviceStatus {
  final String locationId;
  final String locationName;
  final bool isOnline;
  final DateTime lastHeartbeat;
  final bool dangerMode;

  const DeviceStatus({
    required this.locationId,
    required this.locationName,
    required this.isOnline,
    required this.lastHeartbeat,
    this.dangerMode = false,
  });
}
