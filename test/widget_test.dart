import 'package:flutter_test/flutter_test.dart';
import 'package:warga_jatiasih/main.dart';

void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WargakuApp());
    expect(find.text('Wargaku'), findsOneWidget);
  });
}
