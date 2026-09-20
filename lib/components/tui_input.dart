import 'package:flutter/material.dart';

import '../theme/termul_theme.dart';
import 'tui_text.dart';

class TuiInput extends StatefulWidget {
  const TuiInput({
    super.key,
    this.controller,
    this.prompt = '❯',
    this.hint = '',
    this.onSubmitted,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String prompt;
  final String hint;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  State<TuiInput> createState() => _TuiInputState();
}

class _TuiInputState extends State<TuiInput> {
  late final TextEditingController _controller;
  late final FocusNode _focus;
  bool _owned = false;

  @override
  void initState() {
    super.initState();
    _owned = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _focus = FocusNode()..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    if (_owned) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    final focused = _focus.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: p.sidebar,
        border: Border.all(color: focused ? p.accent : p.border),
      ),
      child: Row(
        children: [
          TuiText(widget.prompt, tone: TuiTextTone.accent, bold: true),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              autofocus: widget.autofocus,
              cursorColor: p.accent,
              cursorWidth: 8,
              cursorHeight: 14,
              style: TextStyle(
                color: p.text,
                fontSize: 13,
                fontFamily: 'JetBrains Mono',
                height: 1.3,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: widget.hint,
                hintStyle: TextStyle(color: p.dim, fontSize: 13),
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: widget.onSubmitted,
            ),
          ),
        ],
      ),
    );
  }
}
