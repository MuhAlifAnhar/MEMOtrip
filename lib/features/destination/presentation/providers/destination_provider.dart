import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/mock_destination_data.dart';
import '../../domain/entities/destination.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/report_item.dart';

export '../../domain/entities/destination.dart';
export '../../domain/entities/review.dart';
export '../../domain/entities/report_item.dart';

// ─── Destinations Provider ─────────────────────────────

class DestinationsNotifier extends StateNotifier<List<Destination>> {
  DestinationsNotifier() : super([]) {
    _loadDestinations();
  }

  final _db = FirebaseFirestore.instance;

  Future<void> _loadDestinations() async {
    try {
      final snap = await _db.collection('destinations').get();
      if (snap.docs.isEmpty) {
        await _seedDestinations();
      } else {
        state = snap.docs.map((doc) => _fromMap(doc.id, doc.data())).toList();
      }
    } catch (e) {
      print('Error loading destinations: $e');
      state = List.from(MockDestinationData.destinations);
    }
  }

  Future<void> _seedDestinations() async {
    final initial = MockDestinationData.destinations;
    for (final d in initial) {
      await _db.collection('destinations').doc(d.id).set(_toMap(d));
    }
    state = initial;
  }

  Destination _fromMap(String id, Map<String, dynamic> map) {
    return Destination(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      address: map['address'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      facilities: List<String>.from(map['facilities'] ?? const []),
      operatingHours: Map<String, String>.from(map['operatingHours'] ?? const {}),
      hardwareId: map['hardwareId'],
      isBookmarked: map['isBookmarked'] ?? false,
    );
  }

  Map<String, dynamic> _toMap(Destination d) {
    return {
      'name': d.name,
      'description': d.description,
      'category': d.category,
      'latitude': d.latitude,
      'longitude': d.longitude,
      'address': d.address,
      'rating': d.rating,
      'reviewCount': d.reviewCount,
      'facilities': d.facilities,
      'operatingHours': d.operatingHours,
      'hardwareId': d.hardwareId,
      'isBookmarked': d.isBookmarked,
    };
  }

  void addDestination(Destination destination) {
    state = [...state, destination];
    _db.collection('destinations').doc(destination.id).set(_toMap(destination));
  }

  void updateDestination(Destination destination) {
    state = state.map((d) => d.id == destination.id ? destination : d).toList();
    _db.collection('destinations').doc(destination.id).update(_toMap(destination));
  }

  void deleteDestination(String id) {
    state = state.where((d) => d.id != id).toList();
    _db.collection('destinations').doc(id).delete();
  }

  void toggleBookmark(String id) {
    state = state.map((d) {
      if (d.id == id) {
        final updated = d.copyWith(isBookmarked: !d.isBookmarked);
        _db.collection('destinations').doc(id).update({'isBookmarked': updated.isBookmarked});
        return updated;
      }
      return d;
    }).toList();
  }
}

final destinationsProvider =
    StateNotifierProvider<DestinationsNotifier, List<Destination>>((ref) {
  return DestinationsNotifier();
});

// ─── Reviews Provider ──────────────────────────────────

class ReviewsNotifier extends StateNotifier<List<Review>> {
  ReviewsNotifier() : super([]) {
    _loadReviews();
  }

  final _db = FirebaseFirestore.instance;

  Future<void> _loadReviews() async {
    try {
      final snap = await _db.collection('reviews').get();
      if (snap.docs.isEmpty) {
        await _seedReviews();
      } else {
        state = snap.docs.map((doc) => _fromMap(doc.id, doc.data())).toList();
      }
    } catch (e) {
      print('Error loading reviews: $e');
      state = List.from(MockDestinationData.reviews);
    }
  }

  Future<void> _seedReviews() async {
    final initial = MockDestinationData.reviews;
    for (final r in initial) {
      await _db.collection('reviews').doc(r.id).set(_toMap(r));
    }
    state = initial;
  }

  Review _fromMap(String id, Map<String, dynamic> map) {
    return Review(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userAvatarUrl: map['userAvatarUrl'],
      destinationId: map['destinationId'] ?? '',
      comment: map['comment'] ?? '',
      photoUrl: map['photoUrl'],
      rating: map['rating'] != null ? (map['rating'] as num).toDouble() : null,
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      status: ReviewStatus.values.firstWhere((e) => e.name == map['status'], orElse: () => ReviewStatus.pending),
      isOfficial: map['isOfficial'] ?? false,
    );
  }

