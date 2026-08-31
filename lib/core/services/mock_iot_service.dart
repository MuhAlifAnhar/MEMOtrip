import 'dart:math';
import '../../features/dashboard/domain/entities/sensor_reading.dart';
import 'raspberry_pi_service.dart';

/// MockIoTService — IoT Data Engine
///
/// Provides sensor readings and camera snapshots for the IoT monitoring
/// location: Cafe Dobar Coffee (BTN. Tabaria, Makassar).
///
/// DHT22 ranges (fallback when sensor offline):
///   - Suhu       : 28 °C – 36 °C
///   - Kelembapan : 60 % – 90 %
///
/// EWS Threshold:
///   - Suhu > 35 °C triggers danger mode (red UI).
///
/// Integration:
///   Cafe Dobar Coffee uses REAL data from Raspberry Pi 4 + Webcam + DHT22.
class MockIoTService {
  MockIoTService._();

  static final _rng = Random();

  // ─── EWS Constants ──────────────────────────────────────
  /// Temperature threshold for the Early Warning System.
  static const double ewsTemperatureThreshold = 35.0;

  // ─── DHT22 Ranges (fallback when sensor offline) ────────
  static const double _suhuMin = 28.0;
  static const double _suhuMax = 36.0;
  static const double _kelembapanMin = 60.0;
  static const double _kelembapanMax = 90.0;
  static const double _tekananMin = 1008.0;
  static const double _tekananMax = 1012.0;

  // ─── Location Definition ────────────────────────────────
  static const _locations = [
    _LocationDef(id: 'dobar', name: 'Cafe Dobar Coffee'),
  ];

  // ─── Camera Image Bank ──────────────────────────────────
  /// Cafe Dobar Coffee — cafe / indoor scenes.
  static const _dobarImages = [
    'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=800&h=400&fit=crop',
    'https://images.unsplash.com/photo-1559925393-8be0ec4767c8?w=800&h=400&fit=crop',
    'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=800&h=400&fit=crop',
  ];

  // ─── Helpers ────────────────────────────────────────────

  /// Returns a random double in [min, max] with one decimal.
  static double _rand(double min, double max) {
    final raw = min + _rng.nextDouble() * (max - min);
    return (raw * 10).roundToDouble() / 10;
  }

  /// Pick a random image URL.
  static String _randomImage(String locationId) {
    return _dobarImages[_rng.nextInt(_dobarImages.length)];
  }

  /// Determine crowd level label randomly.
  static String _crowdLevel(String locationId) {
    final roll = _rng.nextInt(100);
    if (roll < 40) return 'Ramai';
    if (roll < 75) return 'Sedang';
    return 'Sepi';
  }

  /// Whether a temperature value triggers danger mode.
  static bool isDanger(double suhu) => suhu > ewsTemperatureThreshold;

  // ─── Public API (Synchronous) ───────────────────────────

  /// Generate sensor readings for Cafe Dobar Coffee.
  /// Uses real DHT22 data when available, falls back to random simulation.
  static List<SensorReading> generateSensorReadings() {
    return _locations.map((loc) {
      final realResult = RaspberryPiService.lastResult;
      
      final suhu = (realResult != null && realResult.suhu != null)
          ? realResult.suhu!
          : _rand(_suhuMin, _suhuMax);
          
      final kelembapan = (realResult != null && realResult.kelembapan != null)
          ? realResult.kelembapan!
          : _rand(_kelembapanMin, _kelembapanMax);

      return SensorReading(
        locationId: loc.id,
        locationName: loc.name,
        suhu: suhu,
        kelembapan: kelembapan,
        tekanan: _rand(_tekananMin, _tekananMax),
        timestamp: DateTime.now().subtract(
          Duration(seconds: _rng.nextInt(120)),
        ),
        isOnline: true,
      );
    }).toList();
  }

  /// Generate camera snapshot for Cafe Dobar Coffee.
  static List<CameraSnapshot> generateCameraSnapshots() {
    return _locations.map((loc) {
      final realResult = RaspberryPiService.lastResult;
      
      final crowdLevel = (realResult != null)
          ? realResult.crowdLevel
          : _crowdLevel(loc.id);

      return CameraSnapshot(
        locationId: loc.id,
        locationName: loc.name,
        imageUrl: _randomImage(loc.id),
        crowdLevel: crowdLevel,
        timestamp: (realResult != null)
            ? realResult.timestamp
            : DateTime.now().subtract(Duration(seconds: _rng.nextInt(300))),
      );
    }).toList();
  }

