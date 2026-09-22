import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/termul_theme.dart';

/// Form field styled for OCI / Termul — paper surface, hairline border, mono label.
class TuiField extends StatelessWidget {
  const TuiField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.autofocus = false,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: p.accent,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: p.panel,
            border: Border.all(color: p.border),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            autofocus: autofocus,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            inputFormatters: inputFormatters,
            cursorColor: p.accent,
            style: TextStyle(
              fontFamily: TermulFonts.mono,
              fontSize: 14,
              color: p.text,
              height: 1.4,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(
                fontFamily: TermulFonts.mono,
                fontSize: 14,
                color: p.dim,
              ),
            ),
            onSubmitted: onSubmitted,
          ),
        ),
      ],
    );
  }
}
