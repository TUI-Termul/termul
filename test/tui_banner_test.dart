import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termul/components/tui_banner.dart';
import 'package:termul/components/tui_button.dart';
import 'package:termul/theme/termul_palette.dart';
import 'package:termul/theme/termul_theme.dart';

void main() {
  testWidgets('renders message and action', (tester) async {
    var restored = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: TermulTheme.of(TermulPalette.paper),
        home: Scaffold(
          body: TuiBanner(
            message: 'Unsaved edits from last time.',
            tone: TuiBannerTone.warning,
            actions: [
              TuiButton(
                label: 'Restore',
                onPressed: () => restored = true,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Unsaved edits from last time.'), findsOneWidget);
    await tester.tap(find.text('RESTORE'));
    await tester.pump();
    expect(restored, isTrue);
  });
}
