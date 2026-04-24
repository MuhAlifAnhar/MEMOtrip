/// MEMOtrip — Placeholder Image URL Generator
///
/// Uses picsum.photos for consistent, seed-based placeholder images
/// so every destination always shows the same beautiful photo.
class PlaceholderImages {
  PlaceholderImages._();

  /// Destination image by ID.
  static String destination(String id, {int w = 400, int h = 300}) =>
      'https://picsum.photos/seed/memotrip_$id/$w/$h';

  /// Destination hero (large).
  static String hero(String id, {int w = 800, int h = 500}) =>
      'https://picsum.photos/seed/hero_$id/$w/$h';

  /// Camera / IoT snapshot placeholder.
  static String camera(String locationId, {int w = 600, int h = 300}) =>
      'https://picsum.photos/seed/cam_$locationId/$w/$h';

  /// Memory gallery photo.
  static String memory(String memoryId, {int w = 400, int h = 500}) =>
      'https://picsum.photos/seed/mem_$memoryId/$w/$h';

  /// Schedule header banner.
  static String schedule(String scheduleId, {int w = 800, int h = 400}) =>
      'https://picsum.photos/seed/sched_$scheduleId/$w/$h';

  /// User profile avatar.
  static String avatar({int size = 200}) =>
      'https://picsum.photos/seed/avatar_memotrip/$size/$size';
}
