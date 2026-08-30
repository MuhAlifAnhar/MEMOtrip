import 'dart:async';
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

  Timer? _iotTimer;

  @override
  void dispose() {
    _iotTimer?.cancel();
    super.dispose();
  }

  Future<void> refreshIoTData() async {
    state = state.copyWith(isRefreshingIoT: true, clearIoTError: true);

    final stopwatch = Stopwatch()..start();
    
    // Fetch integrated data (calls Raspberry Pi API for Pantai Losari)
    final result = await MockIoTService.fetchIntegratedData();
    
    stopwatch.stop();

    state = state.copyWith(
      sensorReadings: result.sensorReadings,
      cameraSnapshots: result.cameraSnapshots,
      deviceStatuses: result.deviceStatuses,
      detectedFaces: result.detectedFaces,
      isUsingRealIoT: result.isUsingRealIoT,
      iotError: result.iotError,
      simulatedLatencyMs: stopwatch.elapsedMicroseconds / 1000.0,
      isRefreshingIoT: false,
    );
  }

  Future<void> _refreshIoTDataBackground() async {
    final result = await MockIoTService.fetchIntegratedData();
    if (!mounted) return;
    state = state.copyWith(
      sensorReadings: result.sensorReadings,
      cameraSnapshots: result.cameraSnapshots,
      deviceStatuses: result.deviceStatuses,
      detectedFaces: result.detectedFaces,
      isUsingRealIoT: result.isUsingRealIoT,
      iotError: result.iotError,
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
    _iotTimer?.cancel();
    if (locationId != null) {
      // Switching to Condition B (IoT Mode)
      refreshIoTData();
      state = state.copyWith(selectedLocationId: locationId);

      // Polling real-time locally every 3 seconds
      _iotTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (state.selectedLocationId != null && !state.isRefreshingIoT) {
          _refreshIoTDataBackground();
        }
      });
    } else {
      // Switching back to Condition A (Cuaca Lokal)
      state = state.copyWith(clearLocationId: true);
    }
  }
}
