import 'package:flutter/material.dart';

import '../theme/termul_theme.dart';

/// Uppercase section heading used in settings and gallery rails.
class TuiSectionLabel extends StatelessWidget {
  const TuiSectionLabel(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return Semantics(
      header: true,
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: p.accent,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
            ),
      ),
    );
  }
}

/// Hairline horizontal rule — chrome divider.
class TuiDivider extends StatelessWidget {
  const TuiDivider({super.key, this.height = 1, this.indent = 0});

  final double height;
  final double indent;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Container(height: height, color: p.border),
    );
  }
}
