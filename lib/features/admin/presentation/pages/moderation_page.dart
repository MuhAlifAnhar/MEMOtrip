import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../destination/data/mock_destination_data.dart';
import '../../../destination/domain/entities/review.dart';

/// Admin Moderation Page — Community content moderation.
/// PRD: "Validasi Review Pengguna, Penanganan Report, Komentar Terverifikasi Admin"
class ModerationPage extends StatefulWidget {
  const ModerationPage({super.key});

  @override
  State<ModerationPage> createState() => _ModerationPageState();
}

class _ModerationPageState extends State<ModerationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Review> _pendingReviews;
  late List<Review> _approvedReviews;
  late List<_ReportItem> _reports;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Seed mock data
    final allReviews = MockDestinationData.reviews;
    _pendingReviews = [
      Review(
        id: 'rp1',
        userId: 'u10',
        userName: 'Irfan Hidayat',
        destinationId: 'losari',
        comment:
            'Tempatnya sangat indah! Sayangnya sampah masih berserakan di beberapa titik.',
        rating: 3.5,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        status: ReviewStatus.pending,
      ),
      Review(
        id: 'rp2',
        userId: 'u11',
        userName: 'Nurul Aini',
        destinationId: 'kubah99',
        comment: 'Masjidnya megah sekali, masyaAllah. Sangat recommended!',
        rating: 5.0,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        status: ReviewStatus.pending,
      ),
      Review(
        id: 'rp3',
        userId: 'u12',
        userName: 'Dimas Pratama',
        destinationId: 'cpi',
        comment: 'Bagus sih tapi tiket masuknya lumayan mahal.',
        rating: 3.0,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        status: ReviewStatus.pending,
      ),
    ];
    _approvedReviews = allReviews
        .where((r) => r.status == ReviewStatus.approved)
        .toList();
    _reports = [
      _ReportItem(
        id: 'rep1',
        reporterName: 'Andi Pratama',
        targetReviewId: 'r1',
        reason: 'Konten mengandung spam/iklan',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      _ReportItem(
        id: 'rep2',
        reporterName: 'Sari Dewi',
        targetReviewId: 'r4',
        reason: 'Komentar tidak sopan',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Moderasi Konten', style: AppTypography.displaySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Validasi review pengguna dan tangani laporan konten',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Stats
          Row(
            children: [
              _buildStatChip(
                  Icons.pending_actions_rounded,
                  '${_pendingReviews.length} Menunggu',
                  AppColors.warning),
              const SizedBox(width: AppSpacing.md),
              _buildStatChip(
                  Icons.check_circle_rounded,
                  '${_approvedReviews.length} Disetujui',
                  AppColors.success),
              const SizedBox(width: AppSpacing.md),
              _buildStatChip(
                  Icons.flag_rounded,
                  '${_reports.length} Laporan',
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
              labelStyle: AppTypography.labelLarge,
              tabs: [
                Tab(
                    text:
                        'Menunggu Validasi (${_pendingReviews.length})'),
                Tab(text: 'Disetujui (${_approvedReviews.length})'),
                Tab(text: 'Laporan (${_reports.length})'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPendingTab(),
                _buildApprovedTab(),
                _buildReportsTab(),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildPendingTab() {
    if (_pendingReviews.isEmpty) {
      return _buildEmptyState(
          Icons.check_circle_outline_rounded, 'Semua review sudah divalidasi!');
    }
    return ListView.builder(
      itemCount: _pendingReviews.length,
      itemBuilder: (_, i) => _buildReviewCard(_pendingReviews[i],
          isPending: true),
    );
  }

  // ─── Approved Tab ─────────────────────────────────────

  Widget _buildApprovedTab() {
    if (_approvedReviews.isEmpty) {
      return _buildEmptyState(
          Icons.rate_review_outlined, 'Belum ada review disetujui');
    }
    return ListView.builder(
      itemCount: _approvedReviews.length,
      itemBuilder: (_, i) =>
          _buildReviewCard(_approvedReviews[i], isPending: false),
    );
  }

  // ─── Reports Tab ──────────────────────────────────────

  Widget _buildReportsTab() {
    if (_reports.isEmpty) {
      return _buildEmptyState(
          Icons.flag_outlined, 'Tidak ada laporan konten');
    }
    return ListView.builder(
      itemCount: _reports.length,
      itemBuilder: (_, i) => _buildReportCard(_reports[i]),
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

  Widget _buildReportCard(_ReportItem report) {
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
    setState(() {
      _pendingReviews.remove(r);
      _approvedReviews.insert(
          0, r.copyWith(status: ReviewStatus.approved));
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Review dari ${r.userName} disetujui'),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _rejectReview(Review r) {
    setState(() => _pendingReviews.remove(r));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Review dari ${r.userName} ditolak'),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _dismissReport(_ReportItem report) {
    setState(() => _reports.remove(report));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Laporan diabaikan'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _removeReportedContent(_ReportItem report) {
    setState(() => _reports.remove(report));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Konten dilaporkan telah dihapus'),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
    ));
  }
}

/// Internal report item model.
class _ReportItem {
  final String id;
  final String reporterName;
  final String targetReviewId;
  final String reason;
  final DateTime timestamp;

  const _ReportItem({
    required this.id,
    required this.reporterName,
    required this.targetReviewId,
    required this.reason,
    required this.timestamp,
  });
}
