import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

/// Styled search bar for destination discovery.
class CustomSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final String hint;

  const CustomSearchBar({
    super.key,
    this.onChanged,
    this.onTap,
    this.hint = 'Cari destinasi wisata...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppSpacing.borderRadiusFull,
        boxShadow: AppColors.cardShadow,
        border: AppColors.cardBorder,
      ),
      child: TextField(
        onChanged: onChanged,
        onTap: onTap,
        style: AppTypography.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.textHint, size: 22),
          suffixIcon: Container(
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: AppSpacing.borderRadiusFull,
            ),
            child: const Icon(Icons.tune_rounded,
                color: Colors.white, size: 18),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.base),
        ),
      ),
    );
  }
}
