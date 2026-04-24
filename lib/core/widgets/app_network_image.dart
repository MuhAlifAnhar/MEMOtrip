import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

/// Reusable network image with shimmer loading and graceful error fallback.
class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData errorIcon;
  final List<Color>? fallbackGradient;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorIcon = Icons.landscape_rounded,
    this.fallbackGradient,
  });

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => _buildShimmer(),
      errorWidget: (_, __, ___) => _buildError(),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.divider,
      highlightColor: AppColors.primarySurface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: borderRadius ?? AppSpacing.borderRadiusMedium,
        ),
      ),
    );
  }

  Widget _buildError() {
    final colors = fallbackGradient ??
        [AppColors.primaryLight, AppColors.primary];
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Icon(errorIcon, color: Colors.white.withOpacity(0.25), size: 48),
    );
  }
}
