import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PremiumBanner extends StatelessWidget {
  const PremiumBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.classLime, AppColors.alertOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '프리미엄 멤버가 되세요',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.backgroundWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '더 많은 기능을 이용해보세요',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.backgroundWhite.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '가입',
                style: TextStyle(
                  color: AppColors.alertOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PointsBanner extends StatelessWidget {
  const PointsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.activeBlue, AppColors.pointCyan],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '보유 포인트',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.backgroundWhite.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '1,500 P',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.backgroundWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '사용',
                style: TextStyle(
                  color: AppColors.activeBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

