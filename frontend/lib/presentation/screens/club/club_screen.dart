import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/club_model.dart';
import 'club_detail_screen.dart';

class ClubScreen extends StatelessWidget {
  const ClubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clubs = ClubModel.dummyList();

    final sections = <_ClubSectionData>[
      _ClubSectionData(
        title: '중앙동아리',
        subtitle: '학교 대표 동아리',
        accentColor: AppColors.activeBlue,
        icon: Icons.verified,
        clubs: clubs
            .where((club) => club.category == ClubCategory.central)
            .toList(growable: false),
      ),
      _ClubSectionData(
        title: '과동아리',
        subtitle: '학과 중심 동아리',
        accentColor: AppColors.classTeal,
        icon: Icons.school,
        clubs: clubs
            .where((club) => club.category == ClubCategory.department)
            .toList(growable: false),
      ),
      _ClubSectionData(
        title: '소모임',
        subtitle: '소규모 친목 모임',
        accentColor: AppColors.alertOrange,
        icon: Icons.groups_2,
        clubs: clubs
            .where((club) => club.category == ClubCategory.smallGroup)
            .toList(growable: false),
      ),
      const _ClubSectionData(
        title: '외부 동아리',
        subtitle: '외부 리그 및 교류 팀',
        accentColor: AppColors.subText,
        icon: Icons.public,
        clubs: [],
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: AppColors.headerGrey,
        elevation: 0,
        title: const Text(
          '동아리',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: clubs.isEmpty
          ? const Center(
              child: Text(
                '표시할 동아리가 없습니다.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.subText,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: sections.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    decoration: BoxDecoration(
                      color: AppColors.headerGrey.withValues(alpha: 0.15),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: AppColors.headerGrey,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '이 곳에서 중앙동아리, 과동아리, 소모임, 외부 동아리의 정보를 확인할 수 있습니다.',
                            style: TextStyle(
                              color: AppColors.titleText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final section = sections[index - 1];
                return _ClubSection(
                  title: section.title,
                  subtitle: section.subtitle,
                  accentColor: section.accentColor,
                  icon: section.icon,
                  clubs: section.clubs,
                  onTapClub: (club) => _openClubDetail(context, club),
                );
              },
            ),
    );
  }

  void _openClubDetail(BuildContext context, ClubModel club) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ClubDetailScreen(
          clubId: club.clubId,
          slug: club.slug,
        ),
      ),
    );
  }
}

class _ClubSectionData {
  final String title;
  final String subtitle;
  final Color accentColor;
  final IconData icon;
  final List<ClubModel> clubs;

  const _ClubSectionData({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.icon,
    required this.clubs,
  });
}

class _ClubSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accentColor;
  final IconData icon;
  final List<ClubModel> clubs;
  final ValueChanged<ClubModel> onTapClub;

  const _ClubSection({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.icon,
    required this.clubs,
    required this.onTapClub,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              accentColor.withValues(alpha: 0.14),
              accentColor.withValues(alpha: 0.06),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.titleText,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.subText,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 128,
              child: clubs.isEmpty
                  ? const Center(
                      child: Text(
                        '등록된 동아리가 없습니다.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.subText,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.horizontal,
                      itemCount: clubs.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final club = clubs[index];
                        return _ClubTile(
                          club: club,
                          accentColor: accentColor,
                          onTap: () => onTapClub(club),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClubTile extends StatelessWidget {
  final ClubModel club;
  final Color accentColor;
  final VoidCallback onTap;

  const _ClubTile({
    required this.club,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${club.clubName} 상세 보기',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Ink(
            width: 110,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor.withValues(alpha: 0.45)),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: accentColor.withValues(alpha: 0.18),
                  backgroundImage: NetworkImage(club.logoUrl),
                ),
                const SizedBox(height: 10),
                Text(
                  club.clubName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.titleText,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
