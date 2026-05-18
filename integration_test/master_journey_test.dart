import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meal_app/main.dart' as app;
import 'package:meal_app/core/services/auth_service.dart';
import 'package:meal_app/core/widgets/meal_card.dart' as app_meal_card;

/// MEALMATE PERFECT MASTER JOURNEY
/// A comprehensive tour of every major feature and screen.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> slowStep(WidgetTester tester, String message) async {
    print('STEP: $message');
    await tester.pump(const Duration(seconds: 3));
  }

  group('MealMate Perfect Master Journey', () {
    testWidgets('Full Visual App Tour', (tester) async {
      // 0. Reset State
      SharedPreferences.setMockInitialValues({});
      await AuthService.resetOnboarding();
      await AuthService.logout();

      // 1. Launch & Splash
      app.main();
      await tester.pump(const Duration(seconds: 2));
      await slowStep(tester, 'App Launched - Showing Animated Splash');
      await tester.pump(const Duration(seconds: 5));

      // 2. Full Onboarding Sequence
      await slowStep(tester, 'Starting Onboarding Sequence');
      for (int i = 0; i < 2; i++) {
        await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
        await slowStep(tester, 'Exploring Feature ${i + 1}...');
      }
      await tester.tap(find.text('Get Started'));
      await slowStep(tester, 'Welcome to Login');

      // 3. Login Flow
      final emailFinder = find.byType(TextFormField).at(0);
      final passwordFinder = find.byType(TextFormField).at(1);
      await tester.enterText(emailFinder, 'tester@mealmate.com');
      await tester.enterText(passwordFinder, 'password123');
      await tester.tap(find.text('Sign In'));
      await slowStep(tester, 'Logging In... (Fetching Production Data)');

      // 4. Home Screen Exploration
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await slowStep(tester, 'Home Dashboard Loaded');

      // 4a. Check Notifications
      final bellIcon = find.byIcon(Icons.notifications_outlined);
      await tester.tap(bellIcon);
      await slowStep(tester, 'Checking Notification Center...');
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await slowStep(tester, 'Returning to Home');

      // 4b. Scroll Home Content
      final scrollFinder = find.byType(CustomScrollView);
      await tester.drag(scrollFinder, const Offset(0, -300));
      await slowStep(tester, 'Browsing Flash Sales & Daily Deals');

      // 4c. Filter by Category
      await tester.tap(find.text('Burgers').first);
      await slowStep(tester, 'Filtering for Gourmet Burgers...');
      await tester.tap(find.text('All').first);
      await slowStep(tester, 'Resetting Filters');

      // 5. Deep Search & Explore
      // Scroll back up to see the search bar
      await tester.drag(scrollFinder, const Offset(0, 300));
      await tester.pumpAndSettle();

      final searchBar = find.textContaining('Search your favorite');
      await tester.ensureVisible(searchBar);
      await tester.tap(searchBar);
      await slowStep(tester, 'Opening Search Explorer');

      final searchInput = find.byType(TextField).first;
      await tester.enterText(searchInput, 'Pizza');
      await slowStep(tester, 'Searching for "Pizza"');

      // Scroll explorer results
      await tester.drag(find.byType(GridView), const Offset(0, -400));
      await slowStep(tester, 'Exploring Search Results...');
      await tester.drag(find.byType(GridView), const Offset(0, 400));

      // 6. Meal Details & Favourites
      // Tap heart on the first meal card in Explorer
      final heartIcon = find.byIcon(Icons.favorite_outline_rounded).first;
      await tester.tap(heartIcon);
      await slowStep(tester, 'Adding to Favourites from Explorer ❤️');

      final mealCard = find.byType(app_meal_card.MealCard).first;
      await tester.tap(mealCard);
      await slowStep(tester, 'Viewing Meal Details');

      // Swipe images in Detail Page
      final pageView = find.byType(PageView);
      if (pageView.evaluate().isNotEmpty) {
        await tester.drag(pageView, const Offset(-300, 0));
        await slowStep(tester, 'Viewing Meal Photos');
      }

      // 7. Customization Flow
      await tester.tap(find.text('Details'));
      await slowStep(tester, 'Reading Meal Info');

      await tester.tap(find.textContaining('Customize Ingredients'));
      await slowStep(tester, 'Entering Customizer');

      await tester.tap(find.text('Pepperoni'));
      await slowStep(tester, 'Adding Extra Pepperoni');

      await tester.tap(find.text('Done'));
      await slowStep(tester, 'Customization Finished');

      // 8. Checkout Journey
      await tester.tap(find.text('Buy Now'));
      await slowStep(tester, 'Moving to Cart');

      expect(find.text('Cart'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.add).first);
      await slowStep(tester, 'Increasing Quantity to 2');

      await tester.enterText(find.byType(TextField).last, 'MEALMATE20');
      await slowStep(tester, 'Applying Promo Code');

      await tester.tap(find.text('Check out'));
      await slowStep(tester, 'Verifying Order Summary');

      await tester.tap(find.text('Place Order'));
      await slowStep(tester, 'Processing Payment...');

      // 9. Order Tracking
      await tester.tap(find.text('Track Order'));
      await slowStep(tester, 'Monitoring Live Delivery Status');

      await tester.tap(find.text('Back to Home'));
      await slowStep(tester, 'Returning to Dashboard');

      // 10. Navigating Tabs (Favourites)
      final favTab = find.byIcon(Icons.favorite_outline_rounded);
      await tester.tap(favTab);
      await slowStep(tester, 'Viewing Saved Favourites');

      // 11. Settings & Profile
      final settingsTab = find.byIcon(Icons.settings_outlined);
      await tester.tap(settingsTab);
      await slowStep(tester, 'Opening App Settings');

      // Explore Order History from Settings
      await tester.tap(find.text('Order History'));
      await slowStep(tester, 'Viewing Previous Orders');
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await slowStep(tester, 'Back to Settings');

      final darkModeSwitch = find.byType(Switch).first;
      await tester.tap(darkModeSwitch);
      await slowStep(tester, 'Switching Theme Mode');
      await tester.pump(
        const Duration(seconds: 3),
      ); // Wait for theme transition

      // Go to Profile
      await tester.tap(find.text('Account'));
      await slowStep(tester, 'Entering Profile Screen');

      // Explore Addresses from Profile
      await tester.tap(find.text('Delivery Addresses'));
      await slowStep(tester, 'Checking Saved Addresses');
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await slowStep(tester, 'Back to Profile');

      // Explore Payments
      await tester.tap(find.text('Payment Cards'));
      await slowStep(tester, 'Managing Payment Methods');
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await slowStep(tester, 'Back to Profile');

      // Explore Offers
      await tester.tap(find.text('Offers & Promo Codes'));
      await slowStep(tester, 'Viewing Active Coupons');
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await slowStep(tester, 'Back to Profile');

      // Toggles with proper visibility checks
      final pushSwitch = find.byType(Switch).at(0);
      await tester.ensureVisible(pushSwitch);
      await tester.tap(pushSwitch);
      await slowStep(tester, 'Toggling Push Notifications');

      final faceIdSwitch = find
          .byType(Switch)
          .at(2); // Face ID is the 3rd switch on this screen
      await tester.ensureVisible(faceIdSwitch);
      await tester.tap(faceIdSwitch);
      await slowStep(tester, 'Toggling Biometric Security');

      // Manual scroll to find Logout
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -600),
      );
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Log Out'));
      await slowStep(tester, 'Logging Out of MealMate');

      expect(find.textContaining('Welcome Back'), findsOneWidget);
      print('--- PERFECT MASTER TOUR COMPLETED ---');
    });
  });
}
