import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Riverpod provider that exposes the current Firebase Auth user reactively.
/// Streams auth state changes so the UI updates when the user logs in/out.
final authUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Riverpod provider that listens to real-time changes of the user's Firestore document.
/// Enables instantaneous updates of display name and profile picture in the UI.
final userDocProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final authUser = ref.watch(authUserProvider).value;
  if (authUser == null) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(authUser.uid)
      .snapshots()
      .map((snap) => snap.data());
});
