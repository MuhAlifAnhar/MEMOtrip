import '../domain/entities/sensor_reading.dart';

/// Mock sensor/camera/device data for development — 3 locations.
class MockSensorData {
  MockSensorData._();

  static List<SensorReading> get sensorReadings => [
    SensorReading(locationId: 'losari', locationName: 'Pantai Losari', suhu: 28.5, kelembapan: 75, tekanan: 1013.2, timestamp: DateTime.now().subtract(const Duration(minutes: 2)), isOnline: true),
    SensorReading(locationId: 'cpi', locationName: 'CPI Makassar', suhu: 27.8, kelembapan: 80, tekanan: 1012.8, timestamp: DateTime.now().subtract(const Duration(minutes: 5)), isOnline: true),
    SensorReading(locationId: 'kubah99', locationName: 'Masjid 99 Kubah', suhu: 30.1, kelembapan: 65, tekanan: 1014.0, timestamp: DateTime.now().subtract(const Duration(minutes: 1)), isOnline: false),
  ];

  static List<CameraSnapshot> get cameraSnapshots => [
    CameraSnapshot(locationId: 'losari', locationName: 'Pantai Losari', imageUrl: '', crowdLevel: 'Sedang', timestamp: DateTime.now().subtract(const Duration(minutes: 3))),
    CameraSnapshot(locationId: 'cpi', locationName: 'CPI Makassar', imageUrl: '', crowdLevel: 'Ramai', timestamp: DateTime.now().subtract(const Duration(minutes: 8))),
    CameraSnapshot(locationId: 'kubah99', locationName: 'Masjid 99 Kubah', imageUrl: '', crowdLevel: 'Sepi', timestamp: DateTime.now().subtract(const Duration(minutes: 15))),
  ];

  static List<DeviceStatus> get deviceStatuses => [
    DeviceStatus(locationId: 'losari', locationName: 'Pantai Losari', isOnline: true, lastHeartbeat: DateTime.now().subtract(const Duration(seconds: 30))),
    DeviceStatus(locationId: 'cpi', locationName: 'CPI Makassar', isOnline: true, lastHeartbeat: DateTime.now().subtract(const Duration(minutes: 1))),
    DeviceStatus(locationId: 'kubah99', locationName: 'Masjid 99 Kubah', isOnline: false, lastHeartbeat: DateTime.now().subtract(const Duration(hours: 2))),
  ];

  static SensorReading? getSensorByLocation(String id) {
    try { return sensorReadings.firstWhere((s) => s.locationId == id); } catch (_) { return null; }
  }

  static CameraSnapshot? getSnapshotByLocation(String id) {
    try { return cameraSnapshots.firstWhere((s) => s.locationId == id); } catch (_) { return null; }
  }
}
