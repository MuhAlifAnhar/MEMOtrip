/// Schedule entity — User travel itinerary.
class Schedule {
  final String id;
  final String userId;
  final String title;
  final List<ScheduleItem> items;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Schedule({required this.id, required this.userId, required this.title, this.items = const [], required this.createdAt, this.updatedAt});

  int get totalPlaces => items.length;

  double get estimatedHours {
    if (items.isEmpty) return 0;
    final sorted = List<ScheduleItem>.from(items)..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return sorted.last.dateTime.difference(sorted.first.dateTime).inMinutes / 60;
  }

  Schedule copyWith({String? id, String? userId, String? title, List<ScheduleItem>? items, DateTime? createdAt, DateTime? updatedAt}) {
    return Schedule(id: id ?? this.id, userId: userId ?? this.userId, title: title ?? this.title, items: items ?? this.items, createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt);
  }
}

/// Single item in a schedule (a stop/destination).
class ScheduleItem {
  final String id;
  final String destinationId;
  final String destinationName;
  final String? destinationImageUrl;
  final DateTime dateTime;
  final String? notes;
  final double? latitude;
  final double? longitude;

  const ScheduleItem({required this.id, required this.destinationId, required this.destinationName, this.destinationImageUrl, required this.dateTime, this.notes, this.latitude, this.longitude});

  ScheduleItem copyWith({String? id, String? destinationId, String? destinationName, String? destinationImageUrl, DateTime? dateTime, String? notes, double? latitude, double? longitude}) {
    return ScheduleItem(id: id ?? this.id, destinationId: destinationId ?? this.destinationId, destinationName: destinationName ?? this.destinationName, destinationImageUrl: destinationImageUrl ?? this.destinationImageUrl, dateTime: dateTime ?? this.dateTime, notes: notes ?? this.notes, latitude: latitude ?? this.latitude, longitude: longitude ?? this.longitude);
  }
}
