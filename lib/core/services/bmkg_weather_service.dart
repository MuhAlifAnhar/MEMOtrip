import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

/// BMKG Weather Data Model — parsed from BMKG API JSON response.
class BmkgWeather {
  final String locationName;
  final String province;
  final String kecamatan;
  final String desa;
  final int temperature;         // °C
  final int humidity;            // %
  final double windSpeed;        // km/h
  final String windDirection;
  final String weatherDesc;      // e.g. "Cerah Berawan"
  final String weatherDescEn;
  final int cloudCover;          // %
  final String visibility;
  final String iconUrl;          // BMKG SVG icon URL
  final int weatherCode;
  final DateTime localTime;
  final DateTime analysisDate;

  const BmkgWeather({
    required this.locationName,
    required this.province,
    required this.kecamatan,
    required this.desa,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.weatherDesc,
    required this.weatherDescEn,
    required this.cloudCover,
    required this.visibility,
    required this.iconUrl,
    required this.weatherCode,
    required this.localTime,
    required this.analysisDate,
  });

  /// Returns a weather emoji based on the BMKG weather code.
  String get weatherEmoji {
    switch (weatherCode) {
      case 0:
      case 1:
        return '☀️';  // Cerah
      case 2:
        return '⛅';  // Cerah Berawan
      case 3:
        return '☁️';  // Berawan
      case 4:
        return '🌥️';  // Berawan Tebal
      case 5:
      case 10:
        return '🌫️';  // Asap / Kabut
      case 17:
      case 95:
      case 97:
        return '⛈️';  // Hujan Petir
      case 60:
      case 61:
        return '🌧️';  // Hujan Ringan
      case 63:
        return '🌧️';  // Hujan Sedang
      case 65:
        return '🌧️';  // Hujan Lebat
      default:
        return '🌤️';
    }
  }
}

/// BMKG Hourly Forecast — for the horizontal forecast strip.
class BmkgHourlyForecast {
  final DateTime localTime;
  final int temperature;
  final String weatherDesc;
  final int weatherCode;
  final String iconUrl;

  const BmkgHourlyForecast({
    required this.localTime,
    required this.temperature,
    required this.weatherDesc,
    required this.weatherCode,
    required this.iconUrl,
  });

  String get weatherEmoji {
    switch (weatherCode) {
      case 0:
      case 1:
        return '☀️';
      case 2:
        return '⛅';
      case 3:
        return '☁️';
      case 4:
        return '🌥️';
      case 5:
      case 10:
        return '🌫️';
      case 17:
      case 95:
      case 97:
        return '⛈️';
      case 60:
      case 61:
      case 63:
      case 65:
        return '🌧️';
      default:
        return '🌤️';
    }
  }

  String get timeLabel {
    final h = localTime.hour.toString().padLeft(2, '0');
    return '$h:00';
  }
}

/// BMKG Weather Service — fetches real-time weather from BMKG Open Data API.
///
/// Strategy:
///   1. User's GPS coordinates → find nearest city from lookup table
///   2. Use the city's adm4 code to query BMKG API
///   3. Parse response and return the current/nearest forecast
class BmkgWeatherService {
  BmkgWeatherService._();

  static const String _baseUrl =
      'https://api.bmkg.go.id/publik/prakiraan-cuaca';

  /// Cache to avoid hitting the 60 req/min limit.
  static BmkgWeather? _cachedWeather;
  static List<BmkgHourlyForecast>? _cachedHourly;
  static DateTime? _lastFetchTime;
  static String? _lastAdm4;

