import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/club_match_model.dart';
import '../../providers/club_match_provider.dart';

class ClubMatchDetailScreen extends StatefulWidget {
  final String requestId;

  const ClubMatchDetailScreen({super.key, required this.requestId});

  @override
  State<ClubMatchDetailScreen> createState() => _ClubMatchDetailScreenState();
}

class _ClubMatchDetailScreenState extends State<ClubMatchDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClubMatchProvider>().loadDetail(widget.requestId);
    });
  }

  Future<void> _handleAttend() async {
    final provider = context.read<ClubMatchProvider>();
    final success = await provider.attend(widget.requestId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '참가 의사가 등록되었습니다!' : (provider.errorMessage ?? '등록 실패')),
          backgroundColor: success ? AppColors.classTeal : Colors.red,
        ),
      );
    }
  }

  void _showResultDialog() {
    final homeController = TextEditingController();
    final awayController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('결과 입력'),
        content: Row(
          children: [
            Expanded(
              child: TextField(
                controller: homeController,
                decoration: const InputDecoration(
                  labelText: '홈팀',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: TextField(
                controller: awayController,
                decoration: const InputDecoration(
                  labelText: '원정팀',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          ElevatedButton(
            onPressed: () async {
              final home = int.tryParse(homeController.text);
              final away = int.tryParse(awayController.text);
              if (home == null || away == null) return;
              Navigator.pop(ctx);
              final provider = context.read<ClubMatchProvider>();
              await provider.submitResult(
                widget.requestId,
                homeScore: home,
                awayScore: away,
              );
            },
            child: const Text('제출'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleApprove() async {
    final provider = context.read<ClubMatchProvider>();
    final success = await provider.approveResult(widget.requestId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '결과가 승인되었습니다!' : (provider.errorMessage ?? '승인 실패')),
          backgroundColor: success ? AppColors.classTeal : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('M/d(E) HH:mm', 'ko');

    return Scaffold(
      appBar: AppBar(title: const Text('친선전 상세')),
      body: Consumer<ClubMatchProvider>(
        builder: (context, provider, _) {
          final request = provider.selectedRequest;
          if (provider.isLoading && request == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (request == null) {
            return Center(
              child: Text(provider.errorMessage ?? '정보를 불러올 수 없습니다',
                  style: const TextStyle(color: AppColors.subText)),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadDetail(widget.requestId),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusFlow(request),
                  const SizedBox(height: 20),
                  _buildTeams(request),
                  const SizedBox(height: 20),
                  _buildInfoCard(request, dateFormat),
                  const SizedBox(height: 24),
                  _buildActions(request),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusFlow(ClubMatchRequestModel request) {
    const steps = ['GATHERING', 'READY', 'MATCHED', 'CONFIRMED', 'DONE'];
    const labels = ['모집중', '준비완료', '매칭완료', '확정', '완료'];
    final currentIdx = steps.indexOf(request.status);

    return SizedBox(
      height: 60,
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i <= currentIdx;
          final isCurrent = i == currentIdx;
          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    if (i > 0)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isActive
                              ? AppColors.classTeal
                              : AppColors.border,
                        ),
                      ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? AppColors.classTeal
                            : AppColors.border,
                        border: isCurrent
                            ? Border.all(
                                color: AppColors.classTeal, width: 3)
                            : null,
                      ),
                      child: isActive
                          ? const Icon(Icons.check,
                              size: 14, color: Colors.white)
                          : null,
                    ),
                    if (i < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: i < currentIdx
                              ? AppColors.classTeal
                              : AppColors.border,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 10,
                    color: isActive ? AppColors.classTeal : AppColors.subText,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTeams(ClubMatchRequestModel request) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.activeBlue.withValues(alpha: 0.15),
                    child: const Icon(Icons.stadium,
                        size: 28, color: AppColors.activeBlue),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    request.homeClubName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '${request.homeAttendanceCount}/5명',
                    style: TextStyle(
                      fontSize: 13,
                      color: request.homeAttendanceCount >= 5
                          ? AppColors.classTeal
                          : AppColors.alertOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Column(
              children: [
                Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.activeBlue,
                  ),
                ),
                Text('5:5',
                    style: TextStyle(fontSize: 12, color: AppColors.subText)),
              ],
            ),
            Expanded(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: request.hasAway
                        ? AppColors.alertOrange.withValues(alpha: 0.15)
                        : AppColors.border.withValues(alpha: 0.3),
                    child: Icon(
                      request.hasAway ? Icons.stadium : Icons.help_outline,
                      size: 28,
                      color: request.hasAway
                          ? AppColors.alertOrange
                          : AppColors.textDisabled,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    request.hasAway ? request.awayClubName! : '???',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: request.hasAway
                          ? AppColors.titleText
                          : AppColors.textDisabled,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (request.hasAway)
                    Text(
                      '${request.awayAttendanceCount}/5명',
                      style: TextStyle(
                        fontSize: 13,
                        color: request.awayAttendanceCount >= 5
                            ? AppColors.classTeal
                            : AppColors.alertOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    const Text('상대 모집중',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textDisabled)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      ClubMatchRequestModel request, DateFormat dateFormat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _infoRow(Icons.location_on_outlined, '장소', request.locationName),
            const SizedBox(height: 8),
            _infoRow(
              Icons.access_time,
              '시간',
              '${dateFormat.format(request.startAt)} ~ ${DateFormat('HH:mm').format(request.endAt)}',
            ),
            const SizedBox(height: 8),
            _infoRow(Icons.info_outline, '상태', request.statusDisplay),
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
        Text('$label: ',
            style: const TextStyle(fontSize: 13, color: AppColors.subText)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildActions(ClubMatchRequestModel request) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (request.isGathering || request.isReady)
          ElevatedButton.icon(
            onPressed: _handleAttend,
            icon: const Icon(Icons.how_to_reg, color: Colors.white),
            label: const Text('참가 의사 등록',
                style: TextStyle(fontSize: 16, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.activeBlue,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        if (request.isDone) ...[
          ElevatedButton.icon(
            onPressed: _showResultDialog,
            icon: const Icon(Icons.scoreboard, color: Colors.white),
            label: const Text('결과 입력',
                style: TextStyle(fontSize: 16, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.classTeal,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _handleApprove,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('결과 승인', style: TextStyle(fontSize: 16)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
        if (request.isConfirmed)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.classTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '경기가 확정되었습니다!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.classTeal,
              ),
            ),
          ),
      ],
    );
  }
}
