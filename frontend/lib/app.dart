import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/complete_profile_screen.dart';
import 'presentation/screens/auth/club_selection_screen.dart';
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
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const LoginScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const RootScreen(),
          '/complete-profile': (context) => const CompleteProfileScreen(),
          '/club-selection': (context) => const ClubSelectionScreen(),
        },
      ),
    );
  }
}
