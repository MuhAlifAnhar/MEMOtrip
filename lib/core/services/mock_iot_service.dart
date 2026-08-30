import 'dart:math';
import '../../features/dashboard/domain/entities/sensor_reading.dart';
import 'raspberry_pi_service.dart';

/// MockIoTService — Dynamic IoT Simulation Engine
///
/// Generates randomised BME280 sensor readings and ESP32-CAM camera
/// snapshots for 3 target locations in Makassar:
///   1. Pantai Losari
///   2. CPI Makassar
///   3. Masjid 99 Kubah
///
/// BME280 ranges (per PRD):
///   - Suhu       : 28 °C – 36 °C
///   - Kelembapan : 60 % – 90 %
///   - Tekanan    : 1008 hPa – 1012 hPa
///
/// EWS Threshold:
///   - Suhu > 35 °C triggers danger mode (red UI).
///
/// Integration Note:
///   Pantai Losari uses REAL data from Raspberry Pi 4 + Webcam when available.
///   CPI Makassar and Masjid 99 Kubah remain mock/simulated.
class MockIoTService {
  MockIoTService._();

  static final _rng = Random();

  // ─── EWS Constants ──────────────────────────────────────
  /// Temperature threshold for the Early Warning System.
  static const double ewsTemperatureThreshold = 35.0;

  // ─── BME280 Ranges ──────────────────────────────────────
  static const double _suhuMin = 28.0;
  static const double _suhuMax = 36.0;
  static const double _kelembapanMin = 60.0;
  static const double _kelembapanMax = 90.0;
  static const double _tekananMin = 1008.0;
  static const double _tekananMax = 1012.0;

  // ─── Location Definitions ───────────────────────────────
  static const _locations = [
    _LocationDef(id: 'losari', name: 'Pantai Losari'),
    _LocationDef(id: 'cpi', name: 'CPI Makassar'),
    _LocationDef(id: 'kubah99', name: 'Masjid 99 Kubah'),
  ];

  // ─── ESP32-CAM Image Banks ──────────────────────────────
  // Curated Unsplash URLs depicting crowd conditions at each site.

  /// Losari — sunset / crowded waterfront scenes.
  static const _losariImages = [
    // Sunset at pier — crowded / lively
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&h=400&fit=crop',
    'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=800&h=400&fit=crop',
    'https://images.unsplash.com/photo-1476673160081-cf065607f449?w=800&h=400&fit=crop',
  ];

  /// CPI — shopping mall / busy area scenes.
  static const _cpiImages = [
    'https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?w=800&h=400&fit=crop',
    'https://images.unsplash.com/photo-1519567241046-7f570eee3ce6?w=800&h=400&fit=crop',
    'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=400&fit=crop',
  ];

  /// Masjid 99 Kubah — quiet / empty mosque courtyard scenes.
  static const _kubah99Images = [
    'https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?w=800&h=400&fit=crop',
    'https://images.unsplash.com/photo-1564769625905-50e93615e769?w=800&h=400&fit=crop',
    'https://images.unsplash.com/photo-1545167496-5a39e453a448?w=800&h=400&fit=crop',
  ];

  // ─── Helpers ────────────────────────────────────────────

  /// Returns a random double in [min, max] with one decimal.
  static double _rand(double min, double max) {
    final raw = min + _rng.nextDouble() * (max - min);
    return (raw * 10).roundToDouble() / 10;
  }

  /// Pick a random image URL for a location.
  static String _randomImage(String locationId) {
    switch (locationId) {
      case 'losari':
        return _losariImages[_rng.nextInt(_losariImages.length)];
      case 'cpi':
        return _cpiImages[_rng.nextInt(_cpiImages.length)];
      case 'kubah99':
        return _kubah99Images[_rng.nextInt(_kubah99Images.length)];
      default:
        return _losariImages.first;
    }
  }

  /// Determine crowd level label randomly with weighted bias:
  ///   Losari  → mostly Ramai (sunset crowd)
  ///   CPI     → mostly Sedang
  ///   Kubah99 → mostly Sepi  (quiet courtyard)
  static String _crowdLevel(String locationId) {
    final roll = _rng.nextInt(100);
    switch (locationId) {
      case 'losari':
        if (roll < 60) return 'Ramai';
        if (roll < 85) return 'Sedang';
        return 'Sepi';
      case 'cpi':
        if (roll < 20) return 'Ramai';
        if (roll < 75) return 'Sedang';
        return 'Sepi';
      case 'kubah99':
        if (roll < 10) return 'Ramai';
        if (roll < 30) return 'Sedang';
        return 'Sepi';
      default:
        return 'Sedang';
    }
  }

  /// Whether a temperature value triggers danger mode.
  static bool isDanger(double suhu) => suhu > ewsTemperatureThreshold;

  // ─── Public API (Synchronous / Mock) ────────────────────

  /// Generate fresh, randomised sensor readings for all 3 locations.
  /// Each call produces new values — simulating a device refresh/poll.
  static List<SensorReading> generateSensorReadings() {
    return _locations.map((loc) {
      final suhu = _rand(_suhuMin, _suhuMax);
      return SensorReading(
        locationId: loc.id,
        locationName: loc.name,
        suhu: suhu,
        kelembapan: _rand(_kelembapanMin, _kelembapanMax),
        tekanan: _rand(_tekananMin, _tekananMax),
        timestamp: DateTime.now().subtract(
          Duration(seconds: _rng.nextInt(120)),
        ),
        isOnline: true, // all 3 locations are online in simulation
      );
    }).toList();
  }

  /// Generate fresh camera snapshots for all 3 locations.
  static List<CameraSnapshot> generateCameraSnapshots() {
    return _locations.map((loc) {
      return CameraSnapshot(
        locationId: loc.id,
        locationName: loc.name,
        imageUrl: _randomImage(loc.id),
        crowdLevel: _crowdLevel(loc.id),
        timestamp: DateTime.now().subtract(
          Duration(seconds: _rng.nextInt(300)),
        ),
      );
    }).toList();
  }

  /// Generate device statuses for all 3 locations.
  static List<DeviceStatus> generateDeviceStatuses() {
    return _locations.map((loc) {
      return DeviceStatus(
        locationId: loc.id,
        locationName: loc.name,
        isOnline: true,
        lastHeartbeat: DateTime.now().subtract(
          Duration(seconds: _rng.nextInt(60)),
        ),
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
  //  Async API — Integrates Real Raspberry Pi Data for Losari
  // ═══════════════════════════════════════════════════════════

  /// Result container from async IoT data fetch.
  /// Contains data lists + metadata about whether real data was obtained.
  static Future<IoTDataResult> fetchIntegratedData() async {
    // 1. Generate mock data for all 3 locations first (baseline).
    final mockSensors = generateSensorReadings();
    final mockSnapshots = generateCameraSnapshots();
    final mockDevices = generateDeviceStatuses();

    // 2. Attempt to fetch real data from Raspberry Pi for Losari.
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

    // 3. If we got real data, override Losari's crowd level in snapshots.
    final finalSnapshots = mockSnapshots.map((snap) {
      if (snap.locationId == 'losari' && realData != null) {
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

    // 4. Mark Losari device as real in device statuses.
    final finalDevices = mockDevices.map((d) {
      if (d.locationId == 'losari') {
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
      sensorReadings: mockSensors,
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

