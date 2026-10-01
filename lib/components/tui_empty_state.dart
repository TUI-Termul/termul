import 'package:flutter/material.dart';

import '../theme/termul_theme.dart';
import 'tui_text.dart';

/// How [TuiEmptyState] lays out on the page.
enum TuiEmptyLayout {
  /// Centered compact block for list pages (logs, transfers, …).
  centered,

  /// Full-bleed hero for Home — large accent title + optional callout.
  page,
}

/// Empty list / empty home chrome — mono glyph, title, body, optional CTA.
///
/// Prefer a single-character [glyph] (`⌀`, `·`, `—`) over Material icons.
class TuiEmptyState extends StatelessWidget {
  const TuiEmptyState({
    super.key,
    required this.title,
    this.glyph,
    this.body,
    this.action,
    this.calloutLabel,
    this.calloutBody,
    this.layout = TuiEmptyLayout.centered,
    this.padding,
  });

  /// Primary heading. May include `\n` for a stacked hero title.
  final String title;

  /// Optional mono mark above the title (`⌀`, `·`, `—`, …).
  final String? glyph;

  /// Supporting copy under the title.
  final String? body;

  /// Typically a [TuiButton] — Add, Connect, Retry, …
  final Widget? action;

  /// Uppercase label inside the accent callout panel ([TuiEmptyLayout.page]).
  final String? calloutLabel;

  /// Body inside the accent callout panel.
  final String? calloutBody;

  final TuiEmptyLayout layout;

  /// Outer padding. Defaults depend on [layout].
  final EdgeInsetsGeometry? padding;

  bool get _hasCallout =>
      (calloutLabel != null && calloutLabel!.isNotEmpty) ||
      (calloutBody != null && calloutBody!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return switch (layout) {
      TuiEmptyLayout.centered => _CenteredEmpty(
          glyph: glyph,
          title: title,
          body: body,
          action: action,
          padding: padding,
        ),
      TuiEmptyLayout.page => _PageEmpty(
          glyph: glyph,
          title: title,
          body: body,
          action: action,
          calloutLabel: calloutLabel,
          calloutBody: calloutBody,
          hasCallout: _hasCallout,
          padding: padding,
        ),
    };
  }
}

class _CenteredEmpty extends StatelessWidget {
  const _CenteredEmpty({
    required this.glyph,
    required this.title,
    required this.body,
    required this.action,
    required this.padding,
  });

  final String? glyph;
  final String title;
  final String? body;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (glyph != null && glyph!.isNotEmpty) ...[
                Text(
                  glyph!,
                  style: TextStyle(
                    fontFamily: TermulFonts.mono,
                    fontSize: 36,
                    color: p.dim,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium!.copyWith(color: p.text),
              ),
              if (body != null && body!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  body!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: p.muted,
                    height: 1.45,
                  ),
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: 24),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PageEmpty extends StatelessWidget {
  const _PageEmpty({
    required this.glyph,
    required this.title,
    required this.body,
    required this.action,
    required this.calloutLabel,
    required this.calloutBody,
    required this.hasCallout,
    required this.padding,
  });

  final String? glyph;
  final String title;
  final String? body;
  final Widget? action;
  final String? calloutLabel;
  final String? calloutBody;
  final bool hasCallout;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    final theme = Theme.of(context);
    final onAccent = p.isLight ? p.panel : p.bg;

    // With an action, fill the parent (Home's Expanded) and pin the CTA at
    // the bottom. Without one, shrink — safe inside a scroll view.
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        mainAxisSize:
            action != null ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (glyph != null && glyph!.isNotEmpty) ...[
            TuiText(glyph!, tone: TuiTextTone.dim, size: 28),
            const SizedBox(height: 12),
          ],
          Text(
            title,
            style: theme.textTheme.displayMedium!.copyWith(color: p.accent),
          ),
          if (body != null && body!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              body!,
              style: theme.textTheme.titleMedium!.copyWith(
                color: p.text,
                height: 1.5,
              ),
            ),
          ],
          if (hasCallout) ...[
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              color: p.accent,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (calloutLabel != null && calloutLabel!.isNotEmpty) ...[
                    Text(
                      calloutLabel!.toUpperCase(),
                      style: theme.textTheme.labelSmall!.copyWith(
                        color: onAccent,
                        letterSpacing: 0.4,
                      ),
                    ),
                    if (calloutBody != null && calloutBody!.isNotEmpty)
                      const SizedBox(height: 12),
                  ],
                  if (calloutBody != null && calloutBody!.isNotEmpty)
                    Text(
                      calloutBody!,
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: onAccent,
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (action != null) ...[
            const Spacer(),
            Align(
              alignment: Alignment.centerLeft,
              child: action!,
            ),
          ],
        ],
      ),
    );
  }
}
