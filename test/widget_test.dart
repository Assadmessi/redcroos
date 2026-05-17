import 'package:flutter_test/flutter_test.dart';
import 'package:redcross_branch/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const RedCrossApp());
    expect(find.text('Red Cross Branch'), findsOneWidget);
  });
}