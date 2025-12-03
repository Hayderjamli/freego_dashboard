// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app_dashboard/main.dart';

void main() {
  testWidgets('Welcome page displays correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DashboardApp());
    await tester.pumpAndSettle();

    // Verify welcome page elements
    expect(find.text('FreeGo'), findsOneWidget);
    expect(find.text('Smart Solar Freezer Dashboard'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
  });
}
