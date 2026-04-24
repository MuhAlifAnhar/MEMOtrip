import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/distance_calculator.dart';
import '../../../../core/utils/page_transitions.dart';
import '../../../../core/utils/placeholder_images.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../data/mock_visit_data.dart';
import '../../../destination/presentation/pages/destination_detail_page.dart';

/// Visit History Page — List of previously visited destinations.
/// PRD Section: "Profil → Riwayat Kunjungan"
class VisitHistoryPage extends StatefulWidget {
  const VisitHistoryPage({super.key});

  @override
  State<VisitHistoryPage> createState() => _VisitHistoryPageState();
}

class _VisitHistoryPageState extends State<VisitHistoryPage> {
  String _selectedFilter = 'all';
  String _sortBy = 'terbaru';

  // Data source — single source of truth for visit history
  List<VisitRecord> get _visits => MockVisitData.visits;
  List<ResolvedVisit> get _resolvedVisits => MockVisitData.resolvedVisits;

  List<ResolvedVisit> get _filtered {
    var list = List<ResolvedVisit>.from(_resolvedVisits);

    // Filter by category
    if (_selectedFilter != 'all') {
      list = list.where((r) => r.destination.category == _selectedFilter).toList();
    }

    // Sort
    if (_sortBy == 'terbaru') {
      list.sort((a, b) => b.visit.visitDate.compareTo(a.visit.visitDate));
    } else if (_sortBy == 'rating') {
      list.sort((a, b) => (b.visit.rating ?? 0).compareTo(a.visit.rating ?? 0));
    } else if (_sortBy == 'terdekat') {
      list.sort((a, b) {
        final distA = DistanceCalculator.haversine(
            LocationService.currentLat, LocationService.currentLng,
            a.destination.latitude, a.destination.longitude);
        final distB = DistanceCalculator.haversine(
            LocationService.currentLat, LocationService.currentLng,
            b.destination.latitude, b.destination.longitude);
        return distA.compareTo(distB);
      });
    }

    return list;
  }

  // Category filter options
  static const _categories = [
    ('all', 'Semua', Icons.grid_view_rounded),
    ('pantai', '🏖️ Pantai', Icons.beach_access_rounded),
    ('gunung', '🏛️ Budaya', Icons.account_balance_rounded),
    ('kafe', '☕ Kafe', Icons.coffee_rounded),
    ('restoran', '🍽️ Kuliner', Icons.restaurant_rounded),
  ];

