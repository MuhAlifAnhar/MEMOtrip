import 'package:cloud_firestore/cloud_firestore.dart';

class TravelMemory {
  final String id;
  final String userId;
  final String destinationName;
  final String category;
  final DateTime date;
  final String caption;
  final String imageUrl;
  final DateTime createdAt;

  const TravelMemory({
    required this.id,
    required this.userId,
    required this.destinationName,
    required this.category,
    required this.date,
    required this.caption,
    required this.imageUrl,
    required this.createdAt,
  });

  TravelMemory copyWith({
    String? id,
    String? userId,
    String? destinationName,
    String? category,
    DateTime? date,
    String? caption,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return TravelMemory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      destinationName: destinationName ?? this.destinationName,
      category: category ?? this.category,
      date: date ?? this.date,
      caption: caption ?? this.caption,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'destinationName': destinationName,
      'category': category,
      'date': Timestamp.fromDate(date),
      'caption': caption,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory TravelMemory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TravelMemory(
      id: doc.id,
      userId: data['userId'] ?? '',
      destinationName: data['destinationName'] ?? '',
      category: data['category'] ?? 'pantai',
      date: (data['date'] as Timestamp).toDate(),
      caption: data['caption'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
