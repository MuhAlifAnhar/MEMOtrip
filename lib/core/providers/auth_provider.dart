import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Riverpod provider that exposes the current Firebase Auth user reactively.
/// Streams auth state changes so the UI updates when the user logs in/out.
final authUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});
