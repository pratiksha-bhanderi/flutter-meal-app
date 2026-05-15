import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_app/core/utils/responsive_util.dart';

class AppColors {
  // Brand Oranges
  static const Color primaryOrange = Color(0xFFE64A19);
  static const Color primaryOrangeDark = Color(0xFFFF6B35);
  static const Color secondaryOrange = Color(0xFFFF8F00);
  static const Color deepOrangeGradient = Color(0xFFBF360C);

  // Dark Theme UI Colors
  static const Color darkBackground = Color(0xFF161618);
  static const Color darkSurface = Color(0xFF252525);
  static const Color darkGrey = Color(0xFF38383B);
  static const Color darkOutline = Color(0xFF333333);
  static const Color almostBlack = Color(0xFF1C1C1C);

  // Light Theme UI Colors
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF1A1A1A);
  static const Color lightOutline = Color(0xFFE8E8E8);

  // Accent Colors
  static const Color blueAccent = Color(0xFF42A5F5);
}

class AppTextStyles {
  /// Global text style factory mapped to responsive text size via `context.sp()`.
  /// Uses GoogleFonts.poppins centrally so it can be changed globally if needed.
  static TextStyle font(
    BuildContext context, {
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.poppins(
      fontSize: context.sp(fontSize),
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }
}
