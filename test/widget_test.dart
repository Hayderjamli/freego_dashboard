// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app_dashboard/main.dart';

void main() {
  testWidgets('Overview navigates to detailed dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DashboardApp());

    expect(find.text("Vue d'ensemble"), findsOneWidget);
    expect(find.text('Température actuelle'), findsOneWidget);
    expect(find.text('Voir le tableau de bord détaillé'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Voir le tableau de bord détaillé'),
      200,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Voir le tableau de bord détaillé'));
    await tester.pumpAndSettle();

    expect(find.text('Tableau de bord'), findsOneWidget);
    expect(find.text('Température'), findsOneWidget);
    expect(find.text('Humidité'), findsOneWidget);
  });
}