  // ─── ADM4 Lookup Table ─────────────────────────────────
  // Maps major Indonesian cities/areas to their BMKG adm4 codes.
  // Each entry: (lat, lng, adm4Code, cityName)
  static const List<({double lat, double lng, String adm4, String name})>
      _adm4Lookup = [
    // Sulawesi Selatan — Makassar
    (lat: -5.1437, lng: 119.4189, adm4: '73.71.04.1003', name: 'Makassar'),
    (lat: -5.1593, lng: 119.4370, adm4: '73.71.01.1001', name: 'Makassar Utara'),
    (lat: -5.1330, lng: 119.4100, adm4: '73.71.04.1001', name: 'Losari'),
    (lat: -5.1230, lng: 119.4926, adm4: '73.71.11.1001', name: 'Tamalanrea'),
    // Sulawesi Selatan — Gowa / Maros
    (lat: -5.2110, lng: 119.4550, adm4: '73.06.07.2003', name: 'Gowa'),
    (lat: -4.9920, lng: 119.5720, adm4: '73.09.01.1002', name: 'Maros'),
    // Jakarta
    (lat: -6.2088, lng: 106.8456, adm4: '31.71.03.1001', name: 'Jakarta Pusat'),
    (lat: -6.1216, lng: 106.7742, adm4: '31.72.01.1001', name: 'Jakarta Utara'),
    (lat: -6.2600, lng: 106.8100, adm4: '31.73.01.1001', name: 'Jakarta Selatan'),
    (lat: -6.1600, lng: 106.7400, adm4: '31.74.01.1001', name: 'Jakarta Barat'),
    (lat: -6.2250, lng: 106.9004, adm4: '31.75.01.1001', name: 'Jakarta Timur'),
    // Jawa Barat
    (lat: -6.9175, lng: 107.6191, adm4: '32.73.07.1006', name: 'Bandung'),
    (lat: -6.5970, lng: 106.7960, adm4: '32.71.03.1001', name: 'Bogor'),
    (lat: -6.7530, lng: 108.5520, adm4: '32.74.01.1001', name: 'Cirebon'),
    // Jawa Tengah
    (lat: -6.9669, lng: 110.4196, adm4: '33.74.01.1001', name: 'Semarang'),
    (lat: -7.5700, lng: 110.8200, adm4: '33.72.01.1001', name: 'Surakarta'),
    // Jawa Timur
    (lat: -7.2575, lng: 112.7521, adm4: '35.78.01.1001', name: 'Surabaya'),
    (lat: -7.9780, lng: 112.6340, adm4: '35.73.01.1001', name: 'Malang'),
    // DI Yogyakarta
    (lat: -7.7956, lng: 110.3695, adm4: '34.71.01.1001', name: 'Yogyakarta'),
    // Bali
    (lat: -8.6500, lng: 115.2191, adm4: '51.71.03.1001', name: 'Denpasar'),
    (lat: -8.4500, lng: 115.2600, adm4: '51.03.03.2001', name: 'Ubud'),
    // Sumatera
    (lat: 3.5952, lng: 98.6722, adm4: '12.71.01.1001', name: 'Medan'),
    (lat: -0.9493, lng: 104.1400, adm4: '21.71.04.1001', name: 'Palembang'),
    (lat: 0.5070, lng: 101.4470, adm4: '14.71.01.1001', name: 'Pekanbaru'),
    (lat: -0.3000, lng: 100.3700, adm4: '13.71.01.1001', name: 'Padang'),
    (lat: 5.5483, lng: 95.3238, adm4: '11.71.01.2001', name: 'Banda Aceh'),
    (lat: -2.9900, lng: 104.7600, adm4: '16.71.01.1001', name: 'Palembang Selatan'),
    (lat: 1.4700, lng: 104.0300, adm4: '21.71.01.1001', name: 'Batam'),
    // Kalimantan
    (lat: -3.3194, lng: 114.5907, adm4: '63.71.05.1001', name: 'Banjarmasin'),
    (lat: -0.5022, lng: 117.1536, adm4: '64.71.01.1001', name: 'Samarinda'),
    (lat: 0.0800, lng: 109.3400, adm4: '61.71.01.1001', name: 'Pontianak'),
    (lat: -2.2070, lng: 113.9160, adm4: '62.71.01.1001', name: 'Palangkaraya'),
    (lat: -1.2400, lng: 116.8520, adm4: '65.71.01.1001', name: 'Balikpapan'),
    // Sulawesi
    (lat: 1.4748, lng: 124.8421, adm4: '71.71.01.1001', name: 'Manado'),
    (lat: -0.8917, lng: 119.8707, adm4: '72.71.01.1001', name: 'Palu'),
    (lat: -3.9985, lng: 122.5129, adm4: '74.71.01.1001', name: 'Kendari'),
    // NTB / NTT
    (lat: -8.5830, lng: 116.1160, adm4: '52.71.01.1001', name: 'Mataram'),
    (lat: -10.1718, lng: 123.6075, adm4: '53.71.01.1001', name: 'Kupang'),
    // Maluku / Papua
    (lat: -3.6954, lng: 128.1814, adm4: '81.71.01.1001', name: 'Ambon'),
    (lat: -2.5337, lng: 140.7181, adm4: '91.71.01.1001', name: 'Jayapura'),
    (lat: 0.7834, lng: 127.3813, adm4: '82.71.01.1001', name: 'Ternate'),
  ];

  /// Find the nearest city's adm4 code from GPS coordinates
  /// using Haversine distance.
  static String _findNearestAdm4(double lat, double lng) {
    double minDist = double.infinity;
    String bestAdm4 = _adm4Lookup.first.adm4;

    for (final entry in _adm4Lookup) {
      final dist = _haversine(lat, lng, entry.lat, entry.lng);
      if (dist < minDist) {
        minDist = dist;
        bestAdm4 = entry.adm4;
      }
    }
    return bestAdm4;
  }

  /// Find the nearest city name.
  static String findNearestCityName(double lat, double lng) {
    double minDist = double.infinity;
    String bestName = _adm4Lookup.first.name;

    for (final entry in _adm4Lookup) {
      final dist = _haversine(lat, lng, entry.lat, entry.lng);
      if (dist < minDist) {
        minDist = dist;
        bestName = entry.name;
      }
    }
    return bestName;
  }

  /// Haversine distance in km.
  static double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  static double _toRad(double deg) => deg * pi / 180;

