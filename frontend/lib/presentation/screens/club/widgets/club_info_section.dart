import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/club_model.dart';
import '../../../providers/auth_provider.dart';

class ClubInfoSection extends StatelessWidget {
  final ClubModel club;
  final ValueChanged<ClubModel>? onClubUpdated;

  const ClubInfoSection({
    super.key,
    required this.club,
    this.onClubUpdated,
  });

  Future<void> _showEditDialog(BuildContext context) async {
    final controller = TextEditingController(text: club.introduction ?? '');
    final authProvider = context.read<AuthProvider>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('동아리 소개 수정'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: '동아리 소개를 입력하세요',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      final updated = await authProvider.updateMyClubIntroduction(
        controller.text.trim(),
      );
      if (updated != null && context.mounted) {
        onClubUpdated?.call(updated);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('동아리 소개가 수정되었습니다.')),
          );
        }
      } else if (context.mounted && authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.errorMessage!)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = club.isCaptain == true && onClubUpdated != null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '동아리 소개',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.titleText,
                ),
              ),
              if (canEdit)
                TextButton.icon(
                  onPressed: () => _showEditDialog(context),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('수정'),
                ),
            ],
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
