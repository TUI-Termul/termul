import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termul/components/tui_pagination.dart';
import 'package:termul/theme/termul_palette.dart';
import 'package:termul/theme/termul_theme.dart';

void main() {
  testWidgets('next page advances', (tester) async {
    var page = 1;
    await tester.pumpWidget(
      MaterialApp(
        theme: TermulTheme.of(TermulPalette.paper),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return TuiPagination(
                page: page,
                pageCount: 5,
                totalItems: 100,
                pageSize: 20,
                onPageChanged: (p) => setState(() => page = p),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('1–20 of 100'), findsOneWidget);
    await tester.tap(find.text('›'));
    await tester.pump();
    expect(page, 2);
    expect(find.text('21–40 of 100'), findsOneWidget);
  });
}
