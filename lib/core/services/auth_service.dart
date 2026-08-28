import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../enums/user_role.dart';

/// Authentication Service — wraps Firebase Auth for clean architecture.
///
/// Provides email/password sign-in, registration, sign-out,
/// Google Sign-In, and an auth state stream for reactive UI guarding.
class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── Auth State Stream ────────────────────────────────
  /// Emits the current user whenever the auth state changes.
  /// Returns `null` when signed out, `User` when signed in.
  ///
  /// IMPORTANT: This is a cached `static final` field, NOT a getter.
  /// Using a getter (`get authStateChanges => _auth.authStateChanges()`)
  /// creates a NEW Stream instance on every access. When StreamBuilder
  /// receives a different stream identity on rebuild, it unsubscribes and
  /// resubscribes — entering ConnectionState.waiting and rebuilding the
  /// entire child tree, which destroys TextFormField focus state.
  static final Stream<User?> authStateChanges = _auth.authStateChanges();

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

    // Create user document in Cloud Firestore
    final user = credential.user;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'role': 'user',
        'createdAt': DateTime.now().toIso8601String(),
      });
    }

    return credential;
  }

  // ─── Google Sign-In ───────────────────────────────────

  /// Sign in with Google and automatically create/update user document.
  static Future<UserCredential?> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      // User canceled the sign-in
      return null;
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    final UserCredential userCredential = await _auth.signInWithCredential(credential);

    // Create user document in Cloud Firestore if it doesn't exist
    final user = userCredential.user;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': user.displayName ?? 'Google User',
          'email': user.email ?? '',
          'photoUrl': user.photoURL ?? '',
          'role': 'user',
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
    }

    return userCredential;
  }

  // ─── Facebook Sign-In ─────────────────────────────────

  /// Sign in with Facebook and automatically create/update user document.
  static Future<UserCredential?> signInWithFacebook() async {
    // Trigger the authentication flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    if (loginResult.status != LoginStatus.success) {
      // User canceled the sign-in or there was an error
      return null;
    }

    // Create a new credential
    final OAuthCredential credential = FacebookAuthProvider.credential(
      loginResult.accessToken!.tokenString,
    );

    // Once signed in, return the UserCredential
    final UserCredential userCredential = await _auth.signInWithCredential(credential);

    // Create user document in Cloud Firestore if it doesn't exist
    final user = userCredential.user;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': user.displayName ?? 'Facebook User',
          'email': user.email ?? '',
          'photoUrl': user.photoURL ?? '',
          'role': 'user',
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
    }

    return userCredential;
  }

  // ─── Image Upload ─────────────────────────────────────
  /// Uploads profile picture bytes to Firebase Storage and returns the download URL.
  static Future<String> uploadProfilePicture({
    required String userId,
    required Uint8List bytes,
    required String extension,
  }) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_pictures')
        .child('$userId.$extension');

    final uploadTask = ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/$extension'),
    );
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // ─── Update Profile ───────────────────────────────────
  static Future<void> updateProfile({
    required String name,
    required String photoUrl,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name.trim());
      await user.updatePhotoURL(photoUrl.trim());
      await user.reload();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': user.email,
        'photoUrl': photoUrl.trim(),
      }, SetOptions(merge: true));
    }
  }

  // ─── Sign Out ─────────────────────────────────────────
  static Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {
      // Ignore errors if not signed in with Google
    }
    try {
      await FacebookAuth.instance.logOut();
    } catch (_) {
      // Ignore errors if not signed in with Facebook
    }
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

  /// Get user role from Firestore
  static Future<UserRole> getUserRole(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return UserRole.fromFirestore(doc.data()?['role']);
  }

  /// Update a user's role (Super Admin only)
  static Future<void> updateUserRole(String uid, UserRole role) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'role': role.toFirestore(),
    });
  }

  /// Ensure existing users have a role field (migration)
  /// Called once on app startup for the current user.
  static Future<void> ensureUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists && !doc.data()!.containsKey('role')) {
      // Assign role based on email
      String role = 'user';
      if (user.email == 'sultankautsar21@gmail.com') {
        role = 'super_admin';
      } else if (user.email == 'jennifer@gmail.com' || user.email == 'syafitrimarhua@gmail.com') {
        role = 'admin';
      }
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'role': role});
    } else if (!doc.exists) {
      // Create user doc if missing
      String role = 'user';
      if (user.email == 'sultankautsar21@gmail.com') {
        role = 'super_admin';
      } else if (user.email == 'jennifer@gmail.com' || user.email == 'syafitrimarhua@gmail.com') {
        role = 'admin';
      }
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'role': role,
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
  }
}
