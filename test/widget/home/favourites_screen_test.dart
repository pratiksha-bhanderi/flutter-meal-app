import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meal_app/core/providers/favourites_provider.dart';
import 'package:meal_app/core/providers/theme_provider.dart';
import 'package:meal_app/core/theme/app_theme.dart';
import 'package:meal_app/screens/home/favourites_screen.dart';
import '../../helpers/test_helpers.dart';

Widget _makeTestable({required FavouritesProvider favsProvider}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<FavouritesProvider>.value(value: favsProvider),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const FavouritesScreen(showBackButton: false),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  final testMeal = {
    'name': 'Margherita Pizza',
    'price': '\$14.50',
    'category': 'Pizza',
    'image': 'assets/images/meals/pizza.png',
  };
  final testMeal2 = {
    'name': 'Classic Burger',
    'price': '\$12.99',
    'category': 'Burgers',
    'image': 'assets/images/meals/burger.png',
  };

  group('FavouritesScreen Widget Tests', () {
    group('when favourites list is empty', () {
      testWidgets('shows "Save your faves" empty state text', (tester) async {
        setPhoneViewport(tester);
        final favs = FavouritesProvider();
        await tester.pumpWidget(_makeTestable(favsProvider: favs));
        await tester.pumpAndSettle();

        expect(find.text('Save your faves'), findsOneWidget);
      });

      testWidgets('shows subtitle hint text', (tester) async {
        setPhoneViewport(tester);
        final favs = FavouritesProvider();
        await tester.pumpWidget(_makeTestable(favsProvider: favs));
        await tester.pumpAndSettle();

        expect(find.textContaining('heart icon'), findsOneWidget);
      });
    });

    group('when favourites has meals', () {
      testWidgets('shows favourite meal name', (tester) async {
        setPhoneViewport(tester);
        final favs = FavouritesProvider();
        favs.toggleFavourite(testMeal);

        await tester.pumpWidget(_makeTestable(favsProvider: favs));
        await tester.pumpAndSettle();

        expect(find.text('Margherita Pizza'), findsOneWidget);
      });

      testWidgets('shows multiple favourites', (tester) async {
        setPhoneViewport(tester);
        final favs = FavouritesProvider();
        favs.toggleFavourite(testMeal);
        favs.toggleFavourite(testMeal2);

        await tester.pumpWidget(_makeTestable(favsProvider: favs));
        await tester.pumpAndSettle();

        expect(find.text('Margherita Pizza'), findsOneWidget);
        expect(find.text('Classic Burger'), findsOneWidget);
      });

      testWidgets('tapping heart icon removes meal from favourites', (tester) async {
        setPhoneViewport(tester);
        final favs = FavouritesProvider();
        favs.toggleFavourite(testMeal);

        await tester.pumpWidget(_makeTestable(favsProvider: favs));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.favorite_rounded).first);
        await tester.pumpAndSettle();

        expect(find.text('Save your faves'), findsOneWidget);
      });
    });

    testWidgets('shows "Favourites" as screen title', (tester) async {
      setPhoneViewport(tester);
      final favs = FavouritesProvider();
      await tester.pumpWidget(_makeTestable(favsProvider: favs));
      await tester.pumpAndSettle();

      expect(find.text('Favourites'), findsOneWidget);
    });
  });
}
