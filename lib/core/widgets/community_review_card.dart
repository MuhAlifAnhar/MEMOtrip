import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

/// Community review card for destination reviews.
class CommunityReviewCard extends StatelessWidget {
  final String userName;
  final String comment;
  final double? rating;
  final DateTime? date;
  final String? avatarUrl;
  final String? photoUrl;
  final bool isOfficial;
  final VoidCallback? onReport;

  const CommunityReviewCard({
    super.key,
    required this.userName,
    required this.comment,
    this.rating,
    this.date,
    this.avatarUrl,
    this.photoUrl,
    this.isOfficial = false,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: AppColors.cardShadow,
        border: isOfficial
            ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 1)
            : AppColors.cardBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primarySurface,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                  style: AppTypography.titleSmall
                      .copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(userName,
                              style: AppTypography.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (isOfficial) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded,
                              size: 14, color: AppColors.primary),
                        ],
                      ],
                    ),
                    if (date != null)
                      Text(_formatDate(date!), style: AppTypography.caption),
                  ],
                ),
              ),
              if (rating != null) ...[
                _buildRating(),
                if (onReport != null) const SizedBox(width: 6),
              ],
              if (onReport != null)
                IconButton(
                  icon: const Icon(Icons.flag_outlined, size: 16, color: AppColors.error),
                  onPressed: onReport,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  tooltip: 'Laporkan ulasan',
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Comment
          Expanded(
            child: Text(comment,
                style: AppTypography.bodySmall.copyWith(height: 1.5),
                maxLines: 4,
                overflow: TextOverflow.ellipsis),
          ),
          // Badge
          if (isOfficial)
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: AppSpacing.borderRadiusFull,
              ),
              child: Text('Terverifikasi',
                  style: AppTypography.labelSmall
                      .copyWith(color: AppColors.primary, fontSize: 10)),
            ),
        ],
      ),
    );
  }

  Widget _buildRating() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.starFilled.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 12, color: AppColors.starFilled),
          const SizedBox(width: 2),
          Text(rating!.toStringAsFixed(1),
              style:
                  AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${d.day}/${d.month}/${d.year}';
  }
}
