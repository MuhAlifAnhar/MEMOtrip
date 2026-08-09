import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../schedule/presentation/providers/schedule_provider.dart';

class UserVisitRecord {
  final String id;
  final String userId;
  final String destinationId;
  final DateTime visitDate;
  final String? notes;
  final double? rating;

  const UserVisitRecord({
    required this.id,
    required this.userId,
    required this.destinationId,
    required this.visitDate,
    this.notes,
    this.rating,
  });
}

/// Dynamic visitsProvider that derives visit records from active schedules
/// to ensure 100% synchronization between Schedule Page and Profile Page.
final visitsProvider = Provider<List<UserVisitRecord>>((ref) {
  final schedules = ref.watch(schedulesProvider);
  final list = <UserVisitRecord>[];
  for (final s in schedules) {
    for (final item in s.items) {
      list.add(UserVisitRecord(
        id: item.id,
        userId: s.userId,
        destinationId: item.destinationId,
        visitDate: item.dateTime,
        notes: item.notes,
        rating: 5.0, // Default rating
      ));
    }
  }
  return list;
});
