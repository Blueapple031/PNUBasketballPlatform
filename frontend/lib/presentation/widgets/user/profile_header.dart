import 'package:flutter/material.dart';
import 'package:basketball_frontend/data/models/user_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../screens/user/edit_profile_screen.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;

  const ProfileHeader({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.border,
            ),
            clipBehavior: Clip.antiAlias,
            child: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                ? Image.network(
                    user.profileImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.subText,
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.subText,
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            user.nickname,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.titleText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.subText,
            ),
            textAlign: TextAlign.center,
          ),
          if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              user.phoneNumber!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.subText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _certificationBadge('여권', AppColors.classTeal),
              const SizedBox(width: 8),
              _certificationBadge('직업', AppColors.alertOrange),
            ],
          ),
          const SizedBox(height: 24),
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
