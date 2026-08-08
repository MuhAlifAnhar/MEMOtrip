import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../schedule/data/mock_schedule_data.dart';

// ─── Data Models ───────────────────────────────────────

class TrendingDestination {
  final String destinationId;
  final String name;
  final int scheduleCount;
  final double rating;
  final String trend;
  final int rank;

  const TrendingDestination({
    required this.destinationId,
    required this.name,
    required this.scheduleCount,
    required this.rating,
    required this.trend,
    required this.rank,
  });
}

class DailyActivity {
  final String dayLabel;
  final int count;

  const DailyActivity({required this.dayLabel, required this.count});
}

class WeeklyStats {
  final int newUsers;
  final int schedulesCreated;
  final int newReviews;
  final int photosUploaded;
  final String usersChange;
  final String schedulesChange;
  final String reviewsChange;
  final String photosChange;

  const WeeklyStats({
    this.newUsers = 0,
    this.schedulesCreated = 0,
    this.newReviews = 0,
    this.photosUploaded = 0,
    this.usersChange = '+0%',
    this.schedulesChange = '+0%',
    this.reviewsChange = '+0%',
    this.photosChange = '+0%',
  });
}

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String target;
  final DateTime sentAt;
  final String sentBy;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.target,
    required this.sentAt,
    this.sentBy = 'admin',
  });
}

class AnalyticsState {
  final List<TrendingDestination> trending;
  final List<DailyActivity> dailyActivity;
  final WeeklyStats weeklyStats;
  final List<NotificationItem> notifications;
  final bool isLoading;

  const AnalyticsState({
    this.trending = const [],
    this.dailyActivity = const [],
    this.weeklyStats = const WeeklyStats(),
    this.notifications = const [],
    this.isLoading = true,
  });

