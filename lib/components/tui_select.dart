import 'package:flutter/material.dart';

import 'tui_button.dart';

/// Single-choice chip row — same interaction model as theme pickers in settings.
class TuiSelect<T> extends StatelessWidget {
  const TuiSelect({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final List<(T, String)> options;
  final T value;
  final ValueChanged<T>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final active = enabled && onChanged != null;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (v, label) in options)
          TuiButton(
            label: label,
            variant: value == v
                ? TuiButtonVariant.primary
                : TuiButtonVariant.ghost,
            onPressed: active ? () => onChanged!(v) : null,
          ),
      ],
    );
  }
}
