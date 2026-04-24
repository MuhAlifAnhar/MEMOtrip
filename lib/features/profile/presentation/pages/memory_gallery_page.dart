import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/placeholder_images.dart';
import '../../../../core/widgets/app_network_image.dart';

/// Memory Gallery — Photo grid from visit history.
/// PRD Section 2 (Profil/Memori): "Galeri foto perjalanan"
class MemoryGalleryPage extends StatefulWidget {
  const MemoryGalleryPage({super.key});

  @override
  State<MemoryGalleryPage> createState() => _MemoryGalleryPageState();
}

class _MemoryGalleryPageState extends State<MemoryGalleryPage> {
  String _selectedFilter = 'all';

  // Mock memory data
  final List<_MemoryItem> _memories = [
    _MemoryItem(
      id: 'm1',
      destinationName: 'Pantai Losari',
      category: 'pantai',
      date: DateTime.now().subtract(const Duration(days: 2)),
      caption: 'Sunset indah di Losari 🌅',
    ),
    _MemoryItem(
      id: 'm2',
      destinationName: 'CPI Makassar',
      category: 'pantai',
      date: DateTime.now().subtract(const Duration(days: 5)),
      caption: 'Weekend seru di CPI',
    ),
    _MemoryItem(
      id: 'm3',
      destinationName: 'Masjid 99 Kubah',
      category: 'gunung',
      date: DateTime.now().subtract(const Duration(days: 7)),
      caption: 'MasyaAllah, megah sekali 🕌',
    ),
    _MemoryItem(
      id: 'm4',
      destinationName: 'Fort Rotterdam',
      category: 'gunung',
      date: DateTime.now().subtract(const Duration(days: 10)),
      caption: 'Tur sejarah benteng',
    ),
    _MemoryItem(
      id: 'm5',
      destinationName: 'Pantai Akkarena',
      category: 'pantai',
      date: DateTime.now().subtract(const Duration(days: 14)),
      caption: 'Waterboom bareng keluarga 🏊',
    ),
    _MemoryItem(
      id: 'm6',
      destinationName: 'Kopi Jilid',
      category: 'kafe',
      date: DateTime.now().subtract(const Duration(days: 18)),
      caption: 'Kopi sore ☕',
    ),
    _MemoryItem(
      id: 'm7',
      destinationName: 'Pallubasa Serigala',
      category: 'restoran',
      date: DateTime.now().subtract(const Duration(days: 21)),
      caption: 'Pallubasa terenak di Makassar 🍲',
    ),
    _MemoryItem(
      id: 'm8',
      destinationName: 'Pantai Losari',
      category: 'pantai',
      date: DateTime.now().subtract(const Duration(days: 30)),
      caption: 'Pisang Epe malam hari',
    ),
    _MemoryItem(
      id: 'm9',
      destinationName: 'CPI Makassar',
      category: 'pantai',
      date: DateTime.now().subtract(const Duration(days: 35)),
      caption: 'Nongkrong sore',
    ),
  ];

