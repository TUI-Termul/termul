import 'package:flutter/material.dart';

import '../theme/termul_theme.dart';

/// One crumb in [TuiBreadcrumbs].
class TuiCrumb {
  const TuiCrumb({required this.id, required this.label});

  final String id;
  final String label;
}

/// Path trail for file browser / editor chrome — mono segments, tappable.
///
/// Pass absolute-style segments (`home`, `deploy`, `app`). The last crumb is
/// the current location and is not tappable unless [onCurrentTap] is set.
class TuiBreadcrumbs extends StatelessWidget {
  const TuiBreadcrumbs({
    super.key,
    required this.crumbs,
    this.onTap,
    this.onCurrentTap,
    this.separator = '/',
    this.overflow = TextOverflow.ellipsis,
    this.dense = false,
  });

  final List<TuiCrumb> crumbs;
  final ValueChanged<TuiCrumb>? onTap;
  final VoidCallback? onCurrentTap;
  final String separator;
  final TextOverflow overflow;
  final bool dense;

  /// Split a POSIX-ish path into crumbs. Leading `/` becomes a root crumb
  /// labelled [rootLabel].
  static List<TuiCrumb> fromPath(
    String path, {
    String rootLabel = '/',
    String rootId = '/',
  }) {
    final absolute = path.startsWith('/');
    var normalized = path;
    if (normalized.length > 1 && normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    if (normalized.isEmpty || normalized == '/') {
      return [TuiCrumb(id: rootId, label: rootLabel)];
    }
    final parts = normalized.split('/').where((p) => p.isNotEmpty).toList();
    final crumbs = <TuiCrumb>[
      if (absolute) TuiCrumb(id: rootId, label: rootLabel),
    ];
    final buf = StringBuffer();
    for (final part in parts) {
      if (absolute) {
        buf.write('/');
        buf.write(part);
      } else {
        if (buf.isNotEmpty) buf.write('/');
        buf.write(part);
      }
      crumbs.add(TuiCrumb(id: buf.toString(), label: part));
    }
    return crumbs;
  }

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    final size = dense ? 11.0 : 12.0;
    if (crumbs.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < crumbs.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  separator,
                  style: TextStyle(
                    fontFamily: TermulFonts.mono,
                    fontSize: size,
                    color: p.dim,
                  ),
                ),
              ),
            _CrumbChip(
              crumb: crumbs[i],
              isLast: i == crumbs.length - 1,
              fontSize: size,
              onTap: i == crumbs.length - 1
                  ? onCurrentTap
                  : (onTap == null ? null : () => onTap!(crumbs[i])),
            ),
          ],
        ],
      ),
    );
  }
}

class _CrumbChip extends StatefulWidget {
  const _CrumbChip({
    required this.crumb,
    required this.isLast,
    required this.fontSize,
    required this.onTap,
  });

  final TuiCrumb crumb;
  final bool isLast;
  final double fontSize;
  final VoidCallback? onTap;

  @override
  State<_CrumbChip> createState() => _CrumbChipState();
}

class _CrumbChipState extends State<_CrumbChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    final canTap = widget.onTap != null;
    final Color color;
    if (widget.isLast) {
      color = p.accent;
    } else if (_hover && canTap) {
      color = p.accent;
    } else {
      color = p.muted;
    }

    final text = Text(
      widget.crumb.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: TermulFonts.mono,
        fontSize: widget.fontSize,
        fontWeight: widget.isLast ? FontWeight.w500 : FontWeight.w400,
        color: color,
        height: 1.2,
      ),
    );

    if (!canTap) return text;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: text,
      ),
    );
  }
}
