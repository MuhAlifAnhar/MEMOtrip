import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

/// Sensor data display card for BME280 readings.
///
/// When [isDanger] is `true` (suhu > 35 °C), the card switches to a
/// red/danger colour scheme per the PRD EWS requirement.
class SensorDataCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color iconColor;

  /// If `true`, the card adopts an EWS red danger theme.
  final bool isDanger;

  const SensorDataCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    this.iconColor = AppColors.primary,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    // Resolve colours based on danger mode
    final effectiveIconColor = isDanger ? AppColors.error : iconColor;
    final effectiveBg = isDanger
        ? AppColors.error.withOpacity(0.08)
        : AppColors.cardBackground;
    final effectiveBorder = isDanger
        ? Border.all(color: AppColors.error.withOpacity(0.5), width: 1.2)
        : AppColors.cardBorder;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      width: AppSpacing.sensorCardWidth,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: isDanger
            ? [
                BoxShadow(
                  color: AppColors.error.withOpacity(0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : AppColors.cardShadow,
        border: effectiveBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge — pulses red in danger mode
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: effectiveIconColor.withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusSmall,
            ),
            child: Icon(icon, color: effectiveIconColor, size: 20),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(label, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: AppTypography.headlineMedium.copyWith(
                    color: effectiveIconColor,
                    fontWeight: isDanger ? FontWeight.w800 : FontWeight.w700,
                  )),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(unit, style: AppTypography.labelSmall),
              ),
            ],
          ),
          // Danger badge
          if (isDanger) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.15),
                borderRadius: AppSpacing.borderRadiusFull,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 12, color: AppColors.error),
                  const SizedBox(width: 3),
                  Text(
                    'EWS',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small online/offline status indicator.
class DeviceStatusIndicator extends StatelessWidget {
  final bool isOnline;
  final String? label;

  const DeviceStatusIndicator({
    super.key,
    required this.isOnline,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isOnline ? AppColors.success : AppColors.error,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (isOnline ? AppColors.success : AppColors.error)
                    .withOpacity(0.4),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: 6),
          Text(
            label!,
            style: AppTypography.labelSmall.copyWith(
              color: isOnline ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}
