import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termul/components/tui_accordion.dart';
import 'package:termul/components/tui_text.dart';
import 'package:termul/theme/termul_palette.dart';
import 'package:termul/theme/termul_theme.dart';

void main() {
  testWidgets('expands and collapses', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TermulTheme.of(TermulPalette.paper),
        home: const Scaffold(
          body: TuiAccordion(
            title: 'tables',
            meta: '2',
            child: TuiText('users'),
          ),
        ),
      ),
    );

    expect(find.text('users'), findsNothing);
    await tester.tap(find.text('TABLES'));
    await tester.pumpAndSettle();
    expect(find.text('users'), findsOneWidget);
  });
}
