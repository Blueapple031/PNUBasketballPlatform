import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../home/home_screen.dart';

/// RootScreen: BottomNavigationBar를 관리하는 루트 화면
/// 
/// 모든 탭 화면을 관리하고, 탭 전환 시 상태를 유지합니다.
/// Design System: PNU Plato Modern UI 규칙 준수
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0;

  // 각 탭에 해당하는 화면들
  final List<Widget> _screens = [
    const HomeScreen(),           // 0: 홈 (프로필 피드)
    const PlaceholderScreen(title: '커뮤니티'), // 1: 커뮤니티
    const PlaceholderScreen(title: '채팅'),     // 2: 채팅
    const PlaceholderScreen(title: '일정'),     // 3: 일정
    const PlaceholderScreen(title: 'MY'),       // 4: 마이페이지
  ];

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

/// 임시 Placeholder 화면 (다른 탭 화면 구현 전까지 사용)
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
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey[400],
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
