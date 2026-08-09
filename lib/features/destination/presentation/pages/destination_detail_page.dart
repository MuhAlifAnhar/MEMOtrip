import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:panorama_viewer/panorama_viewer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/distance_calculator.dart';
import '../../../../core/utils/placeholder_images.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/sensor_data_card.dart';
import '../../../../core/widgets/community_review_card.dart';
import '../../../../core/services/mock_iot_service.dart';
import '../../data/mock_destination_data.dart';
import '../../domain/entities/destination.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/destination_provider.dart';
import '../../domain/entities/review.dart';

/// Destination Detail Page — Deep dive view with sensor data, facilities, reviews.
class DestinationDetailPage extends ConsumerStatefulWidget {
  final Destination destination;

  const DestinationDetailPage({super.key, required this.destination});

  @override
  ConsumerState<DestinationDetailPage> createState() => _DestinationDetailPageState();
}

class _DestinationDetailPageState extends ConsumerState<DestinationDetailPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final Animation<double> _fadeAnim;

  Destination get destination => ref.watch(destinationsProvider).firstWhere(
        (d) => d.id == widget.destination.id,
        orElse: () => widget.destination,
      );

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sensors = MockIoTService.generateSensorReadings();
    final snapshots = MockIoTService.generateCameraSnapshots();
    final sensor = MockIoTService.getSensorByLocation(destination.hardwareId ?? '', sensors);
    final snapshot = MockIoTService.getSnapshotByLocation(destination.hardwareId ?? '', snapshots);
    final reviews = ref
        .watch(reviewsProvider)
        .where((r) =>
            r.destinationId == destination.id &&
            r.status == ReviewStatus.approved)
        .toList();
    final dist = DistanceCalculator.haversine(
        LocationService.defaultLat, LocationService.defaultLng,
        destination.latitude, destination.longitude);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: CustomScrollView(
        slivers: [
          // Hero Image
          SliverAppBar(
            expandedHeight: AppSpacing.heroImageHeight,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primary,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
              ),
              GestureDetector(
                onTap: () {
                  ref
                      .read(destinationsProvider.notifier)
                      .toggleBookmark(destination.id);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(destination.isBookmarked
                          ? 'Dihapus dari bookmark'
                          : 'Ditambahkan ke bookmark'),
                      backgroundColor: AppColors.textPrimary,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    destination.isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: destination.isBookmarked
                        ? AppColors.starFilled
                        : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(
                    imageUrl: PlaceholderImages.hero(destination.id),
                    fit: BoxFit.cover,
                  ),
                  Container(decoration: const BoxDecoration(gradient: AppColors.heroGradient)),
                    Positioned(
                      bottom: 16, left: 16,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PanoramaViewPage(
                                title: destination.name,
                                imagePath: 'assets/images/placeholder_360.png',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: AppSpacing.borderRadiusFull,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.view_in_ar_rounded, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text('360° View', style: AppTypography.labelSmall.copyWith(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Info — staggered
                    _StaggerSection(
                      index: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(destination.name, style: AppTypography.displaySmall),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textHint),
                              const SizedBox(width: 2),
                              Expanded(child: Text(destination.address, style: AppTypography.bodySmall)),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 18, color: AppColors.starFilled),
                              const SizedBox(width: 4),
                              Text(destination.rating.toStringAsFixed(1), style: AppTypography.titleMedium),
                              Text(' (${destination.reviewCount} ulasan)', style: AppTypography.caption),
                              const Spacer(),
                              const Icon(Icons.near_me_rounded, size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(DistanceCalculator.formatDistance(dist),
                                  style: AppTypography.labelMedium.copyWith(color: AppColors.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Action Buttons
                    _StaggerSection(
                      index: 1,
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _openGoogleMapsNavigation(),
                              icon: const Icon(Icons.navigation_rounded, size: 18),
                              label: const Text(AppStrings.petaJalur),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showAddScheduleDialog(context),
                              icon: const Icon(Icons.calendar_month_rounded, size: 18),
                              label: const Text(AppStrings.tambahKeJadwal),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Sensor Data (if available)
                    if (sensor != null) ...[
                      _StaggerSection(
                        index: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${AppStrings.dataRealtime} ⚡', style: AppTypography.headlineSmall),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(child: SensorDataCard(label: AppStrings.suhu, value: sensor.suhu.toStringAsFixed(1), unit: AppStrings.celsius, icon: Icons.thermostat_rounded, iconColor: AppColors.accent, isDanger: MockIoTService.isDanger(sensor.suhu))),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(child: SensorDataCard(label: AppStrings.kelembapan, value: sensor.kelembapan.toStringAsFixed(0), unit: AppStrings.persen, icon: Icons.water_drop_rounded, iconColor: AppColors.info)),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(child: SensorDataCard(label: AppStrings.tekanan, value: sensor.tekanan.toStringAsFixed(0), unit: AppStrings.hPa, icon: Icons.speed_rounded, iconColor: AppColors.warning)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (snapshot != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        _StaggerSection(
                          index: 3,
                          child: Container(
                            width: double.infinity, height: 140,
                            decoration: BoxDecoration(
                              borderRadius: AppSpacing.borderRadiusCard,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                AppNetworkImage(
                                  imageUrl: PlaceholderImages.camera(destination.hardwareId ?? destination.id),
                                  fit: BoxFit.cover,
                                ),
                                Container(decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.5)]),
                                )),
                                Positioned(
                                  bottom: 12, left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: AppSpacing.borderRadiusFull),
                                    child: Text('Keramaian: ${snapshot.crowdLevel}', style: AppTypography.labelSmall.copyWith(color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xxl),
                    ],

                    // Description
                    _StaggerSection(
                      index: sensor != null ? 4 : 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.tentangDestinasi, style: AppTypography.headlineSmall),
                          const SizedBox(height: AppSpacing.md),
                          Text(destination.description, style: AppTypography.bodyMedium.copyWith(height: 1.7)),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Navigation Route Map Section ──
                    _StaggerSection(
                      index: sensor != null ? 5 : 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${AppStrings.ruteNavigasi} 🗺️', style: AppTypography.headlineSmall),
                          const SizedBox(height: AppSpacing.md),
                          GestureDetector(
                            onTap: _openGoogleMapsNavigation,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: AppSpacing.borderRadiusCard,
                                boxShadow: AppColors.elevatedShadow,
                                border: AppColors.cardBorder,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: [
                                  // Mini Map Preview
                                  Container(
                                    height: 160,
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFFE3F2FD),
                                          Color(0xFFBBDEFB),
                                          Color(0xFF90CAF9),
                                        ],
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        // Grid lines (map feel)
                                        ...List.generate(5, (i) => Positioned(
                                          top: (i + 1) * 32.0,
                                          left: 0, right: 0,
                                          child: Container(height: 0.5, color: Colors.white.withOpacity(0.4)),
                                        )),
                                        ...List.generate(5, (i) => Positioned(
                                          left: (i + 1) * 70.0,
                                          top: 0, bottom: 0,
                                          child: Container(width: 0.5, color: Colors.white.withOpacity(0.4)),
                                        )),
                                        // Road-like path
                                        Positioned.fill(
                                          child: CustomPaint(
                                            painter: _RoutePathPainter(),
                                          ),
                                        ),
                                        // Center Pin
                                        Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppColors.primary.withOpacity(0.4),
                                                      blurRadius: 12,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                                child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 22),
                                              ),
                                              const SizedBox(height: 4),
                                              Container(
                                                width: 6, height: 6,
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary.withOpacity(0.3),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Coordinates badge
                                        Positioned(
                                          top: 10, left: 10,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.85),
                                              borderRadius: AppSpacing.borderRadiusFull,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.08),
                                                  blurRadius: 8,
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.my_location_rounded, size: 12, color: AppColors.primary),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${destination.latitude.toStringAsFixed(4)}, ${destination.longitude.toStringAsFixed(4)}',
                                                  style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary, fontSize: 10),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Tap hint badge
                                        Positioned(
                                          bottom: 10, right: 10,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withOpacity(0.9),
                                              borderRadius: AppSpacing.borderRadiusFull,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.open_in_new_rounded, size: 12, color: Colors.white),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Ketuk untuk navigasi',
                                                  style: AppTypography.labelSmall.copyWith(color: Colors.white, fontSize: 10),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Bottom Bar — Address + Action
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
                                    decoration: const BoxDecoration(
                                      color: AppColors.cardBackground,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(destination.name, style: AppTypography.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                                              const SizedBox(height: 2),
                                              Text(destination.address, style: AppTypography.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          decoration: BoxDecoration(
                                            gradient: AppColors.primaryGradient,
                                            borderRadius: AppSpacing.borderRadiusFull,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primary.withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.directions_rounded, color: Colors.white, size: 16),
                                              const SizedBox(width: 6),
                                              Text(
                                                AppStrings.bukaGoogleMaps,
                                                style: AppTypography.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Facilities
                    if (destination.facilities.isNotEmpty) ...[
                      _StaggerSection(
                        index: sensor != null ? 6 : 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppStrings.fasilitas, style: AppTypography.headlineSmall),
                            const SizedBox(height: AppSpacing.md),
                            Wrap(
                              spacing: AppSpacing.sm, runSpacing: AppSpacing.sm,
                              children: destination.facilities.asMap().entries.map((entry) {
                                return TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: Duration(milliseconds: 300 + (entry.key * 50)),
                                  curve: Curves.easeOutCubic,
                                  builder: (_, v, child) => Transform.scale(
                                    scale: 0.8 + 0.2 * v,
                                    child: Opacity(opacity: v, child: child),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: AppSpacing.borderRadiusFull),
                                    child: Text(entry.value, style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],

                    // Operating Hours
                    if (destination.operatingHours.isNotEmpty) ...[
                      _StaggerSection(
                        index: sensor != null ? 7 : 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppStrings.jamOperasional, style: AppTypography.headlineSmall),
                            const SizedBox(height: AppSpacing.md),
                            Container(
                              padding: AppSpacing.paddingCard,
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground, borderRadius: AppSpacing.borderRadiusCard, boxShadow: AppColors.cardShadow,
        border: AppColors.cardBorder,
                              ),
                              child: Column(
                                children: destination.operatingHours.entries.map((e) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(e.key, style: AppTypography.bodyMedium),
                                      Text(e.value, style: AppTypography.labelMedium.copyWith(
                                        color: e.value == 'Tutup' ? AppColors.error : AppColors.success,
                                      )),
                                    ],
                                  ),
                                )).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],

                    // Community Reviews
                    _StaggerSection(
                      index: sensor != null ? 8 : 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${AppStrings.ulasan} 💬',
                                  style: AppTypography.headlineSmall),
                              OutlinedButton.icon(
                                onPressed: () => _showWriteReviewDialog(context),
                                icon: const Icon(Icons.rate_review_rounded, size: 16),
                                label: const Text('Tulis Ulasan'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                                  foregroundColor: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          if (reviews.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: AppSpacing.borderRadiusCard,
                                border: AppColors.cardBorder,
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.rate_review_outlined,
                                      size: 32,
                                      color: AppColors.textHint.withOpacity(0.5)),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Belum ada ulasan terverifikasi.',
                                    style: AppTypography.bodySmall,
                                  ),
                                  Text(
                                    'Jadilah yang pertama menulis ulasan!',
                                    style: AppTypography.caption,
                                  ),
                                ],
                              ),
                            )
                          else
                            SizedBox(
                              height: 180,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: reviews.length,
                                itemBuilder: (_, i) {
                                  final r = reviews[i];
                                  return TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: Duration(
                                        milliseconds: 400 + (i * 100)),
                                    curve: Curves.easeOutCubic,
                                    builder: (_, v, child) =>
                                        Transform.translate(
                                      offset: Offset(30 * (1 - v), 0),
                                      child: Opacity(opacity: v, child: child),
                                    ),
                                    child: CommunityReviewCard(
                                      userName: r.userName,
                                      comment: r.comment,
                                      rating: r.rating,
                                      date: r.timestamp,
                                      isOfficial: r.isOfficial,
                                      onReport: () => _showReportDialog(r),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.bottomSafeArea),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  /// Opens Google Maps navigation to the destination coordinates.
  Future<void> _openGoogleMapsNavigation() async {
    final lat = destination.latitude;
    final lng = destination.longitude;
    final label = Uri.encodeComponent(destination.name);

    // Try Google Maps app first, then fallback to web
    final googleMapsUrl = Uri.parse(
      'google.navigation:q=$lat,$lng&mode=d',
    );
    final googleMapsWebUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=$label&travelmode=driving',
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl);
      } else {
        await launchUrl(googleMapsWebUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka Google Maps'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAddScheduleDialog(BuildContext context) {
    final titleCtrl = TextEditingController(text: destination.name);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          top: AppSpacing.xl, left: AppSpacing.xl, right: AppSpacing.xl,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLarge)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: AppSpacing.borderRadiusFull))),
            const SizedBox(height: AppSpacing.lg),
            Text(AppStrings.tambahKeJadwal, style: AppTypography.headlineMedium),
            const SizedBox(height: AppSpacing.xl),
            Text(AppStrings.judulJadwal, style: AppTypography.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            TextField(controller: titleCtrl, style: AppTypography.bodyMedium),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text(AppStrings.batal))),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('"${destination.name}" ditambahkan ke jadwal'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ));
                  },
                  child: const Text(AppStrings.konfirmasi),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
  void _showWriteReviewDialog(BuildContext context) {
    final commentCtrl = TextEditingController();
    double rating = 4.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Container(
          padding: EdgeInsets.only(
            top: AppSpacing.xl,
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusLarge)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: AppSpacing.borderRadiusFull,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Tulis Ulasan ✍️', style: AppTypography.headlineMedium),
              const SizedBox(height: AppSpacing.xl),

              // Rating Selection
              Text('Rating Anda', style: AppTypography.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: List.generate(5, (index) {
                  final score = index + 1.0;
                  final isFilled = rating >= score;
                  return IconButton(
                    icon: Icon(
                      isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                      color: isFilled ? AppColors.starFilled : AppColors.starEmpty,
                      size: 32,
                    ),
                    onPressed: () {
                      setDialogState(() => rating = score);
                    },
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.base),

              // Comment Field
              Text('Komentar', style: AppTypography.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: commentCtrl,
                maxLines: 3,
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Tulis komentar/ulasan Anda tentang tempat ini...',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: AppSpacing.borderRadiusMedium,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final comment = commentCtrl.text.trim();
                        if (comment.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Komentar tidak boleh kosong'),
                              backgroundColor: AppColors.warning,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        final newReview = Review(
                          id: 'r-${DateTime.now().millisecondsSinceEpoch}',
                          userId: 'user',
                          userName: 'Andi Mappanyukki', // Mock logged in user name
                          destinationId: destination.id,
                          comment: comment,
                          rating: rating,
                          timestamp: DateTime.now(),
                          status: ReviewStatus.pending, // Goes to admin moderation first
                        );

                        ref.read(reviewsProvider.notifier).addReview(newReview);
                        Navigator.pop(ctx);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Ulasan berhasil diajukan! Menunggu persetujuan admin.'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text('Kirim'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDialog(Review r) {
    final reasons = [
      'Konten mengandung unsur SARA / Kebencian',
      'Konten kasar, tidak sopan, atau melecehkan',
      'Spam, promosi terselubung, atau penipuan',
      'Konten tidak relevan dengan destinasi',
      'Lainnya',
    ];
    String selectedReason = reasons.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Container(
          padding: EdgeInsets.only(
            top: AppSpacing.xl,
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusLarge)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: AppSpacing.borderRadiusFull,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: AppSpacing.borderRadiusMedium,
                    ),
                    child: const Icon(Icons.flag_rounded, color: AppColors.error, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text('Laporkan Ulasan 🚩', style: AppTypography.headlineMedium),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Mengapa Anda melaporkan ulasan dari "${r.userName}"?',
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...reasons.map((reason) {
                return RadioListTile<String>(
                  title: Text(reason, style: AppTypography.bodyMedium),
                  value: reason,
                  groupValue: selectedReason,
                  activeColor: AppColors.error,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedReason = val);
                    }
                  },
                );
              }),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        final newReport = ReportItem(
                          id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
                          reporterName: 'Pengguna Aplikasi',
                          targetReviewId: r.id,
                          reason: selectedReason,
                          timestamp: DateTime.now(),
                        );

                        ref.read(reportsProvider.notifier).addReport(newReport);
                        Navigator.pop(ctx);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Laporan berhasil dikirim dan akan ditinjau moderator.'),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text('Kirim Laporan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Staggered section entrance widget for detail page content.
class _StaggerSection extends StatelessWidget {
  final Widget child;
  final int index;

  const _StaggerSection({required this.child, this.index = 0});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 450 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (_, v, ch) => Transform.translate(
        offset: Offset(0, 20 * (1 - v)),
        child: Opacity(opacity: v, child: ch),
      ),
      child: child,
    );
  }
}

/// Custom painter for route path decoration on the mini-map preview.
class _RoutePathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.35)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw a curved "route" path from bottom-left to center
    final path = Path()
      ..moveTo(0, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.25, size.height * 0.6,
        size.width * 0.4, size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.55, size.height * 0.4,
        size.width * 0.5, size.height * 0.5,
      );

    canvas.drawPath(path, paint);

    // Draw a dashed "route" path from center to top-right
    final futurePaint = Paint()
      ..color = AppColors.primary.withOpacity(0.18)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final futurePath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.65, size.height * 0.35,
        size.width * 0.85, size.height * 0.25,
      )
      ..lineTo(size.width, size.height * 0.2);

    // Simple dash simulation
    const dashLength = 6.0;
    const gapLength = 4.0;
    final metrics = futurePath.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0.0, metric.length);
        final extractedPath = metric.extractPath(distance, end);
        canvas.drawPath(extractedPath, futurePaint);
        distance += dashLength + gapLength;
      }
    }

    // Draw small dots along the route for visual interest
    final dotPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.68), 3, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.55), 3, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.32), 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 360 Degree Immersive Viewer Page
class PanoramaViewPage extends StatelessWidget {
  final String title;
  final String imagePath;

  const PanoramaViewPage({super.key, required this.title, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('360° $title'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: PanoramaViewer(
        child: Image.asset(imagePath),
      ),
    );
  }
}

