import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termul/components/tui_search_field.dart';
import 'package:termul/theme/termul_palette.dart';
import 'package:termul/theme/termul_theme.dart';

void main() {
  testWidgets('clears text and notifies', (tester) async {
    final controller = TextEditingController(text: 'prod');
    var last = 'prod';
    await tester.pumpWidget(
      MaterialApp(
        theme: TermulTheme.of(TermulPalette.paper),
        home: Scaffold(
          body: TuiSearchField(
            controller: controller,
            onChanged: (v) => last = v,
          ),
        ),
      ),
    );

    expect(find.text('prod'), findsOneWidget);
    await tester.tap(find.text('×'));
    await tester.pump();
    expect(controller.text, isEmpty);
    expect(last, isEmpty);
  });
}
