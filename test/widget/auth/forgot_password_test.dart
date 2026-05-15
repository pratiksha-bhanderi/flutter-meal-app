import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meal_app/core/providers/theme_provider.dart';
import 'package:meal_app/core/theme/app_theme.dart';
import 'package:meal_app/screens/auth/forgot_password_screen.dart';
import '../../helpers/test_helpers.dart';

Widget _makeTestable(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: child,
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ForgotPasswordScreen Widget Tests', () {
    // ── Renders correctly ────────────────────────────────────────────────────
    testWidgets('shows "Forgot Password?" heading', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(_makeTestable(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Forgot Password'), findsOneWidget);
    });

    testWidgets('shows email text field', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(_makeTestable(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('shows "Send Reset Link" button', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(_makeTestable(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Send Reset Link'), findsOneWidget);
    });

    testWidgets('shows back arrow in AppBar', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(_makeTestable(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });

    // ── Form validation ──────────────────────────────────────────────────────
    testWidgets('shows validation error when submitting with empty email',
        (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(_makeTestable(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();

      expect(find.textContaining('enter your email'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid email format',
        (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(_makeTestable(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'notanemail');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();

      expect(find.textContaining('valid email'), findsOneWidget);
    });

    // ── Success flow ─────────────────────────────────────────────────────────
    testWidgets('shows success view after valid email submission',
        (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(_makeTestable(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextFormField), 'user@example.com');
      await tester.tap(find.text('Send Reset Link'));

      // Simulate the 2-second API delay
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('Check Your Mail'), findsOneWidget);
    });

    testWidgets('success view has "Back to Login" button', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(_makeTestable(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextFormField), 'user@example.com');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('Back to Login'), findsOneWidget);
    });
  });
}