  /// Generate device status for Cafe Dobar Coffee.
  static List<DeviceStatus> generateDeviceStatuses() {
    return _locations.map((loc) {
      final realResult = RaspberryPiService.lastResult;
      
      final isOnline = (realResult != null) ? realResult.isOnline : true;

      return DeviceStatus(
        locationId: loc.id,
        locationName: loc.name,
        isOnline: isOnline,
        lastHeartbeat: (realResult != null)
            ? realResult.timestamp
            : DateTime.now().subtract(Duration(seconds: _rng.nextInt(60))),
      );
    }).toList();
  }

  /// Get a single sensor reading by location ID.
  static SensorReading? getSensorByLocation(
      String id, List<SensorReading> readings) {
    try {
      return readings.firstWhere((s) => s.locationId == id);
    } catch (_) {
      return readings.isNotEmpty ? readings.first : null;
    }
  }

  /// Get a single camera snapshot by location ID.
  static CameraSnapshot? getSnapshotByLocation(
      String id, List<CameraSnapshot> snapshots) {
    try {
      return snapshots.firstWhere((s) => s.locationId == id);
    } catch (_) {
      return snapshots.isNotEmpty ? snapshots.first : null;
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  Async API — Integrates Real Raspberry Pi Data for Dobar
  // ═══════════════════════════════════════════════════════════

  /// Result container from async IoT data fetch.
  /// Contains data lists + metadata about whether real data was obtained.
  static Future<IoTDataResult> fetchIntegratedData() async {
    // 1. Generate baseline data.
    final mockSensors = generateSensorReadings();
    final mockSnapshots = generateCameraSnapshots();
    final mockDevices = generateDeviceStatuses();

    // 2. Attempt to fetch real data from Raspberry Pi.
    CrowdDetectionResult? realData;
    String? iotError;
    try {
      realData = await RaspberryPiService.fetchAndSync();
    } catch (e) {
      iotError = 'Gagal terhubung ke perangkat IoT: $e';
    }

    if (realData == null && iotError == null) {
      iotError = 'Perangkat IoT tidak merespon — menggunakan data simulasi.';
    }

    // 3. If we got real data, override crowd level in snapshots.
    final finalSnapshots = mockSnapshots.map((snap) {
      if (snap.locationId == 'dobar' && realData != null) {
        return CameraSnapshot(
          locationId: snap.locationId,
          locationName: snap.locationName,
          imageUrl: snap.imageUrl,
          crowdLevel: realData.crowdLevel,
          timestamp: realData.timestamp,
        );
      }
      return snap;
    }).toList();

    // Override sensor reading (temperature/humidity) from DHT22
    final finalSensors = mockSensors.map((sensor) {
      if (sensor.locationId == 'dobar' && realData != null) {
        return SensorReading(
          locationId: sensor.locationId,
          locationName: sensor.locationName,
          suhu: realData.suhu ?? sensor.suhu,
          kelembapan: realData.kelembapan ?? sensor.kelembapan,
          tekanan: sensor.tekanan,
          timestamp: realData.timestamp,
          isOnline: sensor.isOnline,
        );
      }
      return sensor;
    }).toList();

    // 4. Mark device as real in device statuses.
    final finalDevices = mockDevices.map((d) {
      if (d.locationId == 'dobar') {
        return DeviceStatus(
          locationId: d.locationId,
          locationName: d.locationName,
          isOnline: realData != null,
          lastHeartbeat: realData?.timestamp ?? d.lastHeartbeat,
        );
      }
      return d;
    }).toList();

    return IoTDataResult(
      sensorReadings: finalSensors,
      cameraSnapshots: finalSnapshots,
      deviceStatuses: finalDevices,
      detectedFaces: realData?.totalFaces,
      isUsingRealIoT: realData != null,
      iotError: iotError,
    );
  }
}

/// Aggregated result from [MockIoTService.fetchIntegratedData].
class IoTDataResult {
  final List<SensorReading> sensorReadings;
  final List<CameraSnapshot> cameraSnapshots;
  final List<DeviceStatus> deviceStatuses;
  final int? detectedFaces;
  final bool isUsingRealIoT;
  final String? iotError;

  const IoTDataResult({
    required this.sensorReadings,
    required this.cameraSnapshots,
    required this.deviceStatuses,
    this.detectedFaces,
    this.isUsingRealIoT = false,
    this.iotError,
  });
}

/// Internal location definition helper.
class _LocationDef {
  final String id;
  final String name;
  const _LocationDef({required this.id, required this.name});
}