  Map<String, dynamic> _toMap(Review r) {
    return {
      'userId': r.userId,
      'userName': r.userName,
      'userAvatarUrl': r.userAvatarUrl,
      'destinationId': r.destinationId,
      'comment': r.comment,
      'photoUrl': r.photoUrl,
      'rating': r.rating,
      'timestamp': r.timestamp.toIso8601String(),
      'status': r.status.name,
      'isOfficial': r.isOfficial,
    };
  }

  void addReview(Review review) {
    state = [review, ...state];
    _db.collection('reviews').doc(review.id).set(_toMap(review));
  }

  void approveReview(String reviewId) {
    state = state.map((r) {
      if (r.id == reviewId) {
        final updated = r.copyWith(status: ReviewStatus.approved);
        _db.collection('reviews').doc(reviewId).update({'status': ReviewStatus.approved.name});
        return updated;
      }
      return r;
    }).toList();
  }

  void rejectReview(String reviewId) {
    state = state.where((r) => r.id != reviewId).toList();
    _db.collection('reviews').doc(reviewId).delete();
  }

  void deleteReview(String reviewId) {
    state = state.where((r) => r.id != reviewId).toList();
    _db.collection('reviews').doc(reviewId).delete();
  }
}

final reviewsProvider =
    StateNotifierProvider<ReviewsNotifier, List<Review>>((ref) {
  return ReviewsNotifier();
});

// ─── Reports Provider ──────────────────────────────────

class ReportsNotifier extends StateNotifier<List<ReportItem>> {
  ReportsNotifier() : super([]) {
    _loadReports();
  }

  final _db = FirebaseFirestore.instance;

  Future<void> _loadReports() async {
    try {
      final snap = await _db.collection('reports').get();
      if (snap.docs.isEmpty) {
        await _seedReports();
      } else {
        state = snap.docs.map((doc) => _fromMap(doc.id, doc.data())).toList();
      }
    } catch (e) {
      print('Error loading reports: $e');
      state = [
        ReportItem(
          id: 'rep1',
          reporterName: 'Andi Pratama',
          targetReviewId: 'r1',
          reason: 'Konten mengandung spam/iklan',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
        ReportItem(
          id: 'rep2',
          reporterName: 'Sari Dewi',
          targetReviewId: 'r4',
          reason: 'Komentar tidak sopan',
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        ),
      ];
    }
  }

  Future<void> _seedReports() async {
    final initial = [
      ReportItem(
        id: 'rep1',
        reporterName: 'Andi Pratama',
        targetReviewId: 'r1',
        reason: 'Konten mengandung spam/iklan',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ReportItem(
        id: 'rep2',
        reporterName: 'Sari Dewi',
        targetReviewId: 'r4',
        reason: 'Komentar tidak sopan',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];
    for (final r in initial) {
      await _db.collection('reports').doc(r.id).set(_toMap(r));
    }
    state = initial;
  }

  ReportItem _fromMap(String id, Map<String, dynamic> map) {
    return ReportItem(
      id: id,
      reporterName: map['reporterName'] ?? '',
      targetReviewId: map['targetReviewId'] ?? '',
      reason: map['reason'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> _toMap(ReportItem r) {
    return {
      'reporterName': r.reporterName,
      'targetReviewId': r.targetReviewId,
      'reason': r.reason,
      'timestamp': r.timestamp.toIso8601String(),
    };
  }

  void addReport(ReportItem report) {
    state = [report, ...state];
    _db.collection('reports').doc(report.id).set(_toMap(report));
  }

  void dismissReport(String reportId) {
    state = state.where((rep) => rep.id != reportId).toList();
    _db.collection('reports').doc(reportId).delete();
  }

  void deleteReport(String reportId) {
    state = state.where((rep) => rep.id != reportId).toList();
    _db.collection('reports').doc(reportId).delete();
  }
}

final reportsProvider =
    StateNotifierProvider<ReportsNotifier, List<ReportItem>>((ref) {
  return ReportsNotifier();
});
