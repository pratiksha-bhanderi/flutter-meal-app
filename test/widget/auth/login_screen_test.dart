import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meal_app/core/providers/cart_provider.dart';
import 'package:meal_app/core/providers/favourites_provider.dart';
import 'package:meal_app/core/providers/data_provider.dart';
import 'package:meal_app/core/providers/order_provider.dart';
import 'package:meal_app/core/providers/history_provider.dart';
import 'package:meal_app/core/providers/theme_provider.dart';
import 'package:meal_app/core/theme/app_theme.dart';
import 'package:meal_app/screens/auth/login_screen.dart';
import '../../helpers/test_helpers.dart';

Widget _makeTestable(Widget child) {
  SharedPreferences.setMockInitialValues({});
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => CartProvider()),
      ChangeNotifierProvider(create: (_) => FavouritesProvider()),
      ChangeNotifierProvider(create: (_) => DataProvider()),
      ChangeNotifierProvider(create: (_) => OrderProvider()),
      ChangeNotifierProvider(create: (_) => HistoryProvider()),
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

  group('LoginScreen Widget Tests', () {
    // ── Renders correctly ────────────────────────────────────────────────────
    testWidgets('shows "Welcome Back" heading', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(_makeTestable(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Welcome Back'), findsOneWidget);
    });

    testWidgets('shows email and password text fields', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(_makeTestable(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('shows "Sign In" button', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(_makeTestable(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('shows "Forgot password?" link', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(_makeTestable(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Forgot password'), findsOneWidget);
    });

    testWidgets('shows "Sign Up" link', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(_makeTestable(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Sign Up'), findsOneWidget);
    });

    // ── Form validation ──────────────────────────────────────────────────────
    testWidgets('shows validation error when submitting with empty fields',
        (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(_makeTestable(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.textContaining('enter your email'), findsOneWidget);
      expect(find.textContaining('enter your password'), findsOneWidget);
    });

    testWidgets('shows error for invalid email format', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(_makeTestable(const LoginScreen()));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'notanemail');
      await tester.enterText(fields.at(1), 'password123');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.textContaining('valid email'), findsOneWidget);
    });

    testWidgets('shows error when password is too short', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(_makeTestable(const LoginScreen()));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'user@test.com');
      await tester.enterText(fields.at(1), '123');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.textContaining('6 characters'), findsOneWidget);
    });

    testWidgets('no validation errors with valid credentials', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(_makeTestable(const LoginScreen()));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'user@test.com');
      await tester.enterText(fields.at(1), 'password123');
      await tester.pumpAndSettle();

      expect(find.textContaining('valid email'), findsNothing);
      expect(find.textContaining('6 characters'), findsNothing);
    });

    // ── Password visibility toggle ───────────────────────────────────────────
    testWidgets('has password visibility toggle icon', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(_makeTestable(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(
        find.byIcon(Icons.visibility_off_outlined),
        findsOneWidget,
      );
    });
  });
}
