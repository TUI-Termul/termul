import 'package:flutter_test/flutter_test.dart';
import 'package:termul/main.dart';

void main() {
  testWidgets('gallery loads', (tester) async {
    await tester.pumpWidget(const TermulApp());
    expect(find.text('termul'), findsWidgets);
    expect(find.text('component gallery'), findsOneWidget);
  });
}
