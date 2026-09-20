import 'package:flutter/material.dart';

import '../theme/termul_theme.dart';
import 'tui_text.dart';

enum TuiButtonVariant { primary, ghost, danger }

class TuiButton extends StatefulWidget {
  const TuiButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = TuiButtonVariant.primary,
    this.prefix,
  });

  final String label;
  final VoidCallback? onPressed;
  final TuiButtonVariant variant;
  final String? prefix;

  @override
  State<TuiButton> createState() => _TuiButtonState();
}

class _TuiButtonState extends State<TuiButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    final enabled = widget.onPressed != null;

    final Color fg;
    final Color bg;
    final Color border;

    switch (widget.variant) {
      case TuiButtonVariant.primary:
        fg = p.bg;
        bg = enabled
            ? (_pressed
                ? p.accent.withValues(alpha: 0.85)
                : (_hover ? p.accent.withValues(alpha: 0.92) : p.accent))
            : p.dim;
        border = bg;
      case TuiButtonVariant.ghost:
        fg = enabled ? p.text : p.dim;
        bg = _hover && enabled ? p.selection : Colors.transparent;
        border = p.border;
      case TuiButtonVariant.danger:
        fg = p.bg;
        bg = enabled ? p.red : p.dim;
        border = bg;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.prefix != null) ...[
                Text(
                  widget.prefix!,
                  style: TextStyle(color: fg, fontSize: 12, height: 1.2),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: fg,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TuiKeyHint extends StatelessWidget {
  const TuiKeyHint({super.key, required this.keys, required this.label});

  final String keys;
  final String label;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(color: p.border),
            color: p.surface,
          ),
          child: TuiText(keys, tone: TuiTextTone.accent, size: 11, bold: true),
        ),
        const SizedBox(width: 6),
        TuiText(label, tone: TuiTextTone.dim, size: 11),
      ],
    );
  }
}
