import 'package:flutter/material.dart';

import '../theme/termul_theme.dart';

/// Expandable section — mono chevron, accent title, optional meta.
///
/// Prefer this over Material [ExpansionTile] for Termul chrome. The host owns
/// expand state when embedding many sections (pass [expanded] + [onChanged]).
class TuiAccordion extends StatelessWidget {
  const TuiAccordion({
    super.key,
    required this.title,
    required this.child,
    this.meta,
    this.expanded,
    this.onChanged,
    this.initiallyExpanded = false,
    this.dense = false,
  });

  final String title;
  final Widget child;

  /// Trailing meta on the header (`12`, `3 tables`, …).
  final String? meta;

  /// Controlled expand state. When null, the widget keeps its own state
  /// (seeded by [initiallyExpanded]).
  final bool? expanded;
  final ValueChanged<bool>? onChanged;

  /// Used only when [expanded] is null (uncontrolled).
  final bool initiallyExpanded;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    if (expanded != null) {
      return _AccordionBody(
        title: title,
        meta: meta,
        expanded: expanded!,
        dense: dense,
        onToggle: () => onChanged?.call(!expanded!),
        child: child,
      );
    }
    return _TuiAccordionStateful(
      title: title,
      meta: meta,
      initiallyExpanded: initiallyExpanded,
      dense: dense,
      onChanged: onChanged,
      child: child,
    );
  }
}

class _TuiAccordionStateful extends StatefulWidget {
  const _TuiAccordionStateful({
    required this.title,
    required this.meta,
    required this.initiallyExpanded,
    required this.dense,
    required this.onChanged,
    required this.child,
  });

  final String title;
  final String? meta;
  final bool initiallyExpanded;
  final bool dense;
  final ValueChanged<bool>? onChanged;
  final Widget child;

  @override
  State<_TuiAccordionStateful> createState() => _TuiAccordionStatefulState();
}

class _TuiAccordionStatefulState extends State<_TuiAccordionStateful> {
  late bool _open = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return _AccordionBody(
      title: widget.title,
      meta: widget.meta,
      expanded: _open,
      dense: widget.dense,
      onToggle: () {
        setState(() => _open = !_open);
        widget.onChanged?.call(_open);
      },
      child: widget.child,
    );
  }
}

class _AccordionBody extends StatelessWidget {
  const _AccordionBody({
    required this.title,
    required this.meta,
    required this.expanded,
    required this.dense,
    required this.onToggle,
    required this.child,
  });

  final String title;
  final String? meta;
  final bool expanded;
  final bool dense;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    final vPad = dense ? 8.0 : 12.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              hoverColor: p.selection,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: vPad),
                child: Row(
                  children: [
                    Text(
                      expanded ? '▾' : '▸',
                      style: TextStyle(
                        fontFamily: TermulFonts.mono,
                        fontSize: 12,
                        color: p.accent,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: TermulFonts.mono,
                          fontSize: dense ? 11 : 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4,
                          color: p.accent,
                        ),
                      ),
                    ),
                    if (meta != null && meta!.isNotEmpty)
                      Text(
                        meta!,
                        style: TextStyle(
                          fontFamily: TermulFonts.mono,
                          fontSize: 11,
                          color: p.dim,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: EdgeInsets.fromLTRB(12, 0, 12, dense ? 8 : 12),
              child: child,
            ),
        ],
      ),
    );
  }
}
