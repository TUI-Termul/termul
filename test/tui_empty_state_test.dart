import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termul/components/tui_button.dart';
import 'package:termul/components/tui_empty_state.dart';
import 'package:termul/theme/termul_palette.dart';
import 'package:termul/theme/termul_theme.dart';

void main() {
  Future<void> pumpHost(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TermulTheme.of(TermulPalette.paper),
        home: Scaffold(body: child),
      ),
    );
  }

  testWidgets('centered empty shows glyph title body and action', (tester) async {
    var tapped = false;
    await pumpHost(
      tester,
      TuiEmptyState(
        glyph: '⌀',
        title: 'No transfers yet',
        body: 'Nothing in flight.',
        action: TuiButton(
          label: 'retry',
          onPressed: () => tapped = true,
        ),
      ),
    );

    expect(find.text('⌀'), findsOneWidget);
    expect(find.text('No transfers yet'), findsOneWidget);
    expect(find.text('Nothing in flight.'), findsOneWidget);
    await tester.tap(find.text('RETRY'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('page empty draws callout panel', (tester) async {
    await pumpHost(
      tester,
      const SizedBox(
        height: 480,
        child: TuiEmptyState(
          layout: TuiEmptyLayout.page,
          title: 'No SSH\nyet',
          body: 'Add a host.',
          calloutLabel: 'FIRST CONNECTION',
          calloutBody: 'Fill in address and credentials.',
        ),
      ),
    );

    expect(find.text('No SSH\nyet'), findsOneWidget);
    expect(find.text('FIRST CONNECTION'), findsOneWidget);
    expect(find.text('Fill in address and credentials.'), findsOneWidget);
  });
}
