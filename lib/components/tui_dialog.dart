import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/termul_theme.dart';
import 'tui_button.dart';
import 'tui_field.dart';
import 'tui_sheet.dart';

/// Centered confirm dialog — panel + mono labels.
///
/// Returns `true` on confirm, `false` on cancel / dismiss.
Future<bool> showTuiConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? detail,
  String confirmLabel = 'confirm',
  String cancelLabel = 'cancel',
  TuiButtonVariant confirmVariant = TuiButtonVariant.danger,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor:
        TermulThemeData.of(context).palette.text.withValues(alpha: 0.35),
    builder: (ctx) => TuiDialog(
      title: title,
      message: message,
      detail: detail,
      actions: [
        TuiButton(
          label: cancelLabel,
          variant: TuiButtonVariant.ghost,
          onPressed: () => Navigator.pop(ctx, false),
        ),
        TuiButton(
          label: confirmLabel,
          variant: confirmVariant,
          onPressed: () => Navigator.pop(ctx, true),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Single-field prompt (password, rename, go-to, …).
///
/// Returns the submitted text, or `null` if cancelled / dismissed.
/// Empty strings are rejected unless [allowEmpty] is true.
Future<String?> showTuiPromptDialog(
  BuildContext context, {
  required String title,
  String? message,
  String? detail,
  required String fieldLabel,
  String? hint,
  String? helper,
  String? initialValue,
  bool obscure = false,
  bool allowEmpty = false,
  String confirmLabel = 'continue',
  String cancelLabel = 'cancel',
  TuiButtonVariant confirmVariant = TuiButtonVariant.primary,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
}) {
  return showDialog<String>(
    context: context,
    barrierColor:
        TermulThemeData.of(context).palette.text.withValues(alpha: 0.35),
    builder: (ctx) => _TuiPromptDialog(
      title: title,
      message: message,
      detail: detail,
      fieldLabel: fieldLabel,
      hint: hint,
      helper: helper,
      initialValue: initialValue,
      obscure: obscure,
      allowEmpty: allowEmpty,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      confirmVariant: confirmVariant,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
    ),
  );
}

/// Pick one option from a list inside a dialog.
///
/// Returns the selected value, or `null` if dismissed. For longer lists on
/// phone, prefer [showTuiChoiceSheet].
Future<T?> showTuiChoiceDialog<T>(
  BuildContext context, {
  required String title,
  String? message,
  String? detail,
  required List<({T value, String label, String? meta})> options,
  T? selected,
  double maxWidth = 360,
}) {
  return showDialog<T>(
    context: context,
    barrierColor:
        TermulThemeData.of(context).palette.text.withValues(alpha: 0.35),
    builder: (ctx) {
      final maxListH = MediaQuery.sizeOf(ctx).height * 0.45;
      return TuiDialog(
        title: title,
        message: message,
        detail: detail,
        maxWidth: maxWidth,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxListH),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: options.length,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              color: TermulThemeData.of(ctx).palette.border,
            ),
            itemBuilder: (context, i) {
              final opt = options[i];
              return TuiSheetOption(
                label: opt.label,
                meta: opt.meta,
                selected: selected == opt.value,
                onTap: () => Navigator.pop(ctx, opt.value),
              );
            },
          ),
        ),
      );
    },
  );
}

class TuiDialog extends StatelessWidget {
  const TuiDialog({
    super.key,
    required this.title,
    this.message,
    this.detail,
    this.child,
    this.actions = const [],
    this.maxWidth = 360,
  });

  final String title;
  final String? message;
  final String? detail;
  final Widget? child;
  final List<Widget> actions;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return Dialog(
      backgroundColor: p.panel,
      shape: const RoundedRectangleBorder(),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                container: true,
                header: true,
                label: title,
                excludeSemantics: true,
                child: Text(
                  title.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: p.accent,
                        letterSpacing: 0.4,
                      ),
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 12),
                Text(
                  message!,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: p.text,
                        fontSize: 22,
                      ),
                ),
              ],
              if (detail != null) ...[
                const SizedBox(height: 8),
                Text(
                  detail!,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: p.muted,
                        height: 1.45,
                      ),
                ),
              ],
              if (child != null) ...[
                const SizedBox(height: 12),
                child!,
              ],
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    actions.first,
                    if (actions.length > 1) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 8,
                          runSpacing: 8,
                          children: [...actions.skip(1)],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TuiPromptDialog extends StatefulWidget {
  const _TuiPromptDialog({
    required this.title,
    required this.message,
    required this.detail,
    required this.fieldLabel,
    required this.hint,
    required this.helper,
    required this.initialValue,
    required this.obscure,
    required this.allowEmpty,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.confirmVariant,
    required this.keyboardType,
    required this.inputFormatters,
  });

  final String title;
  final String? message;
  final String? detail;
  final String fieldLabel;
  final String? hint;
  final String? helper;
  final String? initialValue;
  final bool obscure;
  final bool allowEmpty;
  final String confirmLabel;
  final String cancelLabel;
  final TuiButtonVariant confirmVariant;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<_TuiPromptDialog> createState() => _TuiPromptDialogState();
}

class _TuiPromptDialogState extends State<_TuiPromptDialog> {
  late final TextEditingController _controller;
  late bool _canSubmit;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _canSubmit = widget.allowEmpty || _controller.text.isNotEmpty;
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    final ok = widget.allowEmpty || _controller.text.isNotEmpty;
    if (ok != _canSubmit) setState(() => _canSubmit = ok);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_canSubmit) return;
    Navigator.pop(context, _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return TuiDialog(
      title: widget.title,
      message: widget.message,
      detail: widget.detail,
      actions: [
        TuiButton(
          label: widget.cancelLabel,
          variant: TuiButtonVariant.ghost,
          onPressed: () => Navigator.pop(context),
        ),
        TuiButton(
          label: widget.confirmLabel,
          variant: widget.confirmVariant,
          onPressed: _canSubmit ? _submit : null,
        ),
      ],
      child: TuiField(
        label: widget.fieldLabel,
        controller: _controller,
        hint: widget.hint,
        helper: widget.helper,
        obscure: widget.obscure,
        autofocus: true,
        autocorrect: !widget.obscure,
        enableSuggestions: !widget.obscure,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
      ),
    );
  }
}
