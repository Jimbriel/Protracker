import 'package:flutter_test/flutter_test.dart';
import 'package:protracker/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProTrackerApp());
    expect(find.text('Siguiente'), findsOneWidget);
  });
}
