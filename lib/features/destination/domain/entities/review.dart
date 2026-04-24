/// Review entity — Community review for a destination.
class Review {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String destinationId;
  final String comment;
  final String? photoUrl;
  final double? rating;
  final DateTime timestamp;
  final ReviewStatus status;
  final bool isOfficial;

  const Review({
    required this.id, required this.userId, required this.userName,
    this.userAvatarUrl, required this.destinationId, required this.comment,
    this.photoUrl, this.rating, required this.timestamp,
    this.status = ReviewStatus.pending, this.isOfficial = false,
  });

  Review copyWith({
    String? id, String? userId, String? userName, String? userAvatarUrl,
    String? destinationId, String? comment, String? photoUrl, double? rating,
    DateTime? timestamp, ReviewStatus? status, bool? isOfficial,
  }) {
    return Review(
      id: id ?? this.id, userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      destinationId: destinationId ?? this.destinationId,
      comment: comment ?? this.comment, photoUrl: photoUrl ?? this.photoUrl,
      rating: rating ?? this.rating, timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status, isOfficial: isOfficial ?? this.isOfficial,
    );
  }
}

enum ReviewStatus { pending, approved, rejected }
