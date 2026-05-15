import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meal_app/core/providers/cart_provider.dart';
import 'package:meal_app/core/providers/theme_provider.dart';
import 'package:meal_app/core/providers/favourites_provider.dart';
import 'package:meal_app/core/theme/app_theme.dart';
import 'package:meal_app/screens/home/cart_screen.dart';
import '../../helpers/test_helpers.dart';

/// Pre-populate CartProvider with test items by adding them after build
Future<CartProvider> _cartWithItems(List<Map<String, dynamic>> items) async {
  final provider = CartProvider();
  for (final item in items) {
    await provider.addToCart(item);
  }
  return provider;
}

Widget _makeTestable({required CartProvider cartProvider}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => FavouritesProvider()),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const CartScreen(showBackButton: false),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CartScreen Widget Tests', () {
    // ── Empty state ──────────────────────────────────────────────────────────
    group('when cart is empty', () {
      testWidgets('shows "Your cart is empty" message', (tester) async {
        setPhoneViewport(tester);
        final cart = await _cartWithItems([]);
        await tester.pumpWidget(_makeTestable(cartProvider: cart));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Your cart is empty'), findsOneWidget);
      });

      testWidgets('shows "Start Ordering" button', (tester) async {
        setPhoneViewport(tester);
        final cart = await _cartWithItems([]);
        await tester.pumpWidget(_makeTestable(cartProvider: cart));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Start Ordering'), findsOneWidget);
      });

      testWidgets('does NOT show checkout button', (tester) async {
        setPhoneViewport(tester);
        final cart = await _cartWithItems([]);
        await tester.pumpWidget(_makeTestable(cartProvider: cart));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Check out'), findsNothing);
      });
    });

    // ── Filled state ─────────────────────────────────────────────────────────
    group('when cart has items', () {
      final testItems = [
        {'name': 'Pepperoni Pizza', 'price': '\$14.50', 'image': 'assets/images/meals/pizza.png'},
        {'name': 'Classic Burger',  'price': '\$12.99', 'image': 'assets/images/meals/burger.png'},
      ];

      testWidgets('shows item names', (tester) async {
        setPhoneViewport(tester);
        final cart = await _cartWithItems(testItems);
        await tester.pumpWidget(_makeTestable(cartProvider: cart));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Pepperoni Pizza'), findsOneWidget);
        expect(find.text('Classic Burger'), findsOneWidget);
      });

      testWidgets('shows item prices', (tester) async {
        setPhoneViewport(tester);
        final cart = await _cartWithItems(testItems);
        await tester.pumpWidget(_makeTestable(cartProvider: cart));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('\$14.50'), findsOneWidget);
        expect(find.text('\$12.99'), findsOneWidget);
      });

      testWidgets('shows "Check out" button', (tester) async {
        setPhoneViewport(tester);
        final cart = await _cartWithItems(testItems);
        await tester.pumpWidget(_makeTestable(cartProvider: cart));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Check out'), findsOneWidget);
      });

      testWidgets('shows promo code text field', (tester) async {
        setPhoneViewport(tester);
        final cart = await _cartWithItems(testItems);
        await tester.pumpWidget(_makeTestable(cartProvider: cart));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.textContaining('promo code'), findsOneWidget);
      });

      testWidgets('shows Subtotal and Delivery Fee labels', (tester) async {
        setPhoneViewport(tester);
        final cart = await _cartWithItems(testItems);
        await tester.pumpWidget(_makeTestable(cartProvider: cart));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Subtotal'), findsOneWidget);
        expect(find.text('Delivery Fee'), findsOneWidget);
        expect(find.text('Total'), findsOneWidget);
      });

      testWidgets('shows correct total amount', (tester) async {
        setPhoneViewport(tester);
        final cart = await _cartWithItems([
          {'name': 'Pizza', 'price': '\$10.00', 'image': 'assets/images/meals/pizza.png'},
        ]);
        await tester.pumpWidget(_makeTestable(cartProvider: cart));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Total = 10.00 + 2.50 delivery = 12.50
        expect(find.text('\$12.50'), findsOneWidget);
      });

      testWidgets('shows "Cart" as app bar title', (tester) async {
        setPhoneViewport(tester);
        final cart = await _cartWithItems(testItems);
        await tester.pumpWidget(_makeTestable(cartProvider: cart));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Cart'), findsOneWidget);
      });
    });
  });
}
