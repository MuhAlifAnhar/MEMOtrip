import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../destination/domain/entities/destination.dart';
import '../../domain/entities/schedule.dart';

/// Interactive dialog for creating or editing travel schedules.
/// Supports choosing multiple destinations, setting time and notes, and reordering.
class ScheduleEditorDialog extends StatefulWidget {
  final Schedule? initialSchedule;
  final List<Destination> availableDestinations;
  final Function(String title, List<ScheduleItem> items) onSave;

  const ScheduleEditorDialog({
    super.key,
    this.initialSchedule,
    required this.availableDestinations,
    required this.onSave,
  });

  @override
  State<ScheduleEditorDialog> createState() => _ScheduleEditorDialogState();
}

class _ScheduleEditorDialogState extends State<ScheduleEditorDialog> {
  late final TextEditingController _titleCtrl;
  late List<ScheduleItem> _selectedItems;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.initialSchedule?.title ?? '');
    _selectedItems = widget.initialSchedule != null
        ? List<ScheduleItem>.from(widget.initialSchedule!.items)
        : [];
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  // ── Date & Time Picker ───────────────────────────────
  Future<void> _pickDateTime(int index) async {
    final item = _selectedItems[index];
    final date = await showDatePicker(
      context: context,
      initialDate: item.dateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null) return;

    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(item.dateTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null) return;

    final finalDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      _selectedItems[index] = item.copyWith(dateTime: finalDateTime);
    });
  }

  // ── Add Destination Dropdown ─────────────────────────
  void _addDestination(Destination dest) {
    // Prevent duplicate destination adds if you want, or allow multiple stops.
    // Standard is allowing multiple stops (even same place at different times).
    final newItem = ScheduleItem(
      id: 'si_${DateTime.now().millisecondsSinceEpoch}_${dest.id}',
      destinationId: dest.id,
      destinationName: dest.name,
      destinationImageUrl: dest.imageUrls.isNotEmpty ? dest.imageUrls.first : null,
      dateTime: DateTime.now().add(Duration(hours: _selectedItems.length * 2)),
      latitude: dest.latitude,
      longitude: dest.longitude,
    );

    setState(() {
      _selectedItems.add(newItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: AppSpacing.xl,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusLarge)),
      ),
      child: Form(
        key: _formKey,
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
            
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: AppSpacing.borderRadiusMedium,
                  ),
                  child: Icon(
                    widget.initialSchedule != null ? Icons.edit_calendar_rounded : Icons.add_task_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  widget.initialSchedule != null ? 'Ubah Rencana Jadwal' : 'Tambah Rencana Jadwal',
                  style: AppTypography.headlineMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Schedule Title Input
            Text('Judul Rencana Perjalanan', style: AppTypography.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _titleCtrl,
              style: AppTypography.bodyMedium,
              validator: (val) => val == null || val.trim().isEmpty ? 'Judul tidak boleh kosong' : null,
              decoration: InputDecoration(
                hintText: 'Contoh: Rencana Jalan-Jalan Akhir Pekan...',
                hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
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

            // Destinations Header with Add Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Destinasi & Jadwal Waktu', style: AppTypography.labelLarge),
                PopupMenuButton<Destination>(
                  icon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_location_alt_rounded, color: AppColors.primary, size: 18),
                      const SizedBox(width: 4),
                      Text('Tambah Tempat', style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  onSelected: _addDestination,
                  itemBuilder: (context) {
                    return widget.availableDestinations.map((dest) {
                      return PopupMenuItem<Destination>(
                        value: dest,
                        child: Text(dest.name, style: AppTypography.bodyMedium),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Selected Destinations List
            if (_selectedItems.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppSpacing.borderRadiusMedium,
                  border: Border.all(color: AppColors.divider, width: 0.5),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.map_rounded, size: 36, color: AppColors.textHint.withOpacity(0.5)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Belum ada destinasi. Klik "+ Tambah Tempat" di atas.',
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                constraints: const BoxConstraints(maxHeight: 280),
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  itemCount: _selectedItems.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final item = _selectedItems.removeAt(oldIndex);
                      _selectedItems.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, idx) {
                    final item = _selectedItems[idx];
                    return Card(
                      key: ValueKey(item.id),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppSpacing.borderRadiusMedium,
                        side: const BorderSide(color: AppColors.divider, width: 0.5),
                      ),
                      color: AppColors.cardBackground,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title row with drag handle and remove button
                            Row(
                              children: [
                                ReorderableDragStartListener(
                                  index: idx,
                                  child: const Icon(Icons.drag_indicator_rounded, color: AppColors.textHint, size: 20),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item.destinationName,
                                    style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _selectedItems.removeAt(idx);
                                    });
                                  },
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                            const Divider(height: 12),
                            
                            // Time selection and note input row
                            Row(
                              children: [
                                // Time button
                                InkWell(
                                  onTap: () => _pickDateTime(idx),
                                  borderRadius: AppSpacing.borderRadiusSmall,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primarySurface,
                                      borderRadius: AppSpacing.borderRadiusSmall,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.access_time_rounded, size: 14, color: AppColors.primary),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${DateFormatter.dayLabel(item.dateTime)}, ${DateFormatter.time24(item.dateTime)}',
                                          style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Note input
                                Expanded(
                                  child: TextFormField(
                                    initialValue: item.notes,
                                    style: AppTypography.bodySmall,
                                    decoration: const InputDecoration(
                                      hintText: 'Tambahkan catatan...',
                                      hintStyle: TextStyle(color: AppColors.textHint, fontSize: 11),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 6),
                                    ),
                                    onChanged: (val) {
                                      _selectedItems[idx] = item.copyWith(notes: val.trim());
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: AppSpacing.xl),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(AppStrings.batal),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSave(_titleCtrl.text.trim(), _selectedItems);
                      }
                    },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: Text(widget.initialSchedule != null ? AppStrings.simpan : 'Buat'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
