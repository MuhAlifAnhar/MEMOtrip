import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/overview_provider.dart';

class OverviewPage extends ConsumerWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(overviewProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;

        if (overview.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: AppSpacing.base),
                Text('Memuat data overview dari Firestore...',
                    style: AppTypography.bodyMedium),
              ],
            ),
          );
        }

        final devices = overview.deviceStatuses;
        final online = devices.where((d) => d.isOnline).length;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isNarrow ? AppSpacing.base : AppSpacing.xxl),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header with refresh
            _Stagger(
              index: 0,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dashboard Overview',
                            style: isNarrow
                                ? AppTypography.headlineLarge
                                : AppTypography.displaySmall),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Ringkasan real-time dari Cloud Firestore',
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        ref.read(overviewProvider.notifier).refresh(),
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Refresh data',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Firestore connection badge
            _Stagger(
              index: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.08),
                  borderRadius: AppSpacing.borderRadiusFull,
                  border:
                      Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Terhubung ke Firestore',
                      style: AppTypography.labelSmall
                          .copyWith(color: AppColors.success),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Stats Cards — responsive
            _Stagger(
              index: 1,
              child: isNarrow
                  ? _buildMobileStatCards(overview, online, devices.length)
                  : _buildDesktopStatCards(overview, online, devices.length),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Device Status
            _Stagger(
              index: 2,
              child: Text('Status Perangkat IoT',
                  style: AppTypography.headlineSmall),
            ),
            const SizedBox(height: AppSpacing.md),
            ...devices.asMap().entries.map((entry) {
              final i = entry.key;
              final d = entry.value;
              return _Stagger(
                index: 3 + i,
                child: Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.base),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppSpacing.borderRadiusCard,
                      boxShadow: AppColors.cardShadow),
                  child: Row(children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: d.isOnline ? AppColors.success : AppColors.error,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: (d.isOnline
                                      ? AppColors.success
                                      : AppColors.error)
                                  .withOpacity(0.4),
                              blurRadius: 6)
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                        child: Text(d.locationName,
                            style: AppTypography.titleSmall)),
                    Text(d.isOnline ? 'Online' : 'Offline',
                        style: AppTypography.labelSmall.copyWith(
                            color: d.isOnline
                                ? AppColors.success
                                : AppColors.error)),
                  ]),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.xxl),

            // Activity Log
            _Stagger(
              index: 6,
              child: Text('📋 Log Aktivitas Terbaru',
                  style: AppTypography.headlineSmall),
            ),
            const SizedBox(height: AppSpacing.md),
            if (overview.activityLog.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppSpacing.borderRadiusCard,
                  boxShadow: AppColors.cardShadow,
                ),
                child: Center(
                  child: Text('Belum ada aktivitas terbaru',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textSecondary)),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppSpacing.borderRadiusCard,
                  boxShadow: AppColors.cardShadow,
                  border: AppColors.cardBorder,
                ),
                child: Column(
                  children: overview.activityLog.map((log) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                      decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: AppColors.divider, width: 0.5)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(log.icon, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(log.message,
                                    style: AppTypography.bodySmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text(
                                  _timeAgo(log.timestamp),
                                  style: AppTypography.caption,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ]),
        );
      },
    );
  }

  // Desktop: 4-column row
  Widget _buildDesktopStatCards(
      OverviewState overview, int online, int total) {
    return Row(children: [
      Expanded(
          child: _statCard('Perangkat Online', '$online/$total',
              Icons.sensors_rounded, AppColors.success, 0)),
      const SizedBox(width: AppSpacing.lg),
      Expanded(
          child: _statCard('Total Destinasi', '${overview.totalDestinations}',
              Icons.map_rounded, AppColors.primary, 1)),
      const SizedBox(width: AppSpacing.lg),
      Expanded(
          child: _statCard('Pengguna Aktif', '${overview.activeUsers}',
              Icons.people_rounded, AppColors.info, 2)),
      const SizedBox(width: AppSpacing.lg),
      Expanded(
          child: _statCard('Review Pending', '${overview.pendingReviews}',
              Icons.rate_review_rounded, AppColors.warning, 3)),
    ]);
  }

  // Mobile: 2x2 grid
  Widget _buildMobileStatCards(
      OverviewState overview, int online, int total) {
    return Column(children: [
      Row(children: [
        Expanded(
            child: _statCard('Perangkat Online', '$online/$total',
                Icons.sensors_rounded, AppColors.success, 0)),
        const SizedBox(width: AppSpacing.md),
        Expanded(
            child: _statCard('Total Destinasi', '${overview.totalDestinations}',
                Icons.map_rounded, AppColors.primary, 1)),
      ]),
      const SizedBox(height: AppSpacing.md),
      Row(children: [
        Expanded(
            child: _statCard('Pengguna Aktif', '${overview.activeUsers}',
                Icons.people_rounded, AppColors.info, 2)),
        const SizedBox(width: AppSpacing.md),
        Expanded(
            child: _statCard('Review Pending', '${overview.pendingReviews}',
                Icons.rate_review_rounded, AppColors.warning, 3)),
      ]),
    ]);
  }

  Widget _statCard(
      String title, String value, IconData icon, Color color, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Transform.translate(
        offset: Offset(0, 15 * (1 - v)),
        child: Transform.scale(
          scale: 0.95 + 0.05 * v,
          child: Opacity(opacity: v, child: child),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppSpacing.borderRadiusCard,
            boxShadow: AppColors.cardShadow),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: AppSpacing.borderRadiusSmall),
                  child: Icon(icon, color: color, size: 22)),
              const SizedBox(height: AppSpacing.md),
              Text(value,
                  style: AppTypography.displaySmall
                      .copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(title, style: AppTypography.caption),
            ]),
      ),
    );
  }

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    return '${diff.inDays} hari lalu';
  }
}

/// Reusable staggered entrance widget.
class _Stagger extends StatelessWidget {
  final Widget child;
  final int index;

  const _Stagger({required this.child, this.index = 0});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 70)),
      curve: Curves.easeOutCubic,
      builder: (_, v, ch) => Transform.translate(
        offset: Offset(0, 16 * (1 - v)),
        child: Opacity(opacity: v, child: ch),
      ),
      child: child,
    );
  }
}
