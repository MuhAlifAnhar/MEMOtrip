import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';

/// Admin Analytics & Push Notification page.
/// PRD: "Trending Tracker, Manual Push Notification Sender"
class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Analitik & Notifikasi', style: AppTypography.displaySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Statistik penggunaan dan kirim notifikasi push',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ─── Trending Destinations ──────────────────────
          Text('🔥 Destinasi Trending', style: AppTypography.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text('Destinasi paling banyak dijadwalkan minggu ini',
              style: AppTypography.caption),
          const SizedBox(height: AppSpacing.md),
          _buildTrendingTable(),
          const SizedBox(height: AppSpacing.xxl),

          // ─── Activity Chart (Simplified bar chart) ─────
          Text('📊 Aktivitas Pengguna', style: AppTypography.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text('Jumlah jadwal dibuat per hari (7 hari terakhir)',
              style: AppTypography.caption),
          const SizedBox(height: AppSpacing.md),
          _buildBarChart(),
          const SizedBox(height: AppSpacing.xxl),

          // ─── Quick Stats ───────────────────────────────
          Text('📈 Ringkasan Minggu Ini', style: AppTypography.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                  child: _buildMiniStat(
                      'Pengguna Baru', '48', Icons.person_add_rounded,
                      AppColors.primary, '+12%')),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                  child: _buildMiniStat(
                      'Jadwal Dibuat', '156', Icons.calendar_today_rounded,
                      AppColors.success, '+8%')),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                  child: _buildMiniStat(
                      'Review Baru', '34', Icons.rate_review_rounded,
                      AppColors.warning, '+23%')),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                  child: _buildMiniStat(
                      'Foto Diunggah', '89', Icons.photo_library_rounded,
                      AppColors.info, '+15%')),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ─── Push Notification Sender ──────────────────
          Text('🔔 Kirim Push Notification',
              style: AppTypography.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text('Kirim notifikasi ke semua pengguna MEMOtrip',
              style: AppTypography.caption),
          const SizedBox(height: AppSpacing.md),
          _buildNotificationForm(),
          const SizedBox(height: AppSpacing.xxl),

          // ─── Notification History ──────────────────────
          Text('📋 Riwayat Notifikasi',
              style: AppTypography.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          _buildNotificationHistory(),
        ],
      ),
    );
  }

  // ─── Trending Table ──────────────────────────────────

  Widget _buildTrendingTable() {
    final trending = [
      _TrendingItem('Pantai Losari', 86, 4.7, '+15%', 1),
      _TrendingItem('Masjid 99 Kubah', 72, 4.8, '+22%', 2),
      _TrendingItem('CPI Makassar', 58, 4.5, '+5%', 3),
      _TrendingItem('Fort Rotterdam', 45, 4.6, '+10%', 4),
      _TrendingItem('Pallubasa Serigala', 38, 4.6, '+18%', 5),
    ];

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

  Widget _buildBarChart() {
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final values = [12, 18, 22, 15, 28, 35, 30];
    final maxVal = values.reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: AppColors.cardShadow,
        border: AppColors.cardBorder,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(days.length, (i) {
          final pct = values[i] / maxVal;
          final isMax = values[i] == maxVal.toInt();
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('${values[i]}',
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
                  Text(days[i],
                      style: AppTypography.labelSmall
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          );
        }),
      ),
    );
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

  Widget _buildNotificationHistory() {
    final history = [
      _NotifHistory(
          'Cuaca Ekstrem ⚠️',
          'Perhatian: Hujan lebat diprediksi sore ini di area Losari.',
          DateTime.now().subtract(const Duration(days: 1)),
          'all'),
      _NotifHistory(
          'Event Spesial 🎉',
          'Festival kuliner Makassar di Pantai Losari minggu ini!',
          DateTime.now().subtract(const Duration(days: 3)),
          'losari'),
      _NotifHistory(
          'Destinasi Baru',
          'Kopi Jilid kini tersedia di MEMOtrip. Cek sekarang!',
          DateTime.now().subtract(const Duration(days: 5)),
          'all'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: AppColors.cardShadow,
        border: AppColors.cardBorder,
      ),
      child: Column(
        children: history
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

  void _sendNotification() {
    if (_notifTitleCtrl.text.isEmpty || _notifBodyCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Judul dan isi notifikasi wajib diisi'),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _isSendingNotif = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isSendingNotif = false);
        _notifTitleCtrl.clear();
        _notifBodyCtrl.clear();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Notifikasi terkirim ke ${_notifTarget == "all" ? "semua pengguna" : "pengguna $_notifTarget"}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
      }
    });
  }
}

class _TrendingItem {
  final String name;
  final int scheduleCount;
  final double rating;
  final String trend;
  final int rank;

  const _TrendingItem(
      this.name, this.scheduleCount, this.rating, this.trend, this.rank);
}

class _NotifHistory {
  final String title;
  final String body;
  final DateTime sentAt;
  final String target;

  const _NotifHistory(this.title, this.body, this.sentAt, this.target);
}
