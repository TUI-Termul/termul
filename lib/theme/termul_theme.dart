import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'termul_palette.dart';

class TermulTheme {
  TermulTheme._();

  static ThemeData dark([TermulPalette palette = TermulPalette.mocha]) {
    final base = GoogleFonts.jetBrainsMonoTextTheme(
      ThemeData.dark().textTheme,
    ).apply(
      bodyColor: palette.text,
      displayColor: palette.text,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: palette.bg,
      colorScheme: ColorScheme.dark(
        surface: palette.panel,
        primary: palette.accent,
        secondary: palette.blue,
        error: palette.red,
        onSurface: palette.text,
        onPrimary: palette.bg,
      ),
      textTheme: base,
      primaryTextTheme: base,
      dividerColor: palette.border,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: palette.selection.withValues(alpha: 0.35),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(palette.dim),
        thickness: WidgetStateProperty.all(6),
        radius: Radius.zero,
      ),
      extensions: [TermulThemeData(palette: palette)],
    );
  }
}

@immutable
class TermulThemeData extends ThemeExtension<TermulThemeData> {
  const TermulThemeData({required this.palette});

  final TermulPalette palette;

  static TermulThemeData of(BuildContext context) {
    return Theme.of(context).extension<TermulThemeData>()!;
  }

  @override
  TermulThemeData copyWith({TermulPalette? palette}) {
    return TermulThemeData(palette: palette ?? this.palette);
  }

  @override
  TermulThemeData lerp(ThemeExtension<TermulThemeData>? other, double t) {
    if (other is! TermulThemeData) return this;
    return t < 0.5 ? this : other;
  }
}
