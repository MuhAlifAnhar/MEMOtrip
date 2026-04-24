/// Firebase Service — Placeholder for Firebase initialization and helpers.
///
/// This service will be activated once google-services.json is configured.
/// For now, it provides a mock interface for the app to reference.
class FirebaseService {
  FirebaseService._();

  static bool _initialized = false;

  /// Initialize Firebase. Call from main.dart.
  static Future<void> initialize() async {
    // TODO: Uncomment when google-services.json is ready
    // await Firebase.initializeApp();
    _initialized = true;
  }

  static bool get isInitialized => _initialized;
}
