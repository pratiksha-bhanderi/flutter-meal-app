import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_app/core/theme/app_styles.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightSurface,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryOrange,
          onPrimary: Colors.white,
          secondary: AppColors.secondaryOrange,
          surface: AppColors.lightSurface,
          onSurface: AppColors.lightText,
          outline: AppColors.lightOutline,
        ),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        dividerColor: AppColors.lightOutline,
        // Force dark (black) status bar icons on every AppBar in light mode
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark, // Android: dark icons
            statusBarBrightness: Brightness.light,    // iOS: dark icons
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkSurface,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryOrangeDark,
          onPrimary: Colors.white,
          secondary: Color(0xFFFF9A3C),
          surface: AppColors.darkSurface,
          onSurface: Colors.white,
          outline: AppColors.darkOutline,
        ),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        dividerColor: AppColors.darkOutline,
        // Force light (white) status bar icons on every AppBar in dark mode
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light, // Android: white icons
            statusBarBrightness: Brightness.dark,      // iOS: white icons
          ),
        ),
      );
}

