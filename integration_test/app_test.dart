import 'package:better_todo/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('application launches on the home page', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.text('Better Todo'), findsOneWidget);
    expect(find.text('TEST'), findsOneWidget);
  });
}
