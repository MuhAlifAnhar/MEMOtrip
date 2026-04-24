/// User entity — MEMOtrip user profile.
class AppUser {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final List<String> visitHistory;
  final List<String> bookmarks;
  final DateTime createdAt;
  final bool isAdmin;

  const AppUser({required this.id, required this.name, required this.email, this.photoUrl, this.visitHistory = const [], this.bookmarks = const [], required this.createdAt, this.isAdmin = false});

  int get totalVisits => visitHistory.length;
  int get totalBookmarks => bookmarks.length;

  AppUser copyWith({String? id, String? name, String? email, String? photoUrl, List<String>? visitHistory, List<String>? bookmarks, DateTime? createdAt, bool? isAdmin}) {
    return AppUser(id: id ?? this.id, name: name ?? this.name, email: email ?? this.email, photoUrl: photoUrl ?? this.photoUrl, visitHistory: visitHistory ?? this.visitHistory, bookmarks: bookmarks ?? this.bookmarks, createdAt: createdAt ?? this.createdAt, isAdmin: isAdmin ?? this.isAdmin);
  }
}
