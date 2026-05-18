import 'package:flutter_test/flutter_test.dart';
import 'package:meal_app/core/providers/favourites_provider.dart';

void main() {
  group('FavouritesProvider', () {
    // ── Helpers ──────────────────────────────────────────────────────────────
    Map<String, dynamic> meal(String name) => {
      'name': name,
      'price': '\$10.00',
      'category': 'Pizza',
      'image': 'assets/pizza.png',
    };

    // ── toggleFavourite ──────────────────────────────────────────────────────
    group('toggleFavourite', () {
      test('adds a meal when not already a favourite', () {
        final provider = FavouritesProvider();
        provider.toggleFavourite(meal('Margherita'));

        expect(provider.favouriteMeals.length, 1);
        expect(provider.favouriteMeals[0]['name'], 'Margherita');
      });

      test('removes a meal when it is already a favourite (toggle off)', () {
        final provider = FavouritesProvider();
        provider.toggleFavourite(meal('Margherita'));
        provider.toggleFavourite(meal('Margherita')); // toggle off

        expect(provider.favouriteMeals.isEmpty, true);
      });

      test('handles multiple different meals correctly', () {
        final provider = FavouritesProvider();
        provider.toggleFavourite(meal('Pizza'));
        provider.toggleFavourite(meal('Burger'));

        expect(provider.favouriteMeals.length, 2);
      });

      test('removing one meal does not affect others', () {
        final provider = FavouritesProvider();
        provider.toggleFavourite(meal('Pizza'));
        provider.toggleFavourite(meal('Burger'));
        provider.toggleFavourite(meal('Pizza')); // remove Pizza

        expect(provider.favouriteMeals.length, 1);
        expect(provider.favouriteMeals[0]['name'], 'Burger');
      });
    });

    // ── isFavourite ──────────────────────────────────────────────────────────
    group('isFavourite', () {
      test('returns false for a meal not in favourites', () {
        final provider = FavouritesProvider();

        expect(provider.isFavourite('Unknown Meal'), false);
      });

      test('returns true for a meal that has been added', () {
        final provider = FavouritesProvider();
        provider.toggleFavourite(meal('Pepperoni'));

        expect(provider.isFavourite('Pepperoni'), true);
      });

      test('returns false after a meal is toggled back off', () {
        final provider = FavouritesProvider();
        provider.toggleFavourite(meal('Pepperoni'));
        provider.toggleFavourite(meal('Pepperoni')); // remove

        expect(provider.isFavourite('Pepperoni'), false);
      });
    });

    // ── favouriteCount ───────────────────────────────────────────────────────
    group('favouriteCount', () {
      test('starts at 0', () {
        final provider = FavouritesProvider();
        expect(provider.favouriteCount, 0);
      });

      test('increments when meals are added', () {
        final provider = FavouritesProvider();
        provider.toggleFavourite(meal('Pizza'));
        provider.toggleFavourite(meal('Burger'));

        expect(provider.favouriteCount, 2);
      });

      test('decrements when a meal is toggled off', () {
        final provider = FavouritesProvider();
        provider.toggleFavourite(meal('Pizza'));
        provider.toggleFavourite(meal('Pizza')); // remove

        expect(provider.favouriteCount, 0);
      });
    });

    // ── favouriteMeals (returns copy) ────────────────────────────────────────
    group('favouriteMeals getter', () {
      test('returns a copy — mutating it does not affect provider', () {
        final provider = FavouritesProvider();
        provider.toggleFavourite(meal('Pizza'));

        final copy = provider.favouriteMeals;
        copy.clear();

        // Internal state is unaffected
        expect(provider.favouriteCount, 1);
      });
    });
  });
}
