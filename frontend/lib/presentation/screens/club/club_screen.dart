import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/club_model.dart';
import 'widgets/club_header.dart';
import 'widgets/club_info_section.dart';
import 'widgets/club_member_list.dart';

class ClubScreen extends StatelessWidget {
  const ClubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final club = ClubModel.dummy();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
}
