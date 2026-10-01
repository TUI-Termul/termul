import 'package:flutter/material.dart';

import '../theme/termul_theme.dart';

/// One tappable row in a settings / log / host list — sharp Termul chrome.
///
/// Prefer a mono [leadingGlyph] or a small widget ([leading]) over Material
/// icons. Trailing actions (bookmark, switch, …) go in [trailing].
class TuiListRow extends StatelessWidget {
  const TuiListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleChild,
    this.leading,
    this.leadingGlyph,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.enabled = true,
    this.dense = false,
    this.showDivider = false,
  });

  final String title;
  final String? subtitle;

  /// Optional rich subtitle (e.g. [SelectableText]). Wins over [subtitle].
  final Widget? subtitleChild;

  /// Optional leading widget (badge, avatar, …). Wins over [leadingGlyph].
  final Widget? leading;

  /// Single mono character when no [leading] widget is supplied (`·`, `▸`, …).
  final String? leadingGlyph;

  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final bool enabled;
  final bool dense;

  /// Draw a hairline rule under the row (list separators without
  /// [ListView.separated]).
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    final fg = enabled ? p.text : p.dim;
    final meta = enabled ? p.muted : p.dim;
    final vPad = dense ? 10.0 : 14.0;

    Widget? lead = leading;
    if (lead == null && leadingGlyph != null && leadingGlyph!.isNotEmpty) {
      lead = SizedBox(
        width: 28,
        child: Text(
          leadingGlyph!,
          style: TextStyle(
            fontFamily: TermulFonts.mono,
            fontSize: 16,
            color: selected ? p.accent : meta,
            height: 1,
          ),
        ),
      );
    }

    final row = Material(
      color: selected ? p.selection : Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        onLongPress: enabled ? onLongPress : null,
        hoverColor: p.selection,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, vPad, 12, vPad),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (lead != null) ...[
                lead,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: TermulFonts.mono,
                        fontSize: dense ? 12.5 : 13,
                        fontWeight: FontWeight.w500,
                        color: fg,
                        height: 1.3,
                      ),
                    ),
                    if (subtitleChild != null) ...[
                      const SizedBox(height: 2),
                      DefaultTextStyle(
                        style: TextStyle(
                          fontFamily: TermulFonts.mono,
                          fontSize: 11,
                          color: meta,
                          height: 1.35,
                        ),
                        child: subtitleChild!,
                      ),
                    ] else if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: TermulFonts.mono,
                          fontSize: 11,
                          color: meta,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );

    if (!showDivider) return row;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row,
        Divider(height: 1, thickness: 1, color: p.border),
      ],
    );
  }
}
