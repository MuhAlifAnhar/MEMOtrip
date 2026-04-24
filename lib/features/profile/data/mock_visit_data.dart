import '../../destination/data/mock_destination_data.dart';
import '../../destination/domain/entities/destination.dart';

/// Mock visit history data for development.
/// Will be replaced by Firebase Firestore in production.
class MockVisitData {
  MockVisitData._();

  /// All visit records — references real destination IDs.
  static final List<VisitRecord> visits = [
    VisitRecord(
      destinationId: 'losari',
      visitDate: DateTime.now().subtract(const Duration(days: 2)),
      notes: 'Nonton sunset bareng keluarga 🌅',
      rating: 5.0,
    ),
    VisitRecord(
      destinationId: 'kubah99',
      visitDate: DateTime.now().subtract(const Duration(days: 5)),
      notes: 'Wisata religi weekend',
      rating: 5.0,
    ),
    VisitRecord(
      destinationId: 'cpi',
      visitDate: DateTime.now().subtract(const Duration(days: 8)),
      notes: 'Jalan sore di area CPI',
      rating: 4.5,
    ),
    VisitRecord(
      destinationId: 'pallubasa',
      visitDate: DateTime.now().subtract(const Duration(days: 14)),
      notes: 'Sarapan pallubasa mantap! 🍲',
      rating: 4.8,
    ),
    VisitRecord(
      destinationId: 'fort-rotterdam',
      visitDate: DateTime.now().subtract(const Duration(days: 21)),
      notes: 'Tur sejarah benteng bersejarah',
      rating: 4.5,
    ),
    VisitRecord(
      destinationId: 'kopi-jilid',
      visitDate: DateTime.now().subtract(const Duration(days: 30)),
      notes: 'Coffee date sore hari ☕',
      rating: 4.0,
    ),
    VisitRecord(
      destinationId: 'akkarena',
      visitDate: DateTime.now().subtract(const Duration(days: 45)),
      notes: 'Waterboom bareng anak-anak 🏊',
      rating: 4.3,
    ),
    VisitRecord(
      destinationId: 'losari',
      visitDate: DateTime.now().subtract(const Duration(days: 60)),
      notes: 'Kuliner malam Pisang Epe',
      rating: 4.7,
    ),
  ];

  /// Total visit count.
  static int get totalVisits => visits.length;

  /// Unique destination count.
  static int get uniqueDestinations =>
      visits.map((v) => v.destinationId).toSet().length;

  /// Average rating across all rated visits.
  static String get averageRating {
    final ratings = visits.where((v) => v.rating != null).map((v) => v.rating!);
    if (ratings.isEmpty) return '—';
    final avg = ratings.reduce((a, b) => a + b) / ratings.length;
    return avg.toStringAsFixed(1);
  }

  /// Resolve visits with their destination data.
  static List<ResolvedVisit> get resolvedVisits {
    final list = <ResolvedVisit>[];
    for (final v in visits) {
      final dest = MockDestinationData.getById(v.destinationId);
      if (dest != null) {
        list.add(ResolvedVisit(visit: v, destination: dest));
      }
    }
    return list;
  }
}

/// A single visit record — ties a destination ID to a date, notes, and rating.
class VisitRecord {
  final String destinationId;
  final DateTime visitDate;
  final String? notes;
  final double? rating;

  const VisitRecord({
    required this.destinationId,
    required this.visitDate,
    this.notes,
    this.rating,
  });
}

/// A visit record resolved against the destination catalog.
class ResolvedVisit {
  final VisitRecord visit;
  final Destination destination;

  const ResolvedVisit({required this.visit, required this.destination});
}
