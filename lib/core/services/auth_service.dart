import 'package:firebase_auth/firebase_auth.dart';

/// Authentication Service — wraps Firebase Auth for clean architecture.
///
/// Provides email/password sign-in, registration, sign-out,
/// and an auth state stream for reactive UI guarding.
class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── Auth State Stream ────────────────────────────────
  /// Emits the current user whenever the auth state changes.
  /// Returns `null` when signed out, `User` when signed in.
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current user (null if not signed in).
  static User? get currentUser => _auth.currentUser;

  /// Whether a user is currently signed in.
  static bool get isSignedIn => _auth.currentUser != null;

  // ─── Email / Password ─────────────────────────────────

  /// Sign in with email and password.
  /// Returns the [UserCredential] on success.
  /// Throws [FirebaseAuthException] on failure (caught by caller).
  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Create a new account with email, password, and display name.
  static Future<UserCredential> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Set display name
    await credential.user?.updateDisplayName(name.trim());
    await credential.user?.reload();

    return credential;
  }

  // ─── Sign Out ─────────────────────────────────────────
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // ─── Password Reset ───────────────────────────────────
  static Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ─── Error Message Helper ─────────────────────────────
  /// Converts FirebaseAuthException codes to user-friendly Indonesian messages.
  static String friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Akun tidak ditemukan. Silakan daftar terlebih dahulu.';
      case 'wrong-password':
        return 'Password salah. Silakan coba lagi.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan login.';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'operation-not-allowed':
        return 'Metode login ini belum diaktifkan.';
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet.';
      default:
        return e.message ?? 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }
}
