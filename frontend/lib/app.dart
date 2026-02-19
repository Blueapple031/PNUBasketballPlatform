import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/club/club_screen.dart';

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
        theme: ThemeData(
          primaryColor: AppColors.activeBlue,
          scaffoldBackgroundColor: AppColors.pageBg,
          useMaterial3: true,
        ),
        home: const ClubScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/club': (context) => const ClubScreen(),
        },
      ),
    );
  }
}
