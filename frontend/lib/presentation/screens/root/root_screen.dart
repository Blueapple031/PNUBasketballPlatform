import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../club/club_screen.dart';
import '../home/home_screen.dart';
import '../match/match_list_screen.dart';
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

  // 각 탭에 해당하는 화면들
  final List<Widget> _screens = [
    const HomeScreen(),           // 0: 홈 (프로필 피드)
    const ClubScreen(),      // 1: 커뮤니티
    const PlaceholderScreen(title: '채팅'),     // 2: 채팅
    const MatchListScreen(),      // 3: 매칭
    const UserTab(),              // 4: 마이페이지
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
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.backgroundWhite,
        selectedItemColor: AppColors.activeBlue,
        unselectedItemColor: AppColors.subText,
        elevation: 8,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.stadium_outlined),
            activeIcon: Icon(Icons.stadium),
            label: '커뮤니티',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: '채팅',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups),
            label: '매칭',
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
