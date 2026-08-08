import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/providers/auth_provider.dart';

class AdminSidebar extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool isDrawerMode;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.isDrawerMode = false,
  });

  static const _items = [
    (Icons.dashboard_rounded, 'Overview'),
    (Icons.sensors_rounded, 'Perangkat IoT'),
    (Icons.map_rounded, 'Destinasi'),
    (Icons.rate_review_rounded, 'Moderasi'),
    (Icons.analytics_rounded, 'Analitik'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read auth user from Firebase Auth stream
    final authAsync = ref.watch(authUserProvider);
    final user = authAsync.valueOrNull;
    final displayName = user?.displayName ?? 'Admin';
    final email = user?.email ?? 'admin@memotrip.id';
    final initials = displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : 'A';

    return Container(
      width: isDrawerMode ? null : 260,
      color: AppColors.surface,
      child: SafeArea(
        child: Column(children: [
          // Header with entrance animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (_, v, child) => Opacity(opacity: v, child: child),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration:
                  const BoxDecoration(gradient: AppColors.primaryGradient),
              child: Row(children: [
                const Icon(Icons.travel_explore_rounded,
                    color: Colors.white, size: 28),
                const SizedBox(width: AppSpacing.md),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MEMOtrip',
                          style: AppTypography.headlineMedium
                              .copyWith(color: Colors.white)),
                      Text('Admin Panel',
                          style: AppTypography.caption
                              .copyWith(color: Colors.white70)),
                    ]),
              ]),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          // Nav Items — staggered entrance + animated active state
          ...List.generate(_items.length, (i) {
            final (icon, label) = _items[i];
            final isActive = selectedIndex == i;
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 400 + (i * 80)),
              curve: Curves.easeOutCubic,
              builder: (_, v, child) => Transform.translate(
                offset: Offset(-20 * (1 - v), 0),
                child: Opacity(opacity: v, child: child),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: AppSpacing.borderRadiusMedium,
                  border: isActive
                      ? Border.all(
                          color: AppColors.primary.withOpacity(0.2), width: 1)
                      : Border.all(color: Colors.transparent, width: 1),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: AppSpacing.borderRadiusMedium,
                    splashColor: AppColors.primary.withOpacity(0.08),
                    highlightColor: AppColors.primary.withOpacity(0.04),
                    onTap: () {
                      onTap(i);
                      // Auto-close drawer on mobile
                      if (isDrawerMode) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.base, vertical: 12),
                      child: Row(children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: AppSpacing.borderRadiusSmall,
                          ),
                          child: Icon(icon,
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.textHint,
                              size: 20),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: AppTypography.labelMedium.copyWith(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight:
                                isActive ? FontWeight.w700 : FontWeight.w500,
                          ),
                          child: Text(label),
                        ),
                        if (isActive) ...[
                          const Spacer(),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: AppSpacing.borderRadiusFull,
                            ),
                          ),
                        ],
                      ]),
                    ),
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          // Admin User — dynamically from Firebase Auth
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (_, v, child) =>
                Opacity(opacity: v, child: child),
            child: Container(
              margin: const EdgeInsets.all(AppSpacing.base),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppSpacing.borderRadiusMedium),
              child: Row(children: [
                CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primarySurface,
                    child: Text(initials,
                        style: AppTypography.labelMedium
                            .copyWith(color: AppColors.primary))),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(displayName,
                          style: AppTypography.labelSmall,
                          overflow: TextOverflow.ellipsis),
                      Text(email,
                          style: AppTypography.caption,
                          overflow: TextOverflow.ellipsis),
                    ])),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
