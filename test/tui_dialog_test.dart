import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termul/components/tui_dialog.dart';
import 'package:termul/theme/termul_palette.dart';
import 'package:termul/theme/termul_theme.dart';

void main() {
  late BuildContext hostContext;

  Future<void> pumpHost(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TermulTheme.of(TermulPalette.paper),
        home: Builder(
          builder: (context) {
            hostContext = context;
            return const Scaffold(body: SizedBox.expand());
          },
        ),
      ),
    );
  }

  testWidgets('confirm dialog returns true', (tester) async {
    await pumpHost(tester);

    final result = showTuiConfirmDialog(
      hostContext,
      title: 'discard',
      message: 'Leave without saving?',
      confirmLabel: 'discard',
    );
    await tester.pumpAndSettle();

    expect(find.text('DISCARD'), findsWidgets);
    await tester.tap(find.text('DISCARD').last);
    await tester.pumpAndSettle();
    expect(await result, isTrue);
  });

  testWidgets('prompt dialog returns typed text', (tester) async {
    await pumpHost(tester);

    final result = showTuiPromptDialog(
      hostContext,
      title: 'rename',
      fieldLabel: 'Name',
      confirmLabel: 'save',
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'notes.md');
    await tester.pump();
    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();
    expect(await result, 'notes.md');
  });

  testWidgets('prompt dialog rejects empty by default', (tester) async {
    await pumpHost(tester);

    showTuiPromptDialog(
      hostContext,
      title: 'rename',
      fieldLabel: 'Name',
      confirmLabel: 'save',
    );
    await tester.pumpAndSettle();

    // Confirm disabled while empty — tap does nothing.
    await tester.tap(find.text('SAVE'));
    await tester.pump();
    expect(find.text('RENAME'), findsOneWidget);

    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();
  });

  testWidgets('choice dialog returns selected value', (tester) async {
    await pumpHost(tester);

    final result = showTuiChoiceDialog<String>(
      hostContext,
      title: 'tmux',
      options: const [
        (value: 'main', label: 'main', meta: '2 windows'),
        (value: 'dev', label: 'dev', meta: '1 window'),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('dev'));
    await tester.pumpAndSettle();
    expect(await result, 'dev');
  });
}
