import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

/// RaspberryPiService — Fetches real-time crowd detection data from
/// a Raspberry Pi 4 + Webcam setup and syncs results to Firebase.
///
/// Endpoint: http://10.201.52.51:5000/api/data
/// Response: {"faces": [{"confidence": 36.2, "id": 1}], "total_faces": 1}
///
/// This service is used for the Pantai Losari location only.
/// Other locations continue to use MockIoTService simulations.
class RaspberryPiService {
  RaspberryPiService._();

  // ─── Configuration ───────────────────────────────────────
  static const String _baseUrl = 'http://10.229.22.51:5000';
  static const String _dataEndpoint = '/api/data';
  static const Duration _timeout = Duration(seconds: 5);

  /// Firestore collection for persisting IoT readings.
  static final _db = FirebaseFirestore.instance;
  static const String _collection = 'iot_readings';

  // ─── Crowd Level Thresholds ──────────────────────────────
  static const int _thresholdSedang = 1; // >= 1 faces → Sedang
  static const int _thresholdRamai = 6; // >= 6 faces → Ramai

  // ─── Data Models ─────────────────────────────────────────

  /// Parsed response from Raspberry Pi API.
  static CrowdDetectionResult? _lastResult;

  /// Throttling variables for Firestore writes.
  static DateTime? _lastSyncTime;
  static CrowdDetectionResult? _lastSyncedResult;

  /// Get the most recent successful result (cached in-memory).
  static CrowdDetectionResult? get lastResult => _lastResult;

  // ─── Core API ────────────────────────────────────────────

  /// Fetch crowd detection data from the Raspberry Pi endpoint.
  ///
  /// Returns [CrowdDetectionResult] on success, or `null` if the
  /// request fails (network error, timeout, malformed JSON).
  static Future<CrowdDetectionResult?> fetchCrowdData() async {
    Map<String, dynamic> data = {};
    int totalFaces = 0;
    List<DetectedFace> faces = [];
    bool isOnline = false;

    // 1. Fetch camera data from Raspberry Pi 4 + Webcam
    try {
      final uri = Uri.parse('$_baseUrl$_dataEndpoint');
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        data = json.decode(response.body) as Map<String, dynamic>;
        totalFaces = (data['total_faces'] as num?)?.toInt() ?? 0;
        faces = (data['faces'] as List<dynamic>?)
                ?.map((f) => DetectedFace.fromJson(f as Map<String, dynamic>))
                .toList() ??
            [];
        isOnline = true;
      } else {
        print(
            'DEBUG ERROR status: Status code dari $_baseUrl adalah ${response.statusCode}');
      }
    } catch (e) {
      print(
          'DEBUG ERROR fetch: Gagal menghubungkan ke Raspberry Pi di $_baseUrl: $e');
    }

    // Fallback to mock if Raspberry Pi is offline
    if (!isOnline) {
      return null;
    }

    // 2. Fetch DHT22 sensor readings from Firebase Realtime Database (RTDB)
    double? suhu;
    double? kelembapan;
    try {
      final rtdbUri = Uri.parse('https://memotrip-2026-default-rtdb.firebaseio.com/DHT22.json');
      final rtdbResponse = await http.get(rtdbUri).timeout(const Duration(seconds: 3));
      if (rtdbResponse.statusCode == 200 && rtdbResponse.body != 'null') {
        final rtdbData = json.decode(rtdbResponse.body) as Map<String, dynamic>;
        suhu = (rtdbData['Suhu'] as num?)?.toDouble();
        kelembapan = (rtdbData['Kelembapan'] as num?)?.toDouble();
        print('DEBUG RTDB: DHT22 fetched successfully: Suhu=$suhu, Kelembapan=$kelembapan');
      }
    } catch (e) {
      print('DEBUG ERROR RTDB: Gagal mengambil data DHT22 dari RTDB: $e');
    }

    final result = CrowdDetectionResult(
      totalFaces: totalFaces,
      faces: faces,
      crowdLevel: determineCrowdLevel(totalFaces),
      timestamp: DateTime.now(),
      isOnline: true,
      suhu: suhu,
      kelembapan: kelembapan,
    );

