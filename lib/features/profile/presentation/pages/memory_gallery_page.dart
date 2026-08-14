import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_network_image.dart';

import '../providers/memory_provider.dart';

/// Memory Gallery — CRUD-enabled photo grid synced with Firestore & Storage.
/// PRD Section 2 (Profil/Memori): "Galeri foto perjalanan"
class MemoryGalleryPage extends ConsumerStatefulWidget {
  const MemoryGalleryPage({super.key});

  @override
  ConsumerState<MemoryGalleryPage> createState() => _MemoryGalleryPageState();
}

class _MemoryGalleryPageState extends ConsumerState<MemoryGalleryPage> {
  String _selectedFilter = 'all';

  List<TravelMemory> _filtered(List<TravelMemory> all) {
    if (_selectedFilter == 'all') return all;
    return all.where((m) => m.category == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final memoryState = ref.watch(memoryProvider);
    final memories = _filtered(memoryState.memories);

    // Show errors via SnackBar
    ref.listen<MemoryState>(memoryProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });

    return Scaffold(
      body: Container(
        decoration:
            const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────────
            SliverAppBar(
              expandedHeight: 140,
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
                      Text('Memori Perjalanan 📸',
                          style: AppTypography.displaySmall
                              .copyWith(color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(
                        '${memoryState.memories.length} kenangan tersimpan',
                        style: AppTypography.bodyMedium
                            .copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Filter Chips ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip('all', 'Semua', Icons.grid_view_rounded),
                      _filterChip(
                          'pantai', '🏖️ Pantai', Icons.beach_access_rounded),
                      _filterChip(
                          'gunung', '⛰️ Gunung', Icons.terrain_rounded),
                      _filterChip('kafe', '☕ Kafe', Icons.coffee_rounded),
                      _filterChip('restoran', '🍽️ Restoran',
                          Icons.restaurant_rounded),
                    ],
                  ),
                ),
              ),
            ),

            // ── Stats bar ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    Text('${memories.length} foto',
                        style: AppTypography.labelMedium
                            .copyWith(color: AppColors.textSecondary)),
                    const Spacer(),
                    Icon(Icons.sort_rounded,
                        size: 18, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text('Terbaru',
                        style: AppTypography.labelSmall
                            .copyWith(color: AppColors.textHint)),
                  ],
                ),
              ),
            ),

            // ── Loading indicator ────────────────────────
            if (memoryState.isLoading && memoryState.memories.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            // ── Empty state ──────────────────────────────
            else if (memories.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutBack,
                    builder: (_, v, child) => Transform.scale(
                      scale: 0.8 + 0.2 * v,
                      child: Opacity(opacity: v, child: child),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.photo_library_outlined,
                            size: 64,
                            color: AppColors.textHint.withOpacity(0.3)),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          memoryState.memories.isEmpty
                              ? 'Belum ada memori. Tambahkan kenangan pertamamu!'
                              : 'Belum ada memori di kategori ini',
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.textHint),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            // ── Photo Grid ──────────────────────────────
            else
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildMemoryCard(memories[index], index),
                    childCount: memories.length,
                  ),
                ),
              ),

            // Bottom spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.bottomSafeArea),
            ),
          ],
        ),
      ),

      // ── FAB — Add new memory ────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_a_photo_rounded, color: Colors.white),
        label: Text('Tambah Memori',
            style: AppTypography.labelMedium.copyWith(color: Colors.white)),
      ),
    );
  }

  // ───────────────────────────────────────────────────────
  // Filter Chip
  // ───────────────────────────────────────────────────────

  Widget _filterChip(String key, String label, IconData icon) {
    final isSelected = _selectedFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: AppSpacing.borderRadiusFull,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ]
              : AppColors.cardShadow,
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────
  // Memory Card
  // ───────────────────────────────────────────────────────

  Widget _buildMemoryCard(TravelMemory memory, int index) {
    final row = index ~/ 2;
    final col = index % 2;
    final delay = row * 100 + col * 50;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 450 + delay),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Transform.translate(
        offset: Offset(0, 24 * (1 - v)),
        child: Transform.scale(
          scale: 0.9 + 0.1 * v,
          child: Opacity(opacity: v, child: child),
        ),
      ),
      child: _PressableCard(
        onTap: () => _showMemoryDetail(context, memory),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppSpacing.borderRadiusCard,
            boxShadow: AppColors.cardShadow,
            border: AppColors.cardBorder,
          ),
          child: ClipRRect(
            borderRadius: AppSpacing.borderRadiusCard,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Photo — from Firebase Storage URL
                memory.imageUrl.isNotEmpty
                    ? AppNetworkImage(
                        imageUrl: memory.imageUrl,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _gradientForCategory(memory.category),
                          ),
                        ),
                        child: Icon(
                          _iconForCategory(memory.category),
                          size: 48,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),

                // Category tint overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _gradientForCategory(memory.category)[0]
                            .withOpacity(0.1),
                        _gradientForCategory(memory.category)[1]
                            .withOpacity(0.2),
                      ],
                    ),
                  ),
                ),

                // Bottom info overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          memory.destinationName,
                          style: AppTypography.titleSmall
                              .copyWith(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormatter.shortDate(memory.date),
                          style: AppTypography.caption
                              .copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),

                // Category badge
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: AppSpacing.borderRadiusFull,
                    ),
                    child: Text(
                      _categoryLabel(memory.category),
                      style: AppTypography.caption
                          .copyWith(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────
  // Category helpers
  // ───────────────────────────────────────────────────────

  List<Color> _gradientForCategory(String cat) {
    switch (cat) {
      case 'pantai':
        return [const Color(0xFF4FC3F7), const Color(0xFF0288D1)];
      case 'gunung':
        return [const Color(0xFF66BB6A), const Color(0xFF388E3C)];
      case 'kafe':
        return [const Color(0xFFA1887F), const Color(0xFF5D4037)];
      case 'restoran':
        return [const Color(0xFFFF8A65), const Color(0xFFE64A19)];
      default:
        return [AppColors.primaryLight, AppColors.primary];
    }
  }

  IconData _iconForCategory(String cat) {
    switch (cat) {
      case 'pantai':
        return Icons.beach_access_rounded;
      case 'gunung':
        return Icons.terrain_rounded;
      case 'kafe':
        return Icons.coffee_rounded;
      case 'restoran':
        return Icons.restaurant_rounded;
      default:
        return Icons.landscape_rounded;
    }
  }

  String _categoryLabel(String cat) {
    switch (cat) {
      case 'pantai':
        return '🏖️ Pantai';
      case 'gunung':
        return '⛰️ Gunung';
      case 'kafe':
        return '☕ Kafe';
      case 'restoran':
        return '🍽️ Restoran';
      default:
        return '📍 Lainnya';
    }
  }

  // ───────────────────────────────────────────────────────
  // Detail Bottom Sheet (with Edit & Delete actions)
  // ───────────────────────────────────────────────────────

  void _showMemoryDetail(BuildContext context, TravelMemory memory) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
            // Handle
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

            // Memory image
            ClipRRect(
              borderRadius: AppSpacing.borderRadiusCard,
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: memory.imageUrl.isNotEmpty
                    ? AppNetworkImage(
                        imageUrl: memory.imageUrl,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _gradientForCategory(memory.category),
                          ),
                        ),
                        child: Icon(
                          _iconForCategory(memory.category),
                          size: 64,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Info
            Text(memory.destinationName,
                style: AppTypography.headlineMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(memory.caption, style: AppTypography.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_iconForCategory(memory.category),
                    size: 16, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(
                  _categoryLabel(memory.category),
                  style: AppTypography.caption,
                ),
                const SizedBox(width: 12),
                const Icon(Icons.calendar_today_rounded,
                    size: 14, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(
                  DateFormatter.fullDate(memory.date),
                  style: AppTypography.caption,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Actions — Edit, Delete, Close
            Row(
              children: [
                // Edit
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showAddEditDialog(context, existingMemory: memory);
                    },
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // Delete
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _confirmDelete(context, memory);
                    },
                    icon: Icon(Icons.delete_rounded,
                        size: 18, color: Colors.red.shade400),
                    label: Text('Hapus',
                        style: TextStyle(color: Colors.red.shade400)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.shade300),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // Close
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Tutup'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────
  // Delete confirmation
  // ───────────────────────────────────────────────────────

  void _confirmDelete(BuildContext context, TravelMemory memory) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Memori'),
        content: Text(
            'Apakah kamu yakin ingin menghapus memori "${memory.destinationName}"? '
            'Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(memoryProvider.notifier).deleteMemory(memory.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Memori berhasil dihapus'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('Hapus',
                style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────
  // Add / Edit Dialog (full-screen bottom sheet)
  // ───────────────────────────────────────────────────────

  void _showAddEditDialog(BuildContext context,
      {TravelMemory? existingMemory}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MemoryFormSheet(
        existingMemory: existingMemory,
        onSave: (destinationName, category, date, caption, imageBytes,
            imageExt) async {
          if (existingMemory != null) {
            // UPDATE
            await ref.read(memoryProvider.notifier).updateMemory(
                  memoryId: existingMemory.id,
                  destinationName: destinationName,
                  category: category,
                  date: date,
                  caption: caption,
                  existingImageUrl: existingMemory.imageUrl,
                  newImageBytes: imageBytes,
                  newImageExtension: imageExt,
                );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Memori berhasil diperbarui'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } else {
            // CREATE
            if (imageBytes == null || imageExt == null) return;
            await ref.read(memoryProvider.notifier).addMemory(
                  destinationName: destinationName,
                  category: category,
                  date: date,
                  caption: caption,
                  imageBytes: imageBytes,
                  imageExtension: imageExt,
                );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Memori berhasil ditambahkan!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// Memory Form Sheet — Stateful form for Add / Edit
// ══════════════════════════════════════════════════════════

class _MemoryFormSheet extends StatefulWidget {
  final TravelMemory? existingMemory;
  final Future<void> Function(
    String destinationName,
    String category,
    DateTime date,
    String caption,
    Uint8List? imageBytes,
    String? imageExt,
  ) onSave;

  const _MemoryFormSheet({this.existingMemory, required this.onSave});

  @override
  State<_MemoryFormSheet> createState() => _MemoryFormSheetState();
}

class _MemoryFormSheetState extends State<_MemoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _destinationCtrl;
  late final TextEditingController _captionCtrl;
  late String _category;
  late DateTime _date;
  Uint8List? _pickedImageBytes;
  String? _pickedImageExt;
  bool _isSaving = false;

  bool get _isEditing => widget.existingMemory != null;

  static const _categories = [
    ('pantai', '🏖️ Pantai'),
    ('gunung', '⛰️ Gunung'),
    ('kafe', '☕ Kafe'),
    ('restoran', '🍽️ Restoran'),
  ];

  @override
  void initState() {
    super.initState();
    final m = widget.existingMemory;
    _destinationCtrl =
        TextEditingController(text: m?.destinationName ?? '');
    _captionCtrl = TextEditingController(text: m?.caption ?? '');
    _category = m?.category ?? 'pantai';
    _date = m?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _destinationCtrl.dispose();
    _captionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final ext = picked.path.split('.').last.toLowerCase();
      setState(() {
        _pickedImageBytes = bytes;
        _pickedImageExt = ext.isEmpty ? 'jpg' : ext;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal Perjalanan',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // For new memories, require an image
    if (!_isEditing && _pickedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih foto terlebih dahulu'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    await widget.onSave(
      _destinationCtrl.text.trim(),
      _category,
      _date,
      _captionCtrl.text.trim(),
      _pickedImageBytes,
      _pickedImageExt,
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLarge)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
              child: Column(
                children: [
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
                  Text(
                    _isEditing ? 'Edit Memori' : 'Tambah Memori Baru',
                    style: AppTypography.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isEditing
                        ? 'Perbarui kenangan perjalananmu'
                        : 'Abadikan momen perjalananmu',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textHint),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Form ────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Photo picker
                      GestureDetector(
                        onTap: _pickImage,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 180,
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: AppSpacing.borderRadiusCard,
                            border: Border.all(
                              color: _pickedImageBytes != null
                                  ? AppColors.primary
                                  : AppColors.divider,
                              width: _pickedImageBytes != null ? 2 : 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: AppSpacing.borderRadiusCard,
                            child: _pickedImageBytes != null
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.memory(
                                        _pickedImageBytes!,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        bottom: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            borderRadius:
                                                AppSpacing.borderRadiusFull,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                  Icons.swap_horiz_rounded,
                                                  color: Colors.white,
                                                  size: 14),
                                              const SizedBox(width: 4),
                                              Text('Ganti Foto',
                                                  style: AppTypography.caption
                                                      .copyWith(
                                                          color:
                                                              Colors.white)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : _isEditing &&
                                        widget.existingMemory!.imageUrl
                                            .isNotEmpty
                                    ? Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          AppNetworkImage(
                                            imageUrl: widget
                                                .existingMemory!.imageUrl,
                                            fit: BoxFit.cover,
                                          ),
                                          Positioned(
                                            bottom: 8,
                                            right: 8,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.6),
                                                borderRadius: AppSpacing
                                                    .borderRadiusFull,
                                              ),
                                              child: Row(
                                                mainAxisSize:
                                                    MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                      Icons
                                                          .swap_horiz_rounded,
                                                      color: Colors.white,
                                                      size: 14),
                                                  const SizedBox(width: 4),
                                                  Text('Ganti Foto',
                                                      style: AppTypography
                                                          .caption
                                                          .copyWith(
                                                              color: Colors
                                                                  .white)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                              Icons
                                                  .add_photo_alternate_rounded,
                                              size: 48,
                                              color: AppColors.textHint
                                                  .withOpacity(0.4)),
                                          const SizedBox(
                                              height: AppSpacing.sm),
                                          Text('Ketuk untuk memilih foto',
                                              style: AppTypography.bodySmall
                                                  .copyWith(
                                                      color:
                                                          AppColors.textHint)),
                                        ],
                                      ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Destination name
                      TextFormField(
                        controller: _destinationCtrl,
                        decoration: InputDecoration(
                          labelText: 'Nama Destinasi',
                          hintText: 'Mis. Pantai Losari',
                          prefixIcon: const Icon(Icons.place_rounded),
                          border: OutlineInputBorder(
                            borderRadius: AppSpacing.borderRadiusMedium,
                          ),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Nama destinasi wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Category dropdown
                      DropdownButtonFormField<String>(
                        value: _category,
                        decoration: InputDecoration(
                          labelText: 'Kategori',
                          prefixIcon:
                              const Icon(Icons.category_rounded),
                          border: OutlineInputBorder(
                            borderRadius: AppSpacing.borderRadiusMedium,
                          ),
                        ),
                        items: _categories
                            .map((c) => DropdownMenuItem(
                                  value: c.$1,
                                  child: Text(c.$2),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _category = v);
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Date picker
                      GestureDetector(
                        onTap: _pickDate,
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Tanggal',
                              hintText:
                                  DateFormatter.fullDate(_date),
                              prefixIcon: const Icon(
                                  Icons.calendar_today_rounded),
                              border: OutlineInputBorder(
                                borderRadius:
                                    AppSpacing.borderRadiusMedium,
                              ),
                            ),
                            controller: TextEditingController(
                                text: DateFormatter.fullDate(_date)),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Caption
                      TextFormField(
                        controller: _captionCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Keterangan',
                          hintText: 'Ceritakan momen spesialmu...',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 48),
                            child: Icon(Icons.notes_rounded),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: AppSpacing.borderRadiusMedium,
                          ),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Keterangan wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Save button
                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppSpacing.borderRadiusMedium,
                            ),
                          ),
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  _isEditing
                                      ? Icons.save_rounded
                                      : Icons.add_a_photo_rounded,
                                  color: Colors.white),
                          label: Text(
                            _isSaving
                                ? 'Menyimpan...'
                                : _isEditing
                                    ? 'Simpan Perubahan'
                                    : 'Tambah Memori',
                            style: AppTypography.labelLarge
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// Pressable Card — tactile press-down scale animation
// ══════════════════════════════════════════════════════════

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
