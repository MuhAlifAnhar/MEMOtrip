import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../widgets/app_network_image.dart';

/// Reusable destination card — supports horizontal (carousel) and vertical (list) layouts.
class DestinationCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String location;
  final double rating;
  final String? distance;
  final bool isHorizontal;
  final bool isBookmarked;
  final VoidCallback? onTap;

  const DestinationCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.location,
    this.rating = 0.0,
    this.distance,
    this.isHorizontal = true,
    this.isBookmarked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return isHorizontal ? _buildHorizontal() : _buildVertical();
  }

  Widget _buildHorizontal() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: AppSpacing.md),
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
              // Image
              Stack(
                children: [
                  AppNetworkImage(
                    imageUrl: imageUrl,
                    height: 130,
                    width: double.infinity,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        size: 16,
                        color: isBookmarked
                            ? AppColors.starFilled
                            : AppColors.textHint,
                      ),
                    ),
                  ),
                ],
              ),
              // Info
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: AppTypography.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: AppColors.textHint),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(location,
                              style: AppTypography.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 14, color: AppColors.starFilled),
                        const SizedBox(width: 2),
                        Text(rating.toStringAsFixed(1),
                            style: AppTypography.labelSmall
                                .copyWith(fontWeight: FontWeight.w600)),
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

  Widget _buildVertical() {
    return GestureDetector(
      onTap: onTap,
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
              AppNetworkImage(
                imageUrl: imageUrl,
                width: 110,
                height: 100,
              ),
              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: AppTypography.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 12, color: AppColors.textHint),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(location,
                                style: AppTypography.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: AppColors.starFilled),
                          const SizedBox(width: 2),
                          Text(rating.toStringAsFixed(1),
                              style: AppTypography.labelSmall
                                  .copyWith(fontWeight: FontWeight.w600)),
                          if (distance != null) ...[
                            const Spacer(),
                            const Icon(Icons.near_me_rounded,
                                size: 12, color: AppColors.primary),
                            const SizedBox(width: 2),
                            Text(distance!,
                                style: AppTypography.labelSmall
                                    .copyWith(color: AppColors.primary)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Bookmark
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: Icon(
                  isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: 22,
                  color:
                      isBookmarked ? AppColors.starFilled : AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
