import 'package:flutter/material.dart';
import '../../screens/user/edit_profile_screen.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // 프로필 아바타
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade300,
            ),
            child: Icon(
              Icons.person,
              size: 50,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          // 닉네임, 나이, 국기
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '홍길동',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 8),
              Text(
                '28세',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 8),
              const Text('🇰🇷'),
            ],
          ),
          const SizedBox(height: 12),
          // 소개글
          Text(
            '농구 좋아하는 개발자입니다',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // 인증 배지
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _certificationBadge(context, '여권', Colors.green),
              const SizedBox(width: 12),
              _certificationBadge(context, '직업', Colors.orange),
            ],
          ),
          const SizedBox(height: 20),
          // 프로필 수정 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('프로필 수정'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _certificationBadge(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
