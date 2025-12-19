// This is a basic Flutter widget test for AliExpress Clone app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aliexpress_clone/main.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AliExpressCloneApp());

    // Wait for async operations
    await tester.pumpAndSettle();

    // Verify that the app loads with navigation
    expect(find.byType(NavigationBar), findsOneWidget);

    // Verify bottom navigation labels exist
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Cart'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
  });
}
