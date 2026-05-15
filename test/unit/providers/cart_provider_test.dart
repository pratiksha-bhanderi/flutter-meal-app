import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meal_app/core/providers/cart_provider.dart';

void main() {
  // Mock SharedPreferences before every test so nothing is persisted to disk
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CartProvider', () {
    // ── Helpers ─────────────────────────────────────────────────────────────
    Map<String, dynamic> _meal({
      String name = 'Test Pizza',
      String price = '\$10.00',
      String image = 'assets/pizza.png',
    }) =>
        {'name': name, 'price': price, 'image': image};

    // ── addToCart ────────────────────────────────────────────────────────────
    group('addToCart', () {
      test('adds a new item with quantity 1', () async {
        final provider = CartProvider();
        await Future.delayed(Duration.zero); // wait for _initCart
        await provider.addToCart(_meal());

        expect(provider.items.length, 1);
        expect(provider.items[0]['name'], 'Test Pizza');
        expect(provider.items[0]['quantity'], 1);
      });

      test('increments quantity when same item added twice', () async {
        final provider = CartProvider();
        await Future.delayed(Duration.zero);
        await provider.addToCart(_meal());
        await provider.addToCart(_meal());

        expect(provider.items.length, 1);
        expect(provider.items[0]['quantity'], 2);
      });

      test('adds two different items separately', () async {
        final provider = CartProvider();
        await Future.delayed(Duration.zero);
        await provider.addToCart(_meal(name: 'Pizza'));
        await provider.addToCart(_meal(name: 'Burger', price: '\$12.00'));

        expect(provider.items.length, 2);
      });
    });

    // ── updateQuantity ───────────────────────────────────────────────────────
    group('updateQuantity', () {
      test('increments quantity by 1', () async {
        final provider = CartProvider();
        await Future.delayed(Duration.zero);
        await provider.addToCart(_meal());
        await provider.updateQuantity(0, 1);

        expect(provider.items[0]['quantity'], 2);
      });

      test('decrements quantity by 1', () async {
        final provider = CartProvider();
        await Future.delayed(Duration.zero);
        await provider.addToCart(_meal());
        await provider.updateQuantity(0, 1); // → qty 2
        await provider.updateQuantity(0, -1); // → qty 1

        expect(provider.items[0]['quantity'], 1);
      });

      test('removes item when quantity drops to 0', () async {
        final provider = CartProvider();
        await Future.delayed(Duration.zero);
        await provider.addToCart(_meal());
        await provider.updateQuantity(0, -1); // qty was 1 → 0 → removed

        expect(provider.items.isEmpty, true);
      });
    });

    // ── removeItem ───────────────────────────────────────────────────────────
    group('removeItem', () {
      test('removes item at given index', () async {
        final provider = CartProvider();
        await Future.delayed(Duration.zero);
        await provider.addToCart(_meal(name: 'Pizza'));
        await provider.addToCart(_meal(name: 'Burger', price: '\$12.00'));
        await provider.removeItem(0);

        expect(provider.items.length, 1);
        expect(provider.items[0]['name'], 'Burger');
      });
    });

    // ── clearCart ────────────────────────────────────────────────────────────
    group('clearCart', () {
      test('empties the cart completely', () async {
        final provider = CartProvider();
        await Future.delayed(Duration.zero);
        await provider.addToCart(_meal());
        await provider.addToCart(_meal(name: 'Burger', price: '\$12.00'));
        await provider.clearCart();

        expect(provider.items.isEmpty, true);
      });
    });

    // ── Computed values ──────────────────────────────────────────────────────
    group('computed values', () {
      test('itemCount sums all quantities', () async {
        final provider = CartProvider();
        await Future.delayed(Duration.zero);
        await provider.addToCart(_meal(name: 'Pizza'));
        await provider.addToCart(_meal(name: 'Pizza')); // qty 2
        await provider.addToCart(_meal(name: 'Burger', price: '\$12.00')); // qty 1

        expect(provider.itemCount, 3);
      });

      test('subtotal calculates correctly', () async {
        final provider = CartProvider();
        await Future.delayed(Duration.zero);
        await provider.addToCart(_meal(price: '\$10.00'));
        await provider.addToCart(_meal(price: '\$10.00')); // qty = 2 → \$20.00

        expect(provider.subtotal, closeTo(20.00, 0.01));
      });

      test('deliveryFee is 0 when cart is empty', () async {
        final provider = CartProvider();
        await Future.delayed(Duration.zero);

        expect(provider.deliveryFee, 0.0);
      });

      test('deliveryFee is 2.50 when cart has items', () async {
        final provider = CartProvider();
        await Future.delayed(Duration.zero);
        await provider.addToCart(_meal());

        expect(provider.deliveryFee, 2.50);
      });

      test('total equals subtotal + deliveryFee', () async {
        final provider = CartProvider();
        await Future.delayed(Duration.zero);
        await provider.addToCart(_meal(price: '\$10.00'));

        expect(provider.total, closeTo(12.50, 0.01));
      });
    });

    // ── Lookups ──────────────────────────────────────────────────────────────
    group('getItemQuantity', () {
      test('returns 0 for unknown item', () async {
        final provider = CartProvider();
        await Future.delayed(Duration.zero);

        expect(provider.getItemQuantity('Ghost Item'), 0);
      });

      test('returns correct quantity for existing item', () async {
        final provider = CartProvider();
        await Future.delayed(Duration.zero);
        await provider.addToCart(_meal(name: 'Pizza'));
        await provider.addToCart(_meal(name: 'Pizza')); // qty 2

        expect(provider.getItemQuantity('Pizza'), 2);
      });
    });

    group('getItemIndex', () {
      test('returns -1 for unknown item', () async {
        final provider = CartProvider();
        await Future.delayed(Duration.zero);

        expect(provider.getItemIndex('Ghost'), -1);
      });

      test('returns correct index for existing item', () async {
        final provider = CartProvider();
        await Future.delayed(Duration.zero);
        await provider.addToCart(_meal(name: 'Burger', price: '\$12.00'));
        await provider.addToCart(_meal(name: 'Pizza'));

        expect(provider.getItemIndex('Pizza'), 1);
      });
    });
  });
}
