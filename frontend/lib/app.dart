import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/auth/session_expired_handler.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/community_provider.dart';
import 'presentation/providers/schedule_provider.dart';
import 'presentation/providers/recruitment_provider.dart';
import 'presentation/providers/match_provider.dart';
import 'presentation/providers/club_match_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/complete_profile_screen.dart';
import 'presentation/screens/auth/club_selection_screen.dart';
import 'presentation/screens/root/root_screen.dart';
import 'presentation/screens/matching/recruitment_create_screen.dart';
import 'presentation/screens/matching/recruitment_detail_screen.dart';
import 'presentation/screens/matching/club_match_create_screen.dart';
import 'presentation/screens/matching/club_match_detail_screen.dart';

class BasketballApp extends StatefulWidget {
  const BasketballApp({super.key});

  @override
  State<BasketballApp> createState() => _BasketballAppState();
}

class _BasketballAppState extends State<BasketballApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _configureSessionExpiredHandler();
    });
  }

  void _configureSessionExpiredHandler() {
    final ctx = _navigatorKey.currentContext;
    if (ctx == null) return;
    SessionExpiredHandler.configure(
      navigatorKey: _navigatorKey,
      onLogout: () => ctx.read<AuthProvider>().logout(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => RecruitmentProvider()),
        ChangeNotifierProvider(create: (_) => MatchProvider()),
        ChangeNotifierProvider(create: (_) => ClubMatchProvider()),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: '딸바',
        theme: AppTheme.theme,
        home: const AuthGate(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/recruitment-detail':
              final id = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => RecruitmentDetailScreen(recruitmentId: id),
              );
            case '/club-match-detail':
              final id = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => ClubMatchDetailScreen(requestId: id),
              );
            default:
              return null;
          }
        },
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const RootScreen(),
          '/club': (context) => const RootScreen(initialIndex: 1),
          '/root': (context) => const RootScreen(),
          '/complete-profile': (context) => const CompleteProfileScreen(),
          '/club-selection': (context) => const ClubSelectionScreen(),
          '/recruitment-create': (context) => const RecruitmentCreateScreen(),
          '/club-match-create': (context) => const ClubMatchCreateScreen(),
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
