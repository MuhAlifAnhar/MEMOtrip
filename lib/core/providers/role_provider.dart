import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../enums/user_role.dart';

/// Streams the current user's role from Firestore in real-time.
final userRoleProvider = Provider<UserRole>((ref) {
  final userDoc = ref.watch(userDocProvider).value;
  if (userDoc == null) return UserRole.user;
  return UserRole.fromFirestore(userDoc['role'] as String?);
});

/// Whether the current user has admin panel access (admin or super_admin).
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(userRoleProvider).hasAdminAccess;
});

/// Whether the current user is a super admin (can manage roles).
final isSuperAdminProvider = Provider<bool>((ref) {
  return ref.watch(userRoleProvider).canManageRoles;
});
