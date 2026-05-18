import 'package:flutter/widgets.dart';

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isDesktop => screenWidth > 800;

  // Base design dimensions (standard iPhone size used as reference)
  static const double _designWidth = 390.0;
  static const double _designHeight = 844.0;

  // On desktop, cap the scale factor so everything doesn't become huge.
  double get scaleFactor => isDesktop ? 1.25 : (screenWidth / _designWidth);

  /// Scales the given value based on the screen's width.
  double w(num value) => value * scaleFactor;
  
  /// Scales the given value based on the screen's height.
  /// Uses uniform scaling (scaleFactor) to prevent extreme squishing 
  /// when browser window aspect ratios change dynamically.
  double h(num value) => value * scaleFactor;

  /// Scales the given font size based on the screen's width.
  double sp(num value) => value * scaleFactor;
}
