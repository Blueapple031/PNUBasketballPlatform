import 'package:flutter/material.dart';
import 'package:basketball_frontend/core/theme/plato_theme.dart';
import 'package:basketball_frontend/presentation/widgets/user/profile_header.dart';
import 'package:basketball_frontend/presentation/widgets/user/subscription_banner.dart';
import 'package:basketball_frontend/presentation/widgets/user/settings_list.dart';

class UserTab extends StatelessWidget {
  const UserTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlatoColors.pageBg,
      appBar: AppBar(
        title: const Text('마이페이지'),
        backgroundColor: PlatoColors.headerGrey,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
          children: [
            const PremiumBanner(),
            const SizedBox(height: 16),
            const PointsBanner(),
            const SizedBox(height: 24),
            const ProfileHeader(),
            const SizedBox(height: 24),
            const SettingsList(),
            const SizedBox(height: 16),
          ],
          ),
        ),
      ),
    );
  }
}
