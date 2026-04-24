import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/page_transitions.dart';
import '../../../../core/utils/placeholder_images.dart';
import '../../../profile/presentation/pages/memory_gallery_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
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
    _fadeAnim = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _entranceCtrl, curve: Curves.easeOutCubic));
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
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
              padding:
                  const EdgeInsets.only(bottom: AppSpacing.bottomSafeArea),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.base),
                    // Header — avatar entrance
                    _buildStaggered(
                      index: 0,
                      child: Padding(
                        padding: AppSpacing.paddingSection,
                        child: Row(children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutBack,
                            builder: (_, v, child) => Transform.scale(
                                scale: 0.5 + 0.5 * v,
                                child: Opacity(opacity: v, child: child)),
                            child: CircleAvatar(
                                radius: 32,
                                backgroundColor: AppColors.primarySurface,
                                backgroundImage: CachedNetworkImageProvider(
                                  PlaceholderImages.avatar(),
                                ),
                                child: null),
                          ),
                          const SizedBox(width: AppSpacing.base),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                Text('Traveler',
                                    style: AppTypography.headlineLarge),
                                Text('traveler@memotrip.id',
                                    style: AppTypography.bodySmall),
                              ])),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                shape: BoxShape.circle,
                                boxShadow: AppColors.cardShadow),
                            child: const Icon(Icons.edit_rounded,
                                color: AppColors.primary, size: 20),
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Stats
                    _buildStaggered(
                      index: 1,
                      child: Padding(
                        padding: AppSpacing.paddingSection,
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: AppSpacing.borderRadiusCard),
                          child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: [
                                _stat('5', 'Kunjungan'),
                                Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.white24),
                                _stat('3', 'Jadwal'),
                                Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.white24),
                                _stat('2', 'Bookmark'),
                              ]),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    // Menu Items — staggered
                    _buildStaggered(
                      index: 2,
                      child: _menu(context, Icons.photo_library_rounded,
                          AppStrings.memori, 'Galeri foto perjalanan',
                          onTap: () => Navigator.push(
                            context,
                            PageTransitions.slideRight(
                                page: const MemoryGalleryPage()),
                          )),
                    ),
                    _buildStaggered(
                      index: 3,
                      child: _menu(
                          context,
                          Icons.history_rounded,
                          AppStrings.riwayatKunjungan,
                          'Destinasi yang pernah dikunjungi'),
                    ),
                    _buildStaggered(
                      index: 4,
                      child: _menu(context, Icons.bookmark_rounded,
                          'Bookmark', 'Destinasi tersimpan'),
                    ),
                    _buildStaggered(
                      index: 5,
                      child: _menu(context, Icons.settings_rounded,
                          AppStrings.pengaturan, 'Bahasa, notifikasi, tema'),
                    ),
                    const Divider(indent: 20, endIndent: 20, height: 32),
                    _buildStaggered(
                      index: 6,
                      child: _menu(
                          context,
                          Icons.admin_panel_settings_rounded,
                          'Admin Panel',
                          'Dashboard admin (web)',
                          isAdmin: true,
                          onTap: () =>
                              Navigator.pushNamed(context, '/admin')),
                    ),
                    _buildStaggered(
                      index: 7,
                      child: _menu(context, Icons.logout_rounded,
                          AppStrings.keluar, '',
                          isDestructive: true),
                    ),
                  ]),
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildStaggered({required int index, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 60)),
      curve: Curves.easeOutCubic,
      builder: (context, value, ch) {
        return Transform.translate(
          offset: Offset(0, 16 * (1 - value)),
          child: Opacity(opacity: value, child: ch),
        );
      },
      child: child,
    );
  }

  Widget _stat(String value, String label) => Column(children: [
        Text(value,
            style: AppTypography.headlineLarge.copyWith(color: Colors.white)),
        const SizedBox(height: 4),
        Text(label,
            style:
                AppTypography.labelSmall.copyWith(color: Colors.white70)),
      ]);

  Widget _menu(BuildContext context, IconData icon, String title,
      String subtitle,
      {bool isAdmin = false,
      bool isDestructive = false,
      VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppSpacing.borderRadiusCard,
          splashColor: AppColors.primary.withOpacity(0.08),
          highlightColor: AppColors.primary.withOpacity(0.04),
          onTap: onTap,
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.error.withOpacity(0.1)
                    : isAdmin
                        ? AppColors.warning.withOpacity(0.1)
                        : AppColors.primarySurface,
                borderRadius: AppSpacing.borderRadiusSmall,
              ),
              child: Icon(icon,
                  color: isDestructive
                      ? AppColors.error
                      : isAdmin
                          ? AppColors.warning
                          : AppColors.primary,
                  size: 22),
            ),
            title: Text(title,
                style: AppTypography.titleSmall.copyWith(
                    color: isDestructive ? AppColors.error : null)),
            subtitle: subtitle.isNotEmpty
                ? Text(subtitle, style: AppTypography.caption)
                : null,
            trailing: const Icon(Icons.chevron_right_rounded,
                color: AppColors.textHint),
            shape: RoundedRectangleBorder(
                borderRadius: AppSpacing.borderRadiusCard),
          ),
        ),
      ),
    );
  }
}
