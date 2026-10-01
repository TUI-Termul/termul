import 'package:flutter/material.dart';

import '../theme/termul_theme.dart';
import 'tui_text.dart';

/// Sharp circular radio — single choice in a form.
///
/// Prefer [TuiSegmented] / [TuiSelect] for horizontal chip rows, and
/// [TuiCheckbox] for multi-select.
class TuiRadio<T> extends StatelessWidget {
  const TuiRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.dense = false,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;
  final String? label;
  final bool dense;

  bool get _selected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    final enabled = onChanged != null;
    final size = dense ? 16.0 : 18.0;

    final Color ring;
    final Color fill;
    if (!enabled) {
      ring = p.border;
      fill = p.surface;
    } else if (_selected) {
      ring = p.accent;
      fill = p.accent;
    } else {
      ring = p.border;
      fill = p.panel;
    }

    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill,
        border: Border.all(color: ring, width: 1.5),
      ),
      child: _selected
          ? Center(
              child: Container(
                width: size * 0.4,
                height: size * 0.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: p.isLight ? p.panel : p.bg,
                ),
              ),
            )
          : null,
    );

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        if (label != null) ...[
          SizedBox(width: dense ? 8 : 10),
          Flexible(
            child: TuiText(
              label!,
              size: dense ? 12 : 13,
              tone: enabled ? TuiTextTone.normal : TuiTextTone.dim,
            ),
          ),
        ],
      ],
    );

    return Semantics(
      checked: _selected,
      inMutuallyExclusiveGroup: true,
      enabled: enabled,
      label: label,
      child: InkWell(
        onTap: enabled ? () => onChanged!(value) : null,
        hoverColor: p.selection,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: dense ? 4 : 6),
          child: row,
        ),
      ),
    );
  }
}

/// Vertical stack of [TuiRadio] options with an optional section label.
class TuiRadioGroup<T> extends StatelessWidget {
  const TuiRadioGroup({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.label,
    this.dense = false,
  });

  /// `(value, label)` pairs.
  final List<(T, String)> options;
  final T? value;
  final ValueChanged<T>? onChanged;
  final String? label;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          Text(
            label!.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: p.accent,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
          ),
          const SizedBox(height: 8),
        ],
        for (final (v, text) in options)
          TuiRadio<T>(
            value: v,
            groupValue: value,
            onChanged: onChanged,
            label: text,
            dense: dense,
          ),
      ],
    );
  }
}
