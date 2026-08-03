import '../domain/entities/schedule.dart';

/// Mock schedule data for development.
class MockScheduleData {
  MockScheduleData._();

  static List<Schedule> get schedules => [
    Schedule(id: 's1', userId: 'u1', title: 'Petualangan 5 hari di thailand', items: [
      ScheduleItem(id: 'si1', destinationId: 'losari', destinationName: 'Pantai Losari', dateTime: _today(17, 0), notes: 'Jangan Lupa Bawa Koper dan seluruh hiasan', latitude: -5.1427, longitude: 119.4100),
      ScheduleItem(id: 'si1b', destinationId: 'cpi', destinationName: 'CPI Makassar', dateTime: _today(10, 0), notes: 'Bawa kamera buat foto-foto', latitude: -5.1532, longitude: 119.4267),
      ScheduleItem(id: 'si1c', destinationId: 'akkarena', destinationName: 'Pantai Akkarena', dateTime: _today(14, 0), latitude: -5.1589, longitude: 119.4345),
      ScheduleItem(id: 'si1d', destinationId: 'fort-rotterdam', destinationName: 'Fort Rotterdam', dateTime: _today(16, 0), latitude: -5.1342, longitude: 119.4050),
      ScheduleItem(id: 'si1e', destinationId: 'kubah99', destinationName: 'Masjid 99 Kubah', dateTime: _today(8, 0), latitude: -5.1489, longitude: 119.4312),
    ], createdAt: DateTime.now().subtract(const Duration(days: 2))),
    Schedule(id: 's2', userId: 'u1', title: 'FIKSI Dayyyyyyy!!!!!!', items: [
      ScheduleItem(id: 'si2', destinationId: 'cpi', destinationName: 'CPI Makassar', dateTime: _tomorrow(10, 0), notes: 'Nongkrong + belanja souvenir', latitude: -5.1532, longitude: 119.4267),
      ScheduleItem(id: 'si3', destinationId: 'akkarena', destinationName: 'Pantai Akkarena', dateTime: _tomorrow(14, 0), notes: 'Waterboom sore', latitude: -5.1589, longitude: 119.4345),
    ], createdAt: DateTime.now().subtract(const Duration(days: 1))),
    Schedule(id: 's3', userId: 'u1', title: 'Wisata Religi', items: [
      ScheduleItem(id: 'si4', destinationId: 'kubah99', destinationName: 'Masjid 99 Kubah', dateTime: _daysFromNow(3, 8, 0), notes: 'Kunjungan pagi hari', latitude: -5.1489, longitude: 119.4312),
      ScheduleItem(id: 'si5', destinationId: 'fort-rotterdam', destinationName: 'Fort Rotterdam', dateTime: _daysFromNow(3, 10, 30), notes: 'Tur museum sejarah', latitude: -5.1342, longitude: 119.4050),
      ScheduleItem(id: 'si6', destinationId: 'pallubasa', destinationName: 'Pallubasa Serigala', dateTime: _daysFromNow(3, 12, 0), notes: 'Makan siang pallubasa khas Makassar', latitude: -5.1378, longitude: 119.4234),
    ], createdAt: DateTime.now()),
  ];

  static DateTime _today(int hour, int minute) { final now = DateTime.now(); return DateTime(now.year, now.month, now.day, hour, minute); }
  static DateTime _tomorrow(int hour, int minute) { final now = DateTime.now().add(const Duration(days: 1)); return DateTime(now.year, now.month, now.day, hour, minute); }
  static DateTime _daysFromNow(int days, int hour, int minute) { final d = DateTime.now().add(Duration(days: days)); return DateTime(d.year, d.month, d.day, hour, minute); }
}
