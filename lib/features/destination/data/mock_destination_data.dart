import '../domain/entities/destination.dart';
import '../domain/entities/review.dart';

/// Mock destination & review data for development — 7 Makassar locations.
class MockDestinationData {
  MockDestinationData._();

  static List<Destination> get destinations => [
    const Destination(id: 'losari', name: 'Pantai Losari', description: 'Pantai Losari adalah ikon wisata Kota Makassar yang terletak di sepanjang Jalan Penghibur. Tempat ini terkenal dengan sunset yang memukau, kuliner Pisang Epe, dan suasana malam yang ramai. Pantai ini menjadi pusat aktivitas masyarakat untuk olahraga, bersantai, dan menikmati pemandangan laut.', category: 'pantai', latitude: -5.1427, longitude: 119.4100, address: 'Jl. Penghibur, Losari, Makassar', rating: 4.7, reviewCount: 234, facilities: ['Parkir Luas', 'Toilet Umum', 'Area Kuliner', 'Jogging Track', 'Spot Foto'], operatingHours: {'Senin-Jumat': '06:00-22:00', 'Sabtu-Minggu': '05:00-23:00'}, hardwareId: 'losari', isBookmarked: true),
    const Destination(id: 'cpi', name: 'CPI Makassar', description: 'Centre Point of Indonesia (CPI) adalah landmark modern Makassar yang menjadi pusat rekreasi dan bisnis. Terletak di area reklamasi pantai, CPI menawarkan pemandangan laut yang indah, area publik terbuka, dan berbagai fasilitas hiburan.', category: 'pantai', latitude: -5.1532, longitude: 119.4267, address: 'Jl. Metro Tanjung Bunga, Makassar', rating: 4.5, reviewCount: 189, facilities: ['Parkir', 'Restoran', 'Taman Bermain', 'Area Foto 360°', 'WiFi'], operatingHours: {'Senin-Minggu': '08:00-22:00'}, hardwareId: 'cpi'),
    const Destination(id: 'kubah99', name: 'Masjid 99 Kubah', description: 'Masjid Al Jabbar atau dikenal sebagai Masjid 99 Kubah adalah masjid megah dengan arsitektur modern yang menjadi landmark keagamaan Makassar. Masjid ini memiliki 99 kubah yang melambangkan 99 Asmaul Husna.', category: 'gunung', latitude: -5.1489, longitude: 119.4312, address: 'Jl. Tun Abdul Razak, Gowa', rating: 4.8, reviewCount: 312, facilities: ['Parkir Luas', 'Tempat Wudhu', 'Mushola', 'Taman', 'Museum Mini'], operatingHours: {'Senin-Minggu': '04:00-21:00'}, hardwareId: 'kubah99', isBookmarked: true),
    const Destination(id: 'fort-rotterdam', name: 'Fort Rotterdam', description: 'Benteng peninggalan Kerajaan Gowa-Tallo yang dibangun pada abad ke-16. Fort Rotterdam adalah salah satu benteng terbaik yang masih berdiri di Asia Tenggara, kini berfungsi sebagai museum dan pusat budaya.', category: 'gunung', latitude: -5.1342, longitude: 119.4050, address: 'Jl. Ujung Pandang, Makassar', rating: 4.6, reviewCount: 278, facilities: ['Parkir', 'Museum', 'Area Foto', 'Pemandu Wisata', 'Toko Souvenir'], operatingHours: {'Selasa-Minggu': '08:00-17:00', 'Senin': 'Tutup'}),
    const Destination(id: 'akkarena', name: 'Pantai Akkarena', description: 'Pantai Akkarena adalah destinasi rekreasi keluarga di Makassar yang menawarkan wahana waterboom, pantai berpasir putih, dan area bermain anak. Tempat yang ideal untuk liburan keluarga.', category: 'pantai', latitude: -5.1589, longitude: 119.4345, address: 'Jl. Metro Tanjung Bunga, Makassar', rating: 4.3, reviewCount: 156, facilities: ['Waterboom', 'Parkir', 'Restoran', 'Toilet', 'Area Bermain Anak'], operatingHours: {'Senin-Jumat': '09:00-18:00', 'Sabtu-Minggu': '08:00-19:00'}),
    const Destination(id: 'kopi-jilid', name: 'Kopi Jilid', description: 'Kafe modern dengan suasana cozy dan menu kopi specialty yang beragam. Tempat favorit anak muda Makassar untuk nongkrong, bekerja, dan bersantai.', category: 'kafe', latitude: -5.1456, longitude: 119.4189, address: 'Jl. A.P. Pettarani, Makassar', rating: 4.4, reviewCount: 98, facilities: ['WiFi', 'Parkir', 'Mushola', 'Area Indoor/Outdoor', 'Live Music Weekend'], operatingHours: {'Senin-Minggu': '10:00-23:00'}),
    const Destination(id: 'pallubasa', name: 'Pallubasa Serigala', description: 'Kuliner legendaris Makassar yang menyajikan pallubasa autentik sejak puluhan tahun. Pallubasa adalah sup khas Makassar dengan kuah santan kental dan daging sapi yang empuk.', category: 'restoran', latitude: -5.1378, longitude: 119.4234, address: 'Jl. Gunung Bawakaraeng, Makassar', rating: 4.6, reviewCount: 445, facilities: ['Parkir', 'Dine-in', 'Take Away'], operatingHours: {'Senin-Minggu': '07:00-15:00'}),
  ];

  static List<Review> get reviews => [
    Review(id: 'r1', userId: 'u1', userName: 'Ahmad Rizky', destinationId: 'losari', comment: 'Sunset di Losari selalu memukau! Tempat terbaik untuk bersantai sore hari. Pisang Epe-nya juga wajib dicoba.', rating: 5.0, timestamp: DateTime.now().subtract(const Duration(hours: 2)), status: ReviewStatus.approved),
    Review(id: 'r2', userId: 'u2', userName: 'Siti Nurhaliza', destinationId: 'losari', comment: 'Ramai tapi seru! Cocok untuk jalan-jalan sore bareng keluarga. Banyak jajanan enak.', rating: 4.5, timestamp: DateTime.now().subtract(const Duration(days: 1)), status: ReviewStatus.approved),
    Review(id: 'r3', userId: 'admin', userName: 'MEMOtrip Official', destinationId: 'losari', comment: 'Area kuliner Losari telah direnovasi! Nikmati suasana baru yang lebih bersih dan nyaman.', timestamp: DateTime.now().subtract(const Duration(days: 3)), status: ReviewStatus.approved, isOfficial: true),
    Review(id: 'r4', userId: 'u3', userName: 'Budi Santoso', destinationId: 'kubah99', comment: 'Arsitekturnya luar biasa indah. Recommended banget untuk wisata religi dan foto-foto.', rating: 5.0, timestamp: DateTime.now().subtract(const Duration(days: 2)), status: ReviewStatus.approved),
    Review(id: 'r5', userId: 'u4', userName: 'Andi Mappanyukki', destinationId: 'pallubasa', comment: 'Pallubasa terenak di Makassar! Kuahnya kental dan dagingnya empuk. Harga juga terjangkau.', rating: 4.8, timestamp: DateTime.now().subtract(const Duration(days: 4)), status: ReviewStatus.approved),
  ];

  static Destination? getById(String id) {
    try { return destinations.firstWhere((d) => d.id == id); } catch (_) { return null; }
  }

  static List<Review> getReviewsForDestination(String destId) {
    return reviews.where((r) => r.destinationId == destId).toList();
  }
}
