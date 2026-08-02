import '../../../../core/services/bmkg_weather_service.dart';
import '../../../../core/services/mock_iot_service.dart';
import '../../../dashboard/domain/entities/sensor_reading.dart';

class DashboardState {
  final String? selectedLocationId;
  final bool isLoadingWeather;
  final BmkgWeather? currentWeather;
  final List<BmkgHourlyForecast> hourlyForecasts;
  final bool isUsingRealLocation;
  final String? weatherError;

  final List<SensorReading> sensorReadings;
  final List<CameraSnapshot> cameraSnapshots;
  final List<DeviceStatus> deviceStatuses;

  final double simulatedLatencyMs;
  final bool isRefreshingIoT;

  const DashboardState({
    this.selectedLocationId,
    this.isLoadingWeather = true,
    this.currentWeather,
    this.hourlyForecasts = const [],
    this.isUsingRealLocation = false,
    this.weatherError,
    this.sensorReadings = const [],
    this.cameraSnapshots = const [],
    this.deviceStatuses = const [],
    this.simulatedLatencyMs = 0.0,
    this.isRefreshingIoT = false,
  });

  DashboardState copyWith({
    String? selectedLocationId,
    bool? isLoadingWeather,
    BmkgWeather? currentWeather,
    List<BmkgHourlyForecast>? hourlyForecasts,
    bool? isUsingRealLocation,
    String? weatherError,
    List<SensorReading>? sensorReadings,
    List<CameraSnapshot>? cameraSnapshots,
    List<DeviceStatus>? deviceStatuses,
    double? simulatedLatencyMs,
    bool? isRefreshingIoT,
    bool clearLocationId = false,
    bool clearWeatherError = false,
  }) {
    return DashboardState(
      selectedLocationId:
          clearLocationId ? null : (selectedLocationId ?? this.selectedLocationId),
      isLoadingWeather: isLoadingWeather ?? this.isLoadingWeather,
      currentWeather: currentWeather ?? this.currentWeather,
      hourlyForecasts: hourlyForecasts ?? this.hourlyForecasts,
      isUsingRealLocation: isUsingRealLocation ?? this.isUsingRealLocation,
      weatherError: clearWeatherError ? null : (weatherError ?? this.weatherError),
      sensorReadings: sensorReadings ?? this.sensorReadings,
      cameraSnapshots: cameraSnapshots ?? this.cameraSnapshots,
      deviceStatuses: deviceStatuses ?? this.deviceStatuses,
      simulatedLatencyMs: simulatedLatencyMs ?? this.simulatedLatencyMs,
      isRefreshingIoT: isRefreshingIoT ?? this.isRefreshingIoT,
    );
  }
}
