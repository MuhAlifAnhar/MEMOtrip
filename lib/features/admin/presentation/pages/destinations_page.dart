import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../destination/data/mock_destination_data.dart';
import '../../../destination/domain/entities/destination.dart';

/// Admin Destinations Page — CRUD management for destination content.
/// PRD: "Edit deskripsi, fasilitas, jam operasional, video 360°"
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memotrip/features/destination/presentation/providers/destination_provider.dart';

/// Admin Destinations Page — CRUD management for destination content.
/// PRD: "Edit deskripsi, fasilitas, jam operasional, video 360°"
class DestinationsPage extends ConsumerStatefulWidget {
  const DestinationsPage({super.key});

  @override
  ConsumerState<DestinationsPage> createState() => _DestinationsPageState();
}

class _DestinationsPageState extends ConsumerState<DestinationsPage> {
  String _searchQuery = '';
  String _filterCategory = 'all';

  List<Destination> _getFiltered(List<Destination> destinations) {
    var list = destinations;
    if (_filterCategory != 'all') {
      list = list.where((d) => d.category == _filterCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((d) =>
              d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              d.address.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final destinations = ref.watch(destinationsProvider);
    final filtered = _getFiltered(destinations);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;

        return Padding(
          padding: EdgeInsets.all(isNarrow ? AppSpacing.base : AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                builder: (_, v, child) => Opacity(opacity: v, child: child),
                child: isNarrow
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Manajemen Destinasi',
                              style: AppTypography.headlineLarge),
                          const SizedBox(height: AppSpacing.xs),
                          Text('Kelola konten dan informasi destinasi wisata',
                              style: AppTypography.bodyMedium
                                  .copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _showAddEditDialog(context, null),
                              icon: const Icon(Icons.add_rounded, size: 20),
                              label: const Text('Tambah Destinasi'),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Manajemen Destinasi',
                                  style: AppTypography.displaySmall),
                              const SizedBox(height: AppSpacing.xs),
                              Text('Kelola konten dan informasi destinasi wisata',
                                  style: AppTypography.bodyMedium
                                      .copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showAddEditDialog(context, null),
                            icon: const Icon(Icons.add_rounded, size: 20),
                            label: const Text('Tambah Destinasi'),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Filters
              isNarrow
                  ? Column(
                      children: [
                        TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: AppTypography.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'Cari destinasi...',
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: AppColors.textHint, size: 20),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: AppSpacing.borderRadiusMedium,
                              borderSide: const BorderSide(color: AppColors.divider),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppSpacing.borderRadiusMedium,
                              borderSide: const BorderSide(color: AppColors.divider),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: AppSpacing.borderRadiusMedium,
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _filterCategory,
                              isExpanded: true,
                              style: AppTypography.bodyMedium,
                              items: const [
                                DropdownMenuItem(
                                    value: 'all', child: Text('Semua Kategori')),
                                DropdownMenuItem(
                                    value: 'pantai', child: Text('🏖️ Pantai')),
                                DropdownMenuItem(
                                    value: 'gunung', child: Text('⛰️ Gunung')),
                                DropdownMenuItem(
                                    value: 'kafe', child: Text('☕ Kafe')),
                                DropdownMenuItem(
                                    value: 'restoran', child: Text('🍽️ Restoran')),
                              ],
                              onChanged: (v) =>
                                  setState(() => _filterCategory = v ?? 'all'),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            onChanged: (v) => setState(() => _searchQuery = v),
                            style: AppTypography.bodyMedium,
                            decoration: InputDecoration(
                              hintText: 'Cari destinasi...',
                              prefixIcon: const Icon(Icons.search_rounded,
                                  color: AppColors.textHint, size: 20),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: AppSpacing.borderRadiusMedium,
                                borderSide: const BorderSide(color: AppColors.divider),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: AppSpacing.borderRadiusMedium,
                                borderSide: const BorderSide(color: AppColors.divider),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.base),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: AppSpacing.borderRadiusMedium,
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _filterCategory,
                                isExpanded: true,
                                style: AppTypography.bodyMedium,
                                items: const [
                                  DropdownMenuItem(
                                      value: 'all', child: Text('Semua Kategori')),
                                  DropdownMenuItem(
                                      value: 'pantai', child: Text('🏖️ Pantai')),
                                  DropdownMenuItem(
                                      value: 'gunung', child: Text('⛰️ Gunung')),
                                  DropdownMenuItem(
                                      value: 'kafe', child: Text('☕ Kafe')),
                                  DropdownMenuItem(
                                      value: 'restoran', child: Text('🍽️ Restoran')),
                                ],
                                onChanged: (v) =>
                                    setState(() => _filterCategory = v ?? 'all'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: AppSpacing.lg),

              // Stats bar
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base, vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: AppSpacing.borderRadiusSmall,
                ),
                child: isNarrow
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total: ${filtered.length} destinasi',
                              style: AppTypography.labelMedium
                                  .copyWith(color: AppColors.primary)),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: _categoryChips(destinations),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Text('Total: ${filtered.length} destinasi',
                              style: AppTypography.labelMedium
                                  .copyWith(color: AppColors.primary)),
                          const Spacer(),
                          ..._categoryChips(destinations),
                        ],
                      ),
              ),
              const SizedBox(height: AppSpacing.base),

          // Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppSpacing.borderRadiusCard,
                boxShadow: AppColors.cardShadow,
                border: AppColors.cardBorder,
              ),
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 48,
                              color: AppColors.textHint.withOpacity(0.5)),
                          const SizedBox(height: AppSpacing.md),
                          Text('Tidak ada destinasi ditemukan',
                              style: AppTypography.bodyMedium
                                  .copyWith(color: AppColors.textHint)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.base),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final d = filtered[index];
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 350 + (index * 50)),
                          curve: Curves.easeOutCubic,
                          builder: (_, v, child) => Transform.translate(
                            offset: Offset(0, 10 * (1 - v)),
                            child: Opacity(opacity: v, child: child),
                          ),
                          child: _buildRow(d),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  List<Widget> _categoryChips(List<Destination> destinations) {
    final counts = <String, int>{};
    for (final d in destinations) {
      counts[d.category] = (counts[d.category] ?? 0) + 1;
    }
    return counts.entries
        .map((e) => Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              child: Chip(
                label: Text('${_catEmoji(e.key)} ${e.value}',
                    style: AppTypography.labelSmall),
                backgroundColor: Colors.white,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ))
        .toList();
  }

  String _catEmoji(String cat) {
    switch (cat) {
      case 'pantai':
        return '🏖️';
      case 'gunung':
        return '⛰️';
      case 'kafe':
        return '☕';
      case 'restoran':
        return '🍽️';
      default:
        return '📍';
    }
  }

  Widget _buildRow(Destination d) {
    final hasHardware = d.hardwareId != null && d.hardwareId!.isNotEmpty;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 450;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base, vertical: 6),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: AppSpacing.borderRadiusSmall,
            ),
            child: Icon(Icons.landscape_rounded,
                color: Colors.white.withOpacity(0.7), size: 24),
          ),
          title: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                d.name,
                style: AppTypography.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _catColor(d.category).withOpacity(0.1),
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: Text(
                  '${_catEmoji(d.category)} ${d.category}',
                  style: AppTypography.labelSmall
                      .copyWith(color: _catColor(d.category)),
                ),
              ),
              if (hasHardware)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: AppSpacing.borderRadiusFull,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sensors_rounded,
                          size: 12, color: AppColors.success),
                      const SizedBox(width: 2),
                      Text('IoT',
                          style: AppTypography.labelSmall
                              .copyWith(color: AppColors.success, fontSize: 10)),
                    ],
                  ),
                ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 12, color: AppColors.textHint),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    d.address,
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.star_rounded, size: 14, color: AppColors.starFilled),
                const SizedBox(width: 2),
                Text(
                  '${d.rating} (${d.reviewCount})',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          trailing: isNarrow
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_rounded,
                          size: 18, color: AppColors.primary),
                      onPressed: () => _showAddEditDialog(context, d),
                      tooltip: 'Edit',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_rounded,
                          size: 18, color: AppColors.error),
                      onPressed: () => _confirmDelete(d),
                      tooltip: 'Hapus',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_rounded,
                          size: 20, color: AppColors.primary),
                      onPressed: () => _showAddEditDialog(context, d),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_rounded,
                          size: 20, color: AppColors.error),
                      onPressed: () => _confirmDelete(d),
                      tooltip: 'Hapus',
                    ),
                  ],
                ),
        );
      },
    );
  }

  Color _catColor(String cat) {
    switch (cat) {
      case 'pantai':
        return AppColors.chipBeach;
      case 'gunung':
        return AppColors.chipMountain;
      case 'kafe':
        return AppColors.chipCafe;
      case 'restoran':
        return AppColors.chipRestaurant;
      default:
        return AppColors.primary;
    }
  }

  void _confirmDelete(Destination d) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusCard),
        title: Text('Hapus Destinasi', style: AppTypography.headlineSmall),
        content: Text('Yakin ingin menghapus "${d.name}"?',
            style: AppTypography.bodyMedium),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              ref.read(destinationsProvider.notifier).deleteDestination(d.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('"${d.name}" telah dihapus'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, Destination? existing) {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final addressCtrl = TextEditingController(text: existing?.address ?? '');
    final latCtrl =
        TextEditingController(text: existing?.latitude.toString() ?? '-5.1350');
    final lngCtrl =
        TextEditingController(text: existing?.longitude.toString() ?? '119.4124');
    final facilitiesCtrl =
        TextEditingController(text: existing?.facilities.join(', ') ?? '');
    String category = existing?.category ?? 'pantai';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusCard),
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isEdit ? 'Edit Destinasi' : 'Tambah Destinasi',
                      style: AppTypography.headlineMedium),
                  const SizedBox(height: AppSpacing.xl),
                  // Name
                  _dialogField('Nama Destinasi', nameCtrl),
                  const SizedBox(height: AppSpacing.base),
                  // Category
                  Text('Kategori', style: AppTypography.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: ['pantai', 'gunung', 'kafe', 'restoran']
                        .map((c) => ChoiceChip(
                              label: Text('${_catEmoji(c)} $c'),
                              selected: category == c,
                              selectedColor: _catColor(c).withOpacity(0.2),
                              onSelected: (_) =>
                                  setDialogState(() => category = c),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: AppSpacing.base),
                  // Description
                  _dialogField('Deskripsi', descCtrl, maxLines: 4),
                  const SizedBox(height: AppSpacing.base),
                  // Address
                  _dialogField('Alamat', addressCtrl),
                  const SizedBox(height: AppSpacing.base),
                  // GPS
                  Row(children: [
                    Expanded(child: _dialogField('Latitude', latCtrl)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _dialogField('Longitude', lngCtrl)),
                  ]),
                  const SizedBox(height: AppSpacing.base),
                  // Facilities
                  _dialogField('Fasilitas (pisahkan koma)', facilitiesCtrl),
                  const SizedBox(height: AppSpacing.xl),
                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Batal')),
                      const SizedBox(width: AppSpacing.md),
                      ElevatedButton(
                        onPressed: () {
                          final newDest = Destination(
                            id: existing?.id ??
                                'new-${DateTime.now().millisecondsSinceEpoch}',
                            name: nameCtrl.text,
                            description: descCtrl.text,
                            category: category,
                            latitude:
                                double.tryParse(latCtrl.text) ?? -5.1350,
                            longitude:
                                double.tryParse(lngCtrl.text) ?? 119.4124,
                            address: addressCtrl.text,
                            rating: existing?.rating ?? 0.0,
                            reviewCount: existing?.reviewCount ?? 0,
                            facilities: facilitiesCtrl.text
                                .split(',')
                                .map((e) => e.trim())
                                .where((e) => e.isNotEmpty)
                                .toList(),
                            operatingHours:
                                existing?.operatingHours ?? const {},
                            hardwareId: existing?.hardwareId,
                          );
                          if (isEdit) {
                            ref
                                .read(destinationsProvider.notifier)
                                .updateDestination(newDest);
                          } else {
                            ref
                                .read(destinationsProvider.notifier)
                                .addDestination(newDest);
                          }
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(isEdit
                                ? '"${nameCtrl.text}" berhasil diperbarui'
                                : '"${nameCtrl.text}" berhasil ditambahkan'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ));
                        },
                        child: Text(isEdit ? 'Simpan' : 'Tambah'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dialogField(String label, TextEditingController ctrl,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: AppTypography.bodyMedium,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusMedium,
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
