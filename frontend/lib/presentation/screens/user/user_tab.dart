import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:basketball_frontend/presentation/providers/auth_provider.dart';
import 'package:basketball_frontend/presentation/widgets/user/profile_header.dart';
import 'package:basketball_frontend/presentation/widgets/user/subscription_banner.dart';
import 'package:basketball_frontend/presentation/widgets/user/settings_list.dart';
import '../../../core/theme/app_colors.dart';

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

    if (!mounted) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  Future<void> _handleDeleteAccount() async {
    final confirmationController = TextEditingController();
    var canDelete = false;

    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('회원 탈퇴'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '계정과 개인정보가 영구 삭제되며 복구할 수 없습니다. '
                    '계속하려면 아래 입력란에 “탈퇴”를 입력하세요.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmationController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: '확인 문구',
                      hintText: '탈퇴',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        canDelete = value.trim() == '탈퇴';
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: canDelete
                      ? () => Navigator.of(dialogContext).pop(true)
                      : null,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.errorRed,
                  ),
                  child: const Text('계정 삭제'),
                ),
              ],
            );
          },
        );
      },
    );
    confirmationController.dispose();

    if (shouldDelete != true || !mounted) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final deleted = await authProvider.deleteAccount();

    if (!mounted) {
      return;
    }

    if (!deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? '회원 탈퇴에 실패했습니다.'),
        ),
      );
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
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: AppColors.headerGrey,
        elevation: 0,
        title: const Text(
          '마이페이지',
          style: TextStyle(
            color: AppColors.backgroundWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (authProvider.currentUser == null) {
            final errorText = authProvider.errorMessage;
            final requiresReLogin = errorText == null ||
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
                        color: AppColors.subText,
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
                    SettingsList(
                      onLogout: _handleLogout,
                      onDeleteAccount: _handleDeleteAccount,
                    ),
                    const SizedBox(height: 32),
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
