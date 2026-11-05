import 'package:flutter_test/flutter_test.dart';
import 'package:hands/main.dart';

void main() {
  testWidgets('app launches to the home screen', (tester) async {
    await tester.pumpWidget(const HandsApp());

    expect(find.text('Project HANDS'), findsOneWidget);
  });
}
