import 'package:flutter/material.dart';

/// 401(Unauthorized) 발생 시 로그인 만료 처리
class SessionExpiredHandler {
  static GlobalKey<NavigatorState>? _navigatorKey;
  static Future<void> Function()? _onLogout;

  /// 앱 시작 시 설정 (navigatorKey, 로그아웃 콜백)
  static void configure({
    required GlobalKey<NavigatorState> navigatorKey,
    required Future<void> Function() onLogout,
  }) {
    _navigatorKey = navigatorKey;
    _onLogout = onLogout;
  }

  /// 401 발생 시 호출: 로그아웃 후 로그인 화면으로 이동
  static void trigger() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ctx = _navigatorKey?.currentContext;
      if (ctx == null) return;

      try {
        await _onLogout?.call();
      } catch (_) {}

      if (!ctx.mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text('로그인이 만료되었습니다.'),
          backgroundColor: Colors.red,
        ),
      );

      if (!ctx.mounted) return;
      Navigator.of(ctx).pushNamedAndRemoveUntil('/login', (route) => false);
    });
  }
}
