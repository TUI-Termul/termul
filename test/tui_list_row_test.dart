import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termul/components/tui_list_row.dart';
import 'package:termul/theme/termul_palette.dart';
import 'package:termul/theme/termul_theme.dart';

void main() {
  Future<void> pumpHost(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TermulTheme.of(TermulPalette.mocha),
        home: Scaffold(body: child),
      ),
    );
  }

  testWidgets('fires onTap with title and subtitle', (tester) async {
    var taps = 0;
    await pumpHost(
      tester,
      TuiListRow(
        leadingGlyph: '·',
        title: 'prod-west',
        subtitle: 'deploy@10.0.0.12',
        onTap: () => taps++,
      ),
    );

    expect(find.text('prod-west'), findsOneWidget);
    expect(find.text('deploy@10.0.0.12'), findsOneWidget);
    await tester.tap(find.text('prod-west'));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('disabled ignores taps', (tester) async {
    var taps = 0;
    await pumpHost(
      tester,
      TuiListRow(
        title: 'archived',
        enabled: false,
        onTap: () => taps++,
      ),
    );

    await tester.tap(find.text('archived'));
    await tester.pump();
    expect(taps, 0);
  });
}
