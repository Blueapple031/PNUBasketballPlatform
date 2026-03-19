import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProgressBarWidget extends StatelessWidget {
  final int current;
  final int total;
  final int baseCount;

  const ProgressBarWidget({
    super.key,
    required this.current,
    required this.total,
    required this.baseCount,
  });

  @override
  Widget build(BuildContext context) {
    final filled = baseCount + current;
    final max = baseCount + total;
    final ratio = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;
    final isFull = current >= total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '현재 $filled / $max명',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.titleText,
              ),
            ),
            Text(
              isFull ? '모집 완료!' : '$current명 더 모이면 확정!',
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
