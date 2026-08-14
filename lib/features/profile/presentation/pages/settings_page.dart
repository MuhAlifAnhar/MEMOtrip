import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';

/// Settings Page — Language, Notifications, Theme controls.
/// PRD Section: "Profil → Pengaturan"
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // ─── State ──────────────────────────────────────────────
  String _selectedLanguage = 'id';
  bool _notifPromo = true;
  bool _notifCuaca = true;
  bool _notifEarlyWarning = true;
  bool _notifKomunitas = false;
  String _selectedTheme = 'system';

  // ─── Language Options ───────────────────────────────────
  static const _languages = [
    ('id', '🇮🇩 Bahasa Indonesia', 'Default'),
    ('en', '🇬🇧 English', 'Segera hadir'),
  ];

  // ─── Theme Options ─────────────────────────────────────
  static const _themes = [
    ('light', 'Terang', Icons.light_mode_rounded),
    ('dark', 'Gelap', Icons.dark_mode_rounded),
    ('system', 'Sistem', Icons.settings_brightness_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: CustomScrollView(
          slivers: [
            // ─── App Bar ──────────────────────────────────
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              stretch: true,
              backgroundColor: AppColors.primary,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Pengaturan ⚙️',
                          style: AppTypography.displaySmall
                              .copyWith(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Settings Content ─────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Language Section ──
                    _buildStaggered(
                      index: 0,
                      child: _buildSection(
                        icon: Icons.language_rounded,
                        title: 'Bahasa',
                        subtitle: 'Pilih bahasa aplikasi',
                        child: Column(
                          children: _languages.map((lang) {
                            final isSelected = _selectedLanguage == lang.$1;
                            final isAvailable = lang.$3 != 'Segera hadir';
                            return _buildLanguageOption(
                              key: lang.$1,
                              label: lang.$2,
                              badge: lang.$3,
                              isSelected: isSelected,
                              isAvailable: isAvailable,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Notifications Section ──
                    _buildStaggered(
                      index: 1,
                      child: _buildSection(
                        icon: Icons.notifications_active_rounded,
                        title: 'Notifikasi',
                        subtitle: 'Kelola pemberitahuan',
                        child: Column(
                          children: [
                            _buildNotifToggle(
                              icon: Icons.local_offer_rounded,
                              title: 'Promo & Rekomendasi',
                              subtitle: 'Destinasi populer & diskon',
                              value: _notifPromo,
                              onChanged: (v) =>
                                  setState(() => _notifPromo = v),
                            ),
                            _buildDivider(),
                            _buildNotifToggle(
                              icon: Icons.cloud_rounded,
                              title: 'Info Cuaca',
                              subtitle: 'Update cuaca BMKG real-time',
                              value: _notifCuaca,
                              onChanged: (v) =>
                                  setState(() => _notifCuaca = v),
                            ),
                            _buildDivider(),
                            _buildNotifToggle(
                              icon: Icons.warning_amber_rounded,
                              title: 'Peringatan Dini',
                              subtitle: 'Peringatan dini bencana alam',
                              value: _notifEarlyWarning,
                              iconColor: AppColors.warning,
                              onChanged: (v) =>
                                  setState(() => _notifEarlyWarning = v),
                            ),
                            _buildDivider(),
                            _buildNotifToggle(
                              icon: Icons.forum_rounded,
                              title: 'Komunitas',
                              subtitle: 'Ulasan & komentar baru',
                              value: _notifKomunitas,
                              onChanged: (v) =>
                                  setState(() => _notifKomunitas = v),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Theme Section ──
                    _buildStaggered(
                      index: 2,
                      child: _buildSection(
                        icon: Icons.palette_rounded,
                        title: 'Tema',
                        subtitle: 'Tampilan aplikasi',
                        child: Row(
                          children: _themes.map((t) {
                            final isSelected = _selectedTheme == t.$1;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => _selectedTheme = t.$1);
                                  _showThemeSnackbar(t.$2);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: EdgeInsets.only(
                                    right: t.$1 != 'system' ? AppSpacing.sm : 0,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.background,
                                    borderRadius: AppSpacing.borderRadiusMedium,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.divider,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withOpacity(0.25),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        t.$3,
                                        size: 22,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        t.$2,
                                        style: AppTypography.labelSmall.copyWith(
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── About Section ──
                    _buildStaggered(
                      index: 3,
                      child: _buildSection(
                        icon: Icons.info_outline_rounded,
                        title: 'Tentang Aplikasi',
                        subtitle: null,
                        child: Column(
                          children: [
                            _buildInfoRow('Versi', '1.0.0 (Beta)'),
                            _buildDivider(),
                            _buildInfoRow('Build', '2026.04.24'),
                            _buildDivider(),
                            _buildInfoRow('Platform', 'Flutter'),
                            _buildDivider(),
                            _buildTapRow(
                              icon: Icons.description_outlined,
                              title: 'Kebijakan Privasi',
                              onTap: () => _showComingSoon('Kebijakan Privasi'),
                            ),
                            _buildDivider(),
                            _buildTapRow(
                              icon: Icons.gavel_rounded,
                              title: 'Syarat & Ketentuan',
                              onTap: () =>
                                  _showComingSoon('Syarat & Ketentuan'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Clear Cache ──
                    _buildStaggered(
                      index: 4,
                      child: GestureDetector(
                        onTap: _showClearCacheDialog,
                        child: Container(
                          width: double.infinity,
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
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: AppSpacing.borderRadiusSmall,
                                ),
                                child: const Icon(Icons.cleaning_services_rounded,
                                    color: AppColors.error, size: 20),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Bersihkan Cache',
                                        style: AppTypography.titleSmall
                                            .copyWith(color: AppColors.error)),
                                    Text('Hapus data sementara aplikasi',
                                        style: AppTypography.caption),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded,
                                  color: AppColors.textHint),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.bottomSafeArea),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Section Builder ─────────────────────────────────────
  Widget _buildSection({
    required IconData icon,
    required String title,
    required String? subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: AppSpacing.borderRadiusSmall,
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.titleSmall),
                    if (subtitle != null)
                      Text(subtitle, style: AppTypography.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.md),
          // Content
          child,
        ],
      ),
    );
  }

  // ─── Language Option ──────────────────────────────────────
  Widget _buildLanguageOption({
    required String key,
    required String label,
    required String badge,
    required bool isSelected,
    required bool isAvailable,
  }) {
    return GestureDetector(
      onTap: isAvailable
          ? () {
              setState(() => _selectedLanguage = key);
              _showSnackbar('Bahasa diubah ke $label');
            }
          : () => _showComingSoon(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primarySurface
              : AppColors.background,
          borderRadius: AppSpacing.borderRadiusMedium,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(label, style: AppTypography.bodyMedium.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            )),
            const Spacer(),
            if (!isAvailable)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.textHint.withOpacity(0.15),
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: Text(badge,
                    style: AppTypography.caption.copyWith(fontSize: 10)),
              )
            else if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  size: 20, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  // ─── Notification Toggle ──────────────────────────────────
  Widget _buildNotifToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor ?? AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                )),
                Text(subtitle, style: AppTypography.caption.copyWith(
                  fontSize: 11,
                )),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: (v) {
              onChanged(v);
              _showSnackbar(
                v ? '$title diaktifkan' : '$title dinonaktifkan',
              );
            },
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primaryLight.withOpacity(0.4),
          ),
        ],
      ),
    );
  }

  // ─── Info Row ─────────────────────────────────────────────
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium),
          Text(value,
              style: AppTypography.labelMedium
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // ─── Tap Row ──────────────────────────────────────────────
  Widget _buildTapRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusSmall,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(title, style: AppTypography.bodyMedium)),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  // ─── Divider ──────────────────────────────────────────────
  Widget _buildDivider() {
    return const Divider(height: 1, color: AppColors.divider);
  }

  // ─── Stagger ──────────────────────────────────────────────
  Widget _buildStaggered({required int index, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (_, v, ch) => Transform.translate(
        offset: Offset(0, 16 * (1 - v)),
        child: Opacity(opacity: v, child: ch),
      ),
      child: child,
    );
  }

  // ─── Snackbars & Dialogs ──────────────────────────────────
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMedium),
        margin: const EdgeInsets.all(AppSpacing.lg),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showThemeSnackbar(String themeName) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.palette_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('Tema diubah ke "$themeName"'),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMedium),
        margin: const EdgeInsets.all(AppSpacing.lg),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.construction_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('$feature — Segera hadir!'),
          ],
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMedium),
        margin: const EdgeInsets.all(AppSpacing.lg),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusCard),
        title: Row(
          children: [
            const Icon(Icons.cleaning_services_rounded,
                color: AppColors.error, size: 22),
            const SizedBox(width: 8),
            Text('Bersihkan Cache', style: AppTypography.headlineSmall),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin membersihkan data cache? Ini tidak akan menghapus data akun Anda.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal',
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showSnackbar('Cache berhasil dibersihkan ✨');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadiusMedium),
            ),
            child: const Text('Bersihkan'),
          ),
        ],
      ),
    );
  }
}
