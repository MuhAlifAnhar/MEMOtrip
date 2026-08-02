import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/bmkg_weather_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/mock_iot_service.dart';
import 'dashboard_state.dart';
export 'dashboard_state.dart';

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(const DashboardState()) {
    // Generate initial IoT data synchronously so it's ready.
    refreshIoTData();
  }

  Future<void> refreshIoTData() async {
    state = state.copyWith(isRefreshingIoT: true);

    final stopwatch = Stopwatch()..start();
    // Simulate network latency as requested
    await Future.delayed(const Duration(seconds: 2));
    stopwatch.stop();

    state = state.copyWith(
      sensorReadings: MockIoTService.generateSensorReadings(),
      cameraSnapshots: MockIoTService.generateCameraSnapshots(),
      deviceStatuses: MockIoTService.generateDeviceStatuses(),
      simulatedLatencyMs: stopwatch.elapsedMicroseconds / 1000.0,
      isRefreshingIoT: false,
    );
  }

  Future<void> initWeather() async {
    state = state.copyWith(
      isLoadingWeather: true,
      clearWeatherError: true,
    );

    try {
      final position = await LocationService.getCurrentPosition();
      final isReal = position.isReal;

      final result = await BmkgWeatherService.fetchWeather(
        position.lat,
        position.lng,
      );

      state = state.copyWith(
        currentWeather: result.current,
        hourlyForecasts: result.hourly,
        isLoadingWeather: false,
        isUsingRealLocation: isReal,
        weatherError: result.current == null ? 'Data cuaca tidak tersedia' : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingWeather: false,
        weatherError: 'Gagal memuat data cuaca',
      );
    }
  }

  void selectLocation(String? locationId) {
    if (locationId != null) {
      // Switching to Condition B (IoT Mode)
      refreshIoTData();
      state = state.copyWith(selectedLocationId: locationId);
    } else {
      // Switching back to Condition A (Cuaca Lokal)
      state = state.copyWith(clearLocationId: true);
    }
  }
}
