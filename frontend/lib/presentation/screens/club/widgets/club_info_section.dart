import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/club_model.dart';

class ClubInfoSection extends StatelessWidget {
  final ClubModel club;

  const ClubInfoSection({super.key, required this.club});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '동아리 소개',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.titleText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            club.introduction ?? '동아리 소개가 없습니다.',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.titleText,
            ),
          ),
          if (club.captainName != null && club.captainName!.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              '동아리장',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.titleText,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                club.captainProfileImageUrl != null &&
                        club.captainProfileImageUrl!.isNotEmpty
                    ? CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            NetworkImage(club.captainProfileImageUrl!),
                      )
                    : CircleAvatar(
                        radius: 20,
                        child: Text(
                          club.captainName!.isNotEmpty
                              ? club.captainName![0]
                              : '?',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                const SizedBox(width: 12),
                Text(
                  club.captainName!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.titleText,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
