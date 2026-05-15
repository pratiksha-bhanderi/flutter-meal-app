import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meal_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MealApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
