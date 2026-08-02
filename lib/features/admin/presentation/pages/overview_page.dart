import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/mock_iot_service.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final devices = MockIoTService.generateDeviceStatuses();
    final online = devices.where((d) => d.isOnline).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header — fade entrance
        _Stagger(
          index: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard Overview', style: AppTypography.displaySmall),
              const SizedBox(height: AppSpacing.xs),
              Text('Ringkasan status perangkat dan aktivitas MEMOtrip',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        // Stats Cards — staggered
        _Stagger(
          index: 1,
          child: Row(children: [
            _statCard('Perangkat Online', '$online/${devices.length}',
                Icons.sensors_rounded, AppColors.success, 0),
            const SizedBox(width: AppSpacing.lg),
            _statCard('Total Destinasi', '7', Icons.map_rounded,
                AppColors.primary, 1),
            const SizedBox(width: AppSpacing.lg),
            _statCard('Pengguna Aktif', '48', Icons.people_rounded,
                AppColors.info, 2),
            const SizedBox(width: AppSpacing.lg),
            _statCard('Review Pending', '3', Icons.rate_review_rounded,
                AppColors.warning, 3),
          ]),
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
                    color:
                        d.isOnline ? AppColors.success : AppColors.error,
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
      ]),
    );
  }

  Widget _statCard(
      String title, String value, IconData icon, Color color, int index) {
    return Expanded(
      child: TweenAnimationBuilder<double>(
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
          padding: const EdgeInsets.all(AppSpacing.xl),
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
      ),
    );
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
