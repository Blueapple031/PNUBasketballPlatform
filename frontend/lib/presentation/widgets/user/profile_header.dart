import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../screens/user/edit_profile_screen.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // 프로필 아바타
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.border,
            ),
            child: const Icon(
              Icons.person,
              size: 50,
              color: AppColors.subText,
            ),
          ),
          const SizedBox(height: 16),
          // 닉네임, 나이, 국기
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '홍길동',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.titleText,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '28세',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.subText,
                ),
              ),
              const SizedBox(width: 8),
              const Text('🇰🇷'),
            ],
          ),
          const SizedBox(height: 8),
          // 소개글
          const Text(
            '농구 좋아하는 개발자입니다',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.subText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // 인증 배지
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _certificationBadge('여권', AppColors.classTeal),
              const SizedBox(width: 8),
              _certificationBadge('직업', AppColors.alertOrange),
            ],
          ),
          const SizedBox(height: 24),
          // 프로필 수정 버튼
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.activeBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '프로필 수정',
                  style: TextStyle(
                    color: AppColors.backgroundWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _certificationBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
