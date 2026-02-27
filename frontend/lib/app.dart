import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/root/root_screen.dart';
import 'presentation/screens/user/user_tab.dart';

class BasketballApp extends StatelessWidget {
  const BasketballApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: '딸바',
        theme: AppTheme.theme,
        home: const RootScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const RootScreen(),
        },
      ),
    );
  }
}
