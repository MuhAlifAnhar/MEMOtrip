/// Destination entity — Core domain object.
class Destination {
  final String id;
  final String name;
  final String description;
  final String category;
  final double latitude;
  final double longitude;
  final String address;
  final double rating;
  final int reviewCount;
  final List<String> imageUrls;
  final String? video360Url;
  final List<String> facilities;
  final Map<String, String> operatingHours;
  final String? hardwareId;
  final bool isBookmarked;

  const Destination({
    required this.id, required this.name, required this.description,
    required this.category, required this.latitude, required this.longitude,
    required this.address, this.rating = 0.0, this.reviewCount = 0,
    this.imageUrls = const [], this.video360Url, this.facilities = const [],
    this.operatingHours = const {}, this.hardwareId, this.isBookmarked = false,
  });

  Destination copyWith({
    String? id, String? name, String? description, String? category,
    double? latitude, double? longitude, String? address, double? rating,
    int? reviewCount, List<String>? imageUrls, String? video360Url,
    List<String>? facilities, Map<String, String>? operatingHours,
    String? hardwareId, bool? isBookmarked,
  }) {
    return Destination(
      id: id ?? this.id, name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude, longitude: longitude ?? this.longitude,
      address: address ?? this.address, rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrls: imageUrls ?? this.imageUrls,
      video360Url: video360Url ?? this.video360Url,
      facilities: facilities ?? this.facilities,
      operatingHours: operatingHours ?? this.operatingHours,
      hardwareId: hardwareId ?? this.hardwareId,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
