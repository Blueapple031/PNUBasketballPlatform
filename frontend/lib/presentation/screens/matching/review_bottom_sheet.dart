import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/match_model.dart';
import '../../providers/match_provider.dart';

class ReviewBottomSheet extends StatefulWidget {
  final String matchId;

  const ReviewBottomSheet({super.key, required this.matchId});

  static Future<void> show(BuildContext context, String matchId) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<MatchProvider>(),
        child: ReviewBottomSheet(matchId: matchId),
      ),
    );
  }

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  final Set<int> _thumbsUpIds = {};
  final Set<int> _noShowIds = {};
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchProvider>().loadReviewForm(widget.matchId);
    });
  }

  Future<void> _handleSubmit() async {
    setState(() => _submitting = true);
    final provider = context.read<MatchProvider>();
    final success = await provider.submitReview(
      widget.matchId,
      thumbsUpUserIds: _thumbsUpIds.toList(),
      noShowUserIds: _noShowIds.toList(),
    );
    setState(() => _submitting = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('리뷰가 제출되었습니다!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? '제출 실패'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MatchProvider>(
      builder: (context, provider, _) {
        final form = provider.reviewForm;

        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            if (provider.isLoading || form == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (form.alreadySubmitted) {
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle,
                        size: 64, color: AppColors.classTeal),
                    const SizedBox(height: 16),
                    const Text('이미 리뷰를 제출했습니다',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('닫기'),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sports_basketball,
                        color: AppColors.alertOrange, size: 24),
                    SizedBox(width: 8),
                    Text(
                      '경기가 끝났어요!',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${form.locationName}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.subText),
                ),
                const SizedBox(height: 20),
                const Text(
                  '함께한 사람들을 평가해주세요',
                  style: TextStyle(
                      fontSize: 14, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ...form.participants.map((p) => _buildParticipantRow(p)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.activeBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('제출하기', style: TextStyle(fontSize: 16)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildParticipantRow(ParticipantModel participant) {
    final hasThumbsUp = _thumbsUpIds.contains(participant.userId);
    final hasNoShow = _noShowIds.contains(participant.userId);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.activeBlue.withValues(alpha: 0.15),
            child: Text(
              participant.nickname.isNotEmpty ? participant.nickname[0] : '?',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.activeBlue),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.nickname,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                if (participant.position != null)
                  Text(
                    participant.positionDisplay,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.subText),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                if (hasThumbsUp) {
                  _thumbsUpIds.remove(participant.userId);
                } else {
                  _thumbsUpIds.add(participant.userId);
                  _noShowIds.remove(participant.userId);
                }
              });
            },
            icon: Icon(
              hasThumbsUp ? Icons.thumb_up : Icons.thumb_up_outlined,
              color: hasThumbsUp ? AppColors.activeBlue : AppColors.subText,
              size: 22,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                if (hasNoShow) {
                  _noShowIds.remove(participant.userId);
                } else {
                  _noShowIds.add(participant.userId);
                  _thumbsUpIds.remove(participant.userId);
                }
              });
            },
            icon: Icon(
              hasNoShow ? Icons.warning : Icons.warning_amber_outlined,
              color: hasNoShow ? AppColors.errorRed : AppColors.subText,
              size: 22,
            ),
            tooltip: '노쇼 신고',
          ),
        ],
      ),
    );
  }
}
