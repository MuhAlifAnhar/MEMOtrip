import 'package:firebase_core/firebase_core.dart';

/// Firebase Service — Helper utilities for Firebase integration.
///
/// Firebase is initialized in main.dart via Firebase.initializeApp().
/// This service provides convenience helpers and status checks.
class FirebaseService {
  FirebaseService._();

  /// Check if Firebase has been initialized.
  static bool get isInitialized {
    try {
      Firebase.app();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get the default Firebase app instance.
  static FirebaseApp get app => Firebase.app();
}
