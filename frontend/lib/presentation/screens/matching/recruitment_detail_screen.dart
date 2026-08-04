import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/recruitment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recruitment_provider.dart';
import 'widgets/applicant_card.dart';
import 'widgets/progress_bar_widget.dart';

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

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('번개 신청하기'),
        content: TextField(
          controller: messageController,
          decoration: const InputDecoration(
            hintText: '모집자에게 남길 한줄 메시지 (선택)',
          ),
          maxLength: 200,
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final provider = context.read<RecruitmentProvider>();
              final message = messageController.text.trim();
              final success = await provider.apply(
                widget.recruitmentId,
                message: message.isEmpty ? null : message,
              );
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? '신청이 완료되었습니다.'
                        : (provider.errorMessage ?? '신청에 실패했습니다.'),
                  ),
                  backgroundColor:
                      success ? AppColors.classTeal : AppColors.errorRed,
                ),
              );
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
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('모집 확정'),
        content: const Text('현재 인원으로 모집을 확정하고 경기를 생성할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('확정'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;

    final provider = context.read<RecruitmentProvider>();
    final success = await provider.confirm(widget.recruitmentId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? '모집이 확정되었습니다.' : (provider.errorMessage ?? '확정에 실패했습니다.'),
        ),
        backgroundColor: success ? AppColors.classTeal : AppColors.errorRed,
      ),
    );
  }

  Future<void> _handleCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('모집 취소'),
        content: const Text('정말 이 모집을 취소할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('아니오'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: const Text('취소하기'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;

    final provider = context.read<RecruitmentProvider>();
    final success = await provider.cancel(widget.recruitmentId);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모집이 취소되었습니다.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? '취소에 실패했습니다.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.titleText,
        centerTitle: true,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: const Text(
          '모집 상세',
          style: TextStyle(
            color: AppColors.titleText,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Consumer<RecruitmentProvider>(
        builder: (context, provider, _) {
          final detail =
              provider.selectedRecruitment?.id == widget.recruitmentId
                  ? provider.selectedRecruitment
                  : null;
          if (provider.isLoading && detail == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.activeBlue),
            );
          }
          if (detail == null) {
            return _buildErrorState(provider);
          }

          final isAuthor = currentUser?.userId == detail.authorId;
          return RefreshIndicator(
            color: AppColors.activeBlue,
            onRefresh: () => provider.loadDetail(widget.recruitmentId),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(detail),
                  const SizedBox(height: 20),
                  _buildParticipation(detail),
                  if (isAuthor && detail.isOpen) ...[
                    const SizedBox(height: 28),
                    _buildApplicationsSection(detail, provider),
                  ],
                  if (!detail.isOpen) ...[
                    const SizedBox(height: 24),
                    _buildStatusBanner(detail),
                  ],
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<RecruitmentProvider>(
        builder: (context, provider, _) {
          final detail =
              provider.selectedRecruitment?.id == widget.recruitmentId
                  ? provider.selectedRecruitment
                  : null;
          if (detail == null || !detail.isOpen) {
            return const SizedBox.shrink();
          }
          final isAuthor = currentUser?.userId == detail.authorId;
          return _buildBottomActions(isAuthor);
        },
      ),
    );
  }

  Widget _buildErrorState(RecruitmentProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: AppColors.subText,
            ),
            const SizedBox(height: 12),
            Text(
              provider.errorMessage ?? '모집글을 불러올 수 없습니다.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.subText),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => provider.loadDetail(widget.recruitmentId),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(RecruitmentDetailModel detail) {
    final date = DateFormat('M/d · EEEE', 'ko').format(detail.startAt);
    final startTime = DateFormat('HH:mm').format(detail.startAt);
    final endTime = DateFormat('HH:mm').format(detail.endAt);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.softPrimary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _InfoPill(
                text: date,
                color: AppColors.activeBlue,
                backgroundColor: Colors.white,
              ),
              const Spacer(),
              _InfoPill(
                text: detail.gameFormatDisplay,
                color: AppColors.activeBlue,
                backgroundColor: AppColors.activeBlue.withValues(alpha: 0.08),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _DetailRow(
            icon: Icons.schedule_rounded,
            text: '$startTime–$endTime',
          ),
          const SizedBox(height: 10),
          _DetailRow(
            icon: Icons.location_on_rounded,
            text: detail.locationName,
            emphasized: true,
          ),
          const SizedBox(height: 10),
          _DetailRow(
            icon: Icons.person_outline_rounded,
            text: '모집자  ${detail.authorNickname}',
          ),
          if (detail.deadlineAt != null) ...[
            const SizedBox(height: 10),
            _DetailRow(
              icon: Icons.timer_outlined,
              text:
                  '신청 마감  ${DateFormat('M/d HH:mm').format(detail.deadlineAt!)}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildParticipation(RecruitmentDetailModel detail) {
    final remaining = detail.totalNeeded - detail.currentCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '현재 ${detail.currentCount} / ${detail.totalNeeded}명',
              style: const TextStyle(
                color: AppColors.titleText,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Text(
              detail.isFull
                  ? '모집 완료'
                  : '${remaining.clamp(0, detail.totalNeeded)}명 더 모이면 확정',
              style: const TextStyle(
                color: AppColors.subText,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ProgressBarWidget(
          currentCount: detail.currentCount,
          totalNeeded: detail.totalNeeded,
          showLabels: false,
        ),
      ],
    );
  }

  Widget _buildApplicationsSection(
    RecruitmentDetailModel detail,
    RecruitmentProvider provider,
  ) {
    final pending =
        detail.applications.where((item) => item.isPending).toList();
    final accepted =
        detail.applications.where((item) => item.isAccepted).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '신청 목록 ${detail.applications.length}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        if (detail.applications.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: AppColors.softSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              '아직 신청자가 없습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.subText, fontSize: 12),
            ),
          ),
        if (pending.isNotEmpty) ...[
          const Text(
            '대기중',
            style: TextStyle(
              color: AppColors.alertOrange,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...pending.map(
            (application) => ApplicantCard(
              application: application,
              onAccept: () => provider.acceptApplication(
                detail.id,
                application.applicationId,
              ),
              onReject: () => provider.rejectApplication(
                detail.id,
                application.applicationId,
              ),
            ),
          ),
        ],
        if (accepted.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            '수락됨',
            style: TextStyle(
              color: AppColors.classTeal,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...accepted.map(
            (application) => ApplicantCard(
              application: application,
              showActions: false,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomActions(bool isAuthor) {
    return Material(
      color: Colors.white,
      elevation: 12,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: isAuthor
            ? Row(
                children: [
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _handleCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.errorRed,
                        side: const BorderSide(color: AppColors.errorRed),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _handleConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.activeBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text('현재 인원으로 확정'),
                      ),
                    ),
                  ),
                ],
              )
            : SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _showApplyDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.activeBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    '신청하기',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
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
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        detail.statusDisplay,
        textAlign: TextAlign.center,
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String text;
  final Color color;
  final Color backgroundColor;

  const _InfoPill({
    required this.text,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool emphasized;

  const _DetailRow({
    required this.icon,
    required this.text,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: AppColors.activeBlue),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.titleText,
              fontSize: 13,
              height: 1.25,
              fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
