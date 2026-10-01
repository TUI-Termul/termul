import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termul/components/tui_command_palette.dart';
import 'package:termul/theme/termul_palette.dart';
import 'package:termul/theme/termul_theme.dart';

void main() {
  test('filters commands by tokens', () {
    const cmds = [
      TuiCommand(id: 'a', label: 'Connect host', subtitle: 'SSH'),
      TuiCommand(id: 'b', label: 'Open files'),
    ];
    expect(tuiFilterCommands(cmds, 'conn').map((c) => c.id), ['a']);
    expect(tuiFilterCommands(cmds, 'open file').map((c) => c.id), ['b']);
    expect(tuiFilterCommands(cmds, ''), hasLength(2));
  });

  testWidgets('palette returns selected id', (tester) async {
    late BuildContext host;
    await tester.pumpWidget(
      MaterialApp(
        theme: TermulTheme.of(TermulPalette.paper),
        home: Builder(
          builder: (context) {
            host = context;
            return const Scaffold(body: SizedBox.expand());
          },
        ),
      ),
    );

    final result = showTuiCommandPalette(
      host,
      commands: const [
        TuiCommand(id: 'files', label: 'Open files', glyph: '/'),
        TuiCommand(id: 'settings', label: 'Settings', glyph: '⚙'),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(await result, 'settings');
  });
}
