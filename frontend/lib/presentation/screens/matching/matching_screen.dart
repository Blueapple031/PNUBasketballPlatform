import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'recruitment_list_view.dart';
import 'club_match_list_view.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onFabPressed() {
    if (_tabController.index == 0) {
      Navigator.pushNamed(context, '/recruitment-create');
    } else {
      Navigator.pushNamed(context, '/club-match-create');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.sports_basketball, color: AppColors.alertOrange, size: 28),
            const SizedBox(width: 8),
            const Text('매칭'),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.activeBlue,
          unselectedLabelColor: AppColors.subText,
          indicatorColor: AppColors.activeBlue,
          tabs: const [
            Tab(text: '게스트/번개'),
            Tab(text: '동아리 친선전'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          RecruitmentListView(),
          ClubMatchListView(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onFabPressed,
        backgroundColor: AppColors.activeBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('모집하기', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
