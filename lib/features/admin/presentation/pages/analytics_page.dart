import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/analytics_provider.dart';

/// Admin Analytics & Push Notification page.
/// PRD: "Trending Tracker, Manual Push Notification Sender"
/// Connected to Cloud Firestore for real-time data.
class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  bool _isSendingNotif = false;
  final _notifTitleCtrl = TextEditingController();
  final _notifBodyCtrl = TextEditingController();
  String _notifTarget = 'all';

  @override
  void dispose() {
    _notifTitleCtrl.dispose();
    _notifBodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(analyticsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;

        if (analytics.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: AppSpacing.base),
                Text('Memuat data analitik dari Firestore...',
                    style: AppTypography.bodyMedium),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(isNarrow ? AppSpacing.base : AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with refresh button
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Analitik & Notifikasi',
                            style: isNarrow
                                ? AppTypography.headlineLarge
                                : AppTypography.displaySmall),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Statistik real-time dari Cloud Firestore',
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref.read(analyticsProvider.notifier).refresh(),
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Refresh data',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ─── Firestore connection badge ──────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.08),
                  borderRadius: AppSpacing.borderRadiusFull,
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Terhubung ke Firestore (asia-southeast2)',
                      style: AppTypography.labelSmall
                          .copyWith(color: AppColors.success),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ─── Trending Destinations ──────────────────────
              Text('🔥 Destinasi Trending', style: AppTypography.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text('Destinasi paling banyak dijadwalkan (dari koleksi schedules)',
                  style: AppTypography.caption),
              const SizedBox(height: AppSpacing.md),
              isNarrow
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                          width: 600,
                          child: _buildTrendingTable(analytics.trending)),
                    )
                  : _buildTrendingTable(analytics.trending),
              const SizedBox(height: AppSpacing.xxl),

              // ─── Activity Chart ─────
              Text('📊 Aktivitas Pengguna', style: AppTypography.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text('Jumlah jadwal dibuat per hari (7 hari terakhir)',
                  style: AppTypography.caption),
              const SizedBox(height: AppSpacing.md),
              _buildBarChart(analytics.dailyActivity),
              const SizedBox(height: AppSpacing.xxl),

              // ─── Quick Stats ───────────────────────────────
              Text('📈 Ringkasan Minggu Ini', style: AppTypography.headlineSmall),
              const SizedBox(height: AppSpacing.md),
              _buildQuickStats(analytics.weeklyStats, isNarrow),
              const SizedBox(height: AppSpacing.xxl),

              // ─── Push Notification Sender ──────────────────
              Text('🔔 Kirim Push Notification',
                  style: AppTypography.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text('Kirim notifikasi ke semua pengguna MEMOtrip (tersimpan ke Firestore)',
                  style: AppTypography.caption),
              const SizedBox(height: AppSpacing.md),
              _buildNotificationForm(),
              const SizedBox(height: AppSpacing.xxl),

              // ─── Notification History ──────────────────────
              Text('📋 Riwayat Notifikasi',
                  style: AppTypography.headlineSmall),
              const SizedBox(height: AppSpacing.md),
              _buildNotificationHistory(analytics.notifications),
            ],
          ),
        );
      },
    );
  }

  // ─── Trending Table ──────────────────────────────────

  Widget _buildTrendingTable(List<TrendingDestination> trending) {
    if (trending.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppSpacing.borderRadiusCard,
          boxShadow: AppColors.cardShadow,
          border: AppColors.cardBorder,
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.trending_up_rounded,
                  size: 48, color: AppColors.textHint),
              const SizedBox(height: AppSpacing.md),
              Text('Belum ada data jadwal di Firestore',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: AppColors.cardShadow,
        border: AppColors.cardBorder,
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusCard)),
            ),
            child: Row(
              children: [
                SizedBox(
                    width: 40,
                    child: Text('#',
                        style: AppTypography.labelMedium
                            .copyWith(fontWeight: FontWeight.w700))),
                Expanded(
                    flex: 3,
                    child: Text('Destinasi',
                        style: AppTypography.labelMedium
                            .copyWith(fontWeight: FontWeight.w700))),
                Expanded(
                    child: Text('Jadwal',
                        style: AppTypography.labelMedium
                            .copyWith(fontWeight: FontWeight.w700))),
                Expanded(
                    child: Text('Rating',
                        style: AppTypography.labelMedium
                            .copyWith(fontWeight: FontWeight.w700))),
                Expanded(
                    child: Text('Trend',
                        style: AppTypography.labelMedium
                            .copyWith(fontWeight: FontWeight.w700))),
              ],
            ),
          ),
          // Rows
          ...trending.map((t) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: AppColors.divider, width: 0.5)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: t.rank <= 3
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.background,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${t.rank}',
                            style: AppTypography.labelMedium.copyWith(
                              color: t.rank <= 3
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 3,
                        child:
                            Text(t.name, style: AppTypography.titleSmall)),
                    Expanded(
                      child: Text('${t.scheduleCount}',
                          style: AppTypography.bodyMedium),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: AppColors.starFilled),
                          const SizedBox(width: 2),
                          Text(t.rating.toStringAsFixed(1),
                              style: AppTypography.bodyMedium),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: AppSpacing.borderRadiusFull,
                        ),
                        child: Text(
                          '📈 ${t.trend}',
                          style: AppTypography.labelSmall
                              .copyWith(color: AppColors.success),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ─── Bar Chart ────────────────────────────────────────

  Widget _buildBarChart(List<DailyActivity> dailyActivity) {
    if (dailyActivity.isEmpty) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppSpacing.borderRadiusCard,
          boxShadow: AppColors.cardShadow,
          border: AppColors.cardBorder,
        ),
        child: const Center(child: Text('Belum ada data aktivitas')),
      );
    }

    final maxVal = dailyActivity
        .map((d) => d.count)
        .fold(1, (a, b) => a > b ? a : b)
        .toDouble();

    return Container(
      height: 240,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: AppColors.cardShadow,
        border: AppColors.cardBorder,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: dailyActivity.map((d) {
          final pct = d.count / maxVal;
          final isMax = d.count == maxVal.toInt();
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('${d.count}',
                      style: AppTypography.labelSmall.copyWith(
                          color: isMax
                              ? AppColors.primary
                              : AppColors.textHint,
                          fontWeight:
                              isMax ? FontWeight.w700 : FontWeight.w400)),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: (120 * pct).clamp(8.0, 120.0),
                    decoration: BoxDecoration(
                      gradient: isMax
                          ? AppColors.primaryGradient
                          : LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                AppColors.primaryLight.withOpacity(0.4),
                                AppColors.primaryLight.withOpacity(0.7),
                              ],
                            ),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(d.dayLabel,
                      style: AppTypography.labelSmall
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Quick Stats ──────────────────────────────────────

  Widget _buildQuickStats(WeeklyStats stats, bool isNarrow) {
    if (isNarrow) {
      return Column(children: [
        Row(children: [
          Expanded(child: _buildMiniStat('Pengguna Aktif', '${stats.newUsers}',
              Icons.person_add_rounded, AppColors.primary, stats.usersChange)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _buildMiniStat('Jadwal Dibuat', '${stats.schedulesCreated}',
              Icons.calendar_today_rounded, AppColors.success, stats.schedulesChange)),
        ]),
        const SizedBox(height: AppSpacing.md),
        Row(children: [
          Expanded(child: _buildMiniStat('Review Baru', '${stats.newReviews}',
              Icons.rate_review_rounded, AppColors.warning, stats.reviewsChange)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _buildMiniStat('Foto Diunggah', '${stats.photosUploaded}',
              Icons.photo_library_rounded, AppColors.info, stats.photosChange)),
        ]),
      ]);
    }

    return Row(children: [
      Expanded(child: _buildMiniStat('Pengguna Aktif', '${stats.newUsers}',
          Icons.person_add_rounded, AppColors.primary, stats.usersChange)),
      const SizedBox(width: AppSpacing.lg),
      Expanded(child: _buildMiniStat('Jadwal Dibuat', '${stats.schedulesCreated}',
          Icons.calendar_today_rounded, AppColors.success, stats.schedulesChange)),
      const SizedBox(width: AppSpacing.lg),
      Expanded(child: _buildMiniStat('Review Baru', '${stats.newReviews}',
          Icons.rate_review_rounded, AppColors.warning, stats.reviewsChange)),
      const SizedBox(width: AppSpacing.lg),
      Expanded(child: _buildMiniStat('Foto Diunggah', '${stats.photosUploaded}',
          Icons.photo_library_rounded, AppColors.info, stats.photosChange)),
    ]);
  }

  // ─── Mini Stats ───────────────────────────────────────

  Widget _buildMiniStat(
      String title, String value, IconData icon, Color color, String change) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: AppColors.cardShadow,
        border: AppColors.cardBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: AppSpacing.borderRadiusSmall,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: Text(change,
                    style: AppTypography.labelSmall
                        .copyWith(color: AppColors.success)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(value,
              style: AppTypography.displaySmall
                  .copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(title, style: AppTypography.caption),
        ],
      ),
    );
  }

  // ─── Push Notification Form ───────────────────────────

  Widget _buildNotificationForm() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: AppColors.cardShadow,
        border: AppColors.cardBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text('Judul Notifikasi', style: AppTypography.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _notifTitleCtrl,
            style: AppTypography.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Contoh: Destinasi baru ditambahkan!',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: AppSpacing.borderRadiusMedium,
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          // Body
          Text('Isi Notifikasi', style: AppTypography.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _notifBodyCtrl,
            maxLines: 3,
            style: AppTypography.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Tulis pesan notifikasi...',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: AppSpacing.borderRadiusMedium,
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          // Target audience
          Text('Target', style: AppTypography.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              ChoiceChip(
                label: const Text('Semua Pengguna'),
                selected: _notifTarget == 'all',
                onSelected: (_) => setState(() => _notifTarget = 'all'),
                selectedColor: AppColors.primary.withOpacity(0.2),
              ),
              ChoiceChip(
                label: const Text('Pengguna Losari'),
                selected: _notifTarget == 'losari',
                onSelected: (_) =>
                    setState(() => _notifTarget = 'losari'),
                selectedColor: AppColors.primary.withOpacity(0.2),
              ),
              ChoiceChip(
                label: const Text('Pengguna CPI'),
                selected: _notifTarget == 'cpi',
                onSelected: (_) => setState(() => _notifTarget = 'cpi'),
                selectedColor: AppColors.primary.withOpacity(0.2),
              ),
              ChoiceChip(
                label: const Text('Pengguna 99 Kubah'),
                selected: _notifTarget == 'kubah99',
                onSelected: (_) =>
                    setState(() => _notifTarget = 'kubah99'),
                selectedColor: AppColors.primary.withOpacity(0.2),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          // Send Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isSendingNotif ? null : _sendNotification,
              icon: _isSendingNotif
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded, size: 20),
              label:
                  Text(_isSendingNotif ? 'Mengirim...' : 'Kirim Notifikasi'),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Notification History ─────────────────────────────

  Widget _buildNotificationHistory(List<NotificationItem> notifications) {
    if (notifications.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppSpacing.borderRadiusCard,
          boxShadow: AppColors.cardShadow,
          border: AppColors.cardBorder,
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.notifications_off_rounded,
                  size: 48, color: AppColors.textHint),
              const SizedBox(height: AppSpacing.md),
              Text('Belum ada notifikasi yang dikirim',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: AppColors.cardShadow,
        border: AppColors.cardBorder,
      ),
      child: Column(
        children: notifications
            .map((n) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
                  leading: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: AppSpacing.borderRadiusSmall,
                    ),
                    child: const Icon(Icons.notifications_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                  title: Text(n.title, style: AppTypography.titleSmall),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.body,
                          style: AppTypography.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(
                        'Target: ${n.target == "all" ? "Semua" : n.target} • ${_daysAgo(n.sentAt)}',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  String _daysAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays == 0) return 'Hari ini';
    if (diff.inDays == 1) return 'Kemarin';
    return '${diff.inDays} hari lalu';
  }

  void _sendNotification() async {
    if (_notifTitleCtrl.text.isEmpty || _notifBodyCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Judul dan isi notifikasi wajib diisi'),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _isSendingNotif = true);

    try {
      await ref.read(analyticsProvider.notifier).sendNotification(
            title: _notifTitleCtrl.text,
            body: _notifBodyCtrl.text,
            target: _notifTarget,
          );

      if (mounted) {
        _notifTitleCtrl.clear();
        _notifBodyCtrl.clear();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Notifikasi terkirim ke ${_notifTarget == "all" ? "semua pengguna" : "pengguna $_notifTarget"} & tersimpan di Firestore'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal mengirim: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSendingNotif = false);
    }
  }
}
