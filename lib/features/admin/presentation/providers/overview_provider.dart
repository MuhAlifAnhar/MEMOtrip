import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/mock_iot_service.dart';
import '../../../dashboard/domain/entities/sensor_reading.dart';

// ─── Data Models ───────────────────────────────────────

class ActivityLogItem {
  final String icon;
  final String message;
  final DateTime timestamp;

  const ActivityLogItem({
    required this.icon,
    required this.message,
    required this.timestamp,
  });
}

class OverviewState {
  final int totalDestinations;
  final int activeUsers;
  final int pendingReviews;
  final int totalSchedules;
  final List<DeviceStatus> deviceStatuses;
  final List<ActivityLogItem> activityLog;
  final bool isLoading;

  const OverviewState({
    this.totalDestinations = 0,
    this.activeUsers = 0,
    this.pendingReviews = 0,
    this.totalSchedules = 0,
    this.deviceStatuses = const [],
    this.activityLog = const [],
    this.isLoading = true,
  });

  OverviewState copyWith({
    int? totalDestinations,
    int? activeUsers,
    int? pendingReviews,
    int? totalSchedules,
    List<DeviceStatus>? deviceStatuses,
    List<ActivityLogItem>? activityLog,
    bool? isLoading,
  }) {
    return OverviewState(
      totalDestinations: totalDestinations ?? this.totalDestinations,
      activeUsers: activeUsers ?? this.activeUsers,
      pendingReviews: pendingReviews ?? this.pendingReviews,
      totalSchedules: totalSchedules ?? this.totalSchedules,
      deviceStatuses: deviceStatuses ?? this.deviceStatuses,
      activityLog: activityLog ?? this.activityLog,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ─── Overview Provider ─────────────────────────────────

class OverviewNotifier extends StateNotifier<OverviewState> {
  OverviewNotifier() : super(const OverviewState()) {
    _loadOverview();
  }

  final _db = FirebaseFirestore.instance;

  Future<void> _loadOverview() async {
    try {
      // Fetch all collections in parallel
      final results = await Future.wait([
        _db.collection('destinations').get(),
        _db.collection('reviews').get(),
        _db.collection('schedules').get(),
      ]);

      final destinationsSnap = results[0];
      final reviewsSnap = results[1];
      final schedulesSnap = results[2];

      // ─── Stats ───────────────────────────────────
      final totalDestinations = destinationsSnap.docs.length;

      // Count pending reviews
      final pendingReviews = reviewsSnap.docs.where((doc) {
        final data = doc.data();
        return data['status'] == 'pending';
      }).length;

      // Count unique users from schedules
      final uniqueUsers = <String>{};
      for (final doc in schedulesSnap.docs) {
        final userId = doc.data()['userId'] as String? ?? '';
        if (userId.isNotEmpty) uniqueUsers.add(userId);
      }

      final totalSchedules = schedulesSnap.docs.length;

      // ─── IoT Device Statuses ─────────────────────
      final deviceStatuses = MockIoTService.generateDeviceStatuses();

      // ─── Activity Log (from real data) ───────────
      final activityLog = <ActivityLogItem>[];

      // Recent reviews
      for (final doc in reviewsSnap.docs) {
        final data = doc.data();
        final userName = data['userName'] as String? ?? 'User';
        final destId = data['destinationId'] as String? ?? '';
        final status = data['status'] as String? ?? 'pending';
        final tsStr = data['timestamp'] as String?;
        final ts = tsStr != null
            ? DateTime.tryParse(tsStr) ?? DateTime.now()
            : DateTime.now();

        final statusLabel = status == 'approved' ? 'disetujui' : 'pending';
        activityLog.add(ActivityLogItem(
          icon: '💬',
          message: '$userName menulis ulasan untuk $destId ($statusLabel)',
          timestamp: ts,
        ));
      }

      // Recent schedules
      for (final doc in schedulesSnap.docs) {
        final data = doc.data();
        final title = data['title'] as String? ?? 'Jadwal';
        final userId = data['userId'] as String? ?? 'user';
        final createdAtStr = data['createdAt'] as String?;
        final createdAt = createdAtStr != null
            ? DateTime.tryParse(createdAtStr) ?? DateTime.now()
            : DateTime.now();

        activityLog.add(ActivityLogItem(
          icon: '📅',
          message: 'User $userId membuat jadwal "$title"',
          timestamp: createdAt,
        ));
      }

      // Recent destinations added
      for (final doc in destinationsSnap.docs) {
        activityLog.add(ActivityLogItem(
          icon: '📍',
          message: 'Destinasi "${doc.data()['name'] ?? doc.id}" terdaftar',
          timestamp: DateTime.now().subtract(const Duration(days: 7)),
        ));
      }

      // Sort by timestamp descending, take latest 10
      activityLog.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final latestActivity = activityLog.take(10).toList();

      state = OverviewState(
        totalDestinations: totalDestinations,
        activeUsers: uniqueUsers.isEmpty ? 1 : uniqueUsers.length,
        pendingReviews: pendingReviews,
        totalSchedules: totalSchedules,
        deviceStatuses: deviceStatuses,
        activityLog: latestActivity,
        isLoading: false,
      );
    } catch (e) {
      print('Overview load error: $e');
      // Fallback to mock data
      state = OverviewState(
        totalDestinations: 0,
        activeUsers: 0,
        pendingReviews: 0,
        totalSchedules: 0,
        deviceStatuses: MockIoTService.generateDeviceStatuses(),
        activityLog: [],
        isLoading: false,
      );
    }
  }

  /// Refresh all overview data.
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadOverview();
  }
}

final overviewProvider =
    StateNotifierProvider<OverviewNotifier, OverviewState>((ref) {
  return OverviewNotifier();
});