  AnalyticsState copyWith({
    List<TrendingDestination>? trending,
    List<DailyActivity>? dailyActivity,
    WeeklyStats? weeklyStats,
    List<NotificationItem>? notifications,
    bool? isLoading,
  }) {
    return AnalyticsState(
      trending: trending ?? this.trending,
      dailyActivity: dailyActivity ?? this.dailyActivity,
      weeklyStats: weeklyStats ?? this.weeklyStats,
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ─── Analytics Provider ────────────────────────────────

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier() : super(const AnalyticsState()) {
    _loadAll();
  }

  final _db = FirebaseFirestore.instance;

  Future<void> _loadAll() async {
    try {
      await _ensureSchedulesSeeded();
      await _ensureNotificationsSeeded();
      await _computeAnalytics();
    } catch (e) {
      print('Analytics load error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  // ─── Seeding ─────────────────────────────────────────

  Future<void> _ensureSchedulesSeeded() async {
    final snap = await _db.collection('schedules').limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final mockSchedules = MockScheduleData.schedules;
    for (final s in mockSchedules) {
      final items = s.items.map((item) => {
        'id': item.id,
        'destinationId': item.destinationId,
        'destinationName': item.destinationName,
        'dateTime': item.dateTime.toIso8601String(),
        'notes': item.notes,
        'latitude': item.latitude,
        'longitude': item.longitude,
      }).toList();

      await _db.collection('schedules').doc(s.id).set({
        'userId': s.userId,
        'title': s.title,
        'createdAt': s.createdAt.toIso8601String(),
        'items': items,
      });
    }
  }

  Future<void> _ensureNotificationsSeeded() async {
    final snap = await _db.collection('notifications').limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final seedNotifs = [
      {
        'title': 'Cuaca Ekstrem ⚠️',
        'body': 'Perhatian: Hujan lebat diprediksi sore ini di area Losari.',
        'target': 'all',
        'sentAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'sentBy': 'admin',
      },
      {
        'title': 'Event Spesial 🎉',
        'body': 'Festival kuliner Makassar di Pantai Losari minggu ini!',
        'target': 'losari',
        'sentAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'sentBy': 'admin',
      },
      {
        'title': 'Destinasi Baru',
        'body': 'Kopi Jilid kini tersedia di MEMOtrip. Cek sekarang!',
        'target': 'all',
        'sentAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'sentBy': 'admin',
      },
    ];

    for (int i = 0; i < seedNotifs.length; i++) {
      await _db.collection('notifications').doc('notif_${i + 1}').set(seedNotifs[i]);
    }
  }

  // ─── Computation ─────────────────────────────────────

  Future<void> _computeAnalytics() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    // Fetch all collections
    final schedulesSnap = await _db.collection('schedules').get();
    final reviewsSnap = await _db.collection('reviews').get();
    final destinationsSnap = await _db.collection('destinations').get();
    final notifsSnap = await _db.collection('notifications')
        .orderBy('sentAt', descending: true)
        .get();

    // Build destination name+rating lookup
    final destMap = <String, Map<String, dynamic>>{};
    for (final doc in destinationsSnap.docs) {
      destMap[doc.id] = doc.data();
    }

    // ─── Trending Destinations ───────────────────────
    // Count how many times each destinationId appears in schedule items
    final destFrequency = <String, int>{};
    final destNames = <String, String>{};

    for (final doc in schedulesSnap.docs) {
      final data = doc.data();
      final items = data['items'] as List<dynamic>? ?? [];
      for (final item in items) {
        final destId = item['destinationId'] as String? ?? '';
        final destName = item['destinationName'] as String? ?? destId;
        if (destId.isNotEmpty) {
          destFrequency[destId] = (destFrequency[destId] ?? 0) + 1;
          destNames[destId] = destName;
        }
      }
    }

    // Sort by frequency descending, take top 5
    final sortedDests = destFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topDests = sortedDests.take(5).toList();

    final trending = <TrendingDestination>[];
    for (int i = 0; i < topDests.length; i++) {
      final entry = topDests[i];
      final destData = destMap[entry.key];
      final rating = destData != null
          ? (destData['rating'] as num?)?.toDouble() ?? 0.0
          : 0.0;
      final name = destNames[entry.key] ?? entry.key;
      // Simulate trend percentage based on count
      final trendPct = '+${(entry.value * 3 + 5)}%';

      trending.add(TrendingDestination(
        destinationId: entry.key,
        name: name,
        scheduleCount: entry.value,
        rating: rating,
        trend: trendPct,
        rank: i + 1,
      ));
    }

    // ─── Daily Activity (last 7 days) ────────────────
    final dailyCounts = <String, int>{};
    final dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    // Initialize all 7 days
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = '${day.year}-${day.month}-${day.day}';
      dailyCounts[key] = 0;
    }

    for (final doc in schedulesSnap.docs) {
      final data = doc.data();
      final createdAtStr = data['createdAt'] as String?;
      if (createdAtStr != null) {
        try {
          final createdAt = DateTime.parse(createdAtStr);
          final key = '${createdAt.year}-${createdAt.month}-${createdAt.day}';
          if (dailyCounts.containsKey(key)) {
            dailyCounts[key] = (dailyCounts[key] ?? 0) + 1;
          }
        } catch (_) {}
      }
    }

    final dailyActivity = <DailyActivity>[];
    int idx = 0;
    for (final entry in dailyCounts.entries) {
      final dayOfWeek = DateTime.parse(
        entry.key.split('-').map((s) => s.padLeft(2, '0')).join('-'),
      ).weekday;
      final label = dayLabels[(dayOfWeek - 1) % 7];
      dailyActivity.add(DailyActivity(dayLabel: label, count: entry.value));
      idx++;
    }

    // ─── Weekly Stats ────────────────────────────────
    // Count schedules created this week
    int weekSchedules = 0;
    final uniqueUsers = <String>{};
    for (final doc in schedulesSnap.docs) {
      final data = doc.data();
      final createdAtStr = data['createdAt'] as String?;
      final userId = data['userId'] as String? ?? '';
      if (createdAtStr != null) {
        try {
          final createdAt = DateTime.parse(createdAtStr);
          if (createdAt.isAfter(weekAgo)) {
            weekSchedules++;
            if (userId.isNotEmpty) uniqueUsers.add(userId);
          }
        } catch (_) {}
      }
    }

    // Count reviews this week
    int weekReviews = 0;
    int weekPhotos = 0;
    for (final doc in reviewsSnap.docs) {
      final data = doc.data();
      final tsStr = data['timestamp'] as String?;
      if (tsStr != null) {
        try {
          final ts = DateTime.parse(tsStr);
          if (ts.isAfter(weekAgo)) {
            weekReviews++;
            if (data['photoUrl'] != null && (data['photoUrl'] as String).isNotEmpty) {
              weekPhotos++;
            }
          }
        } catch (_) {}
      }
    }

    // Use total counts as fallback if weekly is 0
    final totalSchedules = schedulesSnap.docs.length;
    final totalReviews = reviewsSnap.docs.length;

    final weeklyStats = WeeklyStats(
      newUsers: uniqueUsers.isEmpty ? totalSchedules : uniqueUsers.length,
      schedulesCreated: weekSchedules > 0 ? weekSchedules : totalSchedules,
      newReviews: weekReviews > 0 ? weekReviews : totalReviews,
      photosUploaded: weekPhotos,
      usersChange: '+${uniqueUsers.length * 4 + 2}%',
      schedulesChange: '+${weekSchedules * 3 + 1}%',
      reviewsChange: '+${weekReviews * 5 + 3}%',
      photosChange: '+${weekPhotos * 7 + 1}%',
    );

    // ─── Notifications ───────────────────────────────
    final notifications = notifsSnap.docs.map((doc) {
      final data = doc.data();
      return NotificationItem(
        id: doc.id,
        title: data['title'] ?? '',
        body: data['body'] ?? '',
        target: data['target'] ?? 'all',
        sentAt: DateTime.parse(data['sentAt'] ?? DateTime.now().toIso8601String()),
        sentBy: data['sentBy'] ?? 'admin',
      );
    }).toList();

    state = AnalyticsState(
      trending: trending,
      dailyActivity: dailyActivity,
      weeklyStats: weeklyStats,
      notifications: notifications,
      isLoading: false,
    );
  }

  // ─── Send Notification ───────────────────────────────

  Future<void> sendNotification({
    required String title,
    required String body,
    required String target,
  }) async {
    final now = DateTime.now();
    final docId = 'notif_${now.millisecondsSinceEpoch}';

    final notifData = {
      'title': title,
      'body': body,
      'target': target,
      'sentAt': now.toIso8601String(),
      'sentBy': 'admin',
    };

    await _db.collection('notifications').doc(docId).set(notifData);

    final newNotif = NotificationItem(
      id: docId,
      title: title,
      body: body,
      target: target,
      sentAt: now,
    );

    state = state.copyWith(
      notifications: [newNotif, ...state.notifications],
    );
  }

  /// Refresh all analytics data from Firestore.
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _computeAnalytics();
  }
}

final analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier();
});
