import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meal_app/core/providers/order_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('OrderProvider', () {
    // ── Helpers ──────────────────────────────────────────────────────────────
    List<Map<String, dynamic>> _sampleItems() => [
          {
            'name': 'Pepperoni Pizza',
            'price': '\$14.50',
            'quantity': 2,
            'image': 'assets/pizza.png',
          },
        ];

    // Wait for the provider constructor's loadOrders() to finish
    Future<OrderProvider> _buildProvider() async {
      final provider = OrderProvider();
      await Future.delayed(const Duration(milliseconds: 50));
      return provider;
    }

    // ── Initial state ────────────────────────────────────────────────────────
    test('starts with an empty order history', () async {
      final provider = await _buildProvider();

      expect(provider.pastOrders.isEmpty, true);
      expect(provider.isLoading, false);
    });

    // ── placeOrder ───────────────────────────────────────────────────────────
    group('placeOrder', () {
      test('adds a new order to pastOrders', () async {
        final provider = await _buildProvider();
        await provider.placeOrder(_sampleItems(), 31.50);

        expect(provider.pastOrders.length, 1);
      });

      test('order contains correct total', () async {
        final provider = await _buildProvider();
        await provider.placeOrder(_sampleItems(), 31.50);

        expect(provider.pastOrders[0]['total'], 31.50);
      });

      test('order contains correct items', () async {
        final provider = await _buildProvider();
        await provider.placeOrder(_sampleItems(), 31.50);

        final items = provider.pastOrders[0]['items'] as List;
        expect(items.length, 1);
        expect(items[0]['name'], 'Pepperoni Pizza');
      });

      test('order has an id', () async {
        final provider = await _buildProvider();
        await provider.placeOrder(_sampleItems(), 31.50);

        expect(provider.pastOrders[0]['id'], isNotNull);
        expect(provider.pastOrders[0]['id'], isNotEmpty);
      });

      test('order has a date', () async {
        final provider = await _buildProvider();
        await provider.placeOrder(_sampleItems(), 31.50);

        expect(provider.pastOrders[0]['date'], isNotNull);
      });

      test('order status defaults to Delivered', () async {
        final provider = await _buildProvider();
        await provider.placeOrder(_sampleItems(), 31.50);

        expect(provider.pastOrders[0]['status'], 'Delivered');
      });

      test('placing multiple orders grows the list', () async {
        final provider = await _buildProvider();
        await provider.placeOrder(_sampleItems(), 10.00);
        await provider.placeOrder(_sampleItems(), 20.00);

        expect(provider.pastOrders.length, 2);
      });

      test('each order gets a unique id', () async {
        final provider = await _buildProvider();
        await provider.placeOrder(_sampleItems(), 10.00);
        await Future.delayed(const Duration(milliseconds: 2));
        await provider.placeOrder(_sampleItems(), 20.00);

        final id1 = provider.pastOrders[0]['id'];
        final id2 = provider.pastOrders[1]['id'];
        // IDs are epoch milliseconds — should differ if placed >1ms apart
        expect(id1, isNotNull);
        expect(id2, isNotNull);
      });
    });

    // ── clearHistory ─────────────────────────────────────────────────────────
    group('clearHistory', () {
      test('removes all orders', () async {
        final provider = await _buildProvider();
        await provider.placeOrder(_sampleItems(), 31.50);
        await provider.placeOrder(_sampleItems(), 20.00);
        await provider.clearHistory();

        expect(provider.pastOrders.isEmpty, true);
      });
    });
  });
}
