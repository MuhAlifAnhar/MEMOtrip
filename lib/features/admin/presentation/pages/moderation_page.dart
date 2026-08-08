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
                    _buildReportsTab(reports),
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

  Widget _buildReportsTab(List<ReportItem> reports) {
    if (reports.isEmpty) {
      return _buildEmptyState(
          Icons.flag_outlined, 'Tidak ada laporan konten');
    }
    return ListView.builder(
      itemCount: reports.length,
      itemBuilder: (_, i) => _buildReportCard(reports[i]),
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

  Widget _buildReportCard(ReportItem report) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.borderRadiusCard,
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusSmall,
            ),
            child: const Icon(Icons.flag_rounded,
                color: AppColors.error, size: 24),
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
                    style: AppTypography.bodySmall),
                const SizedBox(height: 4),
                Text('Review ID: ${report.targetReviewId}',
                    style: AppTypography.caption),
                Text(_timeAgo(report.timestamp),
                    style: AppTypography.caption),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: () => _dismissReport(report),
                child: const Text('Abaikan'),
              ),
              const SizedBox(width: AppSpacing.sm),
              ElevatedButton(
                onPressed: () => _removeReportedContent(report),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error),
                child: const Text('Hapus Konten'),
              ),
            ],
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
