import 'package:flutter/material.dart';

import '../theme/termul_theme.dart';
import 'tui_tooltip.dart';

/// Compact mono search / filter field — explorer chrome, app-bar find, menus.
///
/// Prefer this over a bare [TextField] when the chrome should match Termul.
class TuiSearchField extends StatelessWidget {
  const TuiSearchField({
    super.key,
    required this.controller,
    this.focusNode,
    this.hint = 'Filter…',
    this.prefixGlyph = '/',
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.showClear = true,
    this.enabled = true,
    this.dense = false,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hint;

  /// Leading mono mark (`/`, `⌕`, `❯`, …).
  final String prefixGlyph;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Called when the clear control is tapped (after the controller is cleared).
  final VoidCallback? onClear;

  /// Show × when the field has text.
  final bool showClear;
  final bool enabled;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    final mono = TextStyle(
      fontFamily: TermulFonts.mono,
      fontSize: dense ? 12 : 13,
      color: enabled ? p.text : p.dim,
      height: 1.3,
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final hasText = controller.text.isNotEmpty;
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: dense ? 8 : 10,
            vertical: dense ? 2 : 4,
          ),
          decoration: BoxDecoration(
            color: p.panel,
            border: Border.all(color: p.border),
          ),
          child: Row(
            children: [
              Text(
                prefixGlyph,
                style: mono.copyWith(color: p.dim, fontSize: dense ? 12 : 14),
              ),
              SizedBox(width: dense ? 6 : 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: autofocus,
                  enabled: enabled,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.search,
                  cursorColor: p.accent,
                  style: mono,
                  inputFormatters: const [],
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: mono.copyWith(color: p.dim),
                  ),
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                ),
              ),
              if (showClear && hasText && enabled)
                TuiIconButton(
                  icon: '×',
                  tooltip: 'Clear',
                  size: dense ? 28 : 32,
                  iconSize: 14,
                  onPressed: () {
                    controller.clear();
                    onChanged?.call('');
                    onClear?.call();
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
