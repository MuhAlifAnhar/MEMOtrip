import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../services/bmkg_weather_service.dart';

/// Premium weather card widget that displays live BMKG data.
///
/// Features:
/// - Current temperature with weather description
/// - Location name from BMKG
/// - Humidity, wind speed, cloud cover details
/// - Horizontal 3-hour forecast strip
/// - BMKG attribution badge
/// - Animated shimmer loading state
class BmkgWeatherCard extends StatelessWidget {
  final BmkgWeather? weather;
  final List<BmkgHourlyForecast> hourlyForecasts;
  final bool isLoading;
  final bool isUsingRealLocation;
  final String? errorMessage;
  final VoidCallback? onRefresh;

  const BmkgWeatherCard({
    super.key,
    this.weather,
    this.hourlyForecasts = const [],
    this.isLoading = false,
    this.isUsingRealLocation = false,
    this.errorMessage,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _buildLoadingState();
    if (weather == null) return _buildErrorState();
    return _buildWeatherContent(context);
  }

  // ─── Loading Shimmer ─────────────────────────────────────
  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer location row
          Row(
            children: [
              _shimmerBox(14, 14, isCircle: true),
              const SizedBox(width: 6),
              _shimmerBox(150, 14),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shimmerBox(80, 56),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(120, 18),
                    const SizedBox(height: 8),
                    _shimmerBox(180, 12),
                  ],
                ),
              ),
              _shimmerBox(40, 40, isCircle: true),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Shimmer forecast strip
          SizedBox(
            height: 70,
            child: Row(
              children: List.generate(
                4,
                (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                    child: _shimmerBox(double.infinity, 70),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox(double width, double height, {bool isCircle = false}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 0.7),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOut,
      builder: (_, value, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(value * 0.3),
            borderRadius: isCircle ? null : BorderRadius.circular(8),
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          ),
        );
      },
    );
  }

  // ─── Error / Fallback State ──────────────────────────────
  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.white70, size: 40),
          const SizedBox(height: AppSpacing.md),
          Text(
            errorMessage ?? 'Gagal memuat data cuaca',
            style: AppTypography.bodyMedium.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Periksa koneksi internet Anda',
            style: AppTypography.caption.copyWith(color: Colors.white60),
          ),
          if (onRefresh != null) ...[
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: onRefresh,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh_rounded,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text('Coba Lagi',
                        style: AppTypography.labelSmall
                            .copyWith(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Main Weather Content ────────────────────────────────
  Widget _buildWeatherContent(BuildContext context) {
    final w = weather!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: _weatherGradient(w.weatherCode),
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            right: -30,
            top: -20,
            child: Text(
              w.weatherEmoji,
              style: const TextStyle(fontSize: 120),
            ),
          ),
          Positioned(
            right: -30,
            top: -20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location row
                Row(
                  children: [
                    Icon(
                      isUsingRealLocation
                          ? Icons.gps_fixed_rounded
                          : Icons.location_on_rounded,
                      color: Colors.white70,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${w.locationName}, ${w.province}',
                        style: AppTypography.labelMedium
                            .copyWith(color: Colors.white70),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onRefresh != null)
                      GestureDetector(
                        onTap: onRefresh,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.refresh_rounded,
                              color: Colors.white70, size: 14),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Temperature + Description
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Temperature
                    Text(
                      '${w.temperature}°',
                      style: AppTypography.displayLarge.copyWith(
                        color: Colors.white,
                        fontSize: 56,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    // Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            w.weatherDesc,
                            style: AppTypography.headlineMedium
                                .copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kelembapan ${w.humidity}% • Angin ${w.windSpeed.toStringAsFixed(0)} km/h',
                            style: AppTypography.caption
                                .copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    // Weather emoji
                    Text(w.weatherEmoji,
                        style: const TextStyle(fontSize: 36)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // Detail chips
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _detailChip(Icons.cloud_rounded,
                        'Awan ${w.cloudCover}%'),
                    _detailChip(Icons.explore_rounded,
                        'Angin ${w.windDirection}'),
                    _detailChip(Icons.visibility_rounded,
                        w.visibility),
                  ],
                ),

                // Hourly forecast strip
                if (hourlyForecasts.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    height: 1,
                    color: Colors.white.withOpacity(0.15),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: hourlyForecasts.length,
                      itemBuilder: (_, i) =>
                          _buildHourlyItem(hourlyForecasts[i], i == 0),
                    ),
                  ),
                ],

                // BMKG Attribution
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: AppSpacing.borderRadiusFull,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded,
                          color: Colors.white.withOpacity(0.7), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'Sumber: BMKG',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Hourly Forecast Item ────────────────────────────────
  Widget _buildHourlyItem(BmkgHourlyForecast forecast, bool isFirst) {
    return Container(
      width: 62,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: isFirst
            ? Colors.white.withOpacity(0.2)
            : Colors.white.withOpacity(0.08),
        borderRadius: AppSpacing.borderRadiusMedium,
        border: isFirst
            ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            isFirst ? 'Now' : forecast.timeLabel,
            style: AppTypography.caption.copyWith(
              color: Colors.white.withOpacity(isFirst ? 1.0 : 0.7),
              fontSize: 10,
              fontWeight: isFirst ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(forecast.weatherEmoji,
              style: const TextStyle(fontSize: 18)),
          Text(
            '${forecast.temperature}°',
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Detail Chip ────────────────────────────────────────
  Widget _detailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Gradient based on weather condition ─────────────────
  LinearGradient _weatherGradient(int code) {
    switch (code) {
      case 0:
      case 1: // Cerah
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
        );
      case 2: // Cerah Berawan
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
        );
      case 3: // Berawan
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF78909C), Color(0xFF546E7A)],
        );
      case 4: // Berawan Tebal
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF607D8B), Color(0xFF455A64)],
        );
      case 60:
      case 61:
      case 63:
      case 65: // Hujan
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5C6BC0), Color(0xFF3949AB)],
        );
      case 17:
      case 95:
      case 97: // Hujan Petir
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF37474F), Color(0xFF263238)],
        );
      default:
        return AppColors.primaryGradient;
    }
  }
}
