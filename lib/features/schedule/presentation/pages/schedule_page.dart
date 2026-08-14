import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/page_transitions.dart';
import '../../../../core/utils/placeholder_images.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../data/mock_schedule_data.dart';
import '../../domain/entities/schedule.dart';
import '../../../destination/presentation/providers/destination_provider.dart';
import '../providers/schedule_provider.dart';
import '../widgets/schedule_editor_dialog.dart';
import 'schedule_detail_page.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});
  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage>
    with SingleTickerProviderStateMixin {
  late List<Schedule> _schedules;

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
    ).animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic));
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    _schedules = ref.watch(schedulesProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: _schedules.isEmpty ? _buildEmpty() : _buildContent(),
          ),
        ),
        ),
      ),
    );
  }

  void _showCreateDialog() {
    final availableDestinations = ref.read(destinationsProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ScheduleEditorDialog(
        availableDestinations: availableDestinations,
        onSave: (title, items) {
          final currentUser = ref.read(authUserProvider).value;
          final newSchedule = Schedule(
            id: 's_${DateTime.now().millisecondsSinceEpoch}',
            userId: currentUser?.uid ?? 'u1',
            title: title,
            items: items,
            createdAt: DateTime.now(),
          );
          ref.read(schedulesProvider.notifier).addSchedule(newSchedule);
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Jadwal baru berhasil dibuat!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadiusMedium),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + 0.2 * value,
            child: Opacity(opacity: value, child: child),
          );
        },
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.calendar_month_outlined,
              size: 80, color: AppColors.textHint.withOpacity(0.3)),
          const SizedBox(height: AppSpacing.xl),
          Text(AppStrings.jadwalKosong, style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text('Mulai rencanakan perjalananmu!',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
              onPressed: _showCreateDialog,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Buat Jadwal Baru')),
        ]),
      ),
    );
  }

  Widget _buildContent() {
    final grouped = <String, List<Schedule>>{};
    for (final s in _schedules) {
      final d = s.items.isNotEmpty ? s.items.first.dateTime : s.createdAt;
      grouped.putIfAbsent(DateFormatter.dayLabel(d), () => []).add(s);
    }

    int globalIndex = 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.bottomSafeArea),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: AppSpacing.lg),

        // ═══════════════════════════════════════════════════════
        // 1. HERO HEADER — Illustration + CTA
        // ═══════════════════════════════════════════════════════
        _buildStaggered(
          index: globalIndex++,
          child: Padding(
            padding: AppSpacing.paddingSection,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ayo Rencanakan\nPerjalananmu\nSelanjutnya !!',
                  style: AppTypography.displayMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Illustration row + CTA button
                Row(
                  children: [
                    // Travel illustration emojis
                    const Text('🗺️📅🧳🏖️🌴', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    // Tambah Jadwal button
                    Flexible(
                      child: GestureDetector(
                        onTap: _showCreateDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: AppSpacing.borderRadiusFull,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  'Tambah Jadwal',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // ═══════════════════════════════════════════════════════
        // 2. JADWAL KAMU ! Title
        // ═══════════════════════════════════════════════════════
        _buildStaggered(
          index: globalIndex++,
          child: Padding(
            padding: AppSpacing.paddingSection,
            child: Text(
              'Jadwal Kamu !',
              style: AppTypography.headlineLarge.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ═══════════════════════════════════════════════════════
        // 3. GROUPED SCHEDULE CARDS
        // ═══════════════════════════════════════════════════════
        ...grouped.entries.map((e) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day label with dot indicator
              _buildStaggered(
                index: globalIndex++,
                child: Padding(
                  padding: AppSpacing.paddingSection,
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: e.key == 'Hari Ini'
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        e.key,
                        style: AppTypography.titleMedium.copyWith(
                          color: e.key == 'Hari Ini'
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...e.value.map((s) => _buildStaggered(
                    index: globalIndex++,
                    child: _card(s),
                  )),
              const SizedBox(height: AppSpacing.lg),
            ],
          );
        }),
      ]),
    );
  }

  Widget _buildStaggered({required int index, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 450 + (index * 60)),
      curve: Curves.easeOutCubic,
      builder: (context, value, ch) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: ch),
        );
      },
      child: child,
    );
  }

  // ── Card Widget ────────────────────────────────────────

  Widget _card(Schedule s) {
    // Get the first item image URL if available
    final firstItem = s.items.isNotEmpty ? s.items.first : null;
    final imageUrl = firstItem?.destinationImageUrl ??
        PlaceholderImages.destination(s.id, w: 200, h: 200);
    final firstNote = s.items.isNotEmpty ? s.items.first.notes : null;
    final firstTime = firstItem != null
        ? DateFormatter.timeWita(firstItem.dateTime)
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Main Card ──
          _PressableCard(
            onTap: () => Navigator.push(
              context,
              PageTransitions.slideUp(page: ScheduleDetailPage(schedule: s)),
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppColors.cardShadow,
                border: AppColors.cardBorder,
              ),
              child: Row(
                children: [
                  // Left side: Edit button + info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          s.title,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Location count + time
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              '${s.totalPlaces} Tempat',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (firstTime.isNotEmpty) ...[
                              const SizedBox(width: 10),
                              Icon(Icons.access_time_rounded,
                                  size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                firstTime,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Right side: Thumbnail image
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AppNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Action Buttons Bar ──
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
            child: Row(
              children: [
                // Edit button (blue pill)
                _ActionChip(
                  icon: Icons.edit_rounded,
                  label: 'Edit',
                  color: AppColors.primary,
                  onTap: () => _showEditDialog(s),
                ),
                const SizedBox(width: 8),
                _ActionChip(
                  icon: Icons.delete_outline_rounded,
                  label: 'Hapus',
                  color: AppColors.error,
                  onTap: () => _showDeleteDialog(s),
                ),
                const SizedBox(width: 8),
                _ActionChip(
                  icon: Icons.share_outlined,
                  label: 'Bagikan',
                  color: AppColors.info,
                  onTap: () => _showShareSheet(s),
                ),
                const Spacer(),
                // WITA badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: AppSpacing.borderRadiusFull,
                  ),
                  child: Text(
                    'WITA',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Notes Bubble ──
          if (firstNote != null && firstNote.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.divider,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  '"$firstNote"',
                  style: AppTypography.bodySmall.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  // ── Edit Dialog ────────────────────────────────────────

  void _showEditDialog(Schedule s) {
    final availableDestinations = ref.read(destinationsProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ScheduleEditorDialog(
        initialSchedule: s,
        availableDestinations: availableDestinations,
        onSave: (title, items) {
          final updated = s.copyWith(
            title: title,
            items: items,
            updatedAt: DateTime.now(),
          );
          ref.read(schedulesProvider.notifier).updateSchedule(updated);
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.jadwalDiperbarui),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadiusMedium),
            ),
          );
        },
      ),
    );
  }

  // ── Delete Dialog ──────────────────────────────────────

  void _showDeleteDialog(Schedule s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusCard),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: AppSpacing.borderRadiusMedium,
              ),
              child:
                  const Icon(Icons.delete_rounded, color: AppColors.error, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(AppStrings.konfirmasiHapus,
                  style: AppTypography.headlineMedium),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.yakinHapusJadwal,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.05),
                borderRadius: AppSpacing.borderRadiusMedium,
                border: Border.all(
                    color: AppColors.error.withOpacity(0.15), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 16, color: AppColors.error),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text('"${s.title}"',
                        style: AppTypography.titleSmall
                            .copyWith(color: AppColors.error)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.batal,
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(schedulesProvider.notifier).deleteSchedule(s.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppStrings.jadwalDihapus),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.borderRadiusMedium),
                ),
              );
            },
            icon: const Icon(Icons.delete_forever_rounded, size: 18),
            label: const Text(AppStrings.hapus),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Share Sheet ────────────────────────────────────────

  String _buildShareText(Schedule s) {
    final buffer = StringBuffer();
    buffer.writeln('📅 *${s.title}* — MEMOtrip');
    buffer.writeln('━━━━━━━━━━━━━━━━');
    buffer.writeln('📍 ${s.totalPlaces} Destinasi');
    buffer.writeln('⏱️ Estimasi: ${s.estimatedHours.toStringAsFixed(1)} Jam');
    buffer.writeln('');
    for (int i = 0; i < s.items.length; i++) {
      final item = s.items[i];
      buffer.writeln(
          '${i + 1}. ${item.destinationName}  •  ${DateFormatter.timeWita(item.dateTime)}');
      if (item.notes != null && item.notes!.isNotEmpty) {
        buffer.writeln('   📝 ${item.notes}');
      }
    }
    buffer.writeln('');
    buffer.writeln('Direncanakan via MEMOtrip 🗺️✨');
    return buffer.toString();
  }

  void _showShareSheet(Schedule s) {
    final shareText = _buildShareText(s);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLarge)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: AppSpacing.borderRadiusFull,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: AppSpacing.borderRadiusMedium,
                  ),
                  child: const Icon(Icons.share_rounded,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Text('${AppStrings.bagikanVia} 🚀',
                    style: AppTypography.headlineMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Schedule preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: AppSpacing.borderRadiusMedium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.title,
                      style: AppTypography.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                      '📍 ${s.totalPlaces} Tempat  •  ⏱️ ${s.estimatedHours.toStringAsFixed(1)} Jam',
                      style: AppTypography.caption),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Social Media Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShareButton(
                  icon: Icons.chat_rounded,
                  label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  onTap: () {
                    Navigator.pop(ctx);
                    _shareViaWhatsApp(shareText);
                  },
                ),
                _ShareButton(
                  icon: Icons.send_rounded,
                  label: 'Telegram',
                  color: const Color(0xFF0088CC),
                  onTap: () {
                    Navigator.pop(ctx);
                    _shareViaTelegram(shareText);
                  },
                ),
                _ShareButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Instagram',
                  color: const Color(0xFFE1306C),
                  onTap: () {
                    Navigator.pop(ctx);
                    _shareViaInstagram(shareText);
                  },
                ),
                _ShareButton(
                  icon: Icons.more_horiz_rounded,
                  label: 'Lainnya',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pop(ctx);
                    _shareNative(shareText);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Future<void> _shareViaWhatsApp(String text) async {
    final encoded = Uri.encodeComponent(text);
    final url = Uri.parse('whatsapp://send?text=$encoded');
    final fallback =
        Uri.parse('https://api.whatsapp.com/send?text=$encoded');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        await launchUrl(fallback, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      _shareNative(text);
    }
  }

  Future<void> _shareViaTelegram(String text) async {
    final encoded = Uri.encodeComponent(text);
    final url = Uri.parse('tg://msg?text=$encoded');
    final fallback =
        Uri.parse('https://t.me/share/url?text=$encoded');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        await launchUrl(fallback, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      _shareNative(text);
    }
  }

  Future<void> _shareViaInstagram(String text) async {
    // Instagram doesn't support text sharing directly — open the app and
    // also copy text to clipboard for user convenience, then fall back to
    // native share.
    _shareNative(text);
  }

  Future<void> _shareNative(String text) async {
    await Share.share(text);
  }
}

// ══════════════════════════════════════════════════════════
// ── Supporting Widgets ───────────────────────────────────
// ══════════════════════════════════════════════════════════

/// Action chip for Edit/Hapus/Bagikan below the card.
class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: AppSpacing.borderRadiusFull,
          border: Border.all(color: color.withOpacity(0.2), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Social media share button for the sharing bottom sheet.
class _ShareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: AppTypography.labelSmall
                  .copyWith(color: AppColors.textPrimary)),
        ],
      ),
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
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
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
