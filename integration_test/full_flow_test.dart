import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meal_app/main.dart' as app;
import 'package:meal_app/core/widgets/meal_card.dart' as app_meal_card;

/// This is a high-level Integration Test (E2E) that simulates a real user journey.
/// It runs on a real device or simulator.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Full App Journey', () {
    testWidgets('Login, Browse, Add to Cart, and Change Settings', (
      tester,
    ) async {
      // 1. Start the app
      // We set has_seen_onboarding to true so we go straight to Login/Splash
      SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});
      app.main();
      await tester.pumpAndSettle();

      // Wait for Splash screen to transition (usually a few seconds)
      print('--- Waiting for Splash to finish ---');
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // 2. Login Flow
      print('--- Starting Login Flow ---');
      // Look for the specific hint texts or labels
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;
      final signInButton = find.text('Sign In');

      // If we don't find them, it might be because the app is still loading
      if (emailField.evaluate().isEmpty) {
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();
      }

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'testuser@gmail.com',
      );
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 500));

      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 500));

      await tester.tap(signInButton);
      // Wait for login processing and navigation
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));

      // 3. Home Screen - Browse and Add to Cart
      print('--- Browsing Meals ---');
      // Wait for data provider to load meals and animations to settle
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Find the first MealCard - this is safer than searching by text
      final mealCard = find.byType(app_meal_card.MealCard).first;

      // Scroll to make sure it's fully visible and hit-testable
      await tester.ensureVisible(mealCard);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));

      print('--- Adding Item to Cart ---');
      await tester.tap(mealCard);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));

      // Assuming we are on Detail screen now, look for "Add to Cart"
      final addToCartBtn = find.textContaining('Add to Cart');
      if (addToCartBtn.evaluate().isNotEmpty) {
        await tester.tap(addToCartBtn);
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(seconds: 1));
      }

      // 4. Navigate to Cart
      print('--- Navigating to Cart ---');
      // Tap the Cart tab in BottomNavigationBar (index 1 usually)
      final cartTab = find.byIcon(Icons.shopping_cart_outlined);
      await tester.tap(cartTab);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      // Verify something is in cart (any item name since we tapped the first one)
      expect(find.byType(ListTile), findsWidgets);
      print('--- Item found in cart! ---');

      // 5. Navigate to Settings
      print('--- Navigating to Settings ---');
      final settingsTab = find.byIcon(Icons.person_outline_rounded);
      await tester.tap(settingsTab);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));

      // 6. Toggle Theme
      print('--- Toggling Dark Mode ---');
      final darkModeSwitch = find.byType(Switch);
      expect(darkModeSwitch, findsOneWidget);

      await tester.tap(darkModeSwitch);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      print('--- Journey Completed Successfully ---');
    });
  });
}
