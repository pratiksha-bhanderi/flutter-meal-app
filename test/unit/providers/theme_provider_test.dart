import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meal_app/core/providers/theme_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeProvider', () {
    Future<ThemeProvider> _buildProvider() async {
      final provider = ThemeProvider();
      // Allow _loadTheme() async call to complete
      await Future.delayed(const Duration(milliseconds: 50));
      return provider;
    }

    // ── Default state ────────────────────────────────────────────────────────
    test('defaults to dark theme when no preference saved', () async {
      final provider = await _buildProvider();

      expect(provider.themeMode, ThemeMode.dark);
    });

    // ── setDark ──────────────────────────────────────────────────────────────
    group('setDark', () {
      test('setDark(false) switches to light theme', () async {
        final provider = await _buildProvider();
        await provider.setDark(false);

        expect(provider.themeMode, ThemeMode.light);
      });

      test('setDark(true) switches to dark theme', () async {
        final provider = await _buildProvider();
        await provider.setDark(false); // go light first
        await provider.setDark(true);  // back to dark

        expect(provider.themeMode, ThemeMode.dark);
      });
    });

    // ── Persistence ──────────────────────────────────────────────────────────
    test('persists light theme preference across provider instances', () async {
      // First instance: switch to light and save
      final provider1 = await _buildProvider();
      await provider1.setDark(false);

      // Second instance: should load the saved light preference
      final provider2 = await _buildProvider();
      expect(provider2.themeMode, ThemeMode.light);
    });

    test('persists dark theme preference across provider instances', () async {
      // First instance: explicitly set dark
      final provider1 = await _buildProvider();
      await provider1.setDark(true);

      // Second instance: should load the saved dark preference
      final provider2 = await _buildProvider();
      expect(provider2.themeMode, ThemeMode.dark);
    });

    // ── isDark ───────────────────────────────────────────────────────────────
    group('isDark (with a fake BuildContext)', () {
      testWidgets('isDark returns true when themeMode is dark', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final provider = ThemeProvider();
                expect(provider.isDark(context), true);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      });
    });
  });
}
