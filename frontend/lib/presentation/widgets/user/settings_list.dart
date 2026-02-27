import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SettingsList extends StatelessWidget {
  const SettingsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              '설정',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.titleText,
              ),
            ),
          ),
          const _SettingsMenuTile(
            icon: Icons.language,
            title: '언어 설정',
            subtitle: '한국어 / 日本語',
          ),
          const _SettingsMenuTile(
            icon: Icons.notifications,
            title: '알림 설정',
            subtitle: '',
          ),
          const _SettingsMenuTile(
            icon: Icons.help_center,
            title: '고객센터',
            subtitle: '',
          ),
          const _SettingsMenuTile(
            icon: Icons.info,
            title: '공지사항',
            subtitle: '',
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          const _SettingsMenuTile(
            icon: Icons.logout,
            title: '로그아웃',
            subtitle: '',
            isDestructive: true,
          ),
          const _SettingsMenuTile(
            icon: Icons.delete_forever,
            title: '탈퇴',
            subtitle: '계정을 영구 삭제합니다',
            isDestructive: true,
          ),
        ],
      ),
    );
  }
}

class _SettingsMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isDestructive;

  const _SettingsMenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.errorRed : AppColors.titleText;
    final iconColor = isDestructive ? AppColors.errorRed : AppColors.subText;
    
    return InkWell(
      onTap: () {},
      splashColor: AppColors.activeBlue.withValues(alpha: 0.1),
      highlightColor: AppColors.activeBlue.withValues(alpha: 0.05),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.subText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.subText,
            ),
          ],
        ),
      ),
    );
  }
}
