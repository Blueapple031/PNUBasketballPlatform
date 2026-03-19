import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../club/club_screen.dart';
import '../community/community_screen.dart';
import '../matching/matching_screen.dart';
import '../schedule/schedule_screen.dart';
import '../user/user_tab.dart';

class RootScreen extends StatefulWidget {
  final int initialIndex;

  const RootScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late int _selectedIndex;

  late final List<Widget> _screens = const [
    MatchingScreen(),
    ClubScreen(),
    CommunityScreen(),
    ScheduleScreen(),
    UserTab(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_basketball_outlined),
            activeIcon: Icon(Icons.sports_basketball),
            label: '매칭',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.stadium_outlined),
            activeIcon: Icon(Icons.stadium),
            label: '동아리',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum_outlined),
            activeIcon: Icon(Icons.forum),
            label: '커뮤니티',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: '일정',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'MY',
          ),
        ],
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.headerGrey,
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.backgroundWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction,
              size: 64,
              color: AppColors.border,
            ),
            const SizedBox(height: 16),
            Text(
              '$title 화면',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '준비 중입니다',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.subText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
