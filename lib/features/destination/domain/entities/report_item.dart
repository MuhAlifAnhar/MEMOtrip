/// Model representing a community content report.
class ReportItem {
  final String id;
  final String reporterName;
  final String targetReviewId;
  final String reason;
  final DateTime timestamp;

  const ReportItem({
    required this.id,
    required this.reporterName,
    required this.targetReviewId,
    required this.reason,
    required this.timestamp,
  });

  ReportItem copyWith({
    String? id,
    String? reporterName,
    String? targetReviewId,
    String? reason,
    DateTime? timestamp,
  }) {
    return ReportItem(
      id: id ?? this.id,
      reporterName: reporterName ?? this.reporterName,
      targetReviewId: targetReviewId ?? this.targetReviewId,
      reason: reason ?? this.reason,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