  List<_MemoryItem> get _filtered {
    if (_selectedFilter == 'all') return _memories;
    return _memories.where((m) => m.category == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: CustomScrollView(
          slivers: [
          // App Bar
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
                    Text('Memori Perjalanan 📸',
                        style: AppTypography.displaySmall
                            .copyWith(color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(
                      '${_memories.length} kenangan tersimpan',
                      style: AppTypography.bodyMedium
                          .copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filter chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip('all', 'Semua', Icons.grid_view_rounded),
                    _filterChip(
                        'pantai', '🏖️ Pantai', Icons.beach_access_rounded),
                    _filterChip(
                        'gunung', '⛰️ Gunung', Icons.terrain_rounded),
                    _filterChip('kafe', '☕ Kafe', Icons.coffee_rounded),
                    _filterChip(
                        'restoran', '🍽️ Restoran', Icons.restaurant_rounded),
                  ],
                ),
              ),
            ),
          ),

          // Stats bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Text('${_filtered.length} foto',
                      style: AppTypography.labelMedium
                          .copyWith(color: AppColors.textSecondary)),
                  const Spacer(),
                  Icon(Icons.sort_rounded,
                      size: 18, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text('Terbaru',
                      style: AppTypography.labelSmall
                          .copyWith(color: AppColors.textHint)),
                ],
              ),
            ),
          ),

          // Photo Grid
          _filtered.isEmpty
              ? SliverFillRemaining(
                  child: Center(
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
                          Icon(Icons.photo_library_outlined,
                              size: 64,
                              color: AppColors.textHint.withOpacity(0.3)),
                          const SizedBox(height: AppSpacing.md),
                          Text('Belum ada memori di kategori ini',
                              style: AppTypography.bodyMedium
                                  .copyWith(color: AppColors.textHint)),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 0.8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildMemoryCard(_filtered[index], index),
                      childCount: _filtered.length,
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

  Widget _filterChip(String key, String label, IconData icon) {
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
                      offset: const Offset(0, 2))
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

  Widget _buildMemoryCard(_MemoryItem memory, int index) {
    // Stagger: row 0 = index 0,1; row 1 = index 2,3; etc.
    final row = index ~/ 2;
    final col = index % 2;
    final delay = row * 100 + col * 50;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 450 + delay),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Transform.translate(
        offset: Offset(0, 24 * (1 - v)),
        child: Transform.scale(
          scale: 0.9 + 0.1 * v,
          child: Opacity(opacity: v, child: child),
        ),
      ),
      child: _PressableCard(
        onTap: () => _showMemoryDetail(context, memory),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppSpacing.borderRadiusCard,
            boxShadow: AppColors.cardShadow,
        border: AppColors.cardBorder,
          ),
          child: ClipRRect(
            borderRadius: AppSpacing.borderRadiusCard,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Real photo image
                AppNetworkImage(
                  imageUrl: PlaceholderImages.memory(memory.id),
                  fit: BoxFit.cover,
                ),
                // Category tint overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _gradientForCategory(memory.category)[0].withOpacity(0.1),
                        _gradientForCategory(memory.category)[1].withOpacity(0.2),
                      ],
                    ),
                  ),
                ),
                // Bottom info overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          memory.destinationName,
                          style: AppTypography.titleSmall
                              .copyWith(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormatter.shortDate(memory.date),
                          style: AppTypography.caption
                              .copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
                // Heart button
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_rounded,
                        color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _gradientForCategory(String cat) {
    switch (cat) {
      case 'pantai':
        return [const Color(0xFF4FC3F7), const Color(0xFF0288D1)];
      case 'gunung':
        return [const Color(0xFF66BB6A), const Color(0xFF388E3C)];
      case 'kafe':
        return [const Color(0xFFA1887F), const Color(0xFF5D4037)];
      case 'restoran':
        return [const Color(0xFFFF8A65), const Color(0xFFE64A19)];
      default:
        return [AppColors.primaryLight, AppColors.primary];
    }
  }

  IconData _iconForCategory(String cat) {
    switch (cat) {
      case 'pantai':
        return Icons.beach_access_rounded;
      case 'gunung':
        return Icons.terrain_rounded;
      case 'kafe':
        return Icons.coffee_rounded;
      case 'restoran':
        return Icons.restaurant_rounded;
      default:
        return Icons.landscape_rounded;
    }
  }

  void _showMemoryDetail(BuildContext context, _MemoryItem memory) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLarge)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
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
            // Memory image
            ClipRRect(
              borderRadius: AppSpacing.borderRadiusCard,
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: AppNetworkImage(
                  imageUrl: PlaceholderImages.memory(memory.id, w: 600, h: 400),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Info
            Text(memory.destinationName,
                style: AppTypography.headlineMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(memory.caption, style: AppTypography.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              DateFormatter.fullDate(memory.date),
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.xl),
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Memori dibagikan!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text('Bagikan'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Tutup'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _MemoryItem {
  final String id;
  final String destinationName;
  final String category;
  final DateTime date;
  final String caption;

  const _MemoryItem({
    required this.id,
    required this.destinationName,
    required this.category,
    required this.date,
    required this.caption,
  });
}

/// Card with press-down scale animation for tactile feedback.
class _PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _PressableCard({required this.child, this.onTap});

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
