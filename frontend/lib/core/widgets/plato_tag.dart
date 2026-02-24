import 'package:flutter/material.dart';

/// PlatoTag: 모던 플라토 디자인 시스템의 태그 컴포넌트
/// 
/// 상태를 나타내는 작은 뱃지나 태그(Chip)
/// Soft Tint 기법: 배경을 진한 원색으로 칠하지 않고, 해당 색상의 투명도(Opacity) 10%를 적용
/// 
/// 사용 예시:
/// ```dart
/// PlatoTag(text: '마감임박', baseColor: AppColors.alertOrange)
/// PlatoTag(text: '남성매치', baseColor: AppColors.classLime)
/// ```
class PlatoTag extends StatelessWidget {
  /// 태그에 표시할 텍스트
  final String text;
  
  /// 기본 색상 (이 색상의 10% 투명도로 배경을 채움)
  final Color baseColor;

  const PlatoTag({
    super.key,
    required this.text,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        // Soft Tint 기법: 투명도 10%로 파스텔톤 효과
        color: baseColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: baseColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
