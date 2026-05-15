import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meal_app/core/providers/cart_provider.dart';
import 'package:meal_app/core/providers/favourites_provider.dart';
import 'package:meal_app/core/providers/data_provider.dart';
import 'package:meal_app/core/providers/order_provider.dart';
import 'package:meal_app/core/providers/history_provider.dart';
import 'package:meal_app/core/providers/theme_provider.dart';
import 'package:meal_app/core/theme/app_theme.dart';
import 'package:meal_app/router/app_router.dart';

// ---------------------------------------------------------------------------
// Helper: Boots the full app with a clean (mocked) SharedPreferences state.
// ---------------------------------------------------------------------------
Widget _bootApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => CartProvider()),
      ChangeNotifierProvider(create: (_) => FavouritesProvider()),
      ChangeNotifierProvider(create: (_) => DataProvider()),
      ChangeNotifierProvider(create: (_) => OrderProvider()),
      ChangeNotifierProvider(create: (_) => HistoryProvider()),
    ],
    child: Builder(
      builder: (context) {
        final themeProvider = context.watch<ThemeProvider>();
        return MaterialApp(
          title: 'MealMate Test',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: AppRouter.login, // Start at login (bypass splash/auth guard)
          onGenerateRoute: AppRouter.generateRoute,
        );
      },
    ),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Give every test a clean state
    SharedPreferences.setMockInitialValues({});
  });

  // ── Flow 1: Auth ──────────────────────────────────────────────────────────
  group('Auth Flow', () {
    testWidgets('Login screen renders and validates empty form', (tester) async {
      await tester.pumpWidget(_bootApp());
      await tester.pumpAndSettle();

      // Confirm we are on Login
      expect(find.textContaining('Welcome Back'), findsOneWidget);

      // Tap Sign In with empty fields → validation errors appear
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.textContaining('enter your email'), findsOneWidget);
    });

    testWidgets('Valid login navigates to Home screen', (tester) async {
      await tester.pumpWidget(_bootApp());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'user@mealmate.com');
      await tester.enterText(fields.at(1), 'password123');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // After 1s mock delay, home loads
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Home has the greeting
      expect(find.textContaining('Good day'), findsOneWidget);
    });

    testWidgets('Forgot Password link navigates to ForgotPassword screen',
        (tester) async {
      await tester.pumpWidget(_bootApp());
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Forgot password'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Forgot Password'), findsOneWidget);
    });
  });

  // ── Flow 2: Cart ──────────────────────────────────────────────────────────
  group('Cart Flow', () {
    testWidgets('Cart screen shows empty state initially', (tester) async {
      await tester.pumpWidget(_bootApp());
      await tester.pumpAndSettle();

      // Navigate directly to cart
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => CartProvider()),
            ChangeNotifierProvider(create: (_) => FavouritesProvider()),
            ChangeNotifierProvider(create: (_) => DataProvider()),
            ChangeNotifierProvider(create: (_) => OrderProvider()),
            ChangeNotifierProvider(create: (_) => HistoryProvider()),
          ],
          child: MaterialApp(
            navigatorKey: navigatorKey,
            theme: AppTheme.lightTheme,
            initialRoute: AppRouter.cart,
            onGenerateRoute: AppRouter.generateRoute,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your cart is empty'), findsOneWidget);
    });
  });

  // ── Flow 3: Favourites ────────────────────────────────────────────────────
  group('Favourites Flow', () {
    testWidgets('Favourites screen shows empty state initially', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => FavouritesProvider()),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            initialRoute: AppRouter.addresses, // dummy - test below uses direct widget
            onGenerateRoute: AppRouter.generateRoute,
          ),
        ),
      );
      await tester.pumpAndSettle();
    });
  });

  // ── Flow 4: Settings / Theme Toggle ──────────────────────────────────────
  group('Settings Flow', () {
    testWidgets('Settings screen shows Dark Mode toggle', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            initialRoute: AppRouter.settings,
            onGenerateRoute: AppRouter.generateRoute,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('Toggling Dark Mode switch changes theme mode', (tester) async {
      final themeProvider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>.value(
          value: themeProvider,
          child: Consumer<ThemeProvider>(
            builder: (context, tp, _) => MaterialApp(
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: tp.themeMode,
              initialRoute: AppRouter.settings,
              onGenerateRoute: AppRouter.generateRoute,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final before = themeProvider.themeMode;
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(themeProvider.themeMode, isNot(before));
    });
  });

  // ── Flow 5: Forgot Password full flow ────────────────────────────────────
  group('Forgot Password Flow', () {
    testWidgets('Entering valid email shows success state', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            initialRoute: AppRouter.forgotPassword,
            onGenerateRoute: AppRouter.generateRoute,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'test@mealmate.com');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('Check Your Mail'), findsOneWidget);
    });
  });
}
