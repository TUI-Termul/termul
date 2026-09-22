import 'package:flutter_test/flutter_test.dart';
import 'package:termul/main.dart';

void main() {
  testWidgets('onboarding loads', (tester) async {
    await tester.pumpWidget(const TermulApp());
    expect(find.text('TERMUL'), findsOneWidget);
    expect(find.textContaining('Agents that'), findsOneWidget);
    expect(find.text('CONTINUE'), findsOneWidget);
  });
}
