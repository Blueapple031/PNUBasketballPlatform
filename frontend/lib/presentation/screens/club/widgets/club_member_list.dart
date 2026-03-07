import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/member_model.dart';

class ClubMemberList extends StatelessWidget {
  final List<MemberModel> members;

  const ClubMemberList({super.key, required this.members});

  Color _roleColor(String role) {
    if (role == '주장') return AppColors.classTeal;
    if (role == '부주장') return AppColors.classLime;
    return AppColors.subText;
  }

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            '등록된 멤버가 없습니다.',
            style: TextStyle(color: AppColors.subText),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: members.length,
      separatorBuilder: (_, __) =>
          const Divider(color: AppColors.boxBorder, height: 1),
      itemBuilder: (context, index) {
        final member = members[index];
        final roleColor = _roleColor(member.role);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(member.profileImageUrl),
          ),
          title: Text(
            member.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.titleText,
            ),
          ),
          subtitle: Text(
            member.role,
            style: TextStyle(
              fontSize: 12,
              color: roleColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          onTap: () {
            print('member tapped: ${member.name} (${member.role})');
          },
        );
      },
    );
  }
}
