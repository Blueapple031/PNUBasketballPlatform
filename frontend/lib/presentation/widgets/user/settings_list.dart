import 'package:flutter/material.dart';
import 'package:basketball_frontend/core/theme/plato_theme.dart';

class SettingsList extends StatelessWidget {
  final VoidCallback? onLogout;

  const SettingsList({
    super.key,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            '설정',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: PlatoColors.titleText,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 8),
        const _SettingsMenuTile(
          icon: Icons.language,
          title: '언어 설정',
          subtitle: '한국어 / 日本語',
        ),
        const _SettingsMenuTile(
          icon: Icons.notifications,
          title: '알림 설정',
        ),
        const _SettingsMenuTile(
          icon: Icons.help_center,
          title: '고객센터',
        ),
        const _SettingsMenuTile(
          icon: Icons.info,
          title: '공지사항',
        ),
        _SettingsMenuTile(
          icon: Icons.logout,
          title: '로그아웃',
          isDestructive: true,
          onTap: onLogout,
        ),
        const _SettingsMenuTile(
          icon: Icons.delete_forever,
          title: '탈퇴',
          subtitle: '계정을 영구 삭제합니다',
          isDestructive: true,
        ),
      ],
    );
  }
}

class _SettingsMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _SettingsMenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: PlatoColors.border),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(
          icon,
          color: isDestructive ? PlatoColors.errorRed : PlatoColors.headerGrey,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? PlatoColors.errorRed : PlatoColors.titleText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: const TextStyle(
                  color: PlatoColors.subText,
                  fontSize: 12,
                ),
              )
            : null,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: PlatoColors.subText,
        ),
        onTap: onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title 클릭됨')),
              );
            },
      ),
    );
  }
}
