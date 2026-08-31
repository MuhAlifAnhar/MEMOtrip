import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/mock_iot_service.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/bmkg_weather_card.dart';
import '../../../../core/widgets/custom_gauge.dart';
import '../../domain/entities/sensor_reading.dart';
import '../providers/dashboard_provider.dart';
import '../../../../core/widgets/community_review_card.dart';
import '../../../destination/presentation/providers/destination_provider.dart';

/// Dashboard Page — Adaptive view (Condition A / B).
/// PRD: "Beranda (Real-Time Dashboard) — Condition A & B"
/// State managed by Riverpod [dashboardProvider].
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocationPermission();
      // Trigger Geolocator + BMKG fetch via Riverpod
      ref.read(dashboardProvider.notifier).initWeather();
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
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
    // ─── Read state from Riverpod ──────────────────────────
    final state = ref.watch(dashboardProvider);
    final notifier = ref.read(dashboardProvider.notifier);

    // Determine if the selected location is in EWS danger
    final selectedSensor = state.selectedLocationId != null
        ? MockIoTService.getSensorByLocation(
            state.selectedLocationId!, state.sensorReadings)
        : null;
    final isSelectedDanger =
        selectedSensor != null && MockIoTService.isDanger(selectedSensor.suhu);

    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: isSelectedDanger
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFF5F5), // Very light red
                    Color(0xFFFFEBEE), // Red 50
                    Color(0xFFFFCDD2), // Red 100
                  ],
                  stops: [0.0, 0.5, 1.0],
                )
              : AppColors.backgroundGradient,
        ),
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
                  _buildHeader(state, notifier, isSelectedDanger),

                  // ── EWS Banner (only in Condition B when danger) ──
                  if (state.selectedLocationId != null && isSelectedDanger)
                    _buildEwsBanner(selectedSensor),

                  // ── IoT Status/Error Banner (when Losari selected) ──
                  if (state.selectedLocationId == 'losari' && state.iotError != null)
                    _buildIotErrorBanner(state.iotError!),

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
                    child: state.selectedLocationId == null
                        ? _buildConditionA(state, notifier)
                        : (state.isRefreshingIoT
                            ? const Padding(
                                key: ValueKey('iotLoading'),
                                padding: EdgeInsets.all(AppSpacing.xxl),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : _buildConditionB(state, notifier)),
                  ),
                ],
              ),
            ),
            ),
          ),
        ),
        ),
        // ── Simulated Latency Indicator ──
        if (state.selectedLocationId != null && state.simulatedLatencyMs > 0 && !state.isRefreshingIoT)
          Positioned(
            bottom: 8,
            right: 8,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: Text(
                  state.isUsingRealIoT && state.selectedLocationId == 'losari'
                      ? 'Data Latency: ${state.simulatedLatencyMs.toStringAsFixed(2)} ms (Real-time dari Raspberry Pi 4)'
                      : 'Data Latency: ${state.simulatedLatencyMs.toStringAsFixed(2)} ms (Simulated via Firebase Mock)',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── EWS Danger Banner ────────────────────────────────────

  Widget _buildEwsBanner(SensorReading sensor) {
    return _AnimatedSection(
      index: 0,
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.md,
          bottom: AppSpacing.xs,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEF5350), Color(0xFFE53935)],
            ),
            borderRadius: AppSpacing.borderRadiusCard,
            boxShadow: [
              BoxShadow(
                color: AppColors.error.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: AppSpacing.borderRadiusMedium,
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ Peringatan Dini (EWS)',
                      style: AppTypography.titleSmall
                          .copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${sensor.locationName} — Suhu ${sensor.suhu.toStringAsFixed(1)}°C '
                      'melebihi batas aman ${MockIoTService.ewsTemperatureThreshold.toStringAsFixed(0)}°C!',
                      style: AppTypography.bodySmall
                          .copyWith(color: Colors.white.withOpacity(0.9)),
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

  Widget _buildIotErrorBanner(String error) {
    return _AnimatedSection(
      index: 0,
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.md,
          bottom: AppSpacing.xs,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: AppSpacing.borderRadiusCard,
            border: Border.all(color: Colors.amber[300]!),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: Colors.amber, size: 24),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  error,
                  style: AppTypography.bodySmall
                      .copyWith(color: Colors.amber[900], fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(DashboardState state, DashboardNotifier notifier, bool isDanger) {
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
          // Location Toggle — drives Condition A/B switch
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
                _buildToggle('Cuaca Lokal', state.selectedLocationId == null,
                    () => notifier.selectLocation(null)),
                _buildToggle('IoT Monitor', state.selectedLocationId != null,
                    () => notifier.selectLocation('losari')),
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

  Widget _buildConditionA(DashboardState state, DashboardNotifier notifier) {
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
              weather: state.currentWeather,
              hourlyForecasts: state.hourlyForecasts,
              isLoading: state.isLoadingWeather,
              isUsingRealLocation: state.isUsingRealLocation,
              errorMessage: state.weatherError,
              onRefresh: () => notifier.initWeather(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // 5-day Forecast & Map Row
        _AnimatedSection(
          index: 1,
          child: Padding(
            padding: AppSpacing.paddingSection,
            child: Row(
              children: [
                Expanded(
                  flex: 13,
                  child: _build5DayForecast(state),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 10,
                  child: _buildMapPlaceholder(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Traffic Info
        _AnimatedSection(
          index: 2,
          child: Padding(
            padding: AppSpacing.paddingSection,
            child: _buildTrafficInfo(),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        // Recent Activity
        _AnimatedSection(
          index: 3,
          child: Padding(
            padding: AppSpacing.paddingSection,
            child: Row(
              children: [
                Text('Aktivitas Terkini',
                    style: AppTypography.headlineLarge
                        .copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _AnimatedSection(
          index: 4,
          child: SizedBox(
            height: 130,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              children: state.deviceStatuses.map((d) {
                return _buildRecentActivityCard(d, state, notifier);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _build5DayForecast(DashboardState state) {
    final days = ['WED', 'THR', 'FRI', 'SAT', 'SU'];
    final icons = ['☀️', '⛅', '🌧️', '☁️', '🌧️'];
    final temps = ['22°C', '21°C', '20°C', '24°C', '25°C'];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF455A64), // Darker grey-blue
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Berawan Sebagian',
                  style: AppTypography.caption.copyWith(color: Colors.white70)),
              const Icon(Icons.compare_arrows_rounded,
                  color: Colors.white70, size: 14),
            ],
          ),
          const SizedBox(height: 4),
          Text('Prakiraan 5 Hari',
              style: AppTypography.labelLarge.copyWith(color: Colors.white)),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (i) {
              return Column(
                children: [
                  Text(days[i],
                      style: AppTypography.caption
                          .copyWith(color: Colors.white70, fontSize: 10)),
                  const SizedBox(height: 4),
                  Text(icons[i], style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(temps[i],
                      style: AppTypography.labelSmall
                          .copyWith(color: Colors.white)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: AppColors.cardShadow,
        image: const DecorationImage(
          image: NetworkImage(
              'https://media.wired.com/photos/59269cd37034dc5f91bec0f1/master/w_2240,c_limit/GoogleMapTA.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.white54, BlendMode.lighten),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Lokasi', style: AppTypography.caption),
              const Icon(Icons.more_horiz_rounded,
                  color: AppColors.textHint, size: 14),
            ],
          ),
          Text('Makassar, Indonesia', style: AppTypography.labelMedium),
        ],
      ),
    );
  }

  Widget _buildTrafficInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5C6BC0),
                  borderRadius: AppSpacing.borderRadiusSmall,
                ),
                child: const Icon(Icons.traffic_rounded,
                    color: Colors.white, size: 16),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Informasi Lalu Lintas',
                        style: AppTypography.labelLarge
                            .copyWith(fontWeight: FontWeight.bold)),
                    Text('Sumber : Antara News',
                        style: AppTypography.caption.copyWith(
                          decoration: TextDecoration.underline,
                        )),
                  ],
                ),
              ),
              const Icon(Icons.warning_rounded, color: Colors.red, size: 20),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Demo — Jl. Urip Sumoharjo, Jl. AP Pettarani, dan sekitar Flyover.',
            style:
                AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard(
      DeviceStatus d, DashboardState state, DashboardNotifier notifier) {
    return _PressableCard(
      onTap: () => notifier.selectLocation(d.locationId),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
          ),
          borderRadius: AppSpacing.borderRadiusCard,
          boxShadow: AppColors.cardShadow,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -10,
              top: 10,
              child: Text(
                '⛈️',
                style: const TextStyle(fontSize: 60),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Indonesia',
                        style: AppTypography.caption
                            .copyWith(color: Colors.white70)),
                    Text(
                      d.locationName,
                      style: AppTypography.titleLarge.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Hujan Badai',
                        style: AppTypography.labelMedium
                            .copyWith(color: Colors.white70)),
                    Text('20°C',
                        style: AppTypography.labelLarge
                            .copyWith(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Condition B: Destination selected ────────────────

  Widget _buildConditionB(DashboardState state, DashboardNotifier notifier) {
    final sensors = state.sensorReadings;
    final snapshots = state.cameraSnapshots;
    final selected = sensors.firstWhere(
        (s) => s.locationId == state.selectedLocationId,
        orElse: () => sensors.first);
    final snapshot = snapshots.firstWhere(
        (s) => s.locationId == state.selectedLocationId,
        orElse: () => snapshots.first);
    final reviews = ref
        .watch(reviewsProvider)
        .where((r) =>
            r.destinationId == state.selectedLocationId &&
            r.status == ReviewStatus.approved)
        .toList();
    return Column(
      key: const ValueKey('conditionB'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Location Selection Chips
        _AnimatedSection(
          index: 0,
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children: sensors.map((s) {
                  final isActive = s.locationId == state.selectedLocationId;
                  return GestureDetector(
                    onTap: () => notifier.selectLocation(s.locationId),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: AppSpacing.md),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF2C3E50) : Colors.white,
                        borderRadius: AppSpacing.borderRadiusFull,
                        border: Border.all(
                          color: const Color(0xFF2C3E50),
                          width: 1.5,
                        ),
                        boxShadow: isActive ? AppColors.cardShadow : [],
                      ),
                      child: Center(
                        child: Text(
                          s.locationName,
                          style: AppTypography.labelMedium.copyWith(
                            color: isActive ? Colors.white : const Color(0xFF2C3E50),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),

        // 2. Hero Image Card with Overlapping Label
        _AnimatedSection(
          index: 1,
          child: Padding(
            padding: AppSpacing.paddingSection,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // Image container
                Container(
                  width: double.infinity,
                  height: 220,
                  margin: const EdgeInsets.only(bottom: 24), // Space for overlapping label
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: AppColors.cardShadow,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: AppNetworkImage(
                            imageUrl: snapshot.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: state.isUsingRealIoT && selected.locationId == 'losari'
                                  ? Colors.redAccent.withOpacity(0.85)
                                  : Colors.blueAccent.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  state.isUsingRealIoT && selected.locationId == 'losari'
                                      ? Icons.videocam_rounded
                                      : Icons.sim_card_outlined,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  state.isUsingRealIoT && selected.locationId == 'losari'
                                      ? 'Webcam RPi 4 (Real)'
                                      : 'Simulasi Alat',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Overlapping label
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selected.locationName,
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Makassar, Sulawesi Selatan',
                          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // 3. Current Condition Title
        _AnimatedSection(
          index: 2,
          child: Padding(
            padding: AppSpacing.paddingSection,
            child: Text(
              'Kondisi Terkini',
              style: AppTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 4. Suhu & Kelembapan Gauges (DHT22 Real Data)
        _AnimatedSection(
          index: 3,
          child: Padding(
            padding: AppSpacing.paddingSection,
            child: Row(
              children: [
                Expanded(
                  child: CustomGauge(
                    label: 'Suhu Udara',
                    value: selected.suhu.toStringAsFixed(0),
                    unit: '°C',
                    icon: Icons.thermostat_rounded,
                    percentage: (selected.suhu / 50).clamp(0.0, 1.0),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: CustomGauge(
                    label: 'Kelembapan',
                    value: selected.kelembapan.toStringAsFixed(0),
                    unit: '%',
                    icon: Icons.water_drop_rounded,
                    percentage: (selected.kelembapan / 100).clamp(0.0, 1.0),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // 5. Keramaian & Cuaca Badge
        _AnimatedSection(
          index: 4,
          child: Padding(
            padding: AppSpacing.paddingSection,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: AppColors.cardShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildGridItem(
                    Icons.groups_rounded,
                    'Keramaian',
                    selected.locationId == 'losari' && state.isUsingRealIoT && state.detectedFaces != null
                        ? '${snapshot.crowdLevel}\n(${state.detectedFaces} Wajah)'
                        : snapshot.crowdLevel,
                    Colors.blue,
                  ),
                  _buildBadgeItem(),
                ],
              ),
            ),
          ),
        ),
        // 6. Community Reviews Section
        _AnimatedSection(
          index: 5,
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.lg,
              bottom: AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ulasan Komunitas 💬',
                        style: AppTypography.headlineSmall),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: AppSpacing.borderRadiusFull,
                      ),
                      child: Text(
                        '${reviews.length} Ulasan',
                        style: AppTypography.labelSmall
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (reviews.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.rate_review_outlined,
                            size: 32,
                            color: AppColors.textHint.withOpacity(0.5)),
                        const SizedBox(height: 8),
                        Text(
                          'Belum ada ulasan untuk lokasi ini.',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: reviews.length,
                      itemBuilder: (_, i) {
                        final r = reviews[i];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: SizedBox(
                            width: 280,
                            child: CommunityReviewCard(
                              userName: r.userName,
                              comment: r.comment,
                              rating: r.rating,
                              date: r.timestamp,
                              isOfficial: r.isOfficial,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildGridItem(IconData icon, String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBadgeItem() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: const BoxDecoration(
            color: Color(0xFF3949AB),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x663949AB),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '🌤️',
              style: TextStyle(fontSize: 32),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Cuaca Terkini',
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
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

// ═════════════════════════════════════════════════════════════
//  Community Review Section — Mock data for Condition B
// ═════════════════════════════════════════════════════════════

class _MockReview {
  final String name;
  final String avatar;
  final double rating;
  final String text;
  final String timeAgo;

  const _MockReview({
    required this.name,
    required this.avatar,
    required this.rating,
    required this.text,
    required this.timeAgo,
  });
}

class _CommunityReviewSection extends StatelessWidget {
  final String locationName;

  const _CommunityReviewSection({required this.locationName});

  static const _reviews = [
    _MockReview(
      name: 'Andi Pratama',
      avatar: 'AP',
      rating: 4.5,
      text: 'Pemandangan sunset-nya luar biasa! Cocok untuk foto-foto. Suasana cukup ramai di sore hari tapi masih nyaman.',
      timeAgo: '2 jam lalu',
    ),
    _MockReview(
      name: 'Siti Rahma',
      avatar: 'SR',
      rating: 5.0,
      text: 'Tempat favorit saya untuk jalan sore. Angin sepoi-sepoi dan pemandangan laut yang cantik. Highly recommended! 🌅',
      timeAgo: '5 jam lalu',
    ),
    _MockReview(
      name: 'Budi Setiawan',
      avatar: 'BS',
      rating: 4.0,
      text: 'Fasilitas sudah bagus, tapi agak panas di siang hari. Sebaiknya datang setelah pukul 4 sore.',
      timeAgo: '1 hari lalu',
    ),
    _MockReview(
      name: 'Dewi Lestari',
      avatar: 'DL',
      rating: 4.8,
      text: 'Bersih dan tertata rapi. Pedagang lokal juga ramah-ramah. Pisang epe-nya juara! 🍌',
      timeAgo: '2 hari lalu',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: _reviews.map((r) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: AppSpacing.borderRadiusCard,
              boxShadow: AppColors.cardShadow,
              border: AppColors.cardBorder,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                        ),
                        borderRadius: AppSpacing.borderRadiusFull,
                      ),
                      child: Center(
                        child: Text(r.avatar,
                            style: AppTypography.labelSmall
                                .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    // Name & time
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.name, style: AppTypography.titleSmall),
                          Text(r.timeAgo, style: AppTypography.caption),
                        ],
                      ),
                    ),
                    // Rating
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: AppSpacing.borderRadiusFull,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: AppColors.warning),
                          const SizedBox(width: 2),
                          Text(r.rating.toStringAsFixed(1),
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w700,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(r.text, style: AppTypography.bodySmall),
              ],
            ),
          );
        }).toList(),
      ),
    );
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
