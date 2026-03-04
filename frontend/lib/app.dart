import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/root/root_screen.dart';

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
        home: const AuthGate(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const RootScreen(),
        },
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<bool> _initializeFuture;

  @override
  void initState() {
    super.initState();
    _initializeFuture = context.read<AuthProvider>().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _initializeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return const RootScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
