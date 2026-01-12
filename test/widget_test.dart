import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/main.dart';

void main() {
  testWidgets('App should start', (WidgetTester tester) async {
    await tester.pumpWidget(const PomodoroApp());
    expect(find.text('포모도로'), findsOneWidget);
  });
}
