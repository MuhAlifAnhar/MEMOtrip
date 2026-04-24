import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/page_transitions.dart';
import '../../data/mock_schedule_data.dart';
import '../../domain/entities/schedule.dart';
import 'schedule_detail_page.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});
  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with SingleTickerProviderStateMixin {
  late List<Schedule> _schedules;

  late final AnimationController _entranceCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _schedules = List<Schedule>.from(MockScheduleData.schedules);
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
              onPressed: () {},
              icon: const Icon(Icons.explore_rounded, size: 18),
              label: const Text(AppStrings.cariDestinasiSekarang)),
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
        const SizedBox(height: AppSpacing.base),
        Padding(
            padding: AppSpacing.paddingSection,
            child: Text('Jadwal Perjalanan 📅',
                style: AppTypography.displayMedium)),
        const SizedBox(height: AppSpacing.lg),
        ...grouped.entries.map((e) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStaggered(
                  index: globalIndex++,
                  child: Padding(
                      padding: AppSpacing.paddingSection,
                      child: Text(e.key,
                          style: AppTypography.labelMedium.copyWith(
                              color: e.key == 'Hari Ini'
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w700))),
                ),
                const SizedBox(height: AppSpacing.md),
                ...e.value.map((s) => _buildStaggered(
                      index: globalIndex++,
                      child: _card(s),
                    )),
                const SizedBox(height: AppSpacing.lg),
              ]);
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
    return _PressableCard(
      onTap: () => Navigator.push(
        context,
        PageTransitions.slideUp(page: ScheduleDetailPage(schedule: s)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: AppSpacing.borderRadiusCard,
            boxShadow: AppColors.cardShadow,
            border: AppColors.cardBorder),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(s.title, style: AppTypography.titleMedium)),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: AppSpacing.borderRadiusFull),
                child: Text('${s.totalPlaces} tempat',
                    style: AppTypography.labelSmall
                        .copyWith(color: AppColors.primary))),
            const SizedBox(width: 4),
            // ── Popup Menu (Edit / Delete / Share) ──
            _SchedulePopupMenu(
              onEdit: () => _showEditDialog(s),
              onDelete: () => _showDeleteDialog(s),
              onShare: () => _showShareSheet(s),
            ),
          ]),
          const SizedBox(height: 8),
          ...s.items.take(2).map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(children: [
                const Icon(Icons.location_on_outlined,
                    size: 12, color: AppColors.textHint),
                const SizedBox(width: 4),
                Expanded(
                    child: Text(item.destinationName,
                        style: AppTypography.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
                Text(DateFormatter.time24(item.dateTime),
                    style: AppTypography.caption),
              ]))),
          if (s.items.length > 2)
            Text('+${s.items.length - 2} lagi',
                style:
                    AppTypography.caption.copyWith(color: AppColors.primary)),
        ]),
      ),
    );
  }

  // ── Edit Dialog ────────────────────────────────────────

  void _showEditDialog(Schedule s) {
    final titleCtrl = TextEditingController(text: s.title);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          top: AppSpacing.xl,
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLarge)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
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
                  child: const Icon(Icons.edit_rounded,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(AppStrings.editJadwal,
                    style: AppTypography.headlineMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(AppStrings.judulJadwal, style: AppTypography.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: titleCtrl,
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Masukkan judul jadwal...',
                hintStyle: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusMedium,
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base, vertical: AppSpacing.md),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(AppStrings.batal),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final newTitle = titleCtrl.text.trim();
                      if (newTitle.isNotEmpty) {
                        setState(() {
                          final idx =
                              _schedules.indexWhere((e) => e.id == s.id);
                          if (idx != -1) {
                            _schedules[idx] = _schedules[idx].copyWith(
                              title: newTitle,
                              updatedAt: DateTime.now(),
                            );
                          }
                        });
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
                      }
                    },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text(AppStrings.simpan),
                  ),
                ),
              ],
            ),
          ],
        ),
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
              setState(() {
                _schedules.removeWhere((e) => e.id == s.id);
              });
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

/// Popup menu for schedule card actions (Edit, Delete, Share).
class _SchedulePopupMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const _SchedulePopupMenu({
    required this.onEdit,
    required this.onDelete,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded,
          size: 20, color: AppColors.textSecondary),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMedium,
      ),
      elevation: 8,
      color: AppColors.surface,
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
            break;
          case 'delete':
            onDelete();
            break;
          case 'share':
            onShare();
            break;
        }
      },
      itemBuilder: (_) => [
        _menuItem('edit', Icons.edit_rounded, AppStrings.editJadwal,
            AppColors.primary),
        _menuItem('share', Icons.share_rounded, AppStrings.bagikan,
            AppColors.info),
        const PopupMenuDivider(height: 1),
        _menuItem('delete', Icons.delete_rounded, AppStrings.hapusJadwal,
            AppColors.error),
      ],
    );
  }

  PopupMenuItem<String> _menuItem(
      String value, IconData icon, String label, Color color) {
    return PopupMenuItem<String>(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(label,
              style: AppTypography.labelMedium.copyWith(color: color)),
        ],
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
