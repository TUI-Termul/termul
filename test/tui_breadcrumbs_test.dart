import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termul/components/tui_breadcrumbs.dart';
import 'package:termul/theme/termul_palette.dart';
import 'package:termul/theme/termul_theme.dart';

void main() {
  test('fromPath splits absolute paths', () {
    final crumbs = TuiBreadcrumbs.fromPath('/home/deploy/app');
    expect(crumbs.map((c) => c.label).toList(), ['/', 'home', 'deploy', 'app']);
    expect(crumbs.last.id, '/home/deploy/app');
  });

  testWidgets('taps intermediate crumb', (tester) async {
    String? tapped;
    await tester.pumpWidget(
      MaterialApp(
        theme: TermulTheme.of(TermulPalette.paper),
        home: Scaffold(
          body: TuiBreadcrumbs(
            crumbs: TuiBreadcrumbs.fromPath('/a/b/c'),
            onTap: (c) => tapped = c.id,
          ),
        ),
      ),
    );

    await tester.tap(find.text('b'));
    await tester.pump();
    expect(tapped, '/a/b');
  });
}
