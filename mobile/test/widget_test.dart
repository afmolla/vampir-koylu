import 'package:flutter_test/flutter_test.dart';
import 'package:vampir_koylu/app.dart';

void main() {
  testWidgets('App smoke test', (tester) async {
    await tester.pumpWidget(const VampirKoyluApp());
    expect(find.text('Vampir Köylü'), findsOneWidget);
  });
}
