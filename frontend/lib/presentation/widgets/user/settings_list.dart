import 'package:flutter/material.dart';

class SettingsList extends StatelessWidget {
  const SettingsList({super.key});

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
                  fontWeight: FontWeight.bold,
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
        const Divider(height: 1),
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
    );
  }
}

class _SettingsMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDestructive;

  const _SettingsMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.grey.shade700,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey.shade400,
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title 클릭됨')),
        );
      },
    );
  }
}
