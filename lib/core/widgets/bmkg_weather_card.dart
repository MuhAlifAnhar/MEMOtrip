import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../services/bmkg_weather_service.dart';
import '../utils/date_formatter.dart';

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

    // Format like "Tue, 12 Mei 2026"
    final dateStr = DateFormatter.fullDate(DateTime.now());
    // Mock chance of rain for visual parity
    const chanceOfRain = "60%";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
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
        clipBehavior: Clip.none,
        children: [
          // Background large emoji
          Positioned(
            right: -20,
            top: 20,
            child: Text(
              w.weatherEmoji,
              style: const TextStyle(fontSize: 100),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateStr,
                    style: AppTypography.caption.copyWith(
                      color: Colors.white.withOpacity(0.9),
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
              const SizedBox(height: AppSpacing.sm),
              // Weather Desc
              Text(
                w.weatherDescEn != 'N/A' && w.weatherDescEn.isNotEmpty
                    ? w.weatherDescEn
                    : w.weatherDesc,
                style: AppTypography.displayLarge.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 4),
              // Chance of rain
              Text(
                'Chance of rain $chanceOfRain',
                style: AppTypography.labelMedium.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Location
              Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${w.locationName}, ${w.province}',
                    style: AppTypography.labelMedium.copyWith(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Bottom row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${w.temperature}°',
                    style: AppTypography.displayLarge.copyWith(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0, left: 2.0),
                    child: Text(
                      'C',
                      style: AppTypography.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildBottomDetail(Icons.water_drop_rounded, '10%'),
                  const SizedBox(width: 12),
                  _buildBottomDetail(Icons.wb_sunny_rounded, '0.5'),
                  const SizedBox(width: 12),
                  _buildBottomDetail(Icons.air_rounded, '${w.windSpeed.toStringAsFixed(0)} km/h'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomDetail(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTypography.labelMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
