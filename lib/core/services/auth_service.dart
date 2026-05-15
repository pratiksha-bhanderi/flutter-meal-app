import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userEmailKey = 'user_email';
  static const String _onboardingKey = 'has_seen_onboarding';

  /// Save the auth token to persistent storage
  static Future<void> saveToken(String token) async {
    _isLoggedInCache = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Retrieve the stored auth token (null if not logged in)
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static bool? _isLoggedInCache;

  /// Check if a user is currently logged in
  static Future<bool> isLoggedIn() async {
    if (_isLoggedInCache != null) return _isLoggedInCache!;
    final token = await getToken();
    _isLoggedInCache = token != null && token.isNotEmpty;
    return _isLoggedInCache!;
  }

  static bool isLoggedInSync() => _isLoggedInCache ?? false;

  /// Save user email
  static Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
  }

  /// Get saved user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  /// Clear all auth data (logout)
  static Future<void> logout() async {
    _isLoggedInCache = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userEmailKey);
  }

  /// Check if user has seen the onboarding flow
  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  /// Mark onboarding as completed
  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  /// Reset onboarding for testing
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingKey);
  }
}
