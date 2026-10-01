import 'package:flutter/material.dart';

import '../theme/termul_theme.dart';

/// Home / host list card — accent title, endpoint, status line, action chips.
///
/// Presentation only: the host app owns connect / menu / delete behaviour.
/// [verb] and [trailing] sit on the status row (aligned with `LAST · …`).
class TuiHostCard extends StatelessWidget {
  const TuiHostCard({
    super.key,
    required this.title,
    required this.endpoint,
    this.status,
    this.verb = 'connect',
    this.badge,
    this.trailing,
    this.live = false,
    this.enabled = true,
    this.onTap,
    this.showDivider = true,
  });

  final String title;

  /// Address / summary line under the title (not forced uppercase).
  final String endpoint;

  /// Meta line (`password · tmux`, `last · 21:18`, …). Uppercased in paint.
  final String? status;

  /// Accent verb chip on the status row (`connect`, `open`).
  final String verb;

  /// Optional leading brand / OS badge.
  final Widget? badge;

  /// Optional trailing chrome (remove chip, overflow menu, …).
  final Widget? trailing;

  /// When true, [status] uses accent ink.
  final bool live;
  final bool enabled;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    final theme = Theme.of(context);
    final small = theme.textTheme.labelSmall!;
    final canTap = enabled && onTap != null;

    final body = Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (badge != null) ...[
            badge!,
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineMedium!.copyWith(
                    color: canTap ? p.accent : p.dim,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  endpoint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: small.copyWith(color: p.dim, letterSpacing: 0.4),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: status != null && status!.isNotEmpty
                          ? Text(
                              status!.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: small.copyWith(
                                color: live && canTap ? p.accent : p.muted,
                                letterSpacing: 0.3,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    if (trailing != null) ...[
                      trailing!,
                      const SizedBox(width: 6),
                    ],
                    TuiHostCardAction(
                      label: verb,
                      emphasized: true,
                      enabled: canTap,
                      onTap: onTap,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: p.border))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canTap ? onTap : null,
          hoverColor: p.selection,
          child: body,
        ),
      ),
    );
  }
}

/// Square bordered action chip — matches terminal header / home toolbar chrome.
class TuiHostCardAction extends StatelessWidget {
  const TuiHostCardAction({
    super.key,
    required this.label,
    this.onTap,
    this.enabled = true,
    this.emphasized = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    final active = enabled && onTap != null;
    final ink = emphasized
        ? (active ? p.accent : p.dim)
        : (active ? p.dim : p.muted);

    return Semantics(
      button: true,
      enabled: active,
      label: label,
      child: GestureDetector(
        onTap: active ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: emphasized && active ? p.accent : p.border),
          ),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: TermulFonts.mono,
              fontSize: 10,
              letterSpacing: 0.4,
              fontWeight: FontWeight.w500,
              color: ink,
            ),
          ),
        ),
      ),
    );
  }
}
