import 'package:flutter/widgets.dart';

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  // Base design dimensions (standard iPhone size used as reference)
  static const double _designWidth = 390.0;
  static const double _designHeight = 844.0;

  /// Scales the given value based on the screen's width.
  /// Use this for width, horizontal padding/margin, etc.
  double w(num value) => (value / _designWidth) * screenWidth;
  
  /// Scales the given value based on the screen's height.
  /// Use this for height, vertical padding/margin, etc.
  double h(num value) => (value / _designHeight) * screenHeight;

  /// Scales the given font size based on the screen's width.
  /// This maintains text proportions across different screen widths.
  double sp(num value) => value * (screenWidth / _designWidth);
}
