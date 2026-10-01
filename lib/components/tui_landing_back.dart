import 'package:flutter/material.dart';

import '../theme/termul_theme.dart';
import '../util/open_landing.dart';

/// Leading ← next to the Termul mark — returns to the public landing page.
class TuiLandingBack extends StatelessWidget {
  const TuiLandingBack({super.key});

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return Semantics(
      button: true,
      label: 'Back to landing page',
      child: GestureDetector(
        onTap: openLandingPage,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 2, 12, 2),
          child: Text(
            '←',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: p.deep,
                  height: 1,
                ),
          ),
        ),
      ),
    );
  }
}
