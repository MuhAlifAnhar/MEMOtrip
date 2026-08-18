import '../../../../core/enums/user_role.dart';

/// User entity — MEMOtrip user profile.
class AppUser {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final List<String> visitHistory;
  final List<String> bookmarks;
  final DateTime createdAt;
  final UserRole role;

  const AppUser({required this.id, required this.name, required this.email, this.photoUrl, this.visitHistory = const [], this.bookmarks = const [], required this.createdAt, this.role = UserRole.user});

  int get totalVisits => visitHistory.length;
  int get totalBookmarks => bookmarks.length;
  
  bool get isAdmin => role.hasAdminAccess;
  bool get isSuperAdmin => role.canManageRoles;

  AppUser copyWith({String? id, String? name, String? email, String? photoUrl, List<String>? visitHistory, List<String>? bookmarks, DateTime? createdAt, UserRole? role}) {
    return AppUser(id: id ?? this.id, name: name ?? this.name, email: email ?? this.email, photoUrl: photoUrl ?? this.photoUrl, visitHistory: visitHistory ?? this.visitHistory, bookmarks: bookmarks ?? this.bookmarks, createdAt: createdAt ?? this.createdAt, role: role ?? this.role);
  }

  factory AppUser.fromFirestore(Map<String, dynamic> data) {
    return AppUser(
      id: data['uid'] ?? data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      visitHistory: List<String>.from(data['visitHistory'] ?? []),
      bookmarks: List<String>.from(data['bookmarks'] ?? []),
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : DateTime.now(),
      role: UserRole.fromFirestore(data['role']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'visitHistory': visitHistory,
      'bookmarks': bookmarks,
      'createdAt': createdAt.toIso8601String(),
      'role': role.toFirestore(),
    };
  }
}
