import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sets the test canvas to iPhone 14 Pro logical size.
/// Call inside testWidgets before pumpWidget to prevent overflow errors.
void setPhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