  /// Fetch weather data from BMKG API based on coordinates.
  ///
  /// Uses cached data if available and less than 30 minutes old.
  static Future<({BmkgWeather? current, List<BmkgHourlyForecast> hourly})>
      fetchWeather(double lat, double lng) async {
    final adm4 = _findNearestAdm4(lat, lng);

    // Use cache if same location and less than 30 min old
    if (_cachedWeather != null &&
        _lastAdm4 == adm4 &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!).inMinutes < 30) {
      return (current: _cachedWeather, hourly: _cachedHourly ?? []);
    }

    try {
      final uri = Uri.parse('$_baseUrl?adm4=$adm4');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode != 200) {
        return (current: _cachedWeather, hourly: _cachedHourly ?? []);
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final lokasi = json['lokasi'] as Map<String, dynamic>? ?? {};
      final dataList = json['data'] as List<dynamic>? ?? [];

      if (dataList.isEmpty) {
        return (current: null, hourly: <BmkgHourlyForecast>[]);
      }

      final firstData = dataList.first as Map<String, dynamic>;
      final cuacaGroups = firstData['cuaca'] as List<dynamic>? ?? [];

      // Flatten all forecast entries
      final allForecasts = <Map<String, dynamic>>[];
      for (final group in cuacaGroups) {
        if (group is List) {
          for (final item in group) {
            if (item is Map<String, dynamic>) {
              allForecasts.add(item);
            }
          }
        }
      }

      if (allForecasts.isEmpty) {
        return (current: null, hourly: <BmkgHourlyForecast>[]);
      }

      // Find the forecast entry closest to NOW
      final now = DateTime.now();
      Map<String, dynamic> closest = allForecasts.first;
      int closestDiff = _timeDiff(now, _parseLocalDateTime(closest));

      for (final f in allForecasts) {
        final diff = _timeDiff(now, _parseLocalDateTime(f));
        if (diff < closestDiff) {
          closestDiff = diff;
          closest = f;
        }
      }

      // Parse location info from top-level lokasi
      final province = lokasi['provinsi']?.toString() ?? '';
      final kotkab = lokasi['kotkab']?.toString() ?? '';
      final kecamatan = lokasi['kecamatan']?.toString() ?? '';
      final desa = lokasi['desa']?.toString() ?? '';
      final locationName = kotkab.isNotEmpty ? kotkab : 'Indonesia';

      // Build current weather
      final current = BmkgWeather(
        locationName: locationName,
        province: province,
        kecamatan: kecamatan,
        desa: desa,
        temperature: (closest['t'] as num?)?.toInt() ?? 0,
        humidity: (closest['hu'] as num?)?.toInt() ?? 0,
        windSpeed: (closest['ws'] as num?)?.toDouble() ?? 0.0,
        windDirection: closest['wd']?.toString() ?? '',
        weatherDesc: closest['weather_desc']?.toString() ?? 'N/A',
        weatherDescEn: closest['weather_desc_en']?.toString() ?? 'N/A',
        cloudCover: (closest['tcc'] as num?)?.toInt() ?? 0,
        visibility: closest['vs_text']?.toString() ?? '',
        iconUrl: closest['image']?.toString() ?? '',
        weatherCode: (closest['weather'] as num?)?.toInt() ?? 0,
        localTime: _parseLocalDateTime(closest),
        analysisDate: DateTime.tryParse(
            closest['analysis_date']?.toString() ?? '') ?? now,
      );

      // Build hourly forecasts (next 8 entries from now)
      final hourlyForecasts = <BmkgHourlyForecast>[];
      for (final f in allForecasts) {
        final localDt = _parseLocalDateTime(f);
        // Include forecasts from roughly now onward, up to 8
        if (localDt.isAfter(now.subtract(const Duration(hours: 2))) &&
            hourlyForecasts.length < 8) {
          hourlyForecasts.add(BmkgHourlyForecast(
            localTime: localDt,
            temperature: (f['t'] as num?)?.toInt() ?? 0,
            weatherDesc: f['weather_desc']?.toString() ?? '',
            weatherCode: (f['weather'] as num?)?.toInt() ?? 0,
            iconUrl: f['image']?.toString() ?? '',
          ));
        }
      }

      // Cache results
      _cachedWeather = current;
      _cachedHourly = hourlyForecasts;
      _lastFetchTime = DateTime.now();
      _lastAdm4 = adm4;

      return (current: current, hourly: hourlyForecasts);
    } catch (_) {
      // Return cached data on error, or null
      return (current: _cachedWeather, hourly: _cachedHourly ?? []);
    }
  }

  /// Parse `local_datetime` from BMKG response.
  static DateTime _parseLocalDateTime(Map<String, dynamic> f) {
    final str = f['local_datetime']?.toString() ?? '';
    return DateTime.tryParse(str) ?? DateTime.now();
  }

  /// Absolute time difference in minutes.
  static int _timeDiff(DateTime a, DateTime b) {
    return a.difference(b).inMinutes.abs();
  }
}
