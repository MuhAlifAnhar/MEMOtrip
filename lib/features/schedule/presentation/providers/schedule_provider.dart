import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/mock_schedule_data.dart';
import '../../domain/entities/schedule.dart';

// Expose entities
export '../../domain/entities/schedule.dart';

class SchedulesNotifier extends StateNotifier<List<Schedule>> {
  SchedulesNotifier() : super([]) {
    _loadSchedules();
  }

  final _db = FirebaseFirestore.instance;

  Future<void> _loadSchedules() async {
    try {
      final snap = await _db.collection('schedules').get();
      if (snap.docs.isEmpty) {
        await _seedSchedules();
      } else {
        state = snap.docs.map((doc) => _fromMap(doc.id, doc.data())).toList();
      }
    } catch (e) {
      print('Error loading schedules: $e');
      state = List.from(MockScheduleData.schedules);
    }
  }

  Future<void> _seedSchedules() async {
    final initial = MockScheduleData.schedules;
    for (final s in initial) {
      await _db.collection('schedules').doc(s.id).set(_toMap(s));
    }
    state = initial;
  }

  Schedule _fromMap(String id, Map<String, dynamic> map) {
    final itemsList = map['items'] as List<dynamic>? ?? [];
    final items = itemsList.map((itemMap) {
      final m = itemMap as Map<String, dynamic>;
      return ScheduleItem(
        id: m['id'] ?? '',
        destinationId: m['destinationId'] ?? '',
        destinationName: m['destinationName'] ?? '',
        destinationImageUrl: m['destinationImageUrl'],
        dateTime: DateTime.tryParse(m['dateTime'] ?? '') ?? DateTime.now(),
        notes: m['notes'],
        latitude: m['latitude'] != null ? (m['latitude'] as num).toDouble() : null,
        longitude: m['longitude'] != null ? (m['longitude'] as num).toDouble() : null,
      );
    }).toList();

    return Schedule(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      items: items,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
    );
  }

  Map<String, dynamic> _toMap(Schedule s) {
    return {
      'userId': s.userId,
      'title': s.title,
      'createdAt': s.createdAt.toIso8601String(),
      'updatedAt': s.updatedAt?.toIso8601String(),
      'items': s.items.map((item) => {
        'id': item.id,
        'destinationId': item.destinationId,
        'destinationName': item.destinationName,
        'destinationImageUrl': item.destinationImageUrl,
        'dateTime': item.dateTime.toIso8601String(),
        'notes': item.notes,
        'latitude': item.latitude,
        'longitude': item.longitude,
      }).toList(),
    };
  }

  void addSchedule(Schedule schedule) {
    state = [...state, schedule];
    _db.collection('schedules').doc(schedule.id).set(_toMap(schedule));
  }

  void updateSchedule(Schedule schedule) {
    state = state.map((s) => s.id == schedule.id ? schedule : s).toList();
    _db.collection('schedules').doc(schedule.id).update(_toMap(schedule));
  }

  void deleteSchedule(String id) {
    state = state.where((s) => s.id != id).toList();
    _db.collection('schedules').doc(id).delete();
  }
}

final schedulesProvider =
    StateNotifierProvider<SchedulesNotifier, List<Schedule>>((ref) {
  return SchedulesNotifier();
});
