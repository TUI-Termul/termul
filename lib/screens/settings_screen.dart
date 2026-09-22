import 'package:flutter/material.dart';

import '../components/components.dart';
import '../state/termul_controller.dart';
import '../theme/termul_palette.dart';
import '../theme/termul_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final TermulController controller;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: controller.closeSettings,
                    child: Text(
                      '← BACK',
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            color: p.dim,
                            letterSpacing: 0.4,
                          ),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.settings_outlined, size: 18, color: p.accent),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                children: [
                  Text(
                    'Settings',
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium!
                        .copyWith(color: p.accent, fontSize: 36),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'APP · TERMINAL · ALERTS',
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: p.dim,
                          letterSpacing: 0.4,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(height: 1, color: p.border),
                  const SizedBox(height: 28),
                  _SectionLabel(title: 'system theme'),
                  const SizedBox(height: 12),
                  _ChoiceRow(
                    options: const [
                      (ThemeMode.light, 'LIGHT'),
                      (ThemeMode.dark, 'DARK'),
                      (ThemeMode.system, 'SYSTEM'),
                    ],
                    selected: controller.appThemeMode,
                    onSelect: controller.setAppThemeMode,
                  ),
                  const SizedBox(height: 28),
                  Container(height: 1, color: p.border),
                  const SizedBox(height: 28),
                  _SectionLabel(title: 'terminal theme'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final name in TermulPalette.terminalThemes.keys)
                        TuiButton(
                          label: name,
                          variant: controller.terminalThemeName == name
                              ? TuiButtonVariant.primary
                              : TuiButtonVariant.ghost,
                          onPressed: () => controller.setTerminalTheme(name),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _TerminalPreview(controller: controller),
                  const SizedBox(height: 28),
                  Container(height: 1, color: p.border),
                  const SizedBox(height: 28),
                  _SectionLabel(title: 'terminal font size'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final size in TermulController.terminalFontSizes)
                        TuiButton(
                          label: '${size.toInt()}px',
                          variant: controller.terminalFontSize == size
                              ? TuiButtonVariant.primary
                              : TuiButtonVariant.ghost,
                          onPressed: () =>
                              controller.setTerminalFontSize(size),
                        ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _SectionLabel(title: 'terminal font'),
                  const SizedBox(height: 12),
                  for (final entry in TerminalFonts.options.entries) ...[
                    _FontOption(
                      family: entry.key,
                      label: entry.value,
                      selected: controller.terminalFontFamily == entry.key,
                      onTap: () =>
                          controller.setTerminalFontFamily(entry.key),
                    ),
                    Container(height: 1, color: p.border),
                  ],
                  const SizedBox(height: 28),
                  _SectionLabel(title: 'notifications'),
                  const SizedBox(height: 12),
                  _ToggleRow(
                    label: 'Agent alerts',
                    hint: 'Blocked / done / needs input',
                    value: controller.notificationsEnabled,
                    onChanged: controller.setNotificationsEnabled,
                  ),
                  const SizedBox(height: 28),
                  Container(height: 1, color: p.border),
                  const SizedBox(height: 28),
                  _SectionLabel(title: 'support'),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TuiButton(
                      label: 'report a bug',
                      prefix: '!',
                      onPressed: () => _openBugReport(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Preview build · feedback goes to local inbox (no network yet).',
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: p.dim,
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openBugReport(BuildContext context) async {
    final p = TermulThemeData.of(context).palette;
    final note = TextEditingController();
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: p.panel,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Report a bug',
                style: Theme.of(ctx).textTheme.headlineMedium!.copyWith(
                      color: p.accent,
                      fontSize: 22,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'What broke? Steps to reproduce help most.',
                style: Theme.of(ctx).textTheme.bodySmall!.copyWith(
                      color: p.muted,
                    ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: p.border),
                  color: p.bg,
                ),
                child: TextField(
                  controller: note,
                  maxLines: 5,
                  autofocus: true,
                  cursorColor: p.accent,
                  style: TextStyle(
                    fontFamily: TermulFonts.mono,
                    fontSize: 13,
                    color: p.text,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Describe the bug…',
                    hintStyle: TextStyle(
                      fontFamily: TermulFonts.mono,
                      color: p.dim,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  TuiButton(
                    label: 'cancel',
                    variant: TuiButtonVariant.ghost,
                    onPressed: () => Navigator.pop(ctx, false),
                  ),
                  const Spacer(),
                  TuiButton(
                    label: 'submit',
                    prefix: '▸',
                    onPressed: () {
                      if (note.text.trim().isEmpty) return;
                      Navigator.pop(ctx, true);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (sent == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: p.accent,
          content: Text(
            'Thanks — bug report queued.',
            style: TextStyle(
              fontFamily: TermulFonts.mono,
              color: p.bg,
              fontSize: 12,
            ),
          ),
        ),
      );
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall!.copyWith(
            color: p.accent,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
          ),
    );
  }
}

class _ChoiceRow<T> extends StatelessWidget {
  const _ChoiceRow({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final List<(T, String)> options;
  final T selected;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (value, label) in options)
          TuiButton(
            label: label,
            variant: selected == value
                ? TuiButtonVariant.primary
                : TuiButtonVariant.ghost,
            onPressed: () => onSelect(value),
          ),
      ],
    );
  }
}

class _FontOption extends StatelessWidget {
  const _FontOption({
    required this.family,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String family;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: family,
                  fontSize: 16,
                  color: selected ? p.accent : p.text,
                  fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            Text(
              selected ? 'SELECTED' : 'USE',
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: selected ? p.accent : p.dim,
                    letterSpacing: 0.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: p.accent,
                      fontSize: 18,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                hint.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: p.dim,
                      letterSpacing: 0.3,
                    ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Container(
            width: 52,
            height: 28,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: value ? p.accent : p.panel,
              border: Border.all(color: value ? p.accent : p.border),
            ),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 20,
              height: 20,
              color: value ? p.panel : p.dim,
            ),
          ),
        ),
      ],
    );
  }
}

class _TerminalPreview extends StatelessWidget {
  const _TerminalPreview({required this.controller});

  final TermulController controller;

  @override
  Widget build(BuildContext context) {
    final tp = controller.terminalPalette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      color: tp.panel,
      child: Text(
        '❯ preview · Aa Bb Cc 123\n● agent working on this theme',
        style: TextStyle(
          fontFamily: controller.terminalFontFamily,
          fontSize: controller.terminalFontSize,
          color: tp.text,
          height: 1.45,
        ),
      ),
    );
  }
}
