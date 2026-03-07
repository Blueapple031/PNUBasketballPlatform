import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/club_model.dart';
import 'widgets/club_header.dart';
import 'widgets/club_info_section.dart';
import 'widgets/club_member_list.dart';

class ClubDetailScreen extends StatelessWidget {
  final int clubId;
  final String slug;

  const ClubDetailScreen({
    super.key,
    required this.clubId,
    required this.slug,
  });

  @override
  Widget build(BuildContext context) {
    final clubs = ClubModel.dummyList();
    final club = _findClub(clubs);

    if (club == null) {
      return Scaffold(
        backgroundColor: AppColors.pageBg,
        appBar: AppBar(
          backgroundColor: AppColors.headerGrey,
          title: const Text(
            '동아리 상세',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            '동아리 정보를 불러올 수 없습니다.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.subText,
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.pageBg,
        appBar: AppBar(
          backgroundColor: AppColors.headerGrey,
          elevation: 0,
          title: Text(
            club.clubName,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.activeBlue,
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.subText,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Members'),
            ],
          ),
        ),
        body: Column(
          children: [
            ClubHeader(club: club),
            Expanded(
              child: TabBarView(
                children: [
                  SingleChildScrollView(
                    child: ClubInfoSection(club: club),
                  ),
                  ClubMemberList(members: club.members),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ClubModel? _findClub(List<ClubModel> clubs) {
    for (final club in clubs) {
      if (club.clubId == clubId || club.slug == slug) {
        return club;
      }
    }
    return null;
  }
}
