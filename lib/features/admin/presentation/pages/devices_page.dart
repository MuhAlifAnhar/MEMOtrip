import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/sensor_data_card.dart';
import '../../../../core/services/mock_iot_service.dart';

class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sensors = MockIoTService.generateSensorReadings();
    final snapshots = MockIoTService.generateCameraSnapshots();
    final devices = MockIoTService.generateDeviceStatuses();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header — fade entrance
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          builder: (_, v, child) => Opacity(opacity: v, child: child),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Monitoring Perangkat IoT',
                  style: AppTypography.displaySmall),
              const SizedBox(height: AppSpacing.xs),
              Text('BME280 Sensor & ESP32-CAM — 3 Lokasi',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        // Device cards — staggered entrance
        ...List.generate(sensors.length, (i) {
          final s = sensors[i];
          final snap = snapshots[i];
          final d = devices[i];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 500 + (i * 150)),
            curve: Curves.easeOutCubic,
            builder: (_, v, child) => Transform.translate(
              offset: Offset(0, 20 * (1 - v)),
              child: Opacity(opacity: v, child: child),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.xl),
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppSpacing.borderRadiusCard,
                  boxShadow: AppColors.cardShadow,
                  border: Border.all(
                      color: d.isOnline
                          ? AppColors.success.withOpacity(0.3)
                          : AppColors.error.withOpacity(0.3))),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: d.isOnline
                                ? AppColors.success
                                : AppColors.error,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: (d.isOnline
                                          ? AppColors.success
                                          : AppColors.error)
                                      .withOpacity(0.4),
                                  blurRadius: 6)
                            ]),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(s.locationName,
                          style: AppTypography.headlineSmall),
                      const Spacer(),
                      Text(d.isOnline ? 'Online' : 'Offline',
                          style: AppTypography.labelSmall.copyWith(
                              color: d.isOnline
                                  ? AppColors.success
                                  : AppColors.error)),
                      const SizedBox(width: AppSpacing.md),
                      Text(DateFormatter.relative(d.lastHeartbeat),
                          style: AppTypography.caption),
                    ]),
                    const SizedBox(height: AppSpacing.lg),
                    // Sensor Data
                    Row(children: [
                      Expanded(
                          child: SensorDataCard(
                              label: AppStrings.suhu,
                              value: s.suhu.toStringAsFixed(1),
                              unit: AppStrings.celsius,
                              icon: Icons.thermostat_rounded,
                              iconColor: AppColors.accent,
                              isDanger: MockIoTService.isDanger(s.suhu))),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                          child: SensorDataCard(
                              label: AppStrings.kelembapan,
                              value: s.kelembapan.toStringAsFixed(0),
                              unit: AppStrings.persen,
                              icon: Icons.water_drop_rounded,
                              iconColor: AppColors.info)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                          child: SensorDataCard(
                              label: AppStrings.tekanan,
                              value: s.tekanan.toStringAsFixed(0),
                              unit: AppStrings.hPa,
                              icon: Icons.speed_rounded,
                              iconColor: AppColors.warning)),
                    ]),
                    const SizedBox(height: AppSpacing.lg),
                    // Camera Snapshot
                    Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            Color(0xFF2C3E50),
                            Color(0xFF3498DB)
                          ]),
                          borderRadius: AppSpacing.borderRadiusMedium),
                      child: Stack(children: [
                        Center(
                            child: Icon(Icons.videocam_rounded,
                                color: Colors.white.withOpacity(0.2),
                                size: 36)),
                        Positioned(
                            bottom: 8,
                            left: 8,
                            child: Text(
                                'Keramaian: ${snap.crowdLevel}',
                                style: AppTypography.labelSmall
                                    .copyWith(color: Colors.white))),
                      ]),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Actions
                    Row(children: [
                      OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.camera_alt_rounded,
                              size: 16),
                          label: const Text('Ambil Foto')),
                      const SizedBox(width: AppSpacing.sm),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.warning_rounded,
                            size: 16,
                            color: d.dangerMode
                                ? AppColors.error
                                : null),
                        label: Text(d.dangerMode
                            ? 'Nonaktifkan Bahaya'
                            : 'Set Bahaya'),
                        style: d.dangerMode
                            ? OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppColors.error),
                                foregroundColor: AppColors.error)
                            : null,
                      ),
                    ]),
                  ]),
            ),
          );
        }),
      ]),
    );
  }
}
