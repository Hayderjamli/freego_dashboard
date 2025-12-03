// This is a basic Flutter widget test for the FreeGo Dashboard.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_0/main.dart';

void main() {
  testWidgets('Dashboard displays FreeGo branding', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that FreeGo title is displayed
    expect(find.text('FreeGo'), findsOneWidget);
    
    // Verify dashboard components are present
    expect(find.text('Smart Farm Dashboard'), findsOneWidget);
    expect(find.text('Temperature'), findsOneWidget);
    expect(find.text('Humidity'), findsOneWidget);
  });

  testWidgets('Dashboard shows door status card', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify door status card is present
    expect(find.text('Greenhouse Door'), findsOneWidget);
    expect(find.text('LIVE'), findsOneWidget);
    expect(find.text('Door Status'), findsOneWidget);
  });

  testWidgets('Dashboard shows charts', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify charts are present
    expect(find.text('Soil Temperature'), findsOneWidget);
    expect(find.text('Soil Moisture'), findsOneWidget);
    expect(find.text('Last 7 hours'), findsNWidgets(2));
  });
}
