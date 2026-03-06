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
            club.intro,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.titleText,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: const Border.fromBorderSide(
                  BorderSide(color: AppColors.boxBorder)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '기본 정보',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.titleText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '홈코트: ${club.homeCourt}',
                  style:
                      const TextStyle(fontSize: 14, color: AppColors.titleText),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage:
                          NetworkImage(club.captain.profileImageUrl),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '주장: ${club.captain.name}',
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.titleText),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '주요 멤버',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.titleText,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: club.members.take(4).length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final member = club.members[index];
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(member.profileImageUrl),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.name,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.subText),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
