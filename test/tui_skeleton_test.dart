import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termul/components/tui_skeleton.dart';
import 'package:termul/theme/termul_palette.dart';
import 'package:termul/theme/termul_theme.dart';

void main() {
  testWidgets('skeleton list paints rows', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TermulTheme.of(TermulPalette.mocha),
        home: const Scaffold(body: TuiSkeletonList(count: 3)),
      ),
    );
    expect(find.byType(TuiSkeletonRow), findsNWidgets(3));
    await tester.pump(const Duration(milliseconds: 200));
  });
}
