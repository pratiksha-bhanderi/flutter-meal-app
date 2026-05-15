import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meal_app/core/providers/theme_provider.dart';
import 'package:meal_app/core/theme/app_theme.dart';
import 'package:meal_app/screens/settings/settings_screen.dart';
import '../../helpers/test_helpers.dart';

Widget _makeTestable({required ThemeProvider themeProvider}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const SettingsScreen(showBackButton: false),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsScreen Widget Tests', () {
    testWidgets('shows "Settings" title in AppBar', (tester) async {
      setPhoneViewport(tester);
      final theme = ThemeProvider();
      await tester.pumpWidget(_makeTestable(themeProvider: theme));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows "Dark Mode" toggle', (tester) async {
      setPhoneViewport(tester);
      final theme = ThemeProvider();
      await tester.pumpWidget(_makeTestable(themeProvider: theme));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Dark Mode'), findsOneWidget);
    });

    testWidgets('shows a Switch widget for dark mode', (tester) async {
      setPhoneViewport(tester);
      final theme = ThemeProvider();
      await tester.pumpWidget(_makeTestable(themeProvider: theme));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('shows ACCOUNT section label', (tester) async {
      setPhoneViewport(tester);
      final theme = ThemeProvider();
      await tester.pumpWidget(_makeTestable(themeProvider: theme));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('ACCOUNT'), findsOneWidget);
    });

    testWidgets('shows APPEARANCE section label', (tester) async {
      setPhoneViewport(tester);
      final theme = ThemeProvider();
      await tester.pumpWidget(_makeTestable(themeProvider: theme));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('APPEARANCE'), findsOneWidget);
    });

    testWidgets('shows Order History row', (tester) async {
      setPhoneViewport(tester);
      final theme = ThemeProvider();
      await tester.pumpWidget(_makeTestable(themeProvider: theme));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Order History'), findsOneWidget);
    });

    testWidgets('toggling the switch calls setDark on the provider', (tester) async {
      setPhoneViewport(tester);
      final theme = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 50)); // wait for _loadTheme
      await tester.pumpWidget(_makeTestable(themeProvider: theme));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final initialMode = theme.themeMode;
      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(theme.themeMode, isNot(initialMode));
    });
  });
}
