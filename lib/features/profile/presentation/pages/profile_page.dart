import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/page_transitions.dart';
import '../../../../core/utils/placeholder_images.dart';
import '../../../../core/services/auth_service.dart';
import '../../../profile/presentation/pages/memory_gallery_page.dart';
import '../../../profile/presentation/pages/visit_history_page.dart';
import '../../../profile/presentation/pages/bookmark_page.dart';
import '../../../profile/presentation/pages/settings_page.dart';
import '../../../destination/data/mock_destination_data.dart';
import '../../data/mock_visit_data.dart';
import '../providers/visit_provider.dart';
import '../../../schedule/presentation/providers/schedule_provider.dart';
import '../../../../core/providers/auth_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../destination/presentation/providers/destination_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
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
    final currentUser = ref.watch(authUserProvider).value;
    final userDoc = ref.watch(userDocProvider).value;
    final displayName = userDoc?['name'] ?? currentUser?.displayName ?? 'Traveler';
    final photoURL = userDoc?['photoUrl'] ?? currentUser?.photoURL ?? PlaceholderImages.avatar();
    final currentUserId = currentUser?.uid ?? 'u1';

    final totalVisits = ref.watch(visitsProvider).where((v) => v.userId == currentUserId || v.userId == 'u1' || v.userId.isEmpty).length;
    final totalSchedules = ref.watch(schedulesProvider).where((s) => s.userId == currentUserId || s.userId == 'u1' || s.userId.isEmpty).length;
    final totalBookmarks = ref.watch(destinationsProvider).where((d) => d.isBookmarked).length;

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
                                  photoURL.isNotEmpty ? photoURL : PlaceholderImages.avatar(),
                                ),
                                child: null),
                          ),
                          const SizedBox(width: AppSpacing.base),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                Text(displayName,
                                    style: AppTypography.headlineLarge),
                                Text(currentUser?.email ?? 'traveler@memotrip.id',
                                    style: AppTypography.bodySmall),
                              ])),
                          Container(
                            decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                shape: BoxShape.circle,
                                boxShadow: AppColors.cardShadow),
                            child: IconButton(
                              icon: const Icon(Icons.edit_rounded,
                                  color: AppColors.primary, size: 20),
                              onPressed: () => _showEditProfileDialog(context),
                              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                              padding: EdgeInsets.zero,
                              splashRadius: 20,
                              tooltip: 'Ubah Profil',
                            ),
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
                                _stat('$totalVisits', 'Kunjungan'),
                                Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.white24),
                                _stat('$totalSchedules', 'Jadwal'),
                                Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.white24),
                                _stat('$totalBookmarks', 'Bookmark'),
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
                          'Destinasi yang pernah dikunjungi',
                          onTap: () => Navigator.push(
                            context,
                            PageTransitions.slideRight(
                                page: const VisitHistoryPage()),
                          )),
                    ),
                    _buildStaggered(
                      index: 4,
                      child: _menu(context, Icons.bookmark_rounded,
                          'Bookmark', 'Destinasi tersimpan',
                          onTap: () => Navigator.push(
                            context,
                            PageTransitions.slideRight(
                                page: const BookmarkPage()),
                          )),
                    ),
                    _buildStaggered(
                      index: 5,
                      child: _menu(context, Icons.settings_rounded,
                          AppStrings.pengaturan, 'Bahasa, notifikasi, tema',
                          onTap: () => Navigator.push(
                            context,
                            PageTransitions.slideRight(
                                page: const SettingsPage()),
                          )),
                    ),
                    const Divider(indent: 20, endIndent: 20, height: 32),
                    _buildStaggered(
                      index: 6,
                      child: _menu(
                          context,
                          Icons.admin_panel_settings_rounded,
                          'Panel Admin',
                          'Dashboard admin (web)',
                          isAdmin: true,
                          onTap: () =>
                              Navigator.pushNamed(context, '/admin')),
                    ),
                    _buildStaggered(
                      index: 7,
                      child: _menu(context, Icons.logout_rounded,
                          AppStrings.keluar, '',
                          isDestructive: true,
                          onTap: () => _showLogoutDialog(context)),
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

  // ─── Logout Dialog ──────────────────────────────────────
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusCard),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded,
                color: AppColors.error, size: 22),
            const SizedBox(width: 8),
            Text('Keluar', style: AppTypography.headlineSmall),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun MEMOtrip?',
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
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.signOut();
              // AuthGate will automatically redirect to LoginPage
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadiusMedium),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  // ─── Edit Profile Dialog ──────────────────────────────────
  void _showEditProfileDialog(BuildContext context) {
    final currentUser = ref.read(authUserProvider).value;
    final nameController = TextEditingController(text: currentUser?.displayName ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool isLoading = false;
        XFile? pickedFile;
        Uint8List? pickedBytes;
        String? pickedExtension;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.cardBackground,
              shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusCard),
              title: Text('Ubah Profil', style: AppTypography.headlineMedium),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Avatar Preview & Upload Trigger
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primarySurface,
                                border: Border.all(color: AppColors.primary, width: 2),
                                boxShadow: AppColors.cardShadow,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(45),
                                child: pickedBytes != null
                                    ? Image.memory(pickedBytes!, fit: BoxFit.cover)
                                    : (currentUser?.photoURL != null && currentUser!.photoURL!.isNotEmpty)
                                        ? CachedNetworkImage(
                                            imageUrl: currentUser.photoURL!,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => const Center(
                                                child: SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(strokeWidth: 2))),
                                            errorWidget: (context, url, error) => Image.network(PlaceholderImages.avatar()),
                                          )
                                        : Image.network(PlaceholderImages.avatar()),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.cardBackground, width: 2),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                                  padding: EdgeInsets.zero,
                                  onPressed: isLoading
                                      ? null
                                      : () async {
                                          try {
                                            final picker = ImagePicker();
                                            final file = await picker.pickImage(
                                              source: ImageSource.gallery,
                                              imageQuality: 80,
                                            );
                                            if (file != null) {
                                              final bytes = await file.readAsBytes();
                                              final ext = file.name.split('.').last.toLowerCase();
                                              setState(() {
                                                pickedFile = file;
                                                pickedBytes = bytes;
                                                pickedExtension = ext.isEmpty ? 'jpg' : ext;
                                              });
                                            }
                                          } catch (e) {
                                            debugPrint('Error picking image: $e');
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Gagal memilih gambar: $e'),
                                                  backgroundColor: AppColors.error,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                try {
                                  final picker = ImagePicker();
                                  final file = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 80,
                                  );
                                  if (file != null) {
                                    final bytes = await file.readAsBytes();
                                    final ext = file.name.split('.').last.toLowerCase();
                                    setState(() {
                                      pickedFile = file;
                                      pickedBytes = bytes;
                                      pickedExtension = ext.isEmpty ? 'jpg' : ext;
                                    });
                                  }
                                } catch (e) {
                                  debugPrint('Error picking image: $e');
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Gagal memilih gambar: $e'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                }
                              },
                        child: Text(
                          pickedFile == null ? 'Pilih Foto Baru' : 'Ubah Pilihan Foto',
                          style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: nameController,
                        style: AppTypography.bodyMedium,
                        decoration: InputDecoration(
                          labelText: 'Nama Lengkap',
                          labelStyle: AppTypography.bodySmall,
                          prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
                          filled: true,
                          fillColor: AppColors.textPrimary.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: AppSpacing.borderRadiusMedium,
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          if (v.trim().length < 2) {
                            return 'Nama minimal 2 karakter';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(ctx),
                  child: Text(
                    'Batal',
                    style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setState(() => isLoading = true);
                          try {
                            String photoUrl = currentUser?.photoURL ?? '';
                            if (pickedBytes != null && currentUser != null) {
                              photoUrl = await AuthService.uploadProfilePicture(
                                userId: currentUser.uid,
                                bytes: pickedBytes!,
                                extension: pickedExtension ?? 'jpg',
                              );
                            }
                            await AuthService.updateProfile(
                              name: nameController.text.trim(),
                              photoUrl: photoUrl,
                            );
                            ref.invalidate(authUserProvider);
                            ref.invalidate(userDocProvider);
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profil berhasil diperbarui'),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            }
                          } catch (e) {
                            setState(() => isLoading = false);
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal memperbarui profil: $e'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMedium),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
