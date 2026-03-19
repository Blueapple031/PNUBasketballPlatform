import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/recruitment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recruitment_provider.dart';
import 'widgets/progress_bar_widget.dart';
import 'widgets/applicant_card.dart';

class RecruitmentDetailScreen extends StatefulWidget {
  final String recruitmentId;

  const RecruitmentDetailScreen({super.key, required this.recruitmentId});

  @override
  State<RecruitmentDetailScreen> createState() =>
      _RecruitmentDetailScreenState();
}

class _RecruitmentDetailScreenState extends State<RecruitmentDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecruitmentProvider>().loadDetail(widget.recruitmentId);
    });
  }

  void _showApplyDialog() {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('신청하기'),
        content: TextField(
          controller: messageController,
          decoration: const InputDecoration(
            hintText: '한줄 메시지 (선택)',
            border: OutlineInputBorder(),
          ),
          maxLength: 200,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<RecruitmentProvider>();
              final success = await provider.apply(
                widget.recruitmentId,
                message: messageController.text.trim().isEmpty
                    ? null
                    : messageController.text.trim(),
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '신청 완료!' : (provider.errorMessage ?? '신청 실패')),
                    backgroundColor: success ? AppColors.classTeal : Colors.red,
                  ),
                );
              }
            },
            child: const Text('신청'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleConfirm() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('모집 확정'),
        content: const Text('모집을 확정하고 경기를 생성할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('확정')),
        ],
      ),
    );
    if (confirmed != true) return;

    final provider = context.read<RecruitmentProvider>();
    final success = await provider.confirm(widget.recruitmentId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '모집이 확정되었습니다!' : (provider.errorMessage ?? '확정 실패')),
          backgroundColor: success ? AppColors.classTeal : Colors.red,
        ),
      );
    }
  }

  Future<void> _handleCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('모집 취소'),
        content: const Text('정말 모집을 취소할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('아니오')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            child: const Text('취소하기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final provider = context.read<RecruitmentProvider>();
    final success = await provider.cancel(widget.recruitmentId);
    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모집이 취소되었습니다')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? '취소 실패'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().currentUser;
    final dateFormat = DateFormat('M/d(E) HH:mm', 'ko');

    return Scaffold(
      appBar: AppBar(title: const Text('모집 상세')),
      body: Consumer<RecruitmentProvider>(
        builder: (context, provider, _) {
          final detail = provider.selectedRecruitment;
          if (provider.isLoading && detail == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (detail == null) {
            return Center(
              child: Text(provider.errorMessage ?? '모집글을 불러올 수 없습니다',
                  style: const TextStyle(color: AppColors.subText)),
            );
          }

          final isAuthor = currentUser?.userId == detail.authorId;

          return RefreshIndicator(
            onRefresh: () => provider.loadDetail(widget.recruitmentId),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(detail, dateFormat),
                  const SizedBox(height: 20),
                  ProgressBarWidget(
                    currentCount: detail.currentCount,
                    totalNeeded: detail.totalNeeded,
                  ),
                  const SizedBox(height: 24),
                  if (isAuthor && detail.isOpen) ...[
                    _buildApplicationsSection(detail, provider),
                    const SizedBox(height: 24),
                    _buildAuthorActions(detail),
                  ] else if (!isAuthor && detail.isOpen) ...[
                    _buildApplyButton(),
                  ],
                  if (!detail.isOpen) ...[
                    _buildStatusBanner(detail),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection(RecruitmentDetailModel detail, DateFormat dateFormat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.activeBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    detail.gameFormatDisplay,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.activeBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: detail.isOpen
                        ? AppColors.classTeal.withValues(alpha: 0.1)
                        : AppColors.subText.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    detail.statusDisplay,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: detail.isOpen ? AppColors.classTeal : AppColors.subText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _infoRow(Icons.person_outline, '모집자', detail.authorNickname),
            const SizedBox(height: 8),
            _infoRow(Icons.location_on_outlined, '장소', detail.locationName),
            const SizedBox(height: 8),
            _infoRow(
              Icons.access_time,
              '시간',
              '${dateFormat.format(detail.startAt)} ~ ${DateFormat('HH:mm').format(detail.endAt)}',
            ),
            if (detail.deadlineAt != null) ...[
              const SizedBox(height: 8),
              _infoRow(
                Icons.timer_outlined,
                '마감',
                dateFormat.format(detail.deadlineAt!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.subText),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontSize: 13, color: AppColors.subText)),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildApplicationsSection(
      RecruitmentDetailModel detail, RecruitmentProvider provider) {
    final pending =
        detail.applications.where((a) => a.isPending).toList();
    final accepted =
        detail.applications.where((a) => a.isAccepted).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '신청 목록 (${detail.applications.length})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (pending.isNotEmpty) ...[
          const Text('대기중', style: TextStyle(fontSize: 13, color: AppColors.alertOrange, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...pending.map((app) => ApplicantCard(
                application: app,
                onAccept: () => provider.acceptApplication(
                    detail.id, app.applicationId),
                onReject: () => provider.rejectApplication(
                    detail.id, app.applicationId),
              )),
        ],
        if (accepted.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('수락됨', style: TextStyle(fontSize: 13, color: AppColors.classTeal, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...accepted.map((app) => ApplicantCard(
                application: app,
                showActions: false,
              )),
        ],
      ],
    );
  }

  Widget _buildAuthorActions(RecruitmentDetailModel detail) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _handleCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.errorRed,
              side: const BorderSide(color: AppColors.errorRed),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('취소하기'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _handleConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.classTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('확정하기'),
          ),
        ),
      ],
    );
  }

  Widget _buildApplyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showApplyDialog,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('신청하기', style: TextStyle(fontSize: 16, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.activeBlue,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildStatusBanner(RecruitmentDetailModel detail) {
    final color = detail.status == 'CONFIRMED'
        ? AppColors.classTeal
        : detail.status == 'CANCELLED'
            ? AppColors.errorRed
            : AppColors.subText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        detail.statusDisplay,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
