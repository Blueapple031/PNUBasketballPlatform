// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:basketball_frontend/presentation/providers/club_match_provider.dart';
import 'package:basketball_frontend/presentation/providers/recruitment_provider.dart';
import 'package:basketball_frontend/presentation/screens/matching/matching_screen.dart';

void main() {
  testWidgets('Matching screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => RecruitmentProvider()),
          ChangeNotifierProvider(create: (_) => ClubMatchProvider()),
        ],
        child: const MaterialApp(home: MatchingScreen()),
      ),
    );

    expect(find.byKey(const ValueKey('brand-logo')), findsOneWidget);
    expect(find.byKey(const ValueKey('brand-wordmark')), findsOneWidget);
    expect(find.text('게스트/번개'), findsOneWidget);
    expect(find.text('동아리 친선전'), findsOneWidget);
    expect(find.text('모집하기'), findsOneWidget);
  });
}
