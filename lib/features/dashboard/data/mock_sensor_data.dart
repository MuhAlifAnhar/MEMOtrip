import '../domain/entities/sensor_reading.dart';

/// Mock sensor/camera/device data for development — Cafe Dobar Coffee.
class MockSensorData {
  MockSensorData._();

  static List<SensorReading> get sensorReadings => [
    SensorReading(locationId: 'dobar', locationName: 'Cafe Dobar Coffee', suhu: 28.5, kelembapan: 75, tekanan: 1013.2, timestamp: DateTime.now().subtract(const Duration(minutes: 2)), isOnline: true),
  ];

  static List<CameraSnapshot> get cameraSnapshots => [
    CameraSnapshot(locationId: 'dobar', locationName: 'Cafe Dobar Coffee', imageUrl: '', crowdLevel: 'Sedang', timestamp: DateTime.now().subtract(const Duration(minutes: 3))),
  ];

  static List<DeviceStatus> get deviceStatuses => [
    DeviceStatus(locationId: 'dobar', locationName: 'Cafe Dobar Coffee', isOnline: true, lastHeartbeat: DateTime.now().subtract(const Duration(seconds: 30))),
  ];

  static SensorReading? getSensorByLocation(String id) {
    try { return sensorReadings.firstWhere((s) => s.locationId == id); } catch (_) { return null; }
  }

  static CameraSnapshot? getSnapshotByLocation(String id) {
    try { return cameraSnapshots.firstWhere((s) => s.locationId == id); } catch (_) { return null; }
  }
}