    _lastResult = result;
    return result;
  }

  /// Determine crowd level label based on total detected faces.
  ///
  /// Thresholds:
  ///   - 0 faces       → Sepi
  ///   - 1–5 faces     → Sedang
  ///   - 6+ faces      → Ramai
  static String determineCrowdLevel(int totalFaces) {
    if (totalFaces >= _thresholdRamai) return 'Ramai';
    if (totalFaces >= _thresholdSedang) return 'Sedang';
    return 'Sepi';
  }

  /// Upload crowd detection result to Firestore `iot_readings` collection.
  ///
  /// Each document records:
  ///   - locationId, locationName
  ///   - totalFaces, crowdLevel
  ///   - faces array (id + confidence per face)
  ///   - timestamp (server timestamp)
  static Future<void> syncToFirestore(CrowdDetectionResult result) async {
    final now = DateTime.now();

    // Check if we should throttle the write operation to Firestore.
    // Allow if it's the first sync, or if >= 5 seconds have elapsed,
    // OR if the data has actually changed (different face count or crowd level).
    final hasTimeElapsed =
        _lastSyncTime == null || now.difference(_lastSyncTime!).inSeconds >= 5;

    final hasDataChanged = _lastSyncedResult == null ||
        _lastSyncedResult!.totalFaces != result.totalFaces ||
        _lastSyncedResult!.crowdLevel != result.crowdLevel;

    if (!hasTimeElapsed && !hasDataChanged) {
      // Throttle limit met, skip Firestore write but keep the UI updated locally
      return;
    }

    try {
      final Map<String, dynamic> dataToSync = {
        'locationId': 'losari',
        'locationName': 'Pantai Losari',
        'totalFaces': result.totalFaces,
        'crowdLevel': result.crowdLevel,
        'faces': result.faces
            .map((f) => {'id': f.id, 'confidence': f.confidence})
            .toList(),
        'source': 'raspberry_pi',
        'deviceType': 'Raspberry Pi 4 + Webcam + DHT22',
        'timestamp': FieldValue.serverTimestamp(),
        'clientTimestamp': result.timestamp.toIso8601String(),
      };

      if (result.suhu != null) {
        dataToSync['suhu'] = result.suhu;
      }
      if (result.kelembapan != null) {
        dataToSync['kelembapan'] = result.kelembapan;
      }

      await _db.collection(_collection).add(dataToSync);

      // Update sync markers on success
      _lastSyncTime = now;
      _lastSyncedResult = result;
      print(
          'DEBUG: Data IoT Pantai Losari berhasil disinkronkan ke Firestore.');
    } catch (e) {
      print('DEBUG ERROR: Gagal menulis telemetri IoT ke Firestore: $e');
    }
  }

  /// Combined fetch + sync workflow.
  ///
  /// 1. Fetches data from the Raspberry Pi API.
  /// 2. On success, syncs the result to Firestore in the background.
  /// 3. Returns the parsed [CrowdDetectionResult], or `null` on failure.
  static Future<CrowdDetectionResult?> fetchAndSync() async {
    final result = await fetchCrowdData();
    if (result != null) {
      // Fire-and-forget: sync to Firestore without blocking the UI.
      syncToFirestore(result);
    }
    return result;
  }
}

// ─── Data Classes ──────────────────────────────────────────

/// Represents a single detected face from the Raspberry Pi camera.
class DetectedFace {
  final int id;
  final double confidence;

  const DetectedFace({required this.id, required this.confidence});

  factory DetectedFace.fromJson(Map<String, dynamic> json) {
    return DetectedFace(
      id: (json['id'] as num?)?.toInt() ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Parsed result from the Raspberry Pi crowd detection API.
class CrowdDetectionResult {
  final int totalFaces;
  final List<DetectedFace> faces;
  final String crowdLevel;
  final DateTime timestamp;
  final bool isOnline;
  final double? suhu;
  final double? kelembapan;

  const CrowdDetectionResult({
    required this.totalFaces,
    required this.faces,
    required this.crowdLevel,
    required this.timestamp,
    this.isOnline = true,
    this.suhu,
    this.kelembapan,
  });
}
