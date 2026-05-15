import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _key = 'is_dark_theme';

  ThemeMode _themeMode = ThemeMode.dark; // Set Dark as the default mode

  ThemeMode get themeMode => _themeMode;
  bool isDark(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_key);
    if (saved == null) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = saved ? ThemeMode.dark : ThemeMode.light;
    }
    notifyListeners();
  }

  Future<void> setDark(bool value) async {
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }

  void toggle(BuildContext context) => setDark(!isDark(context));
}
