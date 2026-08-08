import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/distance_calculator.dart';
import '../../../../core/utils/page_transitions.dart';
import '../../../../core/utils/placeholder_images.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import '../../../../core/widgets/destination_card.dart';
import '../../data/mock_destination_data.dart';
import '../../domain/entities/destination.dart';
import 'destination_detail_page.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/destination_provider.dart';

/// Discovery Page — Destination browsing with search, categories & recommendations.
class DiscoveryPage extends ConsumerStatefulWidget {
  const DiscoveryPage({super.key});

  @override
  ConsumerState<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends ConsumerState<DiscoveryPage>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  String _selectedCategory = 'all';
  late List<Destination> _destinations;

  // Carousel
  late final PageController _carouselController;
  int _currentCarouselPage = 0;
  Timer? _autoScrollTimer;

  static const _categories = [
    ('all', 'Semua', Icons.grid_view_rounded),
    ('pantai', '🏖️ Pantai', Icons.beach_access_rounded),
    ('gunung', '⛰️ Gunung', Icons.terrain_rounded),
    ('kafe', '☕ Kafe', Icons.coffee_rounded),
    ('restoran', '🍽️ Restoran', Icons.restaurant_rounded),
  ];

  // Category icon map for the nearby grid
  static const _categoryIcons = {
    'pantai': Icons.beach_access_rounded,
    'gunung': Icons.terrain_rounded,
    'kafe': Icons.coffee_rounded,
    'restoran': Icons.restaurant_rounded,
  };

  static const _categoryColors = {
    'pantai': AppColors.chipBeach,
    'gunung': AppColors.chipMountain,
    'kafe': AppColors.chipCafe,
    'restoran': AppColors.chipRestaurant,
  };

