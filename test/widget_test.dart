import 'package:flutter_test/flutter_test.dart';
import 'package:personal_support_crm/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SupportCrmApp());
    expect(find.byType(SupportCrmApp), findsOneWidget);
  });
}
