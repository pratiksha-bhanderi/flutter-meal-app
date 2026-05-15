import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meal_app/core/services/auth_service.dart';

void main() {
  // Reset SharedPreferences before every test for isolation
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthService', () {
    // ── Token management ─────────────────────────────────────────────────────
    group('token', () {
      test('getToken returns null when no token saved', () async {
        final token = await AuthService.getToken();
        expect(token, isNull);
      });

      test('saveToken then getToken returns the saved token', () async {
        await AuthService.saveToken('my_test_token_123');
        final token = await AuthService.getToken();
        expect(token, 'my_test_token_123');
      });

      test('saveToken overwrites the previous token', () async {
        await AuthService.saveToken('old_token');
        await AuthService.saveToken('new_token');
        final token = await AuthService.getToken();
        expect(token, 'new_token');
      });
    });

    // ── isLoggedIn ───────────────────────────────────────────────────────────
    group('isLoggedIn', () {
      test('returns false when no token exists', () async {
        final loggedIn = await AuthService.isLoggedIn();
        expect(loggedIn, false);
      });

      test('returns true after saving a valid token', () async {
        await AuthService.saveToken('valid_token');
        final loggedIn = await AuthService.isLoggedIn();
        expect(loggedIn, true);
      });

      test('returns false after logout clears the token', () async {
        await AuthService.saveToken('valid_token');
        await AuthService.logout();
        final loggedIn = await AuthService.isLoggedIn();
        expect(loggedIn, false);
      });
    });

    // ── logout ───────────────────────────────────────────────────────────────
    group('logout', () {
      test('clears token on logout', () async {
        await AuthService.saveToken('token');
        await AuthService.logout();
        expect(await AuthService.getToken(), isNull);
      });

      test('clears user email on logout', () async {
        await AuthService.saveUserEmail('test@example.com');
        await AuthService.logout();
        expect(await AuthService.getUserEmail(), isNull);
      });
    });

    // ── Email management ─────────────────────────────────────────────────────
    group('user email', () {
      test('getUserEmail returns null when nothing saved', () async {
        final email = await AuthService.getUserEmail();
        expect(email, isNull);
      });

      test('saveUserEmail then getUserEmail returns saved email', () async {
        await AuthService.saveUserEmail('user@mealmate.com');
        final email = await AuthService.getUserEmail();
        expect(email, 'user@mealmate.com');
      });
    });

    // ── Onboarding flag ──────────────────────────────────────────────────────
    group('onboarding', () {
      test('hasSeenOnboarding returns false initially', () async {
        final seen = await AuthService.hasSeenOnboarding();
        expect(seen, false);
      });

      test('hasSeenOnboarding returns true after setOnboardingSeen', () async {
        await AuthService.setOnboardingSeen();
        final seen = await AuthService.hasSeenOnboarding();
        expect(seen, true);
      });

      test('resetOnboarding reverts hasSeenOnboarding to false', () async {
        await AuthService.setOnboardingSeen();
        await AuthService.resetOnboarding();
        final seen = await AuthService.hasSeenOnboarding();
        expect(seen, false);
      });
    });
  });
}
