import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:basketball_frontend/core/theme/plato_theme.dart';
import 'package:basketball_frontend/presentation/providers/auth_provider.dart';
import 'package:basketball_frontend/presentation/widgets/user/profile_header.dart';
import 'package:basketball_frontend/presentation/widgets/user/subscription_banner.dart';
import 'package:basketball_frontend/presentation/widgets/user/settings_list.dart';

class UserTab extends StatefulWidget {
  const UserTab({super.key});

  @override
  State<UserTab> createState() => _UserTabState();
}

class _UserTabState extends State<UserTab> {
  bool _initialized = false;

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃하시겠어요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('로그아웃'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) {
      return;
    }

    _initialized = true;
    if (context.read<AuthProvider>().currentUser != null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initialize();
    });
  }

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
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (authProvider.currentUser == null) {
            final errorText = authProvider.errorMessage;
            final requiresReLogin =
                errorText == null ||
                errorText.contains('로그인') ||
                errorText.contains('인증');

            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      errorText ?? '로그인 정보가 없습니다.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: PlatoColors.subText,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (requiresReLogin) {
                          Navigator.of(context).pushReplacementNamed('/login');
                          return;
                        }
                        authProvider.fetchCurrentUser();
                      },
                      child: Text(requiresReLogin ? '로그인하러 가기' : '다시 시도'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: authProvider.fetchCurrentUser,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    const PremiumBanner(),
                    const SizedBox(height: 16),
                    const PointsBanner(),
                    const SizedBox(height: 24),
                    ProfileHeader(user: authProvider.currentUser!),
                    const SizedBox(height: 24),
                    SettingsList(onLogout: _handleLogout),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