  // Entrance animation
  late final AnimationController _entranceCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _carouselController = PageController(viewportFraction: 0.88);
    _startAutoScroll();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic));
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _carouselController.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _recommended.isEmpty) return;
      final next = (_currentCarouselPage + 1) % _recommended.length;
      _carouselController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  List<Destination> get _filtered {
    var list = _destinations;
    if (_selectedCategory != 'all') {
      list = list.where((d) => d.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((d) =>
              d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              d.address.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return list;
  }

  List<Destination> get _recommended =>
      _destinations.where((d) => d.rating >= 4.5).toList();

  /// Nearest destinations sorted by Haversine, capped between 2–4.
  List<Destination> get _nearest {
    final sorted = List<Destination>.from(_destinations)
      ..sort((a, b) {
        final distA = DistanceCalculator.haversine(
            LocationService.defaultLat, LocationService.defaultLng,
            a.latitude, a.longitude);
        final distB = DistanceCalculator.haversine(
            LocationService.defaultLat, LocationService.defaultLng,
            b.latitude, b.longitude);
        return distA.compareTo(distB);
      });
    // Min 2, Max 4
    final count = sorted.length.clamp(2, 4);
    return sorted.take(count).toList();
  }

  double _distanceKm(Destination d) {
    return DistanceCalculator.haversine(
        LocationService.defaultLat, LocationService.defaultLng,
        d.latitude, d.longitude);
  }

  String _distanceFrom(Destination d) {
    return DistanceCalculator.formatDistance(_distanceKm(d));
  }

  @override
  Widget build(BuildContext context) {
    _destinations = ref.watch(destinationsProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: AppSpacing.bottomSafeArea),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const SizedBox(height: AppSpacing.base),
              // Header
              Padding(
                padding: AppSpacing.paddingSection,
                child: Text('Jelajahi Destinasi 🗺️',
                    style: AppTypography.displayMedium),
              ),
              const SizedBox(height: AppSpacing.base),
              // Search
              Padding(
                padding: AppSpacing.paddingSection,
                child: CustomSearchBar(
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Category Filter
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: _categories.length,
                  itemBuilder: (_, i) {
                    final (key, label, _) = _categories[i];
                    final isActive = _selectedCategory == key;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: AppSpacing.sm),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.base,
                            vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.cardBackground,
                          borderRadius: AppSpacing.borderRadiusFull,
                          boxShadow:
                              isActive ? null : AppColors.cardShadow,
                        ),
                        child: Center(
                          child: Text(label,
                              style: AppTypography.labelMedium.copyWith(
                                color: isActive
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              )),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ══════════════════════════════════════════════
              // SECTION 1: Rekomendasi Tempat (Carousel)
              // ══════════════════════════════════════════════
              if (_searchQuery.isEmpty && _selectedCategory == 'all') ...[
                Padding(
                  padding: AppSpacing.paddingSection,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: AppSpacing.borderRadiusSmall,
                            ),
                            child: const Icon(Icons.auto_awesome_rounded,
                                color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text('${AppStrings.rekomendasi} ⭐',
                              style: AppTypography.headlineSmall),
                        ],
                      ),
                      TextButton(
                          onPressed: () {},
                          child: Text(AppStrings.selengkapnya,
                              style: AppTypography.labelMedium
                                  .copyWith(color: AppColors.primary))),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Carousel PageView
                SizedBox(
                  height: 220,
                  child: PageView.builder(
                    controller: _carouselController,
                    onPageChanged: (i) =>
                        setState(() => _currentCarouselPage = i),
                    itemCount: _recommended.length,
                    itemBuilder: (_, i) {
                      final d = _recommended[i];
                      return _buildCarouselCard(d);
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Dot indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _recommended.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _currentCarouselPage == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentCarouselPage == i
                            ? AppColors.primary
                            : AppColors.divider,
                        borderRadius: AppSpacing.borderRadiusFull,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // ══════════════════════════════════════════════
                // SECTION 2: Destinasi Terdekat (Grid — max 4)
                // ══════════════════════════════════════════════
                Padding(
                  padding: AppSpacing.paddingSection,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.15),
                              borderRadius: AppSpacing.borderRadiusSmall,
                            ),
                            child: const Icon(Icons.near_me_rounded,
                                color: AppColors.success, size: 16),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text('${AppStrings.terdekat} 📍',
                              style: AppTypography.headlineSmall),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: AppSpacing.borderRadiusFull,
                        ),
                        child: Text(
                          '${_nearest.length} tempat',
                          style: AppTypography.labelSmall
                              .copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // 2-column grid
                Padding(
                  padding: AppSpacing.paddingSection,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: _nearest.length,
                    itemBuilder: (_, i) =>
                        _buildNearbyCard(_nearest[i], i),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],

              // ══════════════════════════════════════════════
              // SECTION 3: All / Filtered Destinations
              // ══════════════════════════════════════════════
              Padding(
                padding: AppSpacing.paddingSection,
                child: Row(
                  children: [
                    Text(
                        _searchQuery.isNotEmpty
                            ? 'Hasil Pencarian 🔍'
                            : 'Semua Destinasi 🌏',
                        style: AppTypography.headlineSmall),
                    const Spacer(),
                    Text('${_filtered.length} tempat',
                        style: AppTypography.caption),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ..._filtered.map((d) => Padding(
                    padding: AppSpacing.paddingSection,
                    child: DestinationCard(
                      imageUrl: PlaceholderImages.destination(d.id),
                      name: d.name,
                      location: d.address,
                      rating: d.rating,
                      distance: _distanceFrom(d),
                      isHorizontal: false,
                      isBookmarked: d.isBookmarked,
                      onTap: () => _navigateToDetail(d),
                    ),
                  )),
              if (_filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 48,
                            color: AppColors.textHint.withOpacity(0.3)),
                        const SizedBox(height: AppSpacing.md),
                        Text('Tidak ditemukan',
                            style: AppTypography.bodyMedium
                                .copyWith(color: AppColors.textHint)),
                      ],
                    ),
                  ),
                ),
            ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }

  // ─── Carousel Card ──────────────────────────────────────
  Widget _buildCarouselCard(Destination d) {
    final km = _distanceKm(d);
    return GestureDetector(
      onTap: () => _navigateToDetail(d),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: AppSpacing.borderRadiusCard,
          boxShadow: AppColors.elevatedShadow,
        ),
        child: ClipRRect(
          borderRadius: AppSpacing.borderRadiusCard,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background photo
              AppNetworkImage(
                imageUrl: PlaceholderImages.destination(d.id, w: 600, h: 400),
              ),
              // Dark overlay for readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.55),
                    ],
                  ),
                ),
              ),
              // Pattern overlay
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  _categoryIcons[d.category] ?? Icons.place_rounded,
                  size: 120,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              Positioned(
                left: -10,
                bottom: -10,
                child: Icon(
                  Icons.explore_rounded,
                  size: 80,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
              // Dark gradient at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 120,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
              ),
              // Top badges
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: AppSpacing.borderRadiusFull,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.starFilled, size: 14),
                      const SizedBox(width: 3),
                      Text(d.rating.toStringAsFixed(1),
                          style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 1),
                  ),
                  child: Icon(
                    d.isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    size: 18,
                    color: d.isBookmarked
                        ? AppColors.starFilled
                        : Colors.white,
                  ),
                ),
              ),
              // Bottom info
              Positioned(
                bottom: 14,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.name,
                        style: AppTypography.headlineMedium
                            .copyWith(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 13, color: Colors.white70),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(d.address,
                              style: AppTypography.caption
                                  .copyWith(color: Colors.white70),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: AppSpacing.borderRadiusFull,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.near_me_rounded,
                                  size: 11, color: Colors.white),
                              const SizedBox(width: 3),
                              Text(
                                DistanceCalculator.formatDistance(km),
                                style: AppTypography.labelSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Nearby Grid Card ──────────────────────────────────
  Widget _buildNearbyCard(Destination d, int index) {
    final km = _distanceKm(d);
    final catColor = _categoryColors[d.category] ?? AppColors.primary;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
      onTap: () => _navigateToDetail(d),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: AppSpacing.borderRadiusCard,
          boxShadow: AppColors.cardShadow,
        border: AppColors.cardBorder,
        ),
        child: ClipRRect(
          borderRadius: AppSpacing.borderRadiusCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image area with category gradient
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            catColor.withOpacity(0.8),
                            catColor.withOpacity(0.5),
                          ],
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AppNetworkImage(
                            imageUrl: PlaceholderImages.destination(d.id, w: 300, h: 300),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  catColor.withOpacity(0.15),
                                  catColor.withOpacity(0.4),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Distance badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppSpacing.borderRadiusFull,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.near_me_rounded,
                                size: 10, color: catColor),
                            const SizedBox(width: 3),
                            Text(
                              DistanceCalculator.formatDistance(km),
                              style: AppTypography.labelSmall.copyWith(
                                  color: catColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Rank number
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: AppTypography.labelSmall.copyWith(
                                color: catColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 11),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Info
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.name,
                          style: AppTypography.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 11, color: AppColors.textHint),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              d.address.split(',').first,
                              style: AppTypography.caption
                                  .copyWith(fontSize: 10),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 13, color: AppColors.starFilled),
                          const SizedBox(width: 2),
                          Text(d.rating.toStringAsFixed(1),
                              style: AppTypography.labelSmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11)),
                          const Spacer(),
                          const Icon(Icons.directions_car_rounded,
                              size: 11, color: AppColors.textHint),
                          const SizedBox(width: 2),
                          Text(
                            DistanceCalculator.estimateDriveTime(km),
                            style: AppTypography.caption
                                .copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  void _navigateToDetail(Destination d) {
    Navigator.push(
      context,
      PageTransitions.slideUp(page: DestinationDetailPage(destination: d)),
    );
  }
}
