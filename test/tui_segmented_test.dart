import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termul/components/tui_segmented.dart';
import 'package:termul/theme/termul_palette.dart';
import 'package:termul/theme/termul_theme.dart';

void main() {
  testWidgets('selects a segment', (tester) async {
    var value = 'a';
    await tester.pumpWidget(
      MaterialApp(
        theme: TermulTheme.of(TermulPalette.mocha),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return TuiSegmented<String>(
                value: value,
                onChanged: (v) => setState(() => value = v),
                options: const [
                  TuiSegmentedOption(value: 'a', label: 'Alpha'),
                  TuiSegmentedOption(value: 'b', label: 'Beta'),
                ],
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('BETA'));
    await tester.pump();
    expect(value, 'b');
  });
}
