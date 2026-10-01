import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termul/components/tui_radio.dart';
import 'package:termul/theme/termul_palette.dart';
import 'package:termul/theme/termul_theme.dart';

void main() {
  testWidgets('radio group selects one', (tester) async {
    var value = 'a';
    await tester.pumpWidget(
      MaterialApp(
        theme: TermulTheme.of(TermulPalette.paper),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return TuiRadioGroup<String>(
                label: 'Mode',
                value: value,
                onChanged: (v) => setState(() => value = v),
                options: const [
                  ('a', 'Alpha'),
                  ('b', 'Beta'),
                ],
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Beta'));
    await tester.pump();
    expect(value, 'b');
  });
}
