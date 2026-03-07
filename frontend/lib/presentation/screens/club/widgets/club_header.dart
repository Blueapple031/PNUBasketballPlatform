import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/club_model.dart';

class ClubHeader extends StatelessWidget {
  final ClubModel club;

  const ClubHeader({super.key, required this.club});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.boxBorder),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: club.logoUrl != null && club.logoUrl!.isNotEmpty
                ? NetworkImage(club.logoUrl!)
                : null,
            child: club.logoUrl == null || club.logoUrl!.isEmpty
                ? Text(
                    club.name.isNotEmpty ? club.name[0] : '?',
                    style: const TextStyle(fontSize: 24),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  club.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.titleText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '부산대학교',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.subText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '회원 ${club.memberCount}명',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.subText,
                  ),
                ),
                if (club.captainName != null && club.captainName!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.classTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (club.captainProfileImageUrl != null &&
                            club.captainProfileImageUrl!.isNotEmpty)
                          CircleAvatar(
                            radius: 10,
                            backgroundImage:
                                NetworkImage(club.captainProfileImageUrl!),
                          )
                        else
                          CircleAvatar(
                            radius: 10,
                            child: Text(
                              club.captainName!.isNotEmpty
                                  ? club.captainName![0]
                                  : '?',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        const SizedBox(width: 6),
                        Text(
                          '동아리장 ${club.captainName}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.classTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
