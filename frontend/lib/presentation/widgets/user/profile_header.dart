import 'package:flutter/material.dart';
import 'package:basketball_frontend/core/theme/plato_theme.dart';
import 'package:basketball_frontend/data/models/user_model.dart';
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PlatoColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: PlatoColors.border,
            ),
            clipBehavior: Clip.antiAlias,
            child: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                ? Image.network(
                    user.profileImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.person,
                      size: 50,
                      color: PlatoColors.subText,
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 50,
                    color: PlatoColors.subText,
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            user.nickname,
            style: const TextStyle(
              color: PlatoColors.titleText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.email,
            style: const TextStyle(
              fontSize: 12,
              color: PlatoColors.subText,
            ),
            textAlign: TextAlign.center,
          ),
          if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              user.phoneNumber!,
              style: const TextStyle(
                fontSize: 12,
                color: PlatoColors.subText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _certificationBadge('여권', PlatoColors.classTeal),
              const SizedBox(width: 12),
              _certificationBadge('직업', PlatoColors.alertOrange),
            ],
          ),
          const SizedBox(height: 20),
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
                backgroundColor: PlatoColors.activeBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('프로필 수정'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _certificationBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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
