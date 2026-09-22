import 'package:flutter/material.dart';

import 'termul_palette.dart';

/// Bundled font families — Refero OCI substitutes.
///
/// - Display: Space Grotesk ≈ PP Neue Montreal
/// - Mono: JetBrains Mono ≈ GT America Mono
abstract final class TermulFonts {
  static const display = 'SpaceGrotesk';
  static const mono = 'JetBrainsMono';
}

class TermulTheme {
  TermulTheme._();

  static ThemeData of(TermulPalette palette) {
    final brightness =
        palette.isLight ? Brightness.light : Brightness.dark;

    TextStyle mono({
      double size = 13,
      FontWeight weight = FontWeight.w400,
      double height = 1.45,
      double tracking = 0.2,
      Color? color,
    }) =>
        TextStyle(
          fontFamily: TermulFonts.mono,
          fontSize: size,
          fontWeight: weight,
          height: height,
          letterSpacing: tracking,
          color: color ?? palette.text,
        );

    TextStyle display({
      double size = 16,
      FontWeight weight = FontWeight.w400,
      double height = 1.5,
      double tracking = 0,
      Color? color,
    }) =>
        TextStyle(
          fontFamily: TermulFonts.display,
          fontSize: size,
          fontWeight: weight,
          height: height,
          letterSpacing: tracking,
          color: color ?? palette.text,
        );

    final textTheme = TextTheme(
      displayLarge: display(size: 160, height: 0.94, tracking: -0.8),
      displayMedium: display(size: 46, height: 0.94, tracking: -0.8),
      displaySmall: display(size: 36, height: 1.1),
      headlineMedium: display(size: 24, height: 1.3, weight: FontWeight.w500),
      titleMedium: display(size: 18, height: 1.5),
      bodyLarge: mono(size: 14, tracking: 0.3),
      bodyMedium: mono(size: 13),
      bodySmall: mono(size: 11, tracking: 0.4),
      labelSmall: mono(size: 10, tracking: -0.3, height: 1.3),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: palette.bg,
      fontFamily: TermulFonts.mono,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: palette.accent,
        onPrimary: palette.isLight ? palette.panel : palette.bg,
        secondary: palette.deep,
        onSecondary: palette.panel,
        error: palette.red,
        onError: palette.panel,
        surface: palette.panel,
        onSurface: palette.text,
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      dividerColor: palette.border,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: palette.selection,
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(palette.dim),
        thickness: WidgetStateProperty.all(6),
        radius: Radius.zero,
      ),
      extensions: [TermulThemeData(palette: palette)],
    );
  }

  static ThemeData dark([TermulPalette palette = TermulPalette.mocha]) =>
      of(palette);
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
