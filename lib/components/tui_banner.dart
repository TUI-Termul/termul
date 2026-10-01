import 'package:flutter/material.dart';

import '../theme/termul_theme.dart';

/// Tone for [TuiBanner] — glyph + wash, not a colour flood.
enum TuiBannerTone { info, success, warning, danger, neutral }

/// Inline status strip — draft restore, query errors, soft alerts.
///
/// Prefer [showTuiToast] for transient feedback and [showTuiErrorSheet] for
/// blocking failures. Use this when the message must stay above content.
class TuiBanner extends StatelessWidget {
  const TuiBanner({
    super.key,
    required this.message,
    this.tone = TuiBannerTone.info,
    this.glyph,
    this.actions = const [],
    this.onDismiss,
    this.dense = false,
  });

  final String message;
  final TuiBannerTone tone;

  /// Override the default mono mark for [tone].
  final String? glyph;

  /// Trailing controls — typically ghost / primary [TuiButton]s.
  final List<Widget> actions;

  /// Optional × control that calls this.
  final VoidCallback? onDismiss;
  final bool dense;

  String get _defaultGlyph => switch (tone) {
        TuiBannerTone.info => 'i',
        TuiBannerTone.success => '+',
        TuiBannerTone.warning => '!',
        TuiBannerTone.danger => 'x',
        TuiBannerTone.neutral => '·',
      };

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;

    final Color wash;
    final Color ink;
    switch (tone) {
      case TuiBannerTone.info:
        wash = p.selection;
        ink = p.text;
      case TuiBannerTone.success:
        wash = Color.alphaBlend(p.green.withValues(alpha: 0.15), p.panel);
        ink = p.green;
      case TuiBannerTone.warning:
        wash = Color.alphaBlend(p.yellow.withValues(alpha: 0.18), p.panel);
        ink = p.isLight ? p.deep : p.yellow;
      case TuiBannerTone.danger:
        wash = p.isLight
            ? p.deep
            : Color.alphaBlend(p.red.withValues(alpha: 0.2), p.panel);
        ink = p.isLight ? p.panel : p.red;
      case TuiBannerTone.neutral:
        wash = p.surface;
        ink = p.muted;
    }

    final mark = glyph ?? _defaultGlyph;
    final vPad = dense ? 6.0 : 8.0;

    return Container(
      width: double.infinity,
      color: wash,
      padding: EdgeInsets.fromLTRB(12, vPad, 8, vPad),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            mark,
            style: TextStyle(
              fontFamily: TermulFonts.mono,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ink,
              height: 1,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: TermulFonts.mono,
                fontSize: 12,
                color: ink,
                height: 1.4,
              ),
            ),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(width: 8),
            ...[
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                actions[i],
              ],
            ],
          ],
          if (onDismiss != null) ...[
            const SizedBox(width: 4),
            InkWell(
              onTap: onDismiss,
              hoverColor: p.selection,
              child: SizedBox(
                width: 28,
                height: 28,
                child: Center(
                  child: Text(
                    '×',
                    style: TextStyle(
                      fontFamily: TermulFonts.mono,
                      fontSize: 14,
                      color: ink,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
