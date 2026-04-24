import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

/// Sensor data display card for BME280 readings.
class SensorDataCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color iconColor;

  const SensorDataCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    this.iconColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.sensorCardWidth,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: AppColors.cardShadow,
        border: AppColors.cardBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusSmall,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(label, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: AppTypography.headlineMedium
                      .copyWith(color: iconColor)),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(unit, style: AppTypography.labelSmall),
              ),
            ],
          ),
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
