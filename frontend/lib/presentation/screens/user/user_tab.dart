import 'package:flutter/material.dart';
import 'package:basketball_frontend/presentation/widgets/user/profile_header.dart';
import 'package:basketball_frontend/presentation/widgets/user/subscription_banner.dart';
import 'package:basketball_frontend/presentation/widgets/user/settings_list.dart';

class UserTab extends StatelessWidget {
  const UserTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 프리미엄 베너 (최상단, 광고처럼)
            const PremiumBanner(),
            const SizedBox(height: 16),
            // 포인트 배너 (카드 형태, 프리미엄 베너 바로 밑)
            const PointsBanner(),
            const SizedBox(height: 24),
            // 프로필 헤더
            const ProfileHeader(),
            const SizedBox(height: 24),
            // 설정 메뉴 리스트
            const SettingsList(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
