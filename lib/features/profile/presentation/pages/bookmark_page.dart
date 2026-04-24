import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/distance_calculator.dart';
import '../../../../core/utils/page_transitions.dart';
import '../../../../core/utils/placeholder_images.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../destination/data/mock_destination_data.dart';
import '../../../destination/domain/entities/destination.dart';
import '../../../destination/presentation/pages/destination_detail_page.dart';

/// Bookmark Page — Saved/bookmarked destinations list.
/// PRD Section: "Profil → Bookmark"
class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  late List<Destination> _bookmarked;

  @override
  void initState() {
    super.initState();
    _bookmarked = MockDestinationData.destinations
        .where((d) => d.isBookmarked)
        .toList();
  }

  /// Remove bookmark and show undo snackbar.
  void _removeBookmark(int index) {
    final removed = _bookmarked[index];
    setState(() => _bookmarked.removeAt(index));

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${removed.name} dihapus dari bookmark'),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMedium),
        margin: const EdgeInsets.all(AppSpacing.lg),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppColors.primaryLight,
          onPressed: () {
            setState(() => _bookmarked.insert(index, removed));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: CustomScrollView(
          slivers: [
            // ─── App Bar ────────────────────────────────────
            SliverAppBar(
              expandedHeight: 140,
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
                      Text('Bookmark 🔖',
                          style: AppTypography.displaySmall
                              .copyWith(color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(
                        '${_bookmarked.length} destinasi tersimpan',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Bookmark List or Empty State ───────────────
            if (_bookmarked.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildBookmarkCard(_bookmarked[index], index),
                    childCount: _bookmarked.length,
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
            Icon(Icons.bookmark_border_rounded,
                size: 64, color: AppColors.textHint.withOpacity(0.3)),
            const SizedBox(height: AppSpacing.md),
            Text('Belum ada bookmark',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textHint)),
            const SizedBox(height: AppSpacing.sm),
            Text('Simpan destinasi favoritmu! ⭐',
                style: AppTypography.caption),
          ],
        ),
      ),
    );
  }

  // ─── Bookmark Card ────────────────────────────────────────
  Widget _buildBookmarkCard(Destination dest, int index) {
    final km = DistanceCalculator.haversine(
        LocationService.currentLat, LocationService.currentLng,
        dest.latitude, dest.longitude);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Transform.translate(
        offset: Offset(0, 20 * (1 - v)),
        child: Opacity(opacity: v, child: child),
      ),
      child: Dismissible(
        key: ValueKey(dest.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => _removeBookmark(index),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.xl),
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.12),
            borderRadius: AppSpacing.borderRadiusCard,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error, size: 24),
              const SizedBox(height: 4),
              Text('Hapus',
                  style: AppTypography.labelSmall
                      .copyWith(color: AppColors.error)),
            ],
          ),
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
              child: Row(
                children: [
                  // Image
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: AppNetworkImage(
                      imageUrl: PlaceholderImages.destination(
                          dest.id, w: 300, h: 300),
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Info
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dest.name,
                              style: AppTypography.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
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
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 14, color: AppColors.starFilled),
                              const SizedBox(width: 2),
                              Text(
                                dest.rating.toStringAsFixed(1),
                                style: AppTypography.labelSmall.copyWith(
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                ' (${dest.reviewCount})',
                                style: AppTypography.caption
                                    .copyWith(fontSize: 10),
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
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Bookmark icon + swipe hint
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bookmark_rounded,
                            size: 22, color: AppColors.starFilled),
                        const SizedBox(height: 4),
                        Icon(Icons.chevron_right_rounded,
                            size: 16, color: AppColors.textHint.withOpacity(0.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