  // Unique destinations visited count
  int get _uniqueDestinations => MockVisitData.uniqueDestinations;

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: CustomScrollView(
          slivers: [
            // ─── App Bar ────────────────────────────────────
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              stretch: true,
              backgroundColor: AppColors.primary,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Riwayat Kunjungan 📍',
                          style: AppTypography.displaySmall
                              .copyWith(color: Colors.white)),
                      const SizedBox(height: 8),
                      // Stats row
                      Row(
                        children: [
                          _headerStat(
                              '${_visits.length}', 'Total', Icons.check_circle_outline_rounded),
                          const SizedBox(width: 20),
                          _headerStat(
                              '$_uniqueDestinations', 'Destinasi', Icons.place_rounded),
                          const SizedBox(width: 20),
                          _headerStat(
                              _avgRating, 'Rating', Icons.star_rounded),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Category Filter ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories
                        .map((c) => _filterChip(c.$1, c.$2))
                        .toList(),
                  ),
                ),
              ),
            ),

            // ─── Sort & Count Bar ───────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    Text(
                      '${filtered.length} kunjungan',
                      style: AppTypography.labelMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    _sortButton(),
                  ],
                ),
              ),
            ),

            // ─── Visit List or Empty State ──────────────────
            if (filtered.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildVisitCard(filtered[index], index),
                    childCount: filtered.length,
                  ),
                ),
              ),

            // Bottom spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.bottomSafeArea),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header Stat ──────────────────────────────────────────
  String get _avgRating => MockVisitData.averageRating;

  Widget _headerStat(String value, String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 4),
        Text(
          '$value $label',
          style: AppTypography.labelSmall.copyWith(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ─── Filter Chip ──────────────────────────────────────────
  Widget _filterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: AppSpacing.borderRadiusFull,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2)),
                ]
              : AppColors.cardShadow,
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ─── Sort Button ──────────────────────────────────────────
  Widget _sortButton() {
    return PopupMenuButton<String>(
      onSelected: (val) => setState(() => _sortBy = val),
      itemBuilder: (_) => [
        _sortItem('terbaru', 'Terbaru', Icons.access_time_rounded),
        _sortItem('rating', 'Rating Tertinggi', Icons.star_rounded),
        _sortItem('terdekat', 'Jarak Terdekat', Icons.near_me_rounded),
      ],
      shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: AppSpacing.borderRadiusFull,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort_rounded, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              _sortBy == 'terbaru'
                  ? 'Terbaru'
                  : _sortBy == 'rating'
                      ? 'Rating'
                      : 'Terdekat',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _sortItem(String value, String label, IconData icon) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon,
              size: 16,
              color: _sortBy == value ? AppColors.primary : AppColors.textHint),
          const SizedBox(width: 8),
          Text(label,
              style: AppTypography.bodyMedium.copyWith(
                color: _sortBy == value
                    ? AppColors.primary
                    : AppColors.textPrimary,
                fontWeight:
                    _sortBy == value ? FontWeight.w600 : FontWeight.w400,
              )),
          if (_sortBy == value) ...[
            const Spacer(),
            const Icon(Icons.check_rounded,
                size: 16, color: AppColors.primary),
          ],
        ],
      ),
    );
  }

  // ─── Empty State ──────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutBack,
        builder: (_, v, child) => Transform.scale(
          scale: 0.8 + 0.2 * v,
          child: Opacity(opacity: v, child: child),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore_off_rounded,
                size: 64, color: AppColors.textHint.withOpacity(0.3)),
            const SizedBox(height: AppSpacing.md),
            Text('Belum ada kunjungan di kategori ini',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textHint)),
            const SizedBox(height: AppSpacing.sm),
            Text('Mulai jelajahi destinasi! 🗺️',
                style: AppTypography.caption),
          ],
        ),
      ),
    );
  }

  // ─── Visit Card ───────────────────────────────────────────
  Widget _buildVisitCard(ResolvedVisit resolved, int index) {
    final dest = resolved.destination;
    final visit = resolved.visit;
    final km = DistanceCalculator.haversine(
        LocationService.currentLat, LocationService.currentLng,
        dest.latitude, dest.longitude);
    final isRepeatVisit =
        _visits.where((v) => v.destinationId == dest.id).length > 1;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 60)),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Transform.translate(
        offset: Offset(0, 20 * (1 - v)),
        child: Opacity(opacity: v, child: child),
      ),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          PageTransitions.slideUp(
              page: DestinationDetailPage(destination: dest)),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: AppSpacing.borderRadiusCard,
            boxShadow: AppColors.cardShadow,
            border: AppColors.cardBorder,
          ),
          child: ClipRRect(
            borderRadius: AppSpacing.borderRadiusCard,
            child: Column(
              children: [
                // Image section
                SizedBox(
                  height: 140,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppNetworkImage(
                        imageUrl: PlaceholderImages.destination(
                            dest.id, w: 600, h: 300),
                        fit: BoxFit.cover,
                      ),
                      // Dark gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.05),
                              Colors.black.withOpacity(0.4),
                            ],
                          ),
                        ),
                      ),
                      // Category badge
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _categoryColor(dest.category).withOpacity(0.85),
                            borderRadius: AppSpacing.borderRadiusFull,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_categoryIcon(dest.category),
                                  size: 12, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                _categoryLabel(dest.category),
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Repeat visit badge
                      if (isRepeatVisit)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.starFilled.withOpacity(0.9),
                              borderRadius: AppSpacing.borderRadiusFull,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.replay_rounded,
                                    size: 11, color: Colors.white),
                                const SizedBox(width: 3),
                                Text(
                                  'Kunjungan Ulang',
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Date overlay
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: AppSpacing.borderRadiusFull,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today_rounded,
                                  size: 11, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                DateFormatter.relative(visit.visitDate),
                                style: AppTypography.caption.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Rating overlay
                      if (visit.rating != null)
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: AppSpacing.borderRadiusFull,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded,
                                    size: 13, color: AppColors.starFilled),
                                const SizedBox(width: 2),
                                Text(
                                  visit.rating!.toStringAsFixed(1),
                                  style: AppTypography.labelSmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Info section
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Destination name
                      Text(dest.name,
                          style: AppTypography.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      // Address
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 12, color: AppColors.textHint),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              dest.address,
                              style: AppTypography.caption.copyWith(fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      // Notes
                      if (visit.notes != null && visit.notes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface.withOpacity(0.5),
                            borderRadius: AppSpacing.borderRadiusMedium,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.notes_rounded,
                                  size: 14,
                                  color: AppColors.primary.withOpacity(0.7)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  visit.notes!,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      // Bottom info row
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded,
                              size: 12, color: AppColors.textHint),
                          const SizedBox(width: 3),
                          Text(
                            DateFormatter.fullDate(visit.visitDate),
                            style: AppTypography.caption.copyWith(fontSize: 10),
                          ),
                          const Spacer(),
                          const Icon(Icons.near_me_rounded,
                              size: 12, color: AppColors.primary),
                          const SizedBox(width: 3),
                          Text(
                            DistanceCalculator.formatDistance(km),
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.chevron_right_rounded,
                              size: 18, color: AppColors.textHint),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Category Helpers ─────────────────────────────────────
  Color _categoryColor(String cat) {
    switch (cat) {
      case 'pantai':
        return AppColors.chipBeach;
      case 'gunung':
        return AppColors.chipCulture;
      case 'kafe':
        return AppColors.chipCafe;
      case 'restoran':
        return AppColors.chipRestaurant;
      default:
        return AppColors.primary;
    }
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'pantai':
        return Icons.beach_access_rounded;
      case 'gunung':
        return Icons.account_balance_rounded;
      case 'kafe':
        return Icons.coffee_rounded;
      case 'restoran':
        return Icons.restaurant_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  String _categoryLabel(String cat) {
    switch (cat) {
      case 'pantai':
        return 'Pantai';
      case 'gunung':
        return 'Budaya';
      case 'kafe':
        return 'Kafe';
      case 'restoran':
        return 'Kuliner';
      default:
        return 'Lainnya';
    }
  }
}

