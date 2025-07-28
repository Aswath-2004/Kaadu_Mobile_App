// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kaadu_organics_app/main.dart'; // Import your main application file

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Changed MyApp() to KaaduOrganicsApp() to match your main application widget
    await tester.pumpWidget(const KaaduOrganicsApp());

    // Verify that our counter starts at 0.
    // Note: The default Flutter counter app test expects a counter.
    // If your app doesn't have a counter, these assertions might fail.
    // You'll need to update these tests to reflect your app's actual UI.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    // This assumes there's a FloatingActionButton with an add icon.
    // If your app doesn't have this, this line will cause an error.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
