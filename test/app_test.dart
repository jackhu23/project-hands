import 'package:flutter_test/flutter_test.dart';

import 'test_app.dart';

void main() {
  testWidgets('app launches to the home screen', (tester) async {
    await pumpApp(tester);

    expect(find.text('Balloon Touch'), findsOneWidget);
  });
}
