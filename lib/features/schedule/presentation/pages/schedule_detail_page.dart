import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/placeholder_images.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/schedule.dart';

class ScheduleDetailPage extends StatefulWidget {
  final Schedule schedule;
  const ScheduleDetailPage({super.key, required this.schedule});

  @override
  State<ScheduleDetailPage> createState() => _ScheduleDetailPageState();
}

class _ScheduleDetailPageState extends State<ScheduleDetailPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final Animation<double> _fadeAnim;
  late Schedule _schedule;

  Schedule get schedule => _schedule;

  @override
  void initState() {
    super.initState();
    _schedule = widget.schedule;
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
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
        child: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: AppColors.primary,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () => _showShareSheet(),
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle),
                child: const Icon(Icons.share_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
            PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle),
                child: const Icon(Icons.more_vert_rounded,
                    color: Colors.white, size: 20),
              ),
              shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMedium),
              color: AppColors.surface,
              onSelected: (v) {
                if (v == 'edit') _showEditDialog();
                if (v == 'delete') _showDeleteDialog();
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit', child: Row(children: [
                  const Icon(Icons.edit_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text(AppStrings.editJadwal, style: AppTypography.labelMedium.copyWith(color: AppColors.primary)),
                ])),
                const PopupMenuDivider(height: 1),
                PopupMenuItem(value: 'delete', child: Row(children: [
                  const Icon(Icons.delete_rounded, size: 18, color: AppColors.error),
                  const SizedBox(width: 10),
                  Text(AppStrings.hapusJadwal, style: AppTypography.labelMedium.copyWith(color: AppColors.error)),
                ])),
              ],
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                AppNetworkImage(
                  imageUrl: PlaceholderImages.schedule(schedule.id),
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(schedule.title,
                          style: AppTypography.displaySmall
                              .copyWith(color: Colors.white)),
                      const SizedBox(height: 8),
                      Row(children: [
                        _chip('📍 ${schedule.totalPlaces} Tempat'),
                        const SizedBox(width: 8),
                        _chip(
                            '⏱️ ${schedule.estimatedHours.toStringAsFixed(1)} Jam'),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Route Map Placeholder
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, child) => Transform.translate(
                      offset: Offset(0, 15 * (1 - v)),
                      child: Opacity(opacity: v, child: child),
                    ),
                    child: ClipRRect(
                      borderRadius: AppSpacing.borderRadiusCard,
                      child: SizedBox(
                        width: double.infinity,
                        height: 180,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            AppNetworkImage(
                              imageUrl: PlaceholderImages.schedule('${schedule.id}_map', w: 600, h: 300),
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.primary.withOpacity(0.3),
                                    AppColors.primaryDark.withOpacity(0.5),
                                  ],
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.map_rounded,
                                    size: 40, color: Colors.white),
                                const SizedBox(height: 8),
                                Text('Peta Rute',
                                    style: AppTypography.labelMedium
                                        .copyWith(color: Colors.white)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // ── Action Buttons ──
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 550),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, child) => Opacity(opacity: v, child: child),
                    child: Row(children: [
                      Expanded(child: OutlinedButton.icon(
                        onPressed: _showEditDialog,
                        icon: const Icon(Icons.edit_rounded, size: 16),
                        label: const Text(AppStrings.editJadwal),
                      )),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: ElevatedButton.icon(
                        onPressed: () => _showShareSheet(),
                        icon: const Icon(Icons.share_rounded, size: 16),
                        label: const Text(AppStrings.bagikan),
                      )),
                      const SizedBox(width: AppSpacing.sm),
                      SizedBox(width: 48, height: 42, child: OutlinedButton(
                        onPressed: _showDeleteDialog,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error, width: 1),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(Icons.delete_outline_rounded, size: 18),
                      )),
                    ]),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    builder: (_, v, child) =>
                        Opacity(opacity: v, child: child),
                    child: Text('Urutan Destinasi',
                        style: AppTypography.headlineSmall),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Timeline items — staggered entrance
                  ...schedule.items.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    final isLast = i == schedule.items.length - 1;
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration:
                          Duration(milliseconds: 450 + (i * 120)),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, child) => Transform.translate(
                        offset: Offset(0, 25 * (1 - v)),
                        child: Opacity(opacity: v, child: child),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Timeline
                          Column(children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(
                                  milliseconds: 500 + (i * 150)),
                              curve: Curves.easeOutBack,
                              builder: (_, v, child) =>
                                  Transform.scale(
                                      scale: v, child: child),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]),
                                child: Center(
                                  child: Text('${i + 1}',
                                      style: AppTypography.labelSmall
                                          .copyWith(
                                              color: Colors.white,
                                              fontWeight:
                                                  FontWeight.w700)),
                                ),
                              ),
                            ),
                            if (!isLast)
                              Container(
                                  width: 2,
                                  height: 60,
                                  color: AppColors.divider),
                          ]),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(
                                  bottom: AppSpacing.md),
                              padding:
                                  const EdgeInsets.all(AppSpacing.base),
                              decoration: BoxDecoration(
                                  color: AppColors.cardBackground,
                                  borderRadius:
                                      AppSpacing.borderRadiusCard,
                                  boxShadow: AppColors.cardShadow),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(item.destinationName,
                                      style: AppTypography.titleSmall),
                                  const SizedBox(height: 4),
                                  Row(children: [
                                    const Icon(
                                        Icons.access_time_rounded,
                                        size: 12,
                                        color: AppColors.textHint),
                                    const SizedBox(width: 4),
                                    Text(
                                        DateFormatter.timeWita(
                                            item.dateTime),
                                        style: AppTypography.caption),
                                  ]),
                                  if (item.notes != null &&
                                      item.notes!.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(item.notes!,
                                        style: AppTypography.bodySmall),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: AppSpacing.bottomSafeArea),
                ],
              ),
            ),
          ),
        ),
      ]),
      ),
    );
  }

  Widget _chip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: AppSpacing.borderRadiusFull),
        child: Text(text,
            style: AppTypography.labelSmall.copyWith(color: Colors.white)),
      );

  // ── Edit Dialog ──
  void _showEditDialog() {
    final ctrl = TextEditingController(text: schedule.title);
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(top: AppSpacing.xl, left: AppSpacing.xl, right: AppSpacing.xl,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl),
        decoration: const BoxDecoration(color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLarge))),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: AppSpacing.borderRadiusFull))),
          const SizedBox(height: AppSpacing.lg),
          Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: AppSpacing.borderRadiusMedium),
              child: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 20)),
            const SizedBox(width: AppSpacing.md),
            Text(AppStrings.editJadwal, style: AppTypography.headlineMedium),
          ]),
          const SizedBox(height: AppSpacing.xl),
          Text(AppStrings.judulJadwal, style: AppTypography.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          TextField(controller: ctrl, style: AppTypography.bodyMedium,
            decoration: InputDecoration(filled: true, fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: AppSpacing.borderRadiusMedium, borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md))),
          const SizedBox(height: AppSpacing.xl),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text(AppStrings.batal))),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: ElevatedButton.icon(
              onPressed: () {
                final t = ctrl.text.trim();
                if (t.isNotEmpty) {
                  setState(() { _schedule = _schedule.copyWith(title: t, updatedAt: DateTime.now()); });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.jadwalDiperbarui), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating));
                }
              },
              icon: const Icon(Icons.check_rounded, size: 18), label: const Text(AppStrings.simpan))),
          ]),
        ]),
      ),
    );
  }

  // ── Delete Dialog ──
  void _showDeleteDialog() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusCard),
      title: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: AppSpacing.borderRadiusMedium),
          child: const Icon(Icons.delete_rounded, color: AppColors.error, size: 20)),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(AppStrings.konfirmasiHapus, style: AppTypography.headlineMedium)),
      ]),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(AppStrings.yakinHapusJadwal, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.md),
        Container(padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(color: AppColors.error.withOpacity(0.05), borderRadius: AppSpacing.borderRadiusMedium,
            border: Border.all(color: AppColors.error.withOpacity(0.15))),
          child: Row(children: [
            const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.error),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text('"${schedule.title}"', style: AppTypography.titleSmall.copyWith(color: AppColors.error))),
          ])),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.batal, style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary))),
        ElevatedButton.icon(
          onPressed: () { Navigator.pop(ctx); Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.jadwalDihapus), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating));
          },
          icon: const Icon(Icons.delete_forever_rounded, size: 18), label: const Text(AppStrings.hapus),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white)),
      ],
    ));
  }

  // ── Share ──
  String _buildShareText() {
    final b = StringBuffer();
    b.writeln('📅 *${schedule.title}* — MEMOtrip');
    b.writeln('━━━━━━━━━━━━━━━━');
    b.writeln('📍 ${schedule.totalPlaces} Destinasi  •  ⏱️ ${schedule.estimatedHours.toStringAsFixed(1)} Jam');
    b.writeln('');
    for (int i = 0; i < schedule.items.length; i++) {
      final it = schedule.items[i];
      b.writeln('${i + 1}. ${it.destinationName}  •  ${DateFormatter.timeWita(it.dateTime)}');
      if (it.notes != null && it.notes!.isNotEmpty) b.writeln('   📝 ${it.notes}');
    }
    b.writeln('');
    b.writeln('Direncanakan via MEMOtrip 🗺️✨');
    return b.toString();
  }

  void _showShareSheet() {
    final text = _buildShareText();
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (ctx) => Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: const BoxDecoration(color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLarge))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: AppSpacing.borderRadiusFull)),
        const SizedBox(height: AppSpacing.lg),
        Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: AppSpacing.borderRadiusMedium),
            child: const Icon(Icons.share_rounded, color: AppColors.primary, size: 20)),
          const SizedBox(width: AppSpacing.md),
          Text('${AppStrings.bagikanVia} 🚀', style: AppTypography.headlineMedium),
        ]),
        const SizedBox(height: AppSpacing.xl),
        Container(width: double.infinity, padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(color: AppColors.background, borderRadius: AppSpacing.borderRadiusMedium),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(schedule.title, style: AppTypography.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text('📍 ${schedule.totalPlaces} Tempat  •  ⏱️ ${schedule.estimatedHours.toStringAsFixed(1)} Jam', style: AppTypography.caption),
          ])),
        const SizedBox(height: AppSpacing.xl),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _shareBtn(Icons.chat_rounded, 'WhatsApp', const Color(0xFF25D366), () { Navigator.pop(ctx); _launchShare('whatsapp://send?text=${Uri.encodeComponent(text)}', 'https://api.whatsapp.com/send?text=${Uri.encodeComponent(text)}', text); }),
          _shareBtn(Icons.send_rounded, 'Telegram', const Color(0xFF0088CC), () { Navigator.pop(ctx); _launchShare('tg://msg?text=${Uri.encodeComponent(text)}', 'https://t.me/share/url?text=${Uri.encodeComponent(text)}', text); }),
          _shareBtn(Icons.camera_alt_rounded, 'Instagram', const Color(0xFFE1306C), () { Navigator.pop(ctx); _nativeShare(text); }),
          _shareBtn(Icons.more_horiz_rounded, 'Lainnya', AppColors.primary, () { Navigator.pop(ctx); _nativeShare(text); }),
        ]),
        const SizedBox(height: AppSpacing.lg),
      ]),
    ));
  }

  Widget _shareBtn(IconData icon, String label, Color color, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 56, height: 56, decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 26)),
      const SizedBox(height: 8),
      Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textPrimary)),
    ]),
  );

  Future<void> _launchShare(String appUrl, String webUrl, String fallbackText) async {
    try {
      final u = Uri.parse(appUrl);
      if (await canLaunchUrl(u)) { await launchUrl(u); } else { await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication); }
    } catch (_) { _nativeShare(fallbackText); }
  }

  Future<void> _nativeShare(String text) async {
    await Share.share(text);
  }
}
