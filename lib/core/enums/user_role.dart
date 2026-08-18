/// Role-Based Access Control enum for MEMOtrip.
///
/// Three levels:
/// - [superAdmin] — Full access, can manage user roles
/// - [admin] — Admin panel access
/// - [user] — Regular user (default)
enum UserRole {
  superAdmin,
  admin,
  user;

  /// Serialize to Firestore string value.
  String toFirestore() {
    switch (this) {
      case UserRole.superAdmin:
        return 'super_admin';
      case UserRole.admin:
        return 'admin';
      case UserRole.user:
        return 'user';
    }
  }

  /// Deserialize from Firestore string value.
  static UserRole fromFirestore(String? value) {
    switch (value) {
      case 'super_admin':
        return UserRole.superAdmin;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.user;
    }
  }

  /// Human-readable label in Indonesian.
  String get label {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.admin:
        return 'Admin';
      case UserRole.user:
        return 'User';
    }
  }

  /// Whether this role has admin panel access.
  bool get hasAdminAccess =>
      this == UserRole.superAdmin || this == UserRole.admin;

  /// Whether this role can manage other users' roles.
  bool get canManageRoles => this == UserRole.superAdmin;
}
