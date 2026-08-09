import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../destination/data/mock_destination_data.dart';
import '../../../destination/domain/entities/review.dart';

/// Admin Moderation Page — Community content moderation.
/// PRD: "Validasi Review Pengguna, Penanganan Report, Komentar Terverifikasi Admin"
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memotrip/features/destination/presentation/providers/destination_provider.dart';
import '../../../destination/domain/entities/report_item.dart';

class ModerationPage extends ConsumerStatefulWidget {
  const ModerationPage({super.key});

  @override
  ConsumerState<ModerationPage> createState() => _ModerationPageState();
}

class _ModerationPageState extends ConsumerState<ModerationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allReviews = ref.watch(reviewsProvider);
    final pendingReviews = allReviews.where((r) => r.status == ReviewStatus.pending).toList();
    final approvedReviews = allReviews.where((r) => r.status == ReviewStatus.approved).toList();
    final reports = ref.watch(reportsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;

        return Padding(
          padding: EdgeInsets.all(isNarrow ? AppSpacing.base : AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Moderasi Konten',
                  style: isNarrow
                      ? AppTypography.headlineLarge
                      : AppTypography.displaySmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Validasi review pengguna dan tangani laporan konten',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Stats
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                children: [
                  _buildStatChip(
                      Icons.pending_actions_rounded,
                      '${pendingReviews.length} Menunggu',
                      AppColors.warning),
                  _buildStatChip(
                      Icons.check_circle_rounded,
                      '${approvedReviews.length} Disetujui',
                      AppColors.success),
                  _buildStatChip(
                      Icons.flag_rounded,
                      '${reports.length} Laporan',
                      AppColors.error),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Tabs
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppSpacing.borderRadiusCard,
                  boxShadow: AppColors.cardShadow,
                  border: AppColors.cardBorder,
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelStyle: isNarrow
                      ? AppTypography.labelSmall
                      : AppTypography.labelLarge,
                  isScrollable: isNarrow,
                  tabs: [
                    Tab(
                        text:
                            'Menunggu (${pendingReviews.length})'),
                    Tab(text: 'Disetujui (${approvedReviews.length})'),
                    Tab(text: 'Laporan (${reports.length})'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPendingTab(pendingReviews),
                    _buildApprovedTab(approvedReviews),
                    _buildReportsTab(reports, isNarrow),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.sm),
          Text(label,
              style: AppTypography.labelMedium
                  .copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ─── Pending Tab ──────────────────────────────────────

  Widget _buildPendingTab(List<Review> pendingReviews) {
    if (pendingReviews.isEmpty) {
      return _buildEmptyState(
          Icons.check_circle_outline_rounded, 'Semua review sudah divalidasi!');
    }
    return ListView.builder(
      itemCount: pendingReviews.length,
      itemBuilder: (_, i) => _buildReviewCard(pendingReviews[i],
          isPending: true),
    );
  }

  // ─── Approved Tab ─────────────────────────────────────

  Widget _buildApprovedTab(List<Review> approvedReviews) {
    if (approvedReviews.isEmpty) {
      return _buildEmptyState(
          Icons.rate_review_outlined, 'Belum ada review disetujui');
    }
    return ListView.builder(
      itemCount: approvedReviews.length,
      itemBuilder: (_, i) =>
          _buildReviewCard(approvedReviews[i], isPending: false),
    );
  }

  // ─── Reports Tab ──────────────────────────────────────

  Widget _buildReportsTab(List<ReportItem> reports, bool isNarrow) {
    if (reports.isEmpty) {
      return _buildEmptyState(
          Icons.flag_outlined, 'Tidak ada laporan konten');
    }
    return ListView.builder(
      itemCount: reports.length,
      itemBuilder: (_, i) => _buildReportCard(reports[i], isNarrow),
    );
  }

  Widget _buildReviewCard(Review r, {required bool isPending}) {
    final destName = _getDestinationName(r.destinationId);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: AppColors.cardShadow,
        border: isPending
            ? Border.all(color: AppColors.warning.withOpacity(0.3), width: 1)
            : AppColors.cardBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primarySurface,
                child: Text(
                  r.userName.isNotEmpty ? r.userName[0].toUpperCase() : '?',
                  style: AppTypography.titleMedium
                      .copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(r.userName, style: AppTypography.titleSmall),
                        if (r.isOfficial) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded,
                              size: 16, color: AppColors.primary),
                        ],
                      ],
                    ),
                    Text(
                      '$destName • ${_timeAgo(r.timestamp)}',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              if (r.rating != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.starFilled.withOpacity(0.1),
                    borderRadius: AppSpacing.borderRadiusFull,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 14, color: AppColors.starFilled),
                      const SizedBox(width: 2),
                      Text(r.rating!.toStringAsFixed(1),
                          style: AppTypography.labelSmall
                              .copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Comment
          Text(r.comment,
              style: AppTypography.bodyMedium.copyWith(height: 1.6)),
          const SizedBox(height: AppSpacing.base),
          // Actions
          if (isPending)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _rejectReview(r),
                  icon: const Icon(Icons.close_rounded,
                      size: 18, color: AppColors.error),
                  label: Text('Tolak',
                      style: AppTypography.labelMedium
                          .copyWith(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error)),
                ),
                const SizedBox(width: AppSpacing.md),
                ElevatedButton.icon(
                  onPressed: () => _approveReview(r),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Setujui'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildReportCard(ReportItem report, bool isNarrow) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: AppSpacing.borderRadiusSmall,
                ),
                child: const Icon(Icons.flag_rounded,
                    color: AppColors.error, size: 22),
              ),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dilaporkan oleh ${report.reporterName}',
                        style: AppTypography.titleSmall),
                    const SizedBox(height: 4),
                    Text('Alasan: ${report.reason}',
                        style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.error)),
                    const SizedBox(height: 4),
                    Text('Review ID: ${report.targetReviewId}',
                        style: AppTypography.caption),
                    Text(_timeAgo(report.timestamp),
                        style: AppTypography.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.visibility_rounded, size: 16),
                label: const Text('Detail / View'),
                onPressed: () => _showReportDetailsDialog(report),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text('Abaikan'),
                onPressed: () => _dismissReport(report),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.delete_outline_rounded, size: 16),
                label: const Text('Hapus Konten'),
                onPressed: () => _removeReportedContent(report),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showReportDetailsDialog(ReportItem report) {
    final allReviews = ref.read(reviewsProvider);
    Review review;
    try {
      review = allReviews.firstWhere((r) => r.id == report.targetReviewId);
    } catch (_) {
      review = Review(
        id: report.targetReviewId,
        userId: '',
        userName: 'Tidak Ditemukan',
        destinationId: '',
        comment: '(Ulasan telah dihapus atau tidak ditemukan di database)',
        rating: 0.0,
        timestamp: DateTime.now(),
      );
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusCard),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: AppSpacing.borderRadiusMedium,
              ),
              child: const Icon(Icons.flag_rounded, color: AppColors.error, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Detail Laporan Konten',
                style: AppTypography.headlineMedium,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reporter Info
              Text('INFORMASI LAPORAN', style: AppTypography.labelSmall.copyWith(color: AppColors.textHint)),
              const SizedBox(height: 6),
              Text('Pelapor: ${report.reporterName}', style: AppTypography.titleSmall),
              Text('Alasan: "${report.reason}"', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.error)),
              Text('Waktu Laporan: ${_timeAgo(report.timestamp)}', style: AppTypography.caption),
              const Divider(height: 24),

              // Reported Review Info
              Text('KONTEN YANG DILAPORKAN', style: AppTypography.labelSmall.copyWith(color: AppColors.textHint)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppSpacing.borderRadiusMedium,
                  border: Border.all(color: AppColors.divider, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.primarySurface,
                          child: Text(
                            review.userName.isNotEmpty ? review.userName[0].toUpperCase() : '?',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            review.userName,
                            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (review.rating != null && review.rating! > 0)
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 14, color: AppColors.starFilled),
                              const SizedBox(width: 2),
                              Text(review.rating!.toStringAsFixed(1), style: AppTypography.labelSmall),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      review.comment,
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Destinasi ID: ${review.destinationId}  •  Dibuat: ${review.timestamp.day}/${review.timestamp.month}/${review.timestamp.year}',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Tutup', style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _dismissReport(report);
            },
            child: const Text('Abaikan Laporan'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              _removeReportedContent(report);
            },
            child: const Text('Hapus Konten'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: AppColors.textHint.withOpacity(0.3)),
          const SizedBox(height: AppSpacing.md),
          Text(message, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }

  String _getDestinationName(String id) {
    return MockDestinationData.getById(id)?.name ?? id;
  }

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  void _approveReview(Review r) {
    ref.read(reviewsProvider.notifier).approveReview(r.id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Review dari ${r.userName} disetujui'),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _rejectReview(Review r) {
    ref.read(reviewsProvider.notifier).rejectReview(r.id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Review dari ${r.userName} ditolak'),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _dismissReport(ReportItem report) {
    ref.read(reportsProvider.notifier).dismissReport(report.id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Laporan diabaikan'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _removeReportedContent(ReportItem report) {
    ref.read(reportsProvider.notifier).deleteReport(report.id);
    ref.read(reviewsProvider.notifier).deleteReview(report.targetReviewId);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Konten dilaporkan telah dihapus'),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
    ));
  }
}
