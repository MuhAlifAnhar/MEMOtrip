import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/bmkg_weather_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/placeholder_images.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/bmkg_weather_card.dart';
import '../../../../core/widgets/sensor_data_card.dart';
import '../../data/mock_sensor_data.dart';

/// Dashboard Page — Adaptive view (Condition A / B).
/// PRD: "Beranda (Real-Time Dashboard) — Condition A & B"
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  // null = Condition A, non-null = Condition B
  String? _selectedLocationId;

  late final AnimationController _entranceCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // ─── BMKG Weather State ──────────────────────────────────
  bool _isLoadingWeather = true;
  BmkgWeather? _currentWeather;
  List<BmkgHourlyForecast> _hourlyForecasts = [];
  bool _isUsingRealLocation = false;
  String? _weatherError;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _entranceCtrl,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceCtrl,
      curve: Curves.easeOutCubic,
    ));
    _entranceCtrl.forward();

    // Check location permission after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkLocationPermission());

    // Trigger location + weather fetch on page load
    _initWeather();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  /// Initialize weather: request GPS permission → get location → fetch BMKG data.
  Future<void> _initWeather() async {
    setState(() {
      _isLoadingWeather = true;
      _weatherError = null;
    });

    try {
      // Step 1: Get GPS location (this triggers the permission dialog)
      final position = await LocationService.getCurrentPosition();
      _isUsingRealLocation = position.isReal;

      // Step 2: Fetch BMKG weather data using coordinates
      final result = await BmkgWeatherService.fetchWeather(
        position.lat,
        position.lng,
      );

      if (mounted) {
        setState(() {
          _currentWeather = result.current;
          _hourlyForecasts = result.hourly;
          _isLoadingWeather = false;
          if (result.current == null) {
            _weatherError = 'Data cuaca tidak tersedia';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingWeather = false;
          _weatherError = 'Gagal memuat data cuaca';
        });
      }
    }
  }

  /// Get user's first name from Firebase for personalized greeting.
  String _getUserName() {
    final name = AuthService.currentUser?.displayName;
    if (name == null || name.trim().isEmpty) return 'Traveler 👋';
    final firstName = name.trim().split(' ').first;
    return '$firstName 👋';
  }

  /// Check location permission and show dialog if needed.
  Future<void> _checkLocationPermission() async {
    final status = await LocationService.ensurePermission();
    if (!mounted || status == LocationStatus.granted) return;

    late String title;
    late String message;
    late String actionLabel;
    late VoidCallback action;

    switch (status) {
      case LocationStatus.serviceDisabled:
        title = 'Lokasi Tidak Aktif';
        message =
            'MEMOtrip membutuhkan akses lokasi untuk menampilkan cuaca, '
            'jarak destinasi, dan rekomendasi terdekat. '
            'Aktifkan layanan lokasi di pengaturan perangkat Anda.';
        actionLabel = 'Buka Pengaturan';
        action = () {
          Navigator.pop(context);
          LocationService.openSettings();
        };
        break;
      case LocationStatus.denied:
        title = 'Izin Lokasi Diperlukan';
        message =
            'Untuk pengalaman terbaik, MEMOtrip memerlukan akses lokasi. '
            'Berikan izin agar cuaca dan destinasi terdekat dapat ditampilkan.';
        actionLabel = 'Coba Lagi';
        action = () {
          Navigator.pop(context);
          _checkLocationPermission();
        };
        break;
      case LocationStatus.deniedForever:
        title = 'Izin Lokasi Diblokir';
        message =
            'Izin lokasi telah diblokir secara permanen. '
            'Buka pengaturan aplikasi untuk mengaktifkan izin lokasi secara manual.';
        actionLabel = 'Buka Pengaturan Aplikasi';
        action = () {
          Navigator.pop(context);
          LocationService.openAppSettings();
        };
        break;
      case LocationStatus.granted:
        return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusCard),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: AppSpacing.borderRadiusSmall,
              ),
              child: const Icon(Icons.location_off_rounded,
                  color: AppColors.warning, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title, style: AppTypography.headlineSmall),
            ),
          ],
        ),
        content: Text(message, style: AppTypography.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Nanti',
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton.icon(
            onPressed: action,
            icon: const Icon(Icons.location_on_rounded, size: 18),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: AppSpacing.bottomSafeArea),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.lg),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.05),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _selectedLocationId == null
                        ? _buildConditionA()
                        : _buildConditionB(),
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: AppSpacing.paddingSection,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.base),
          Text(DateFormatter.greeting(),
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xs),
          Text(_getUserName(), style: AppTypography.displayMedium),
          const SizedBox(height: AppSpacing.base),
          // Location Toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: AppSpacing.borderRadiusFull,
              boxShadow: AppColors.cardShadow,
        border: AppColors.cardBorder,
            ),
            child: Row(
              children: [
                _buildToggle('Cuaca Lokal', _selectedLocationId == null,
                    () => setState(() => _selectedLocationId = null)),
                _buildToggle('IoT Monitor', _selectedLocationId != null,
                    () => setState(() => _selectedLocationId = 'losari')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: AppSpacing.borderRadiusFull,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: AppTypography.labelMedium.copyWith(
                color: isActive ? Colors.white : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Condition A: No destination selected ─────────────

  Widget _buildConditionA() {
    return Column(
      key: const ValueKey('conditionA'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ══════════════════════════════════════════════════════
        // BMKG Weather Card — Dynamic, real-time data
        // ══════════════════════════════════════════════════════
        _AnimatedSection(
          index: 0,
          child: Padding(
            padding: AppSpacing.paddingSection,
            child: BmkgWeatherCard(
              weather: _currentWeather,
              hourlyForecasts: _hourlyForecasts,
              isLoading: _isLoadingWeather,
              isUsingRealLocation: _isUsingRealLocation,
              errorMessage: _weatherError,
              onRefresh: _initWeather,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        // Traffic Info
        _AnimatedSection(
          index: 1,
          child: Padding(
            padding: AppSpacing.paddingSection,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: AppSpacing.borderRadiusCard,
                boxShadow: AppColors.cardShadow,
        border: AppColors.cardBorder,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: AppSpacing.borderRadiusMedium,
                    ),
                    child: const Icon(Icons.traffic_rounded,
                        color: AppColors.success, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.infoLaluLintas,
                            style: AppTypography.titleSmall),
                        const SizedBox(height: 2),
                        Text('Lancar — estimasi 15 mnt ke Losari',
                            style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: AppSpacing.borderRadiusFull,
                    ),
                    child: Text('Lancar',
                        style: AppTypography.labelSmall
                            .copyWith(color: AppColors.success)),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        // Active Locations
        _AnimatedSection(
          index: 2,
          child: Padding(
            padding: AppSpacing.paddingSection,
            child: Text('${AppStrings.lokasiAktif} 🟢',
                style: AppTypography.headlineSmall),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _AnimatedSection(
          index: 3,
          child: SizedBox(
            height: 130,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              children: MockSensorData.deviceStatuses.map((d) {
                return _PressableCard(
                  onTap: () =>
                      setState(() => _selectedLocationId = d.locationId),
                  child: Container(
                    width: 170,
                    margin: const EdgeInsets.only(right: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.base),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: AppSpacing.borderRadiusCard,
                      boxShadow: AppColors.cardShadow,
                      border: Border.all(
                          color: d.isOnline
                              ? AppColors.success.withOpacity(0.3)
                              : AppColors.error.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            DeviceStatusIndicator(
                                isOnline: d.isOnline, label: null),
                            const Spacer(),
                            Icon(Icons.sensors_rounded,
                                size: 18,
                                color: d.isOnline
                                    ? AppColors.success
                                    : AppColors.textHint),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(d.locationName,
                            style: AppTypography.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(
                            d.isOnline
                                ? 'Online • ${DateFormatter.relative(d.lastHeartbeat)}'
                                : 'Offline • ${DateFormatter.relative(d.lastHeartbeat)}',
                            style: AppTypography.caption),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Condition B: Destination selected ────────────────

  Widget _buildConditionB() {
    final sensors = MockSensorData.sensorReadings;
    final snapshots = MockSensorData.cameraSnapshots;
    final selected = sensors.firstWhere(
        (s) => s.locationId == _selectedLocationId,
        orElse: () => sensors.first);
    final snapshot = snapshots.firstWhere(
        (s) => s.locationId == _selectedLocationId,
        orElse: () => snapshots.first);

    return Column(
      key: const ValueKey('conditionB'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected Location Chips
        _AnimatedSection(
          index: 0,
          child: SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              children: sensors.map((s) {
                final isActive = s.locationId == _selectedLocationId;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedLocationId = s.locationId),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.base, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.cardBackground,
                      borderRadius: AppSpacing.borderRadiusFull,
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : AppColors.cardShadow,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DeviceStatusIndicator(isOnline: s.isOnline),
                        const SizedBox(width: 6),
                        Text(s.locationName,
                            style: AppTypography.labelMedium.copyWith(
                              color: isActive
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        // Sensor Readings
        _AnimatedSection(
          index: 1,
          child: Padding(
            padding: AppSpacing.paddingSection,
            child: Text('${AppStrings.dataRealtime} ⚡',
                style: AppTypography.headlineSmall),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _AnimatedSection(
          index: 2,
          child: Padding(
            padding: AppSpacing.paddingSection,
            child: Row(
              children: [
                Expanded(
                  child: SensorDataCard(
                    label: AppStrings.suhu,
                    value: selected.suhu.toStringAsFixed(1),
                    unit: AppStrings.celsius,
                    icon: Icons.thermostat_rounded,
                    iconColor: AppColors.accent,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: SensorDataCard(
                    label: AppStrings.kelembapan,
                    value: selected.kelembapan.toStringAsFixed(0),
                    unit: AppStrings.persen,
                    icon: Icons.water_drop_rounded,
                    iconColor: AppColors.info,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: SensorDataCard(
                    label: AppStrings.tekanan,
                    value: selected.tekanan.toStringAsFixed(0),
                    unit: AppStrings.hPa,
                    icon: Icons.speed_rounded,
                    iconColor: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        // Camera Snapshot
        _AnimatedSection(
          index: 3,
          child: Padding(
            padding: AppSpacing.paddingSection,
            child: Text(AppStrings.snapshotKeramaian,
                style: AppTypography.headlineSmall),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _AnimatedSection(
          index: 4,
          child: Padding(
            padding: AppSpacing.paddingSection,
            child: Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
                ),
                borderRadius: AppSpacing.borderRadiusCard,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: AppSpacing.borderRadiusCard,
                    child: AppNetworkImage(
                      imageUrl: PlaceholderImages.camera(_selectedLocationId ?? 'losari'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: AppSpacing.borderRadiusCard,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.2), Colors.black.withOpacity(0.6)],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: AppSpacing.base,
                    left: AppSpacing.base,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _crowdColor(snapshot.crowdLevel)
                                .withOpacity(0.2),
                            borderRadius: AppSpacing.borderRadiusFull,
                          ),
                          child: Text('Keramaian: ${snapshot.crowdLevel}',
                              style: AppTypography.labelSmall
                                  .copyWith(color: Colors.white)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                            '${snapshot.locationName} • ${DateFormatter.relative(snapshot.timestamp)}',
                            style: AppTypography.caption
                                .copyWith(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        // Comparison Cards
        _AnimatedSection(
          index: 5,
          child: Padding(
            padding: AppSpacing.paddingSection,
            child: Text('Perbandingan Lokasi',
                style: AppTypography.headlineSmall),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _AnimatedSection(
          index: 6,
          child: SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: sensors.length,
              itemBuilder: (_, i) {
                final s = sensors[i];
                return _PressableCard(
                  onTap: () =>
                      setState(() => _selectedLocationId = s.locationId),
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: AppSpacing.borderRadiusCard,
                      boxShadow: AppColors.cardShadow,
                      border: s.locationId == _selectedLocationId
                          ? Border.all(color: AppColors.primary, width: 1.5)
                          : AppColors.cardBorder,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            DeviceStatusIndicator(isOnline: s.isOnline),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(s.locationName,
                                  style: AppTypography.labelSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text('${s.suhu.toStringAsFixed(1)}°C',
                            style: AppTypography.headlineMedium
                                .copyWith(color: AppColors.accent)),
                        Text('💧 ${s.kelembapan.toStringAsFixed(0)}%',
                            style: AppTypography.caption),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Color _crowdColor(String level) {
    switch (level.toLowerCase()) {
      case 'sepi':
        return AppColors.success;
      case 'sedang':
        return AppColors.warning;
      case 'ramai':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }
}

/// Internal staggered section animation widget.
class _AnimatedSection extends StatefulWidget {
  final Widget child;
  final int index;

  const _AnimatedSection({required this.child, this.index = 0});

  @override
  State<_AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<_AnimatedSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 20),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Transform.translate(
          offset: _slide.value,
          child: Opacity(
            opacity: _fade.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Card with press-down scale animation for tactile feedback.
class _PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _PressableCard({required this.child, this.onTap});

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
