import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../club/club_screen.dart';

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
    PlaceholderScreen(title: '홈'),
    ClubScreen(),
    PlaceholderScreen(title: '채팅'),
    PlaceholderScreen(title: '일정'),
    PlaceholderScreen(title: 'MY'),
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
        selectedItemColor: AppColors.activeBlue,
        unselectedItemColor: AppColors.subText,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
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
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: Text(
          '$title 화면 준비 중',
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.subText,
          ),
        ),
      ),
    );
  }
}
