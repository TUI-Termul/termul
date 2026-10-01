import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termul/components/tui_host_card.dart';
import 'package:termul/theme/termul_palette.dart';
import 'package:termul/theme/termul_theme.dart';

void main() {
  testWidgets('fires onTap and shows status', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: TermulTheme.of(TermulPalette.paper),
        home: Scaffold(
          body: TuiHostCard(
            title: 'prod-west',
            endpoint: 'deploy@10.0.0.12',
            status: 'active session',
            live: true,
            onTap: () => taps++,
          ),
        ),
      ),
    );

    expect(find.text('prod-west'), findsOneWidget);
    expect(find.text('ACTIVE SESSION'), findsOneWidget);
    expect(find.text('CONNECT'), findsOneWidget);
    await tester.tap(find.text('prod-west'));
    await tester.pump();
    expect(taps, 1);
  });
}
