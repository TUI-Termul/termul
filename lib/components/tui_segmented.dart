import 'package:flutter/material.dart';

import '../theme/termul_theme.dart';

/// One segment in [TuiSegmented].
class TuiSegmentedOption<T> {
  const TuiSegmentedOption({
    required this.value,
    required this.label,
    this.enabled = true,
  });

  final T value;
  final String label;
  final bool enabled;
}

/// Contiguous exclusive control — sharp joined segments (not wrapped chips).
///
/// Prefer [TuiSelect] when options should wrap as separate buttons.
/// Prefer [TuiRadioGroup] for vertical labelled choices in a form.
class TuiSegmented<T> extends StatelessWidget {
  const TuiSegmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.expanded = false,
  });

  final List<TuiSegmentedOption<T>> options;
  final T value;
  final ValueChanged<T>? onChanged;
  final bool enabled;

  /// Stretch segments evenly across the parent width.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    final active = enabled && onChanged != null;

    Widget segment(TuiSegmentedOption<T> opt) {
      final selected = opt.value == value;
      final canTap = active && opt.enabled;
      final Color fg;
      final Color bg;
      if (!canTap && !selected) {
        fg = p.dim;
        bg = p.surface;
      } else if (selected) {
        fg = p.isLight ? p.panel : p.bg;
        bg = p.accent;
      } else {
        fg = p.text;
        bg = p.panel;
      }

      final child = Material(
        color: bg,
        child: InkWell(
          onTap: canTap ? () => onChanged!(opt.value) : null,
          hoverColor: selected ? null : p.selection,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              opt.label.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: TermulFonts.mono,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
                color: fg,
                height: 1.2,
              ),
            ),
          ),
        ),
      );

      return expanded ? Expanded(child: child) : child;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: p.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
          children: [
            for (var i = 0; i < options.length; i++) ...[
              if (i > 0)
                VerticalDivider(width: 1, thickness: 1, color: p.border),
              segment(options[i]),
            ],
          ],
        ),
      ),
    );
  }
}
