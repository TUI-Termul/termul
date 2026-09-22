import 'package:flutter/material.dart';

import '../theme/termul_theme.dart';

enum TuiTextTone {
  normal,
  muted,
  dim,
  accent,
  green,
  yellow,
  red,
  blue,
  cyan,
  magenta,
}

class TuiText extends StatelessWidget {
  const TuiText(
    this.data, {
    super.key,
    this.tone = TuiTextTone.normal,
    this.size = 13,
    this.bold = false,
    this.maxLines,
    this.overflow,
  });

  final String data;
  final TuiTextTone tone;
  final double size;
  final bool bold;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    final color = switch (tone) {
      TuiTextTone.normal => p.text,
      TuiTextTone.muted => p.muted,
      TuiTextTone.dim => p.dim,
      TuiTextTone.accent => p.accent,
      TuiTextTone.green => p.green,
      TuiTextTone.yellow => p.yellow,
      TuiTextTone.red => p.red,
      TuiTextTone.blue => p.blue,
      TuiTextTone.cyan => p.cyan,
      TuiTextTone.magenta => p.magenta,
    };

    return Text(
      data,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontFamily: TermulFonts.mono,
        color: color,
        fontSize: size,
        fontWeight: bold ? FontWeight.w500 : FontWeight.w400,
        height: size <= 10 ? 1.3 : 1.45,
        letterSpacing: size <= 10 ? -0.3 : 0.2,
      ),
    );
  }
}
