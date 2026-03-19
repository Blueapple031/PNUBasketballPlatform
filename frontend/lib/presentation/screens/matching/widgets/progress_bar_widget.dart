import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// 모집 인원 진행률: currentCount = 현재 인원, totalNeeded = 총 필요 인원
class ProgressBarWidget extends StatelessWidget {
  final int currentCount;
  final int totalNeeded;

  const ProgressBarWidget({
    super.key,
    required this.currentCount,
    required this.totalNeeded,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = totalNeeded - currentCount;
    final ratio = totalNeeded > 0 ? (currentCount / totalNeeded).clamp(0.0, 1.0) : 0.0;
    final isFull = remaining <= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '현재 $currentCount / $totalNeeded명',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.titleText,
              ),
            ),
            Text(
              isFull ? '모집 완료!' : '$remaining명 더 모이면 확정!',
              style: TextStyle(
                fontSize: 12,
                color: isFull ? AppColors.classTeal : AppColors.subText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(
              isFull ? AppColors.classTeal : AppColors.activeBlue,
            ),
          ),
        ),
      ],
    );
  }
}
