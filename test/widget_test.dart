// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:loopapp/app/app_scope.dart';
import 'package:loopapp/app/app.dart';

void main() {
  testWidgets('shows splash screen before opening login', (
    WidgetTester tester,
  ) async {
    final app = await AppScope.create(child: const LoopinApp());
    await tester.pumpWidget(app);

    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('LOOPIN'), findsOneWidget);
    expect(find.text('Make progress a habit.'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pump(const Duration(milliseconds: 650));
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
